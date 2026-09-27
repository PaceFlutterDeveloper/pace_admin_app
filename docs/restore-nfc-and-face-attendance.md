# Restore NFC and face attendance

This release ships the Careers module only. NFC tag reading and face-attendance capture were taken out of the binary so App Review would not ask for an NFC hardware demo. Device location was removed in a later pass; see `docs/restore-location-services.md`. The careers binary is **1.0.0 build 32**.

The last commit that still has the working implementations is:

`ce36fce65486154d38503adb6a79fed26c8c685a`

Restore the files below from that commit, then put the native permissions back. Restoring one Dart file by itself will not compile, because the camera and NFC call sites changed together.

Do not hand-edit generated files. `flutter pub get` and `pod install` rewrite them.

## What still exists

These were left in place. Do not recreate them.

- Route `Routes.nfcMapping` (`/nfcMapping`) and `NfcMapyScreen` in `lib/core/routes/app_routes.dart`
- `NfcProvider` registration in `lib/app.dart`
- `NfcMappRepository` registration in `lib/dependancy_injection.dart`
- NFC mapping API in `lib/UI/employee/transport/nfc_mappy/repository/repository.dart`
- Menu icon case `'nfcMapping'` in `lib/UI/home/components/menu_component.dart`
- Attendance bloc, page, and `CaptureAndVerifyFaceUseCase` registration
- Face ID (`NSFaceIDUsageDescription` and `local_auth`). That is account unlock, not face detection.
- Photo library permission strings

Location permissions were removed after this note was first written. Restore them from `docs/restore-location-services.md` together with `geolocator`. The Dart checkout below from `ce36fce` also contains the old location calls, so the package and the native location keys have to come back with those files.

## 1. Packages

In `pubspec.yaml`, restore these dependencies:

```yaml
nfc_manager: ^4.1.1
camera: ^0.12.0+1
google_mlkit_face_detection: ^0.15.1
mobile_scanner: ^7.4.0
```

Restore this override. `camera` 0.12.0+1 otherwise resolves a CameraX version that fails on Gradle 9:

```yaml
dependency_overrides:
  camera_android_camerax: 0.7.4+6
```

Then run:

```bash
flutter pub get
cd ios && pod install
```

That puts these pods back into the iOS app:

- `nfc_manager`
- `camera_avfoundation`
- `google_mlkit_face_detection`
- `mobile_scanner`

`pod install` also refreshes `ios/Podfile.lock`, `ios/Runner.xcodeproj/project.pbxproj`, and the plugin registrant. On macOS, Flutter regenerates `macos/Flutter/GeneratedPluginRegistrant.swift`, which dropped the `mobile_scanner` import.

`ios/Podfile` still loads the ML Kit Apple Silicon simulator helper when `google_mlkit_commons` is present. No Podfile edit is required for that.

## 2. iOS permissions and the NFC entitlement

### `ios/Runner/Runner.entitlements`

Put this back above `com.apple.developer.associated-domains`:

```xml
<key>com.apple.developer.nfc.readersession.formats</key>
<array>
  <string>TAG</string>
</array>
```

In Xcode, the Runner target also needs the **Near Field Communication Tag Reading** capability. The App ID must have that capability enabled in the Apple Developer account. This key is what made App Review ask for a hardware demo, so only add it on a build that actually ships NFC.

### `ios/Runner/Info.plist`

Add:

```xml
<key>NFCReaderUsageDescription</key>
<string>This app needs NFC access to read student NFC cards for attendance and mapping.</string>
<key>NSMicrophoneUsageDescription</key>
<string>Need microphone access for uploading audio</string>
```

Replace the camera string with:

```xml
<key>NSCameraUsageDescription</key>
<string>This app uses the camera for attendance face verification and for attaching ticket photos.</string>
```

Replace the always-location string with:

```xml
<key>NSLocationAlwaysUsageDescription</key>
<string>Background location access helps keep attendance geofence status ready before face scan.</string>
```

### `ios/Podfile`

`permission_handler` only prompts for permissions that are compiled in. Restore `PERMISSION_CAMERA=1` in both branches of `post_install`:

```ruby
if defs.nil?
  config.build_settings['GCC_PREPROCESSOR_DEFINITIONS'] = ['$(inherited)', 'PERMISSION_CAMERA=1', 'PERMISSION_LOCATION=1']
elsif defs.is_a?(Array)
  defs << 'PERMISSION_CAMERA=1' unless defs.any? { |d| d.to_s.include?('PERMISSION_CAMERA') }
  defs << 'PERMISSION_LOCATION=1' unless defs.any? { |d| d.to_s.include?('PERMISSION_LOCATION') }
end
```

## 3. Android permissions

In `android/app/src/main/AndroidManifest.xml`, put these back at the top of `<manifest>`:

```xml
<uses-permission android:name="android.permission.NFC"/>
<uses-feature android:name="android.hardware.nfc" android:required="false"/>
<uses-permission android:name="android.permission.CAMERA"/>
```

`android:required="false"` keeps the app installable on phones without NFC. `android/build.gradle` still applies Kotlin to `file_picker` because `nfc_manager` used to apply the Kotlin plugin. Leave that block as it is.

## 4. Dart files to restore from git

Run this from the repo root. It overwrites the careers-build stubs with the implementations from `ce36fce`.

