import 'package:faithconnect/features/church/domain/entities/church_profile.dart';
import 'package:faithconnect/features/home/presentation/widgets/featured_event_card.dart';
import 'package:faithconnect/features/home/presentation/widgets/post_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

/// Posts tab body for church profile (reuses home feed post cards).
class ChurchProfilePostsContent {
  ChurchProfilePostsContent._();

  static List<Widget> buildSlivers(ChurchProfileFeed feed) {
    final slivers = <Widget>[
      SliverList(
        delegate: SliverChildBuilderDelegate(
          (context, index) => PostCard(post: feed.posts[index]),
          childCount: feed.posts.length,
        ),
      ),
    ];

    if (feed.featuredEvent != null) {
      slivers.addAll([
        SliverToBoxAdapter(child: SizedBox(height: 8.h)),
        SliverToBoxAdapter(
          child: FeaturedEventCard(event: feed.featuredEvent!),
        ),
      ]);
    }

    return slivers;
  }
}
