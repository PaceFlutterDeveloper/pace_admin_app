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
      missingFields: _parseMissingFields(json['missing_fields']),
      breakdown: Map<String, dynamic>.from(json['breakdown'] ?? {}),
    );
  }

  static List<String> _parseMissingFields(dynamic raw) {
    if (raw is! List) return [];
    return raw
        .map((item) {
          if (item is String) return item.trim();
          if (item is Map) {
            return (item['field'] ?? item['key'] ?? item['name'] ?? '')
                .toString()
                .trim();
          }
          return item.toString().trim();
        })
        .where((value) => value.isNotEmpty)
        .toList();
  }

  /// Parses the full `GET /profile-completion` `data` envelope, merging
  /// top-level and nested `missing_fields` plus `breakdown`.
  factory ProfileCompletionModel.fromApiData(Map<String, dynamic> data) {
    final completionRaw = data['completion'];
    final completionJson = completionRaw is Map
        ? Map<String, dynamic>.from(completionRaw)
        : <String, dynamic>{};

    final rootMissing = _parseMissingFields(data['missing_fields']);
    final nestedMissing = _parseMissingFields(completionJson['missing_fields']);

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

    for (final key in [
      'is_complete',
      'can_apply',
      'percentage',
      'is_fresher',
      'required_percentage',
    ]) {
      if (!completionJson.containsKey(key) && data.containsKey(key)) {
        completionJson[key] = data[key];
      }
    }

    return ProfileCompletionModel.fromJson(completionJson);
  }

  ProfileCompletionModel copyWith({
    bool? isComplete,
    bool? canApply,
    int? percentage,
    bool? isFresher,
    int? requiredPercentage,
    List<String>? missingFields,
    Map<String, dynamic>? breakdown,
  }) {
    return ProfileCompletionModel(
      isComplete: isComplete ?? this.isComplete,
      canApply: canApply ?? this.canApply,
      percentage: percentage ?? this.percentage,
      isFresher: isFresher ?? this.isFresher,
      requiredPercentage: requiredPercentage ?? this.requiredPercentage,
      missingFields: missingFields ?? this.missingFields,
      breakdown: breakdown ?? this.breakdown,
    );
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
