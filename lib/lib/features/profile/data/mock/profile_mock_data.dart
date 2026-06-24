import 'package:faithconnect/core/constants/branding_assets.dart';
import 'package:faithconnect/features/profile/domain/entities/gift_period.dart';
import 'package:faithconnect/features/profile/domain/entities/gift_summary.dart';
import 'package:faithconnect/features/profile/domain/entities/gift_transaction.dart';
import 'package:faithconnect/features/profile/domain/entities/live_viewers_range.dart';
import 'package:faithconnect/features/profile/domain/entities/live_viewers_summary.dart';
import 'package:faithconnect/features/profile/domain/entities/new_member.dart';
import 'package:faithconnect/features/profile/domain/entities/organization_profile.dart';
import 'package:faithconnect/features/profile/domain/entities/subscribers_summary.dart';

abstract final class ProfileMockData {
  ProfileMockData._();

  static const _ownerAvatar =
      'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=200';
  static const _orgAvatar =
      'https://images.unsplash.com/photo-1529156069898-49953e39b3ac?w=200';

  static const _shortThumbA =
      'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=600';
  static const _shortThumbB =
      'https://images.unsplash.com/photo-1516450360452-9312f5e86fc7?w=600';
  static const _shortThumbC =
      'https://images.unsplash.com/photo-1504052434569-70ad5836ab65?w=600';
  static const _shortThumbD =
      'https://images.unsplash.com/photo-1529070538774-1843cb3265df?w=600';
  static const _shortThumbE =
      'https://images.unsplash.com/photo-1494790108377-be9c29b29330?w=600';
  static const _shortThumbF =
      'https://images.unsplash.com/photo-1529156069898-49953e39b3ac?w=600';

  static OrganizationProfile organizationProfile() {
    return const OrganizationProfile(
      id: 'beza-international',
      name: 'Beza International',
      hubLabel: 'Global Ministry Hub',
      avatarUrl: _orgAvatar,
      bannerAssetPath: BrandingAssets.churchprofileBackgrounddrakmode,
      owner: ProfileOwner(
        name: 'Abebe Tesfaye',
        role: 'Global Administrator',
        avatarUrl: _ownerAvatar,
      ),
      stats: ProfileStats(
        subscriberCount: 12400,
        subscriberGrowthPercent: 8,
        campaignCount: 42,
        campaignGrowthPercent: 5,
        monthlyGiftsTotal: 4150,
        monthlyGiftsGrowthPercent: 12,
        livePeakViewers: 489,
        liveGrowthPercent: 18,
      ),
      shorts: [
        ProfileShortClip(
          id: 'clip-1',
          title: 'Power of Prayer in the Morning',
          thumbnailUrl: _shortThumbA,
          viewCount: 12400,
        ),
        ProfileShortClip(
          id: 'clip-2',
          title: 'Morning Glory Clip: Worship',
          thumbnailUrl: _shortThumbB,
          viewCount: 8100,
        ),
        ProfileShortClip(
          id: 'clip-3',
          title: 'Faith Over Fear',
          thumbnailUrl: _shortThumbC,
          viewCount: 24500,
        ),
        ProfileShortClip(
          id: 'clip-4',
          title: 'Community Outreach Wrap',
          thumbnailUrl: _shortThumbD,
          viewCount: 5200,
        ),
        ProfileShortClip(
          id: 'clip-5',
          title: 'Sunday Service Clip',
          thumbnailUrl: _shortThumbE,
          viewCount: 18600,
        ),
        ProfileShortClip(
          id: 'clip-6',
          title: 'Youth Bible Study',
          thumbnailUrl: _shortThumbF,
          viewCount: 3100,
        ),
      ],
    );
  }

