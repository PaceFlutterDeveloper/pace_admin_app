import 'package:flutter/foundation.dart';
import 'package:hive/hive.dart';

const mustChangePasswordKey = 'mustChangePassword';

/// Holds the school's demand that this sign-in replace its password.
///
/// Login and the dashboard both write it. The router listens and keeps every
/// other staff screen closed until the password is saved.
class MustChangePasswordGate extends ChangeNotifier {
  bool get required {
    if (!Hive.isBoxOpen('settingsBox')) return false;
    return Hive.box('settingsBox').get(mustChangePasswordKey) == true;
  }

  void apply(bool value) {
    if (!Hive.isBoxOpen('settingsBox')) return;
    final box = Hive.box('settingsBox');
    if (box.get(mustChangePasswordKey) == value) return;
    box.put(mustChangePasswordKey, value);
    notifyListeners();
  }
}

final mustChangePasswordGate = MustChangePasswordGate();
