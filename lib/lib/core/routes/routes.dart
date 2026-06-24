import 'package:faithconnect/features/church/presentation/pages/church_moderators_page.dart';
import 'package:faithconnect/features/profile/presentation/bloc/account_profile_bloc.dart';
import 'package:faithconnect/features/profile/presentation/bloc/account_profile_event.dart';
import 'package:faithconnect/features/profile/presentation/bloc/live_viewers_bloc.dart';
import 'package:faithconnect/features/profile/presentation/bloc/monthly_gifts_bloc.dart';
import 'package:faithconnect/features/profile/presentation/bloc/subscribers_bloc.dart';
import 'package:faithconnect/features/profile/presentation/pages/account_profile_page.dart';
import 'package:faithconnect/features/profile/presentation/pages/account_settings_page.dart';
import 'package:faithconnect/features/profile/presentation/pages/analytics.dart';
import 'package:faithconnect/features/profile/presentation/pages/edit_profile_page.dart';
import 'package:faithconnect/features/profile/presentation/pages/live_viewers_page.dart';
import 'package:faithconnect/features/profile/presentation/pages/monthly_gifts_page.dart';
import 'package:faithconnect/features/profile/presentation/pages/subscribers_page.dart';
import 'package:faithconnect/features/campaign/presentation/bloc/campaign_detail_bloc.dart';
import 'package:faithconnect/features/campaign/presentation/bloc/campaigns_hub_bloc.dart';
import 'package:faithconnect/features/campaign/presentation/bloc/new_campaign_bloc.dart';
import 'package:faithconnect/features/campaign/presentation/pages/campaign_detail_page.dart';
import 'package:faithconnect/features/campaign/presentation/pages/campaigns_hub_page.dart';
import 'package:faithconnect/features/campaign/presentation/pages/new_campaign_page.dart';
import 'package:faithconnect/features/discovery/presentation/pages/discovery_page.dart';
import 'package:faithconnect/features/discovery/presentation/pages/nearby_churches_page.dart';
import 'package:faithconnect/features/notifications/presentation/bloc/notifications_bloc.dart';
import 'package:faithconnect/features/notifications/presentation/pages/notifications_page.dart';
import 'package:faithconnect/features/event/presentation/pages/events_page.dart';
import 'package:faithconnect/features/wallet/presentation/pages/wallet_page.dart';
import 'package:faithconnect/features/campaign/presentation/pages/edit_campaign_page.dart';
import 'package:faithconnect/features/event/presentation/pages/edit_event_page.dart';
import 'package:faithconnect/features/post/presentation/pages/edit_post_page.dart';
import 'package:faithconnect/features/home/domain/entities/post.dart';
import 'package:faithconnect/features/campaign/domain/entities/campaign.dart';
import 'package:faithconnect/features/event/domain/entities/church_event.dart';
import 'package:faithconnect/features/church/domain/entities/church_profile.dart';

import 'package:faithconnect/core/layout/app_shell_layout.dart';
import 'package:faithconnect/core/widgets/church_content_guard.dart';

import 'package:faithconnect/core/routes/routes_constant.dart';

import 'package:faithconnect/features/splash/presentation/pages/splash_page.dart';

import 'package:faithconnect/features/onboarding/presentation/pages/onboarding_page.dart';

import 'package:faithconnect/features/auth/presentation/pages/login_page.dart';

import 'package:faithconnect/features/auth/presentation/pages/language_page.dart';
import 'package:faithconnect/features/auth/presentation/pages/forgot_password_page.dart';
import 'package:faithconnect/features/auth/presentation/blocs/forgot_password_bloc.dart';
import 'package:faithconnect/features/auth/presentation/pages/sign_up_page.dart';

import 'package:faithconnect/features/chat/presentation/blocs/new_group_bloc.dart';
import 'package:faithconnect/features/chat/domain/entities/chat_room_type.dart';
import 'package:faithconnect/features/chat/presentation/pages/chat_add_user_page.dart';
import 'package:faithconnect/features/chat/presentation/pages/chat_detail_page.dart';
import 'package:faithconnect/features/chat/presentation/pages/chat_list_page.dart';
import 'package:faithconnect/features/chat/presentation/pages/new_group_page.dart';

