import 'package:equatable/equatable.dart';

class NewCampaignDraft extends Equatable {
  final String title;
  final String goalAmount;
  final String endDate;
  final String description;
  final bool allowAnonymousGiving;
  final bool showProgressPublicly;
  final bool isSubmitting;
  final String? coverImagePath;

  const NewCampaignDraft({
    this.title = '',
    this.goalAmount = '',
    this.endDate = '',
    this.description = '',
    this.allowAnonymousGiving = true,
    this.showProgressPublicly = false,
    this.isSubmitting = false,
    this.coverImagePath,
  });

  NewCampaignDraft copyWith({
    String? title,
    String? goalAmount,
    String? endDate,
    String? description,
    bool? allowAnonymousGiving,
    bool? showProgressPublicly,
    bool? isSubmitting,
    String? coverImagePath,
    bool clearCoverImage = false,
  }) {
    return NewCampaignDraft(
      title: title ?? this.title,
      goalAmount: goalAmount ?? this.goalAmount,
      endDate: endDate ?? this.endDate,
      description: description ?? this.description,
      allowAnonymousGiving:
          allowAnonymousGiving ?? this.allowAnonymousGiving,
      showProgressPublicly:
          showProgressPublicly ?? this.showProgressPublicly,
      isSubmitting: isSubmitting ?? this.isSubmitting,
      coverImagePath: clearCoverImage
          ? null
          : (coverImagePath ?? this.coverImagePath),
    );
  }

  double? get parsedGoal {
    final raw = goalAmount.replaceAll(',', '').trim();
    if (raw.isEmpty) return null;
    return double.tryParse(raw);
  }

  @override
  List<Object?> get props => [
        title,
        goalAmount,
        endDate,
        description,
        allowAnonymousGiving,
        showProgressPublicly,
        isSubmitting,
        coverImagePath,
      ];
}
