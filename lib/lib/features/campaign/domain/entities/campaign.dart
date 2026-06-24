import 'package:equatable/equatable.dart';
import 'package:faithconnect/features/campaign/domain/entities/campaign_status.dart';

class Campaign extends Equatable {
  final String id;
  final String title;
  final String description;
  final String? imageUrl;
  final double raisedAmountEtb;
  final double goalAmountEtb;
  final CampaignStatus status;
  final List<String> tags;
  final String? stewardshipTag;
  final bool isFeatured;
  final String organizationName;
  final String? location;
  final String statusBadge;
  final int? daysLeft;
  final DateTime? completedAt;
  final int? beneficiaryCount;
  final String? avatarUrl;

  const Campaign({
    required this.id,
    required this.title,
    required this.description,
    this.imageUrl,
    required this.raisedAmountEtb,
    required this.goalAmountEtb,
    required this.status,
    this.tags = const [],
    this.stewardshipTag,
    this.isFeatured = false,
    required this.organizationName,
    this.location,
    required this.statusBadge,
    this.daysLeft,
    this.completedAt,
    this.beneficiaryCount,
    this.avatarUrl,
  });

  double get progressPercent =>
      goalAmountEtb <= 0 ? 0 : (raisedAmountEtb / goalAmountEtb).clamp(0, 1) * 100;

  int get progressPercentRounded => progressPercent.round();

  Campaign copyWith({
    String? id,
    String? title,
    String? description,
    String? imageUrl,
    double? raisedAmountEtb,
    double? goalAmountEtb,
    CampaignStatus? status,
    List<String>? tags,
    String? stewardshipTag,
    bool? isFeatured,
    String? organizationName,
    String? location,
    String? statusBadge,
    int? daysLeft,
    DateTime? completedAt,
    int? beneficiaryCount,
    String? avatarUrl,
  }) {
    return Campaign(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      imageUrl: imageUrl ?? this.imageUrl,
      raisedAmountEtb: raisedAmountEtb ?? this.raisedAmountEtb,
      goalAmountEtb: goalAmountEtb ?? this.goalAmountEtb,
      status: status ?? this.status,
      tags: tags ?? this.tags,
      stewardshipTag: stewardshipTag ?? this.stewardshipTag,
      isFeatured: isFeatured ?? this.isFeatured,
      organizationName: organizationName ?? this.organizationName,
      location: location ?? this.location,
      statusBadge: statusBadge ?? this.statusBadge,
      daysLeft: daysLeft ?? this.daysLeft,
      completedAt: completedAt ?? this.completedAt,
      beneficiaryCount: beneficiaryCount ?? this.beneficiaryCount,
      avatarUrl: avatarUrl ?? this.avatarUrl,
    );
  }

  @override
  List<Object?> get props => [
        id,
        title,
        description,
        imageUrl,
        raisedAmountEtb,
        goalAmountEtb,
        status,
        tags,
        stewardshipTag,
        isFeatured,
        organizationName,
        location,
        statusBadge,
        daysLeft,
        completedAt,
        beneficiaryCount,
        avatarUrl,
      ];
}
