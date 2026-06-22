class ProfileCompletionModel {
  final bool isComplete;
  final bool canApply;
  final int percentage;
  final bool isFresher;
  final int requiredPercentage;
  final List<String> missingFields;
  final Map<String, dynamic> breakdown;

  ProfileCompletionModel({
    required this.isComplete,
    required this.canApply,
    required this.percentage,
    required this.isFresher,
    required this.requiredPercentage,
    required this.missingFields,
    this.breakdown = const {},
  });

  factory ProfileCompletionModel.fromJson(Map<String, dynamic> json) {
    return ProfileCompletionModel(
      isComplete: json['is_complete'] == true || json['is_complete'] == 1,
      canApply: json['can_apply'] == true || json['can_apply'] == 1,
      percentage: json['percentage'] is int
          ? json['percentage'] as int
          : int.tryParse(json['percentage']?.toString() ?? '') ?? 0,
      isFresher: json['is_fresher'] == true || json['is_fresher'] == 1,
      requiredPercentage: json['required_percentage'] is int
          ? json['required_percentage'] as int
          : int.tryParse(json['required_percentage']?.toString() ?? '') ?? 85,
      missingFields: List<String>.from(json['missing_fields'] ?? []),
      breakdown: Map<String, dynamic>.from(json['breakdown'] ?? {}),
    );
  }

  /// Parses the full `GET /profile-completion` `data` envelope, merging
  /// top-level and nested `missing_fields` plus `breakdown`.
  factory ProfileCompletionModel.fromApiData(Map<String, dynamic> data) {
    final completionRaw = data['completion'];
    final completionJson = completionRaw is Map
        ? Map<String, dynamic>.from(completionRaw)
        : <String, dynamic>{};

    final rootMissing = (data['missing_fields'] as List<dynamic>?)
            ?.map((e) => e.toString())
            .toList() ??
        <String>[];
    final nestedMissing = (completionJson['missing_fields'] as List<dynamic>?)
            ?.map((e) => e.toString())
            .toList() ??
        <String>[];

    final mergedMissing = <String>{
      ...rootMissing,
      ...nestedMissing,
    }.toList();

    final breakdown = <String, dynamic>{};
    final rootBreakdown = data['breakdown'];
    final nestedBreakdown = completionJson['breakdown'];
    if (rootBreakdown is Map) {
      breakdown.addAll(Map<String, dynamic>.from(rootBreakdown));
    }
    if (nestedBreakdown is Map) {
      breakdown.addAll(Map<String, dynamic>.from(nestedBreakdown));
    }

    completionJson['missing_fields'] = mergedMissing;
    completionJson['breakdown'] = breakdown;

    return ProfileCompletionModel.fromJson(completionJson);
  }

  Map<String, dynamic> toJson() {
    return {
      'is_complete': isComplete,
      'can_apply': canApply,
      'percentage': percentage,
      'is_fresher': isFresher,
      'required_percentage': requiredPercentage,
      'missing_fields': missingFields,
      'breakdown': breakdown,
    };
  }
}

class ProfileCompletionCandidateSummary {
  final int id;
  final String name;
  final String email;

  const ProfileCompletionCandidateSummary({
    required this.id,
    required this.name,
    required this.email,
  });

  factory ProfileCompletionCandidateSummary.fromJson(
    Map<String, dynamic> json,
  ) {
    return ProfileCompletionCandidateSummary(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      email: json['email'] ?? '',
    );
  }
}

class ProfileCompletionResponse {
  final ProfileCompletionCandidateSummary candidate;
  final ProfileCompletionModel completion;

  ProfileCompletionResponse({
    required this.candidate,
    required this.completion,
  });

  factory ProfileCompletionResponse.fromJson(Map<String, dynamic> json) {
    return ProfileCompletionResponse(
      candidate: ProfileCompletionCandidateSummary.fromJson(
        json['candidate'] is Map
            ? Map<String, dynamic>.from(json['candidate'] as Map)
            : <String, dynamic>{},
      ),
      completion: ProfileCompletionModel.fromApiData(json),
    );
  }
}
