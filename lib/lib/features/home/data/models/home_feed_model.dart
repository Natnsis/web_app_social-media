import 'package:faithconnect/features/home/domain/entities/daily_verse.dart';
import 'package:faithconnect/features/home/domain/entities/featured_event.dart';
import 'package:faithconnect/features/home/domain/entities/home_feed.dart';
import 'package:faithconnect/features/home/domain/entities/live_now_item.dart';

class HomeFeedModel extends HomeFeed {
  const HomeFeedModel({
    required super.liveNow,
    required super.dailyVerse,
    required super.dailyVerses,
    required super.posts,
    required super.featuredEvent,
  });

  HomeFeed toEntity() => HomeFeed(
        liveNow: liveNow,
        dailyVerse: dailyVerse,
        dailyVerses: dailyVerses,
        posts: posts,
        featuredEvent: featuredEvent,
      );
}

class LiveNowItemModel extends LiveNowItem {
  const LiveNowItemModel({
    required super.id,
    required super.name,
    super.avatarUrl,
    super.isLive,
    super.streamId,
  });
}

class DailyVerseModel extends DailyVerse {
  const DailyVerseModel({
    required super.quote,
    required super.reference,
    required super.subtitle,
  });
}

class FeaturedEventModel extends FeaturedEvent {
  const FeaturedEventModel({
    required super.id,
    required super.title,
    required super.description,
    required super.dateTime,
    required super.location,
    super.imageUrl,
  });
}
