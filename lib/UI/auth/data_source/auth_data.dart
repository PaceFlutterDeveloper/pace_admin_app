import 'package:admin_app/UI/auth/models/auth_model.dart';
import 'package:admin_app/dependancy_injection.dart';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';

class AuthData {
  /// Adds a new user to the Hive box.
  /// - Deactivates all existing users.
  /// - Removes any existing user with the same [userId], [userName], and [schoolCode].
  /// - Adds the new user as active.
  static Future<void> addNewUser({
    required String schoolCode,
    required String userName,
    required String password,
    required String token,
    required String profilePicture,
    required String designation,
    required String name,
    required String userId,
    required String logo,
    required String schoolName,
  }) async {
    final Box<AuthModel> loginBox = locator<Box<AuthModel>>();

    // Deactivate all existing users
    final deactivatedEntries = <int, AuthModel>{};
    for (final entry in loginBox.toMap().entries) {
      final user = entry.value;
      if (user.isActive) {
        deactivatedEntries[entry.key] = user.copyWith(isActive: false);
        debugPrint('🔻 Deactivated user: ${user.userName} (${user.userId})');
      }
    }

    if (deactivatedEntries.isNotEmpty) {
      await loginBox.putAll(deactivatedEntries);
      debugPrint('🔁 Updated ${deactivatedEntries.length} user(s) to inactive');
    } else {
      debugPrint('ℹ️ No active users to deactivate');
    }

    // Remove any existing user with the same userId, userName, and schoolCode
    final keysToRemove = loginBox
        .toMap()
        .entries
        .where((entry) =>
            entry.value.userId == userId &&
            entry.value.userName == userName &&
            entry.value.schoolCode == schoolCode)
        .map((entry) => entry.key)
        .toList();

    if (keysToRemove.isNotEmpty) {
      await loginBox.deleteAll(keysToRemove);
      debugPrint(
          '🗑️ Removed ${keysToRemove.length} existing user(s) with matching credentials');
    } else {
      debugPrint('ℹ️ No matching users to remove');
    }

    // Add and activate the new user
    final newUser = AuthModel(
      notificationCount: 0,
      schoolCode: schoolCode,
      id: loginBox.length,
      userName: userName,
      password: password,
      token: token,
      profilePicture: profilePicture,
      isActive: true,
      designation: designation,
      name: name,
      userId: userId,
      logo: logo,
      schoolName: schoolName,
    );

    await loginBox.add(newUser);
    debugPrint(
        '✅ Added new active user: ${newUser.userName} (${newUser.userId})');
  }

  /// Deactivates all users except the specified user after successful authentication.
  static Future<void> deactivateAllUsersExcept(
    String userName,
    String schoolCode,
    String userId,
  ) async {
    final loginBox = locator<Box<AuthModel>>();
    final updatedEntries = <int, AuthModel>{};

    for (final entry in loginBox.toMap().entries) {
      final user = entry.value;
      final isTargetUser = user.userName == userName &&
          user.schoolCode == schoolCode &&
          user.userId == userId;

      updatedEntries[entry.key] = user.copyWith(isActive: isTargetUser);

      debugPrint(
          '${isTargetUser ? '✅ Activated' : '❌ Deactivated'} user: ${user.userName} (${user.userId}) from school ${user.schoolCode}');
    }

    await loginBox.putAll(updatedEntries);
    debugPrint('🔁 Finished updating ${updatedEntries.length} users');
  }

  /// Clears all users from the Hive box.
  static Future<void> deactivateAllUsers() async {
    final Box<AuthModel> loginBox = locator<Box<AuthModel>>();
    await loginBox.clear();
    debugPrint('🧹 Cleared all users from the login box');
  }

  /// Returns the currently active user, if any.
  static Future<AuthModel?> getActiveUser() async {
    final Box<AuthModel> loginBox = locator<Box<AuthModel>>();

    try {
      final activeUser = loginBox.values.firstWhere((user) => user.isActive);
      debugPrint(
          '👤 Active user found: ${activeUser.userName} (${activeUser.userId})');
      return activeUser;
    } catch (e) {
      debugPrint('ℹ️ No active user found');
      return null;
    }
  }

  /// Logs out the current active user by deleting their entry from the Hive box.
  static Future<void> logoutCurrentUser() async {
    final box = locator<Box<AuthModel>>();

    try {
      final boxMap = box.toMap();

      final activeEntry = boxMap.entries.firstWhere(
        (entry) => entry.value.isActive,
      );

      await box.delete(activeEntry.key);
      debugPrint(
          '✅ Logged out and deleted active user: ${activeEntry.value.userName}');
    } on StateError {
      debugPrint('ℹ️ No active user found to logout');
    } catch (e, stackTrace) {
      debugPrint('❌ Error during logout: $e\n$stackTrace');
      rethrow;
    }
  }

  /// Updates the notification count of a user by adding to the existing count based on app code and user ID.
  static Future<void> updateNotificationCount({
    required String appCode,
    required String userId,
    required int notificationCount,
    NotificationUpdateMode mode = NotificationUpdateMode.add,
  }) async {
    final Box<AuthModel> loginBox = locator<Box<AuthModel>>();

    try {
      final targetEntry = loginBox.toMap().entries.firstWhere(
            (entry) =>
                entry.value.schoolCode == appCode &&
                entry.value.userId == userId,
          );

      final targetUser = targetEntry.value;
      final targetUserKey = targetEntry.key;

      int newCount = targetUser.notificationCount;

      switch (mode) {
        case NotificationUpdateMode.add:
          newCount += notificationCount;
          break;
        case NotificationUpdateMode.replace:
          newCount = notificationCount;
          break;
        case NotificationUpdateMode.clear:
          newCount = 0;
          break;
        case NotificationUpdateMode.decrease:
          newCount = (newCount - notificationCount).clamp(0, newCount);
          break;
      }

      await loginBox.put(
        targetUserKey,
        targetUser.copyWith(notificationCount: newCount),
      );

      debugPrint(
          '🔔 Updated notification count for user: ${targetUser.userName} (${targetUser.userId}) to $newCount');
    } catch (e) {
      debugPrint('ℹ️ No matching user found to update notification count');
    }
  }

  /// Checks if a user exists based on [schoolCode], [userId], and [userName].
  static Future<bool> doesUserExist({
    required String schoolCode,
    required String userId,
    required String userName,
  }) async {
    final box = locator<Box<AuthModel>>();

    final exists = box.values.any(
      (user) =>
          user.schoolCode == schoolCode &&
          user.userId == userId &&
          user.userName == userName,
    );

    debugPrint(
        '🔍 User existence check for $userName ($userId) in school $schoolCode: ${exists ? 'Found' : 'Not Found'}');

    return exists;
  }
}

enum NotificationUpdateMode { add, replace, clear, decrease }
