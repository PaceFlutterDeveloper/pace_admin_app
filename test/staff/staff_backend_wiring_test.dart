import 'package:admin_app/core/services/staff_session_expired_handler.dart';
import 'package:admin_app/staff/account/components/update_password_page.dart';
import 'package:admin_app/staff/leave/domain/leave_models.dart';
import 'package:admin_app/staff/leave/presentation/leave_format.dart';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';

DioException _error(String url, int status, Object? body) {
  final options = RequestOptions(path: url);
  return DioException(
    requestOptions: options,
    response: Response(requestOptions: options, statusCode: status, data: body),
  );
}

void main() {
  group('StaffSessionExpiredHandler', () {
    const url = 'https://demo.paceeducation.com/erp-api/index.php?page=tasks';

    test('401 with TOKEN_EXPIRED or TOKEN_INVALID is an expired session', () {
      expect(
        StaffSessionExpiredHandler.isExpiredSessionError(
          _error(url, 401, {'code': 'TOKEN_EXPIRED'}),
        ),
        isTrue,
      );
      expect(
        StaffSessionExpiredHandler.isExpiredSessionError(
          _error(url, 401, '{"status":false,"code":"TOKEN_INVALID"}'),
        ),
        isTrue,
      );
    });

    test('other failures never sign the user out', () {
      expect(
        StaffSessionExpiredHandler.isExpiredSessionError(
          _error(url, 401, {'code': 'BAD_PASSWORD'}),
        ),
        isFalse,
      );
      expect(
        StaffSessionExpiredHandler.isExpiredSessionError(
          _error(url, 500, {'code': 'TOKEN_EXPIRED'}),
        ),
        isFalse,
      );
      expect(
        StaffSessionExpiredHandler.isExpiredSessionError(
          _error('https://demo.paceeducation.com/careers/api', 401, {
            'code': 'TOKEN_EXPIRED',
          }),
        ),
        isFalse,
      );
    });

    test('codeOf copes with junk', () {
      expect(StaffSessionExpiredHandler.codeOf(null), '');
      expect(StaffSessionExpiredHandler.codeOf('not json'), '');
      expect(StaffSessionExpiredHandler.codeOf('<b>x</b>{"code":"A"}'), 'A');
    });

    test('a switch does not sign out on the previous profile\'s rejection', () {
      expect(
        expiredTokenShouldSignOut(
          switching: true,
          requestToken: 'old',
          activeToken: 'old',
        ),
        isFalse,
      );
      expect(
        expiredTokenShouldSignOut(
          switching: false,
          requestToken: 'old',
          activeToken: 'new',
        ),
        isFalse,
      );
      expect(
        expiredTokenShouldSignOut(
          switching: false,
          requestToken: 'new',
          activeToken: 'new',
        ),
        isTrue,
      );
    });

    test('tokenOn reads the token the call sent', () {
      final options = RequestOptions(path: url);
      options.extra['staffToken'] = 'from-extra';
      expect(
        StaffSessionExpiredHandler.tokenOn(
          DioException(requestOptions: options),
        ),
        'from-extra',
      );

      final form = RequestOptions(
        path: url,
        data: FormData.fromMap({'token': 'from-form', 'admin_id': '1'}),
      );
      expect(
        StaffSessionExpiredHandler.tokenOn(DioException(requestOptions: form)),
        'from-form',
      );
    });
  });

  group('passwordProblem', () {
    test('accepts a valid change', () {
      expect(
        passwordProblem(
          current: 'old-pass',
          next: 'new-pass-1',
          confirm: 'new-pass-1',
        ),
        isNull,
      );
    });

    test('rejects each bad case with a message', () {
      expect(
        passwordProblem(current: '', next: 'abcdefgh', confirm: 'abcdefgh'),
        isNotNull,
      );
      expect(
        passwordProblem(current: 'old', next: 'short', confirm: 'short'),
        isNotNull,
      );
      expect(
        passwordProblem(
          current: 'abcdefgh',
          next: 'abcdefgh',
          confirm: 'abcdefgh',
        ),
        isNotNull,
      );
      expect(
        passwordProblem(current: 'old', next: 'abcdefgh', confirm: 'abcdefgi'),
        isNotNull,
      );
    });
  });

  group('leave models', () {
    test('LeaveBalance reads numbers sent as strings', () {
      final b = LeaveBalance.fromMap({
        'leave_type_id': '3',
        'type': 'Medical',
        'entitled': '30',
        'taken': 2.5,
        'pending': '0',
        'remaining': '27.5',
      });
      expect(b.typeId, 3);
      expect(b.type, 'Medical');
      expect(b.remaining, 27.5);
      expect(b.taken, 2.5);
    });

    test('LeaveStatus.parse is forgiving', () {
      expect(LeaveStatus.parse(' Approved '), LeaveStatus.approved);
      expect(LeaveStatus.parse('declined'), LeaveStatus.rejected);
      expect(LeaveStatus.parse('canceled'), LeaveStatus.cancelled);
      expect(LeaveStatus.parse('whatever'), LeaveStatus.other);
    });

    test('LeaveRequest reads the list payload fields', () {
      final r = LeaveRequest.fromMap({
        'request_id': 801,
        'type': 'Unpaid Leave',
        'leave_type_id': 4,
        'from_date': '2025-12-19',
        'to_date': '2025-12-20',
        'days': 0,
        'half_day': null,
        'status': 'approved',
        'reason': 'LOP',
        'approver_name': 'ADMIN MANAGER',
        'approver_comment': 'ADMIN MANAGER',
        'applied_at': '2025-12-19T00:00:00+04:00',
      });
      expect(r.id, '801');
      expect(r.type, 'Unpaid Leave');
      expect(r.typeId, 4);
      expect(r.days, 0);
      expect(r.halfDay, '');
      expect(r.status, LeaveStatus.approved);
      expect(r.reason, 'LOP');
      expect(r.approverName, 'ADMIN MANAGER');
      expect(r.approverComment, 'ADMIN MANAGER');
      expect(r.from, DateTime(2025, 12, 19));
      expect(r.to, DateTime(2025, 12, 20));
      expect(r.appliedAt, isNotNull);
    });

    test('leaveLengthLabel skips a zero day count', () {
      expect(leaveLengthLabel(days: 0, halfDay: ''), '');
      expect(leaveLengthLabel(days: 0, halfDay: 'am'), 'Morning half');
      expect(leaveLengthLabel(days: 2, halfDay: ''), '2 days');
      expect(
        leaveLengthLabel(days: 0.5, halfDay: 'pm'),
        'Afternoon half · 0.5 days',
      );
    });
  });
}
