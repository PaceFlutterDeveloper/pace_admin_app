part of 'notification_cubit.dart';

@freezed
class NotificationState with _$NotificationState {
  const factory NotificationState.initial() = _Initial;
  const factory NotificationState.loading() = _Loading;
  const factory NotificationState.success(
      List<NotificationModel> notifications) = _Success;
  const factory NotificationState.failure(String error) = _Failure;
  // read single notification
  const factory NotificationState.readed(
      List<NotificationModel> notifications) = _Readed;
  const factory NotificationState.unreaded(
      List<NotificationModel> notifications) = _Unreaded;
  const factory NotificationState.readLoader(
      List<NotificationModel> notifications) = _ReadLoader;

  // read all notification
  const factory NotificationState.readAll(
      List<NotificationModel> notifications) = _ReadAll;
  const factory NotificationState.unreadAll(
      List<NotificationModel> notifications) = _UnreadAll;
  const factory NotificationState.readAllLoader(
      List<NotificationModel> notifications) = _ReadAllLoader;
}
