import 'package:faithconnect/core/utils/media_url_resolver.dart';
import 'package:faithconnect/features/campaign/domain/entities/campaign.dart';
import 'package:faithconnect/features/campaign/domain/entities/campaign_status.dart';
import 'package:faithconnect/features/discovery/domain/entities/discovery_campaign.dart';
import 'package:faithconnect/features/home/data/models/home_feed_model.dart';

class CampaignApiDto {
  final String id;
  final String title;
  final String description;
  final String? imageUrl;
  final String? organizationName;
  final String? location;
  final double raisedAmountEtb;
  final double goalAmountEtb;
  final int? daysLeft;
  final String? status;
  final DateTime? startAt;
  final DateTime? endAt;
  final bool isActive;

  const CampaignApiDto({
    required this.id,
    required this.title,
    this.description = '',
    this.imageUrl,
    this.organizationName,
    this.location,
    this.raisedAmountEtb = 0,
    this.goalAmountEtb = 0,
    this.daysLeft,
    this.status,
    this.startAt,
    this.endAt,
    this.isActive = true,
  });

  factory CampaignApiDto.fromJson(Map<String, dynamic> json) {
    final church = json['church'];
    final churchMap = church is Map ? Map<String, dynamic>.from(church) : null;
    final endAt = DateTime.tryParse(json['endAt']?.toString() ?? '');
    final explicitDays = _intOrNull(json['daysLeft'] ?? json['days_left']);

    return CampaignApiDto(
      id: json['id']?.toString() ?? '',
      title: json['title'] as String? ?? json['name'] as String? ?? '',
      description: json['description'] as String? ?? '',
      imageUrl: MediaUrlResolver.normalize(
        json['imageUrl'] as String? ??
            json['coverImageUrl'] as String? ??
            json['cover_image_url'] as String?,
        imageOnly: true,
      ),
      organizationName: churchMap?['name'] as String? ??
          json['organizationName'] as String? ??
          json['churchName'] as String?,
      location: json['location'] as String? ?? churchMap?['city'] as String?,
      raisedAmountEtb: _toDouble(
        json['raisedAmount'] ??
            json['raised_amount'] ??
            json['raisedAmountEtb'] ??
            json['currentAmount'] ??
            json['currentBalance'],
      ),
      goalAmountEtb: _toDouble(
        json['goalAmount'] ?? json['goal_amount'] ?? json['goalAmountEtb'],
      ),
      daysLeft: explicitDays ?? _daysUntil(endAt),
      status: json['status'] as String?,
      startAt: DateTime.tryParse(
        json['startAt']?.toString() ?? json['startsAt']?.toString() ?? '',
      ),
      endAt: endAt,
      isActive: json['isActive'] == true,
    );
  }

  Campaign toCampaign({
    bool isFeatured = false,
    String? organizationNameOverride,
  }) {
    final campaignStatus = _resolveStatus();
    return Campaign(
      id: id,
      title: title,
      description: description.isNotEmpty
          ? description
          : 'Community fundraising campaign',
      imageUrl: imageUrl,
      raisedAmountEtb: raisedAmountEtb,
      goalAmountEtb: goalAmountEtb,
      status: campaignStatus,
      organizationName:
          organizationNameOverride ?? organizationName ?? 'Church',
      location: location,
      statusBadge: _statusBadge(campaignStatus),
      daysLeft: daysLeft,
      isFeatured: isFeatured,
      tags: const [],
    );
  }

  CampaignStatus _resolveStatus() {
    final normalized = status?.trim().toUpperCase() ?? '';
    if (normalized.contains('COMPLET') ||
        normalized.contains('SUCCESS') ||
        normalized.contains('CLOSED') ||
        normalized.contains('ENDED')) {
      return CampaignStatus.completed;
    }
    if (isActive == false && normalized.isNotEmpty) {
      return CampaignStatus.completed;
    }
    return CampaignStatus.active;
  }

  static String _statusBadge(CampaignStatus status) {
    return switch (status) {
      CampaignStatus.completed => 'Completed',
      CampaignStatus.active => 'Active',
    };
  }

  static int? _daysUntil(DateTime? end) {
    if (end == null) return null;
    final days = end.difference(DateTime.now()).inDays;
    return days < 0 ? 0 : days;
  }

  DiscoveryCampaign toDiscoveryCampaign() {
    return DiscoveryCampaign(
      id: id,
      title: title,
      organizationName: organizationName ?? 'Church',
      raisedAmountEtb: raisedAmountEtb,
      goalAmountEtb: goalAmountEtb,
      daysLeft: daysLeft ?? 0,
      imageUrl: imageUrl,
    );
  }

  FeaturedEventModel? toFeaturedEventModel() {
    if (id.isEmpty || title.isEmpty) return null;
    final days = daysLeft ?? 0;
    final when = days > 0 ? 'Ends in $days days' : 'Active now';
    return FeaturedEventModel(
      id: id,
      title: title,
      description: description.isNotEmpty
          ? description
          : 'Join us for this community campaign.',
      dateTime: when,
      location: location ?? organizationName ?? '',
      imageUrl: imageUrl,
    );
  }

  static double _toDouble(dynamic value) {
    if (value is num) return value.toDouble();
    return 0;
  }

  static int? _intOrNull(dynamic value) {
    if (value is int) return value;
    if (value is num) return value.toInt();
    return null;
  }
}