import 'package:faithconnect/features/church/application/church_service.dart';
import 'package:faithconnect/features/church/presentation/bloc/church_bloc.dart';
import 'package:faithconnect/features/church/presentation/pages/church_profile_page.dart';
import 'package:faithconnect/features/church/presentation/pages/edit_church_profile_page.dart';
import 'package:faithconnect/features/church/presentation/pages/following_page.dart';
import 'package:faithconnect/features/home/gift/domain/entities/gift_item.dart';
import 'package:faithconnect/features/home/gift/presentation/bloc/gift_bloc.dart';
import 'package:faithconnect/features/home/gift/presentation/pages/gift_page.dart';
import 'package:faithconnect/features/home/gift/presentation/pages/gift_church_search_page.dart';
import 'package:faithconnect/features/home/presentation/pages/home_page.dart';
import 'package:faithconnect/features/post/presentation/bloc/post_compose_bloc.dart';
import 'package:faithconnect/features/post/presentation/pages/new_post_page.dart';
import 'package:faithconnect/features/scripture/presentation/bloc/new_post_bloc.dart';
import 'package:faithconnect/features/scripture/presentation/pages/new_post_page.dart';
import 'package:faithconnect/features/comment/application/comments_service.dart';
import 'package:faithconnect/features/post/application/post_service.dart';
import 'package:faithconnect/features/post/presentation/bloc/post_detail_bloc.dart';
import 'package:faithconnect/features/post/presentation/pages/post_detail_page.dart';
import 'package:faithconnect/injection.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:faithconnect/features/live_streaming/presentation/pages/go_live_page.dart';

import 'package:faithconnect/features/live_streaming/presentation/pages/live_stream_watch_page.dart';
import 'package:faithconnect/features/live_streaming/presentation/pages/live_streams_page.dart';
import 'package:faithconnect/features/live_streaming/presentation/blocs/live_stream_bloc.dart';

import 'package:faithconnect/features/shortvideo/application/short_video_service.dart';
import 'package:faithconnect/features/shortvideo/presentation/bloc/shorts_feed_bloc.dart';
import 'package:faithconnect/features/shortvideo/presentation/pages/shorts_page.dart';

import 'package:flutter/material.dart';

import 'package:go_router/go_router.dart';



final GlobalKey<NavigatorState> rootNavigatorKey = GlobalKey<NavigatorState>(

  debugLabel: 'root',

);

CustomTransitionPage<void> _campaignFadePage({
  required GoRouterState state,
  required Widget child,
}) {
  return CustomTransitionPage<void>(
    key: state.pageKey,
    child: child,
    transitionDuration: const Duration(milliseconds: 280),
    reverseTransitionDuration: const Duration(milliseconds: 240),
    transitionsBuilder: (context, animation, secondaryAnimation, pageChild) {
      return FadeTransition(
        opacity: CurvedAnimation(parent: animation, curve: Curves.easeOut),
        child: pageChild,
      );
    },
  );
}



