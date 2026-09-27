# Restore location services

Smart PACE **1.0.0 build 32** does not use device location. Play Console was flagging fine, coarse, and background location, so those permissions, the `geolocator` plugin, and the attendance GPS calls were removed.

Job “location” text, ticket site names, and profile address fields are ordinary text. They do not use GPS. Leave them as they are.

The last commit that still has the full GPS implementation, including the camera request that used to run beside it, is:

`ce36fce65486154d38503adb6a79fed26c8c685a`

Build 32’s location code is the version below. It does not request the camera. Face capture was already removed. See `docs/restore-nfc-and-face-attendance.md` if you are bringing face attendance back at the same time. That guide checks out `attendance_bloc.dart`, `attendance_permissions_helper.dart`, and `home_page.dart` from `ce36fce`, which also restores GPS calls. Those files will not compile until `geolocator` and the native location keys in this document are back.

## 1. Package

In `pubspec.yaml`:

```yaml
geolocator: ^14.0.2
```

Then:

```bash
flutter pub get
cd ios && pod install
```

`geolocator_android` merges a foreground service, `GeolocatorLocationService`, with `foregroundServiceType="location"`. That service is part of why Play Console treats the app as using location. It returns when the plugin is installed.

## 2. Android

In `android/app/src/main/AndroidManifest.xml`, remove the four `tools:node="remove"` location lines and the `xmlns:tools` namespace if nothing else uses it. Declare the permissions again:

```xml
<uses-permission android:name="android.permission.ACCESS_COARSE_LOCATION"/>
<uses-permission android:name="android.permission.ACCESS_FINE_LOCATION"/>
<uses-permission android:name="android.permission.ACCESS_BACKGROUND_LOCATION"/>
```

`ACCESS_BACKGROUND_LOCATION` is the permission Play reviews most strictly. Only put it back if attendance still needs the GPS stream while the app is open in the background. Google expects a prominent in-app disclosure and a Play Console declaration for background location.

After the new AAB is uploaded, update Play Console:

- App content → Sensitive app permissions / location declaration, so it matches the binary
- Data safety, so location collection matches what the build actually does

A binary without these permissions can still be rejected if the Console form says the app uses background location.

## 3. iOS

In `ios/Runner/Info.plist`, add:

```xml
<key>NSLocationWhenInUseUsageDescription</key>
<string>Location access is required to verify that attendance is marked within school premises.</string>
<key>NSLocationAlwaysAndWhenInUseUsageDescription</key>
<string>Smart PACE uses your location while you use the app and, if you allow always access, to confirm attendance geofence status on school premises.</string>
<key>NSLocationAlwaysUsageDescription</key>
<string>Background location access helps keep attendance geofence status ready on school premises.</string>
```

`UIBackgroundModes` does not include `location`. The old build did not add it. Do not add it unless you intentionally start a background location session.

In `ios/Podfile` `post_install`, compile the location API for `permission_handler`. Without this macro, iOS permission requests do nothing.

```ruby
target.build_configurations.each do |config|
  defs = config.build_settings['GCC_PREPROCESSOR_DEFINITIONS']
  if defs.nil?
    config.build_settings['GCC_PREPROCESSOR_DEFINITIONS'] = ['$(inherited)', 'PERMISSION_LOCATION=1']
  elsif defs.is_a?(Array)
    defs << 'PERMISSION_LOCATION=1' unless defs.any? { |d| d.to_s.include?('PERMISSION_LOCATION') }
  end
  if Gem::Version.new($iOSVersion) > Gem::Version.new(config.build_settings['IPHONEOS_DEPLOYMENT_TARGET'] || '0')
    config.build_settings['IPHONEOS_DEPLOYMENT_TARGET'] = $iOSVersion
  end
end
```

If face attendance is restored in the same pass, also add `PERMISSION_CAMERA=1` as described in `docs/restore-nfc-and-face-attendance.md`.

## 4. Dart

### `lib/features/attendance/utils/attendance_permissions_helper.dart`

