class ProfileCompletionModel {
  final bool isComplete;
  final bool canApply;
  final int percentage;
  final bool isFresher;
  final int requiredPercentage;
  final List<String> missingFields;

  ProfileCompletionModel({
    required this.isComplete,
    required this.canApply,
    required this.percentage,
    required this.isFresher,
    required this.requiredPercentage,
    required this.missingFields,
  });

  factory ProfileCompletionModel.fromJson(Map<String, dynamic> json) {
    return ProfileCompletionModel(
      isComplete: json['is_complete'] ?? false,
      canApply: json['can_apply'] ?? false,
      percentage: json['percentage'] ?? 0,
      isFresher: json['is_fresher'] ?? false,
      requiredPercentage: json['required_percentage'] ?? 85,
      missingFields: List<String>.from(json['missing_fields'] ?? []),
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
    };
  }
}
