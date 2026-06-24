import 'package:dartz/dartz.dart';
import 'package:faithconnect/core/error/failures.dart';
import 'package:faithconnect/features/profile/domain/entities/gift_period.dart';
import 'package:faithconnect/features/profile/domain/entities/gift_summary.dart';
import 'package:faithconnect/features/profile/domain/entities/live_viewers_range.dart';
import 'package:faithconnect/features/profile/domain/entities/live_viewers_summary.dart';
import 'package:faithconnect/features/profile/domain/entities/account_profile_content.dart';
import 'package:faithconnect/features/profile/domain/entities/organization_profile.dart';
import 'package:faithconnect/features/profile/domain/entities/subscribers_summary.dart';

abstract class ProfileRepository {
  Future<Either<Failure, OrganizationProfile>> getOrganizationProfile();

  Future<Either<Failure, AccountProfileContent>> getAccountProfileContent({
    required bool churchMode,
  });

  Future<Either<Failure, GiftSummary>> getGiftSummary(GiftPeriod period);

  Future<Either<Failure, SubscribersSummary>> getSubscribersSummary(
    GiftPeriod period,
  );

  Future<Either<Failure, LiveViewersSummary>> getLiveViewersSummary(
    LiveViewersRange range,
  );
}