Restore imports:

```dart
import 'dart:async';

import 'package:admin_app/features/attendance/utils/attendance_logger.dart';
import 'package:geolocator/geolocator.dart';
import 'package:hive/hive.dart';
import 'package:permission_handler/permission_handler.dart';
```

Replace the two stub functions with:

```dart
Future<bool> areMarkAttendancePermissionsGranted() async {
  final geo = await Geolocator.checkPermission();
  return geo == LocationPermission.whileInUse ||
      geo == LocationPermission.always;
}

Future<AttendancePermissionOutcome> requestMarkAttendancePermissions() async {
  const needLocation =
      'Location permission is required to verify you are on campus.';

  var geo = await Geolocator.checkPermission();
  AttendanceLogger.log('permissions helper: Geolocator.checkPermission → $geo');
  if (geo == LocationPermission.denied) {
    geo = await Geolocator.requestPermission();
    AttendanceLogger.log(
      'permissions helper: Geolocator.requestPermission → $geo',
    );
  }

  if (geo == LocationPermission.deniedForever) {
    AttendanceLogger.log(
      'permissions helper: location deniedForever → Settings path',
    );
    return const AttendancePermissionOutcome(
      granted: false,
      permanentlyDenied: true,
      message:
          'Location access is permanently denied. Enable it in Settings to mark attendance.',
    );
  }

  var locationOk =
      geo == LocationPermission.whileInUse || geo == LocationPermission.always;

  if (!locationOk) {
    final ph = await Permission.locationWhenInUse.request();
    AttendanceLogger.log(
      'permissions helper: Permission.locationWhenInUse.request → $ph',
    );
    if (ph.isPermanentlyDenied) {
      return const AttendancePermissionOutcome(
        granted: false,
        permanentlyDenied: true,
        message:
            'Location access is blocked. Enable it in Settings to mark attendance.',
      );
    }
    if (ph.isGranted || ph.isLimited) {
      geo = await Geolocator.checkPermission();
      locationOk = geo == LocationPermission.whileInUse ||
          geo == LocationPermission.always;
    }
  }

  if (locationOk) {
    AttendanceLogger.log(
      'permissions helper: location OK → scheduling locationAlways (non-blocking)',
    );
    unawaited(
      Future(() async {
        try {
          await Permission.locationAlways.request();
        } catch (_) {}
      }),
    );
    return const AttendancePermissionOutcome(granted: true);
  }

  return const AttendancePermissionOutcome(
    granted: false,
    permanentlyDenied: false,
    message: needLocation,
  );
}
```

`Permission.locationAlways.request()` is the background-location prompt. Remove that block if you restore while-in-use location only and want to stay off Play’s background-location review.

### `lib/features/attendance/data/repositories/attendance_repository_impl.dart`

Add:

```dart
import 'dart:async';
import 'package:geolocator/geolocator.dart';
```

Replace `checkGeofence()` with the GPS implementation:

```dart
@override
Future<Either<Failure, GeofenceCheckResult>> checkGeofence() async {
  final configResult = await getGeofenceConfig();
  return await configResult.fold(
    (failure) async => Left(failure),
    (config) async {
      try {
        final serviceEnabled = await Geolocator.isLocationServiceEnabled();
        if (!serviceEnabled) {
          return const Left(
            Failure(
              'Location service is disabled',
              kind: FailureKind.locationServiceDisabled,
            ),
          );
        }

        final position = await Geolocator.getCurrentPosition(
          locationSettings: const LocationSettings(
            accuracy: LocationAccuracy.high,
            timeLimit: Duration(seconds: 15),
          ),
        ).timeout(
          const Duration(seconds: 22),
          onTimeout: () => throw TimeoutException(
            'GPS fix exceeded 22s',
            const Duration(seconds: 22),
          ),
        );
        final distanceMeters = Geolocator.distanceBetween(
          config.centerLatitude,
          config.centerLongitude,
          position.latitude,
          position.longitude,
        );
        final inside = distanceMeters <= config.radiusMeters;
        return Right(
          GeofenceCheckResult(
            config: config,
            distanceMeters: distanceMeters,
            isInside: inside,
            latitude: position.latitude,
            longitude: position.longitude,
          ),
        );
      } on TimeoutException {
        return const Left(
          Failure(
            'Getting your location timed out. Try again.',
            kind: FailureKind.locationTimeout,
          ),
        );
      } catch (e, st) {
        return const Left(
          Failure(
            'Failed to get your current location',
            kind: FailureKind.locationUnavailable,
          ),
        );
      }
    },
  );
}
```

