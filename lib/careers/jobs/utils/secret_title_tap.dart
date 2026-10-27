/// Counts quiet taps on a title. Unlocks once [requiredTaps] land with no
/// gap longer than [window]. Nothing is shown while counting.
class SecretTitleTap {
  static const requiredTaps = 7;
  static const window = Duration(seconds: 2);

  int _count = 0;
  DateTime? _last;

  bool register(DateTime now) {
    if (_last != null && now.difference(_last!) > window) {
      _count = 0;
    }
    _last = now;
    _count += 1;
    if (_count < requiredTaps) return false;
    _count = 0;
    _last = null;
    return true;
  }
}
