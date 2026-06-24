import 'package:equatable/equatable.dart';
import 'package:faithconnect/features/home/domain/entities/post.dart';
import 'package:faithconnect/features/profile/domain/entities/organization_profile.dart';

import 'package:faithconnect/features/campaign/domain/entities/campaign.dart';
import 'package:faithconnect/features/event/domain/entities/church_event.dart';

class AccountProfileContent extends Equatable {
  final List<Post> posts;
  final List<Post> videos;
  final List<ProfileShortClip> shorts;
  final List<Campaign> campaigns;
  final List<ChurchEvent> events;

  const AccountProfileContent({
    this.posts = const [],
    this.videos = const [],
    this.shorts = const [],
    this.campaigns = const [],
    this.events = const [],
  });

  factory AccountProfileContent.fromPosts(
    List<Post> all, {
    List<ProfileShortClip> shorts = const [],
    List<Campaign> campaigns = const [],
    List<ChurchEvent> events = const [],
  }) {
    final videos =
        all.where((post) => post.mediaType == PostMediaType.video).toList();
    final posts =
        all.where((post) => post.mediaType != PostMediaType.video).toList();

    return AccountProfileContent(
      posts: posts,
      videos: videos,
      shorts: shorts,
      campaigns: campaigns,
      events: events,
    );
  }

  bool get isEmpty =>
      posts.isEmpty &&
      videos.isEmpty &&
      shorts.isEmpty &&
      campaigns.isEmpty &&
      events.isEmpty;

  AccountProfileContent withoutPost(String postId) {
    return AccountProfileContent(
      posts: posts.where((post) => post.id != postId).toList(),
      videos: videos.where((post) => post.id != postId).toList(),
      shorts: shorts,
      campaigns: campaigns,
      events: events,
    );
  }

  AccountProfileContent withUpdatedPost(Post updated) {
    List<Post> replaceIn(List<Post> source) {
      return source
          .map((post) => post.id == updated.id ? updated : post)
          .toList();
    }

    return AccountProfileContent(
      posts: replaceIn(posts),
      videos: replaceIn(videos),
      shorts: shorts,
      campaigns: campaigns,
      events: events,
    );
  }

  AccountProfileContent withoutShort(String shortId) {
    return AccountProfileContent(
      posts: posts,
      videos: videos,
      shorts: shorts.where((short) => short.id != shortId).toList(),
      campaigns: campaigns,
      events: events,
    );
  }

  AccountProfileContent withUpdatedShort(ProfileShortClip updated) {
    return AccountProfileContent(
      posts: posts,
      videos: videos,
      shorts: shorts
          .map((short) => short.id == updated.id ? updated : short)
          .toList(),
      campaigns: campaigns,
      events: events,
    );
  }

  AccountProfileContent withoutCampaign(String id) {
    return AccountProfileContent(
      posts: posts,
      videos: videos,
      shorts: shorts,
      campaigns: campaigns.where((c) => c.id != id).toList(),
      events: events,
    );
  }

  AccountProfileContent withUpdatedCampaign(String id, String newTitle) {
    return AccountProfileContent(
      posts: posts,
      videos: videos,
      shorts: shorts,
      campaigns: campaigns.map((c) {
        if (c.id != id) return c;
        return c.copyWith(title: newTitle);
      }).toList(),
      events: events,
    );
  }

  AccountProfileContent withoutEvent(String id) {
    return AccountProfileContent(
      posts: posts,
      videos: videos,
      shorts: shorts,
      campaigns: campaigns,
      events: events.where((e) => e.id != id).toList(),
    );
  }

  AccountProfileContent withUpdatedEvent(String id, String newTitle) {
    return AccountProfileContent(
      posts: posts,
      videos: videos,
      shorts: shorts,
      campaigns: campaigns,
      events: events.map((e) {
        if (e.id != id) return e;
        return e.copyWith(title: newTitle);
      }).toList(),
    );
  }

  @override
  List<Object?> get props => [posts, videos, shorts, campaigns, events];
}