GoRouter createRouter() => GoRouter(

      navigatorKey: rootNavigatorKey,

      initialLocation: RoutesConstant.splash,

      routes: [

        GoRoute(

          path: RoutesConstant.splash,

          name: RoutesConstant.splash,

          builder: (context, state) => const SplashPage(),

        ),

        GoRoute(

          path: RoutesConstant.onboarding,

          name: RoutesConstant.onboarding,

          builder: (context, state) => const OnboardingPage(),

        ),

        GoRoute(

          path: RoutesConstant.login,

          name: RoutesConstant.login,

          builder: (context, state) => const LoginPage(),

        ),

        GoRoute(

          path: RoutesConstant.signUp,

          name: RoutesConstant.signUp,

          builder: (context, state) => const SignUpPage(),

        ),

        GoRoute(

          path: RoutesConstant.forgotPassword,

          name: RoutesConstant.forgotPassword,

          builder: (context, state) => BlocProvider(

            create: (_) => sl<ForgotPasswordBloc>(),

            child: const ForgotPasswordPage(),

          ),

        ),

        GoRoute(

          path: RoutesConstant.language,

          name: RoutesConstant.language,

          parentNavigatorKey: rootNavigatorKey,

          builder: (context, state) => const LanguagePage(),

        ),
        GoRoute(
          path: RoutesConstant.wallet,
          name: RoutesConstant.wallet,
          parentNavigatorKey: rootNavigatorKey,
          builder: (context, state) => const WalletPage(),
        ),

        StatefulShellRoute.indexedStack(

          builder: (context, state, navigationShell) {

            return AppShellLayout(
              navigationShell: navigationShell,
            );

          },

          branches: [

            StatefulShellBranch(

              routes: [

                GoRoute(

                  path: RoutesConstant.home,

                  name: RoutesConstant.home,

                  builder: (context, state) => const HomePage(),

                ),

              ],

            ),

            StatefulShellBranch(

              routes: [

                GoRoute(

                  path: RoutesConstant.chatList,

                  name: RoutesConstant.chatList,

                  builder: (context, state) {
                    final tab = state.uri.queryParameters['tab'];
                    final initialTab = tab == 'groups'
                        ? ChatRoomType.group
                        : ChatRoomType.direct;
                    return ChatListPage(initialInboxTab: initialTab);
                  },

                ),

              ],

            ),

            StatefulShellBranch(

              routes: [

                GoRoute(

                  path: RoutesConstant.shorts,

                  name: RoutesConstant.shorts,

                  builder: (context, state) => BlocProvider(
                    create: (_) => ShortsFeedBloc(
                      shortVideoService: sl<ShortVideoService>(),
                      churchService: sl<ChurchService>(),
                    ),
                    child: const ShortsPage(),
                  ),

                ),

              ],

            ),

            StatefulShellBranch(

              routes: [

                GoRoute(

                  path: RoutesConstant.account,

                  name: RoutesConstant.account,

                  builder: (context, state) => BlocProvider(
                    create: (_) => sl<AccountProfileBloc>(),
                    child: const AccountProfilePage(),
                  ),

                  routes: [
                    GoRoute(
                      path: 'settings',
                      name: RoutesConstant.accountSettings,
                      parentNavigatorKey: rootNavigatorKey,
                      builder: (context, state) => BlocProvider(
                        create: (_) => sl<AccountProfileBloc>()
                          ..add(const AccountProfileRequested()),
                        child: const AccountSettingsPage(),
                      ),
                    ),
                    GoRoute(
                      path: 'analytics',
                      name: RoutesConstant.analytics,
                      parentNavigatorKey: rootNavigatorKey,
                      builder: (context, state) => BlocProvider(
                        create: (_) => sl<AccountProfileBloc>()
                          ..add(const AccountProfileRequested()),
                        child: const Analytics(),
                      ),
                    ),
                    GoRoute(
                      path: 'edit-profile',
                      name: RoutesConstant.editProfile,
                      parentNavigatorKey: rootNavigatorKey,
                      builder: (context, state) => const EditProfilePage(),
                    ),
                  ],

                ),

              ],

            ),

          ],

        ),

        GoRoute(
          path: RoutesConstant.gift,
          name: RoutesConstant.gift,
          parentNavigatorKey: rootNavigatorKey,
          builder: (context, state) => BlocProvider(
            create: (_) => sl<GiftBloc>(),
            child: const GiftPage(),
          ),
        ),
        GoRoute(
          path: RoutesConstant.giftChurchSearch,
          name: RoutesConstant.giftChurchSearch,
          parentNavigatorKey: rootNavigatorKey,
          builder: (context, state) {
            final gift = state.extra as GiftItem;
            return GiftChurchSearchPage(gift: gift);
          },
        ),

        GoRoute(
          path: RoutesConstant.monthlyGifts,
          name: RoutesConstant.monthlyGifts,
          parentNavigatorKey: rootNavigatorKey,
          builder: (context, state) => BlocProvider(
            create: (_) => sl<MonthlyGiftsBloc>(),
            child: const MonthlyGiftsPage(),
          ),
        ),

        GoRoute(
          path: RoutesConstant.subscribers,
          name: RoutesConstant.subscribers,
          parentNavigatorKey: rootNavigatorKey,
          builder: (context, state) => BlocProvider(
            create: (_) => sl<SubscribersBloc>(),
            child: const SubscribersPage(),
          ),
        ),

        GoRoute(
          path: RoutesConstant.following,
          name: RoutesConstant.following,
          parentNavigatorKey: rootNavigatorKey,
          builder: (context, state) => const FollowingPage(),
        ),

        GoRoute(
          path: RoutesConstant.churchModerators,
          name: RoutesConstant.churchModerators,
          parentNavigatorKey: rootNavigatorKey,
          builder: (context, state) => const ChurchModeratorsPage(),
        ),

        GoRoute(
          path: RoutesConstant.liveViewers,
          name: RoutesConstant.liveViewers,
          parentNavigatorKey: rootNavigatorKey,
          builder: (context, state) => BlocProvider(
            create: (_) => sl<LiveViewersBloc>(),
            child: const LiveViewersPage(),
          ),
        ),

        GoRoute(
          path: RoutesConstant.newGroup,
          name: RoutesConstant.newGroup,
          parentNavigatorKey: rootNavigatorKey,
          builder: (context, state) => ChurchContentGuard(
            child: BlocProvider(
              create: (_) => sl<NewGroupBloc>(),
              child: const NewGroupPage(),
            ),
          ),
        ),
        GoRoute(
          path: RoutesConstant.chatAddUser,
          name: RoutesConstant.chatAddUser,
          parentNavigatorKey: rootNavigatorKey,
          builder: (context, state) => const ChatAddUserPage(),
        ),
        GoRoute(
          path: RoutesConstant.chatDetail,
          name: RoutesConstant.chatDetail,
          parentNavigatorKey: rootNavigatorKey,
          builder: (context, state) {
            final roomId = state.pathParameters['id'] ?? '';
            final roomType =
                state.extra is ChatRoomType ? state.extra as ChatRoomType : null;
            return ChatDetailPage(roomId: roomId, roomType: roomType);
          },
        ),
        GoRoute(
          path: RoutesConstant.newPost,
          name: RoutesConstant.newPost,
          parentNavigatorKey: rootNavigatorKey,
          builder: (context, state) => ChurchContentGuard(
            child: BlocProvider(
              create: (_) => sl<PostComposeBloc>(),
              child: const NewPostPage(),
            ),
          ),
        ),
        GoRoute(
          path: RoutesConstant.scriptureNewPost,
          name: RoutesConstant.scriptureNewPost,
          parentNavigatorKey: rootNavigatorKey,
          builder: (context, state) => BlocProvider(
            create: (_) => sl<NewPostBloc>(),
            child: const ScriptureNewPostPage(),
          ),
        ),
        GoRoute(
          path: RoutesConstant.postDetail,
          name: RoutesConstant.postDetail,
          parentNavigatorKey: rootNavigatorKey,
          builder: (context, state) {
            final postId = state.pathParameters['id'] ?? '';
            final autofocusComment =
                state.uri.queryParameters['focus'] == 'comment';
            return BlocProvider(
              create: (_) => PostDetailBloc(
                postService: sl<PostService>(),
                commentsService: sl<CommentsService>(),
                churchService: sl<ChurchService>(),
                postId: postId,
              ),
              child: PostDetailPage(
                postId: postId,
                autofocusComment: autofocusComment,
              ),
            );
          },
        ),
        GoRoute(
          path: RoutesConstant.editPost,
          name: RoutesConstant.editPost,
          parentNavigatorKey: rootNavigatorKey,
          builder: (context, state) {
            final post = state.extra as Post;
            return ChurchContentGuard(
              child: EditPostPage(post: post),
            );
          },
        ),
          GoRoute(
            path: RoutesConstant.churchProfile,
            name: RoutesConstant.churchProfile,
            parentNavigatorKey: rootNavigatorKey,
            builder: (context, state) {
              final profileId = state.pathParameters['id'] ?? '';
              final extraMap = state.extra as Map<String, dynamic>?;
              final pendingGift = extraMap?['pendingGift'] as GiftItem?;

              return BlocProvider<ChurchBloc>(
                create: (_) => sl<ChurchBloc>(param1: profileId),
                child: ChurchProfilePage(
                  profileId: profileId,
                  pendingGift: pendingGift,
                ),
              );
            },
          ),
        GoRoute(
          path: RoutesConstant.editChurchProfile,
          name: RoutesConstant.editChurchProfile,
          parentNavigatorKey: rootNavigatorKey,
          builder: (context, state) {
            final profile = state.extra;
            return ChurchContentGuard(
              child: EditChurchProfilePage(
                churchId: state.pathParameters['id'] ?? '',
                profile: profile is ChurchProfile ? profile : null,
              ),
            );
          },
        ),
        GoRoute(
          path: RoutesConstant.campaigns,
          name: RoutesConstant.campaigns,
          parentNavigatorKey: rootNavigatorKey,
          pageBuilder: (context, state) {
            final openCreate = state.uri.queryParameters['create'] == '1';
            return _campaignFadePage(
              state: state,
              child: BlocProvider(
                create: (_) => sl<CampaignsHubBloc>(),
                child: CampaignsHubPage(openCreateOnLoad: openCreate),
              ),
            );
          },
        ),
        GoRoute(
          path: RoutesConstant.newCampaign,
          name: RoutesConstant.newCampaign,
          parentNavigatorKey: rootNavigatorKey,
          pageBuilder: (context, state) => _campaignFadePage(
            state: state,
            child: ChurchContentGuard(
              child: BlocProvider(
                create: (_) => sl<NewCampaignBloc>(),
                child: const NewCampaignPage(),
              ),
            ),
          ),
        ),
        GoRoute(
          path: RoutesConstant.campaignDetail,
          name: RoutesConstant.campaignDetail,
          parentNavigatorKey: rootNavigatorKey,
          pageBuilder: (context, state) {
            final campaignId = state.pathParameters['id'] ?? '';
            final autoDonate = state.uri.queryParameters['donate'] == '1';
            return _campaignFadePage(
              state: state,
              child: BlocProvider(
                create: (_) => sl<CampaignDetailBloc>(param1: campaignId),
                child: CampaignDetailPage(
                  campaignId: campaignId,
                  autoOpenDonate: autoDonate,
                ),
              ),
            );
          },
        ),
        GoRoute(
          path: RoutesConstant.editCampaign,
          name: RoutesConstant.editCampaign,
          parentNavigatorKey: rootNavigatorKey,
          pageBuilder: (context, state) {
            final campaign = state.extra as Campaign;
            return _campaignFadePage(
              state: state,
              child: ChurchContentGuard(
                child: EditCampaignPage(campaign: campaign),
              ),
            );
          },
        ),

        GoRoute(
          path: RoutesConstant.notifications,
          name: RoutesConstant.notifications,
          parentNavigatorKey: rootNavigatorKey,
          pageBuilder: (context, state) => _campaignFadePage(
            state: state,
            child: const NotificationsPage(),
          ),
        ),
        GoRoute(
          path: RoutesConstant.discovery,
          name: RoutesConstant.discovery,
          parentNavigatorKey: rootNavigatorKey,
          pageBuilder: (context, state) => _campaignFadePage(
            state: state,
            child: const DiscoveryPage(),
          ),
        ),
        GoRoute(
          path: RoutesConstant.discoveryNearby,
          name: RoutesConstant.discoveryNearby,
          parentNavigatorKey: rootNavigatorKey,
          pageBuilder: (context, state) => _campaignFadePage(
            state: state,
            child: const NearbyChurchesPage(),
          ),
        ),
        GoRoute(
          path: RoutesConstant.events,
          name: RoutesConstant.events,
          parentNavigatorKey: rootNavigatorKey,
          pageBuilder: (context, state) => _campaignFadePage(
            state: state,
            child: const EventsPage(),
          ),
        ),
        GoRoute(
          path: RoutesConstant.editEvent,
          name: RoutesConstant.editEvent,
          parentNavigatorKey: rootNavigatorKey,
          pageBuilder: (context, state) {
            final event = state.extra as ChurchEvent;
            return _campaignFadePage(
              state: state,
              child: ChurchContentGuard(
                child: EditEventPage(event: event),
              ),
            );
          },
        ),
          GoRoute(
            path: RoutesConstant.liveStreams,
            name: RoutesConstant.liveStreams,
            parentNavigatorKey: rootNavigatorKey,
            pageBuilder: (context, state) => _campaignFadePage(
              state: state,
              child: BlocProvider(
                create: (_) => sl<LiveStreamBloc>(),
                child: const LiveStreamsPage(),
              ),
            ),
          ),
        GoRoute(
          path: RoutesConstant.goLive,
          name: RoutesConstant.goLive,
          parentNavigatorKey: rootNavigatorKey,
          pageBuilder: (context, state) => _campaignFadePage(
            state: state,
            child: ChurchContentGuard(child: const GoLivePage()),
          ),
        ),

        GoRoute(
          path: RoutesConstant.liveStreamDetail,
          name: RoutesConstant.liveStreamDetail,
          parentNavigatorKey: rootNavigatorKey,
          builder: (context, state) {
            final streamId = state.pathParameters['id'] ?? '';
            return BlocProvider(
              create: (_) => sl<LiveStreamBloc>(),
              child: LiveStreamWatchPage(streamId: streamId),
            );
          },
        ),

      ],

    );
