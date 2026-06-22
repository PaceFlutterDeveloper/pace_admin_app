import 'package:admin_app/UI/public/user/bloc/profile/careers_profile_events.dart';
import 'package:admin_app/UI/public/user/models/profile_completion_model.dart';

/// Maps API `missing_fields` / `breakdown` keys to UI labels and profile tabs.
class ProfileCompletionMapper {
  ProfileCompletionMapper._();

  static const Map<String, String> _fieldLabels = {
    'avatar_file': 'Profile photo',
    'cv_file': 'CV / Resume',
    'candidate_data': 'Basic information',
    'candidate_name': 'Full name',
    'name': 'Full name',
    'phone': 'Phone number',
    'email': 'Email',
    'date_of_birth': 'Date of birth',
    'gender': 'Gender',
    'marital_status': 'Marital status',
    'visa_status': 'Visa status',
    'visa_exp_date': 'Visa expiry date',
    'nationality_country_id': 'Nationality country',
    'nationality_id': 'Nationality country',
    'current_country_id': 'Current country',
    'current_location': 'Current location',
    'address_local': 'Address',
    'experience_years': 'Experience years',
    'available_from': 'Available from',
    'preferred_position': 'Preferred position',
    'education_records': 'Education records',
    'experience_records': 'Experience records',
    'family_members': 'Family details',
    'references': 'References',
    'professional_programs': 'Certificates / programs',
  };

  static String labelFor(String key) {
    final normalized = key.trim().toLowerCase();
    if (_fieldLabels.containsKey(normalized)) {
      return _fieldLabels[normalized]!;
    }
    return normalized
        .split('_')
        .where((part) => part.isNotEmpty)
        .map(
          (part) =>
              part.length == 1 ? part.toUpperCase() : '${part[0].toUpperCase()}${part.substring(1)}',
        )
        .join(' ');
  }

  static List<String> displayMissingItems(ProfileCompletionModel completion) {
    final items = <String>[];
    for (final field in completion.missingFields) {
      final label = labelFor(field);
      if (!items.contains(label)) items.add(label);
    }
    return items;
  }

  static ProfileSection? sectionForKey(String key) {
    final normalized = key.trim().toLowerCase();

    if (_matchesAny(normalized, [
      'education_records',
      'education',
      'edu_',
      'grade_course',
      'board_univ',
    ])) {
      return ProfileSection.education;
    }
    if (_matchesAny(normalized, [
      'experience_records',
      'experience',
      'ex_',
      'organization',
      'designation',
    ])) {
      return ProfileSection.experience;
    }
    if (_matchesAny(normalized, [
      'family_members',
      'family',
      'fam_',
      'dependent_yn',
    ])) {
      return ProfileSection.family;
    }
    if (_matchesAny(normalized, [
      'references',
      'ref_',
      'ref_name',
    ])) {
      return ProfileSection.references;
    }
    if (_matchesAny(normalized, [
      'professional_programs',
      'programs',
      'pp_',
      'course_name',
    ])) {
      return ProfileSection.programs;
    }

    return ProfileSection.basic;
  }

  static Set<ProfileSection> incompleteSections(
    ProfileCompletionModel completion,
  ) {
    final sections = <ProfileSection>{};

    for (final field in completion.missingFields) {
      sections.add(sectionForKey(field) ?? ProfileSection.basic);
    }

    for (final entry in completion.breakdown.entries) {
      if (_isBreakdownIncomplete(entry.value)) {
        sections.add(sectionForKey(entry.key) ?? ProfileSection.basic);
      }
    }

    if (!completion.isComplete && sections.isEmpty) {
      sections.add(ProfileSection.basic);
    }

    return sections;
  }

  static bool isSectionIncomplete(
    ProfileSection section,
    ProfileCompletionModel? completion,
  ) {
    if (completion == null) return false;
    return incompleteSections(completion).contains(section);
  }

  static bool _matchesAny(String value, List<String> needles) {
    for (final needle in needles) {
      if (needle.endsWith('_')) {
        if (value.startsWith(needle)) return true;
      } else if (value == needle || value.contains(needle)) {
        return true;
      }
    }
    return false;
  }

  static bool _isBreakdownIncomplete(dynamic value) {
    if (value is num) return value < 100;
    if (value is Map) {
      final complete = value['is_complete'] ?? value['complete'];
      if (complete == false || complete == 0) return true;
      final pct = value['percentage'] ?? value['percent'] ?? value['score'];
      if (pct is num && pct < 100) return true;
    }
    return false;
  }
}
