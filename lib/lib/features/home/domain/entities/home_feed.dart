import 'package:equatable/equatable.dart';
import 'package:faithconnect/features/home/domain/entities/daily_verse.dart';
import 'package:faithconnect/features/home/domain/entities/featured_event.dart';
import 'package:faithconnect/features/home/domain/entities/live_now_item.dart';
import 'package:faithconnect/features/home/domain/entities/post.dart';

class HomeFeed extends Equatable {
  final List<LiveNowItem> liveNow;
  final DailyVerse dailyVerse;
  final List<DailyVerse>? dailyVerses;
  final List<Post> posts;
  final FeaturedEvent featuredEvent;

  const HomeFeed({
    required this.liveNow,
    required this.dailyVerse,
    this.dailyVerses,
    required this.posts,
    required this.featuredEvent,
  });

  /// Scrypers for the home carousel; always non-null.
  List<DailyVerse> get allDailyVerses {
    final verses = dailyVerses;
    if (verses != null && verses.isNotEmpty) return verses;
    return [dailyVerse];
  }

  @override
  List<Object?> get props =>
      [liveNow, dailyVerse, dailyVerses, posts, featuredEvent];
}