```bash
git checkout ce36fce65486154d38503adb6a79fed26c8c685a -- \
  lib/UI/employee/transport/nfc_mappy/provider/nfc_provider.dart \
  lib/UI/employee/transport/nfc_mappy/nfc_available.dart \
  lib/UI/employee/transport/nfc_mappy/widgets/barcode_scanner_page.dart \
  lib/features/attendance/domain/usecases/capture_and_verify_face_usecase.dart \
  lib/features/attendance/presentation/widgets/face_capture_widget.dart \
  lib/features/attendance/presentation/bloc/attendance_event.dart \
  lib/features/attendance/presentation/bloc/attendance_bloc.dart \
  lib/features/attendance/presentation/pages/attendance_page.dart \
  lib/features/attendance/utils/attendance_permissions_helper.dart \
  lib/UI/home/home_page.dart \
  lib/UI/home/data/dummy_home_menu.dart \
  lib/core/widgets/app_glass_nav_bar.dart
```

If that commit is no longer reachable, the sections below describe what each file lost.

### NFC hardware — `lib/UI/employee/transport/nfc_mappy/provider/nfc_provider.dart`

The careers build reports NFC as unavailable and never starts a session. The HTTP mapping method `upinsert` is still there.

The restored provider must import:

```dart
import 'package:nfc_manager/nfc_manager.dart';
import 'package:nfc_manager/nfc_manager_android.dart';
import 'package:nfc_manager/nfc_manager_ios.dart';
```

And implement again:

- `checkNfcAvailability()` via `NfcManager.instance.checkAvailability()`
- `startNfcScan()` via `NfcManager.instance.startSession`, polling `iso14443` and `iso15693`
- `_extractTagId()` using `NfcTagAndroid` on Android and `MiFareIos` / `Iso7816Ios` / `Iso15693Ios` / `FeliCaIos` on iOS
- `_stopSession()` and `_safeStopSession()`

### Student barcode — `lib/UI/employee/transport/nfc_mappy/nfc_available.dart` and `widgets/barcode_scanner_page.dart`

`_scanStudentCode()` must request `Permission.camera`, open `BarcodeScannerPage`, and keep only the digits from the scan.

`BarcodeScannerPage` must use `mobile_scanner` (`MobileScannerController` and `MobileScanner`). The careers build replaces that page with a message that scanning is unavailable.

### Face capture

| File | Careers build | Restore |
| --- | --- | --- |
| `lib/features/attendance/presentation/widgets/face_capture_widget.dart` | Static “not available” message. No camera. | Front-camera preview, 3-second auto capture, `CameraController`, callback `(XFile file, int sensorOrientation)`. |
| `lib/features/attendance/domain/usecases/capture_and_verify_face_usecase.dart` | Always returns “Face verification is not available in this version.” | ML Kit `FaceDetector` on the captured JPEG: one face, centered, not low light, then compress to 800px. Takes an `XFile`. |
| `lib/features/attendance/presentation/bloc/attendance_event.dart` | `FaceCapturedEvent.imagePath` is a `String`. | `import 'package:camera/camera.dart';` and `final XFile image`. |
| `lib/features/attendance/presentation/bloc/attendance_bloc.dart` | Passes `event.imagePath` into the use case. | Pass `event.image` (`XFile`) and log `event.image.path`. |
| `lib/features/attendance/presentation/pages/attendance_page.dart` | Same callback shape, but the file is a `String`. | Pass the `XFile` from `FaceCaptureWidget` into `FaceCapturedEvent`. |

### Attendance permission prompt — `lib/features/attendance/utils/attendance_permissions_helper.dart`

`areMarkAttendancePermissionsGranted()` must require both location and `Permission.camera`.

`requestMarkAttendancePermissions()` must request the camera after location, and fail with:

- “Location and camera permissions are required to mark attendance.” when both are missing
- “Camera permission is required to verify your identity.” when only the camera is missing
- “Camera access is blocked. Enable it in Settings to mark attendance.” when the camera is permanently denied

### Entry points that were hidden

**Home card** in `lib/UI/home/home_page.dart`, in the Tools section, before the Profile card. Also restore `import 'package:google_fonts/google_fonts.dart';`.

The card title is `NFC Mapping`, subtitle `Configure NFC tags & access points`, and `onTap` is `context.push(Routes.nfcMapping.path)`.

The Mark Attendance dialog on that page must again say location and camera are used to confirm the user is on campus and to verify identity.

**Glass nav** in `lib/core/widgets/app_glass_nav_bar.dart`. Insert the NFC tab after Attendance and shift the later indexes back:

| Index | Tab | Action |
| --- | --- | --- |
| 0 | Home | `Routes.home` |
| 1 | Tickets | `Routes.tickets` |
| 2 | Attendance | `Routes.navAttendance` |
| 3 | NFC | `context.push(Routes.nfcMapping.path)` |
| 4 | Alerts | `Routes.getNotifications` |
| 5 | Reports | `Routes.navReports` |
| 6 | Schedule | `Routes.navSchedule` |
| 7 | Profile | `Routes.userProfile` |

`glassShellTabIndex` must use those same indexes. The careers build uses 6 for Profile, 3 for Alerts, 4 for Reports, and 5 for Schedule.

**Debug menu** in `lib/UI/home/data/dummy_home_menu.dart`. Restore the dummy item after Staff profile:

- `id`: `dummy-nfc`
- `menuKey`: `dummy_nfc`
- `menuVal`: `nfc_mapping`
- `menuName`: `NFC mapping`
- `page`: `nfcMapping`
- `parentId`: `dummy-hub`

## 5. Check that it works

1. `flutter pub get`
2. `cd ios && pod install`
3. `flutter analyze`
4. On a physical iPhone, open NFC Mapping and scan a tag. The iOS scan sheet must appear.
5. On Mark Attendance, the front camera must open and a photo with no face must be rejected.
6. On the NFC mapping form, Scan student code must open the barcode camera.

Archive a new build number after this. Build 32 is the careers-only binary. A restored admin build needs a higher build number, and App Review will ask for an NFC hardware video again once the entitlement is back.
