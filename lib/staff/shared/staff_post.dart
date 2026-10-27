import 'package:admin_app/core/services/api_service.dart';
import 'package:admin_app/staff/auth/data_source/auth_data.dart';
import 'package:admin_app/staff/shared/read_json.dart';
import 'package:dio/dio.dart';

/// Posts one staff `index.php?page=` call and returns the JSON object.
///
/// Sends the active user's `admin_id` and `token` unless [authenticated] is
/// false (password reset runs before anyone is signed in).
Future<Map<String, dynamic>> postStaffPage({
  required ApiService api,
  required Future<String> url,
  required Map<String, dynamic> fields,
  bool authenticated = true,
}) async {
  final auth = authenticated ? await AuthData.getActiveUser() : null;
  if (authenticated && auth == null) {
    throw const StaffApiException('Not signed in');
  }
  final response = await api.postAPI(
    url: await url,
    body: FormData.fromMap({
      if (auth != null) ...{'admin_id': auth.userId, 'token': auth.token},
      ...fields,
    }),
  );
  if (response.isLeft) {
    final message = response.left.message.trim();
    throw StaffApiException(message.isEmpty ? 'Request failed' : message);
  }
  final body = decodeJsonMap(response.right);
  final status = body['status'];
  final failed = status == false || status == 0 || status == 'false';
  if (failed) {
    final message = readString(body['message']);
    throw StaffApiException(message.isEmpty ? 'Request failed' : message);
  }
  return body;
}

String ymd(DateTime date) {
  final local = DateTime(date.year, date.month, date.day);
  final month = local.month.toString().padLeft(2, '0');
  final day = local.day.toString().padLeft(2, '0');
  return '${local.year}-$month-$day';
}
