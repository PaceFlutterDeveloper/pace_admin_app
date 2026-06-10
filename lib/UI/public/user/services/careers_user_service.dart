import 'package:admin_app/UI/public/user/models/careers_user_model.dart';
import 'package:get_it/get_it.dart';
import 'package:hive/hive.dart';

class CareersUserService {
  late Box<CareersUserModel> _careersUserBox;

  CareersUserService() {
    _careersUserBox = GetIt.instance<Box<CareersUserModel>>();
  }

  // Get current careers user
  CareersUserModel? getCurrentCareersUser() {
    return _careersUserBox.get('current_user');
  }

  // Set current careers user
  Future<void> setCurrentCareersUser(CareersUserModel user) async {
    await _careersUserBox.put('current_user', user);
  }

  // Update current careers user
  Future<void> updateCurrentCareersUser(CareersUserModel user) async {
    await _careersUserBox.put('current_user', user);
  }

  // Clear current careers user
  Future<void> clearCurrentCareersUser() async {
    await _careersUserBox.delete('current_user');
  }

  // Check if user is logged in
  bool isCareersUserLoggedIn() {
    return _careersUserBox.get('current_user') != null;
  }

  // Get user preferences
  Map<String, dynamic> getUserPreferences() {
    final user = getCurrentCareersUser();
    return user?.preferences ?? {};
  }

  // Update user preferences
  Future<void> updateUserPreferences(Map<String, dynamic> preferences) async {
    final user = getCurrentCareersUser();
    if (user != null) {
      final updatedUser = user.copyWith(preferences: preferences);
      await setCurrentCareersUser(updatedUser);
    }
  }

  // Get preferred school IDs
  List<int> getPreferredSchoolIds() {
    final user = getCurrentCareersUser();
    return user?.preferredSchoolIds ?? [];
  }

  // Update preferred school IDs
  Future<void> updatePreferredSchoolIds(List<int> schoolIds) async {
    final user = getCurrentCareersUser();
    if (user != null) {
      final updatedUser = user.copyWith(preferredSchoolIds: schoolIds);
      await setCurrentCareersUser(updatedUser);
    }
  }

  // Get user skills
  List<String> getUserSkills() {
    final user = getCurrentCareersUser();
    return user?.skills ?? [];
  }

  // Update user skills
  Future<void> updateUserSkills(List<String> skills) async {
    final user = getCurrentCareersUser();
    if (user != null) {
      final updatedUser = user.copyWith(skills: skills);
      await setCurrentCareersUser(updatedUser);
    }
  }

  // Update last login time
  Future<void> updateLastLogin() async {
    final user = getCurrentCareersUser();
    if (user != null) {
      final updatedUser = user.copyWith(lastLoginAt: DateTime.now());
      await setCurrentCareersUser(updatedUser);
    }
  }

  // Get user by ID (for future use if we need to store multiple users)
  CareersUserModel? getUserById(String id) {
    return _careersUserBox.get(id);
  }

  // Save user by ID (for future use if we need to store multiple users)
  Future<void> saveUserById(String id, CareersUserModel user) async {
    await _careersUserBox.put(id, user);
  }

  // Get all users (for future use if we need to store multiple users)
  List<CareersUserModel> getAllUsers() {
    return _careersUserBox.values.toList();
  }

  // Clear all users data
  Future<void> clearAllUsers() async {
    await _careersUserBox.clear();
  }
}
