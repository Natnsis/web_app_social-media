import 'package:equatable/equatable.dart';

class NewGroupDraft extends Equatable {
  final String name;
  final String category;
  final String description;
  final bool isPrivate;
  final bool approvalRequired;
  final bool allowMemberInvitations;
  final Set<String> selectedModeratorIds;
  final bool isSubmitting;
  final String? coverImagePath;

  const NewGroupDraft({
    this.name = '',
    this.category = 'Bible Study',
    this.description = '',
    this.isPrivate = true,
    this.approvalRequired = false,
    this.allowMemberInvitations = true,
    this.selectedModeratorIds = const {},
    this.isSubmitting = false,
    this.coverImagePath,
  });

  static const List<String> categories = [
    'Bible Study',
    'Fellowship',
    'Outreach',
    'Leadership',
    'Prayer',
    'Youth',
  ];

  NewGroupDraft copyWith({
    String? name,
    String? category,
    String? description,
    bool? isPrivate,
    bool? approvalRequired,
    bool? allowMemberInvitations,
    Set<String>? selectedModeratorIds,
    bool? isSubmitting,
    String? coverImagePath,
    bool clearCoverImage = false,
  }) {
    return NewGroupDraft(
      name: name ?? this.name,
      category: category ?? this.category,
      description: description ?? this.description,
      isPrivate: isPrivate ?? this.isPrivate,
      approvalRequired: approvalRequired ?? this.approvalRequired,
      allowMemberInvitations:
          allowMemberInvitations ?? this.allowMemberInvitations,
      selectedModeratorIds:
          selectedModeratorIds ?? this.selectedModeratorIds,
      isSubmitting: isSubmitting ?? this.isSubmitting,
      coverImagePath: clearCoverImage
          ? null
          : (coverImagePath ?? this.coverImagePath),
    );
  }

  @override
  List<Object?> get props => [
        name,
        category,
        description,
        isPrivate,
        approvalRequired,
        allowMemberInvitations,
        selectedModeratorIds,
        isSubmitting,
        coverImagePath,
      ];
}
