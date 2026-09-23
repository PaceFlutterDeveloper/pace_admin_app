import 'package:admin_app/UI/public/jobs/utils/secret_title_tap.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final start = DateTime(2026, 9, 23, 12);

  test('unlocks on the seventh tap inside the window', () {
    final taps = SecretTitleTap();
    for (var i = 0; i < 6; i++) {
      expect(
        taps.register(start.add(Duration(milliseconds: 200 * i))),
        isFalse,
      );
    }
    expect(
      taps.register(start.add(const Duration(milliseconds: 1200))),
      isTrue,
    );
  });

  test('a pause longer than the window starts the count over', () {
    final taps = SecretTitleTap();
    for (var i = 0; i < 6; i++) {
      taps.register(start.add(Duration(milliseconds: 100 * i)));
    }
    expect(taps.register(start.add(const Duration(seconds: 3))), isFalse);
    for (var i = 0; i < 5; i++) {
      expect(
        taps.register(
          start.add(Duration(seconds: 3, milliseconds: 200 * (i + 1))),
        ),
        isFalse,
      );
    }
    expect(taps.register(start.add(const Duration(seconds: 4))), isTrue);
  });

  test('unlocking resets so the next taps do not stay armed', () {
    final taps = SecretTitleTap();
    for (var i = 0; i < SecretTitleTap.requiredTaps - 1; i++) {
      taps.register(start.add(Duration(milliseconds: 100 * i)));
    }
    expect(taps.register(start.add(const Duration(milliseconds: 700))), isTrue);
    expect(
      taps.register(start.add(const Duration(milliseconds: 800))),
      isFalse,
    );
  });
}