`submitAttendance()` already calls `checkGeofence()`. Restoring this method restores that gate.

### `lib/features/attendance/presentation/bloc/attendance_bloc.dart`

Add `import 'dart:async';` and `import 'package:geolocator/geolocator.dart';`.

Put the stream fields back on the bloc:

```dart
StreamSubscription<Position>? _positionStream;
DateTime? _lastStreamGeofenceAt;
static const Duration _streamGeofenceThrottle = Duration(seconds: 45);
```

Replace the empty `_startBackgroundLocationMonitoring` and `close` with:

```dart
void _startBackgroundLocationMonitoring() {
  _positionStream?.cancel();
  _positionStream = Geolocator.getPositionStream(
    locationSettings: const LocationSettings(
      accuracy: LocationAccuracy.medium,
      distanceFilter: 25,
    ),
  ).listen((_) {
    final now = DateTime.now();
    if (_lastStreamGeofenceAt != null &&
        now.difference(_lastStreamGeofenceAt!) < _streamGeofenceThrottle) {
      return;
    }
    _lastStreamGeofenceAt = now;
    add(const CheckLocationEvent(showLoading: false));
  });
}

@override
Future<void> close() {
  _positionStream?.cancel();
  return super.close();
}
```

`_onInitializeAttendance` already calls `_startBackgroundLocationMonitoring()` after permissions succeed. No other change is required there.

### `lib/UI/home/home_page.dart`

Restore:

```dart
import 'package:admin_app/core/widgets/app_dialogs.dart';
import 'package:admin_app/features/attendance/utils/attendance_permissions_helper.dart';
import 'package:flutter/scheduler.dart';
```

On `_HomeScreenState`:

```dart
bool _scheduledMarkAttendancePermissionIntro = false;
```

Restore the one-time prompt. This is what asks for location from the employee home screen:

```dart
Future<void> _maybeMarkAttendancePermissionIntro() async {
  if (!mounted) return;
  if (await AttendancePermissionsPrefs.isIntroCompleted()) return;
  if (await areMarkAttendancePermissionsGranted()) {
    await AttendancePermissionsPrefs.setIntroCompleted();
    return;
  }
  if (!mounted) return;

  final go = await showAppConfirmDialog(
    context: context,
    title: 'Mark Attendance',
    message:
        'Location is used to confirm you are on campus. You can enable it now, or later from Mark attendance in the menu.',
    confirmLabel: 'Continue',
    cancelLabel: 'Not now',
  );

  if (!mounted) return;
  if (go == true) {
    await requestMarkAttendancePermissions();
  }
  await AttendancePermissionsPrefs.setIntroCompleted();
}
```

Call it from the home `BlocListener` `success` branch, once, in a post-frame callback guarded by `_scheduledMarkAttendancePermissionIntro`.

On the Mark Attendance card, set the subtitle back to `Face + location`.

## 5. Check

1. `flutter pub get`
2. `cd ios && pod install`
3. `flutter analyze`
4. Build an Android App Bundle and confirm the merged manifest has no `ACCESS_*_LOCATION` until you intend to ship location. After restore, confirm fine, coarse, and background location are present only if you added them back.
5. On a device, Mark Attendance must prompt for location and accept a fix inside the school radius.

Ship a new build number. Build 32 is the careers binary without location. Play Console will look at the new AAB, not at this document.
