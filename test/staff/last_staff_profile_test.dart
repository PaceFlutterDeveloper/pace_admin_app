import 'package:admin_app/staff/auth/last_staff_profile.dart';
import 'package:admin_app/staff/auth/models/auth_model.dart';
import 'package:flutter_test/flutter_test.dart';

AuthModel _account(
  String userId, {
  String schoolCode = 'pace',
  String? userName,
  bool active = false,
}) {
  return AuthModel.empty().copyWith(
    userId: userId,
    schoolCode: schoolCode,
    userName: userName ?? userId,
    isActive: active,
  );
}

void main() {
  test('a switch remembers the profile that was left', () {
    final previous = _account('a', active: true);
    final token = tokenForProfileLeftBehind(
      previous: previous,
      userId: 'b',
      schoolCode: 'pace',
      userName: 'b',
    );

    final picked = lastSwitchedStaffProfile(
      accounts: [
        previous.copyWith(isActive: false),
        _account('b', active: true),
        _account('c'),
      ],
      token: token,
    );

    expect(picked?.userId, 'a');
  });

  test('signing in again as the same profile does not replace the memory', () {
    expect(
      tokenForProfileLeftBehind(
        previous: _account('a', active: true),
        userId: 'a',
        schoolCode: 'pace',
        userName: 'a',
      ),
      isNull,
    );
    expect(
      tokenForProfileLeftBehind(
        previous: null,
        userId: 'a',
        schoolCode: 'pace',
        userName: 'a',
      ),
      isNull,
    );
  });

  test('the same person at another school is a different profile', () {
    final token = staffProfileToken(
      userId: '1',
      schoolCode: 'north',
      userName: 'ann',
    );

    final picked = lastSwitchedStaffProfile(
      accounts: [
        _account('1', schoolCode: 'south', userName: 'ann'),
        _account('1', schoolCode: 'north', userName: 'ann'),
        _account('2', active: true),
      ],
      token: token,
    );

    expect(picked?.schoolCode, 'north');
  });

  test(
    'one other profile is the double-tap target when nothing is remembered',
    () {
      final picked = lastSwitchedStaffProfile(
        accounts: [_account('a', active: true), _account('b')],
        token: null,
      );

      expect(picked?.userId, 'b');
    },
  );

  test('several profiles and no memory do not guess', () {
    expect(
      lastSwitchedStaffProfile(
        accounts: [_account('a', active: true), _account('b'), _account('c')],
        token: null,
      ),
      isNull,
    );
  });

  test('a missing or current memory falls back to the only other profile', () {
    final accounts = [_account('a', active: true), _account('b')];

    expect(
      lastSwitchedStaffProfile(
        accounts: accounts,
        token: staffProfileToken(
          userId: 'gone',
          schoolCode: 'pace',
          userName: 'gone',
        ),
      )?.userId,
      'b',
    );
    expect(
      lastSwitchedStaffProfile(
        accounts: accounts,
        token: staffProfileToken(
          userId: 'a',
          schoolCode: 'pace',
          userName: 'a',
        ),
      )?.userId,
      'b',
    );
    expect(
      lastSwitchedStaffProfile(
        accounts: [_account('a', active: true)],
        token: null,
      ),
      isNull,
    );
  });

  test('a broken token is ignored', () {
    expect(
      lastSwitchedStaffProfile(
        accounts: [_account('a', active: true), _account('b'), _account('c')],
        token: 'not-json',
      ),
      isNull,
    );
  });
}