  static GiftSummary giftSummary(GiftPeriod period) {
    final now = DateTime.now();
    final transactions = [
      GiftTransaction(
        id: 'gt1',
        donorName: 'Solomon K.',
        donorInitials: 'SK',
        fundName: 'Building Fund',
        createdAt: now.subtract(const Duration(hours: 2)),
        amount: 100,
      ),
      GiftTransaction(
        id: 'gt2',
        donorName: 'Hanna M.',
        donorInitials: 'HM',
        fundName: 'Youth Outreach',
        createdAt: now.subtract(const Duration(hours: 5)),
        amount: 250,
      ),
      GiftTransaction(
        id: 'gt3',
        donorName: 'Daniel T.',
        donorInitials: 'DT',
        fundName: 'Missions',
        createdAt: now.subtract(const Duration(days: 1)),
        amount: 500,
      ),
    ];

    switch (period) {
      case GiftPeriod.week:
        return GiftSummary(
          period: period,
          totalAmount: 980,
          growthPercent: 5,
          periodRangeLabel: 'This week',
          trendPoints: const [
            GrowthTrendPoint(label: 'MON', value: 120),
            GrowthTrendPoint(label: 'TUE', value: 180),
            GrowthTrendPoint(label: 'WED', value: 150),
            GrowthTrendPoint(label: 'THU', value: 220),
            GrowthTrendPoint(label: 'FRI', value: 310),
          ],
          recentTransactions: transactions,
        );
      case GiftPeriod.year:
        return GiftSummary(
          period: period,
          totalAmount: 48200,
          growthPercent: 18,
          periodRangeLabel: 'Jan 1 – Dec 31',
          trendPoints: const [
            GrowthTrendPoint(label: 'Q1', value: 9200),
            GrowthTrendPoint(label: 'Q2', value: 11800),
            GrowthTrendPoint(label: 'Q3', value: 12400),
            GrowthTrendPoint(label: 'Q4', value: 14800),
          ],
          recentTransactions: transactions,
        );
      case GiftPeriod.all:
        return GiftSummary(
          period: period,
          totalAmount: 128400,
          growthPercent: 24,
          periodRangeLabel: 'All time',
          trendPoints: const [
            GrowthTrendPoint(label: '2022', value: 28000),
            GrowthTrendPoint(label: '2023', value: 42000),
            GrowthTrendPoint(label: '2024', value: 58400),
          ],
          recentTransactions: transactions,
        );
      case GiftPeriod.month:
        return GiftSummary(
          period: period,
          totalAmount: 4150,
          growthPercent: 12,
          periodRangeLabel: 'May 1 – May 31',
          trendPoints: const [
            GrowthTrendPoint(label: 'WEEK 1', value: 820),
            GrowthTrendPoint(label: 'WEEK 2', value: 1100),
            GrowthTrendPoint(label: 'WEEK 3', value: 980),
            GrowthTrendPoint(label: 'WEEK 4', value: 1250),
          ],
          recentTransactions: transactions,
        );
    }
  }

  static SubscribersSummary subscribersSummary(GiftPeriod period) {
    final gift = giftSummary(period);
    final now = DateTime.now();

    return SubscribersSummary(
      period: period,
      totalNetwork: switch (period) {
        GiftPeriod.week => 1180,
        GiftPeriod.month => 1240,
        GiftPeriod.year => 12400,
        GiftPeriod.all => 48200,
      },
      previousPeriodTotal: switch (period) {
        GiftPeriod.week => 1090,
        GiftPeriod.month => 1104,
        GiftPeriod.year => 10800,
        GiftPeriod.all => 42000,
      },
      growthPercent: switch (period) {
        GiftPeriod.week => 8.2,
        GiftPeriod.month => 12.4,
        GiftPeriod.year => 14.8,
        GiftPeriod.all => 22.0,
      },
      periodRangeLabel: gift.periodRangeLabel,
      trendPoints: gift.trendPoints,
      newMembers: [
        NewMember(
          id: 'nm1',
          name: 'Abebe Balcha',
          avatarUrl: _ownerAvatar,
          joinedAt: now.subtract(const Duration(hours: 2)),
        ),
        NewMember(
          id: 'nm2',
          name: 'Selamawit T.',
          avatarUrl:
              'https://images.unsplash.com/photo-1494790108377-be9c29b29330?w=200',
          joinedAt: now.subtract(const Duration(hours: 6)),
        ),
      ],
    );
  }

  static LiveViewersSummary liveViewersSummary(LiveViewersRange range) {
    final points = switch (range) {
      LiveViewersRange.oneHour => const [
        GrowthTrendPoint(label: '0m', value: 120),
        GrowthTrendPoint(label: '15m', value: 280),
        GrowthTrendPoint(label: '30m', value: 350),
        GrowthTrendPoint(label: '45m', value: 420),
        GrowthTrendPoint(label: '60m', value: 489),
      ],
      LiveViewersRange.sixHours => const [
        GrowthTrendPoint(label: '00:00', value: 80),
        GrowthTrendPoint(label: '01:30', value: 210),
        GrowthTrendPoint(label: '03:00', value: 340),
        GrowthTrendPoint(label: '04:30', value: 410),
        GrowthTrendPoint(label: '06:00', value: 489),
      ],
      LiveViewersRange.twelveHours => const [
        GrowthTrendPoint(label: '00:00', value: 95),
        GrowthTrendPoint(label: '03:00', value: 180),
        GrowthTrendPoint(label: '06:00', value: 320),
        GrowthTrendPoint(label: '09:00', value: 400),
        GrowthTrendPoint(label: '12:00', value: 465),
      ],
      LiveViewersRange.twentyFourHours => const [
        GrowthTrendPoint(label: '00:00', value: 62),
        GrowthTrendPoint(label: '06:00', value: 185),
        GrowthTrendPoint(label: '12:00', value: 360),
        GrowthTrendPoint(label: '18:00', value: 430),
        GrowthTrendPoint(label: '23:59', value: 489),
      ],
    };

    return LiveViewersSummary(
      range: range,
      peakViewers: 489,
      previousPeakViewers: 414,
      growthPercent: 18,
      chartSubtitle: 'Aggregated data for Ethiopia (GMT+3)',
      activityPoints: points,
      averageRetention: '12m 45s',
    );
  }
}
