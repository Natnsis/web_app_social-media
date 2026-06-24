import 'package:faithconnect/features/analytics/data/repositories/analytics_repository.dart';
import 'package:faithconnect/features/analytics/data/repositories/analytics_repository_impl.dart';
import 'package:faithconnect/features/analytics/domain/usecases/get_analytics.dart';
import 'package:faithconnect/features/analytics/presentation/bloc/analytics_bloc.dart';
import 'package:faithconnect/features/auth/application/auth_service.dart';
import 'package:faithconnect/features/auth/data/datasources/auth_local_datasource.dart';
import 'package:faithconnect/features/auth/data/datasources/auth_remote_datasource.dart';
import 'package:faithconnect/features/auth/application/google_auth_service.dart';
import 'package:faithconnect/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:faithconnect/features/auth/domain/repositories/auth_repository.dart';
import 'package:faithconnect/features/auth/presentation/blocs/auth_bloc.dart';
import 'package:faithconnect/features/auth/presentation/blocs/forgot_password_bloc.dart';
import 'package:faithconnect/features/chat/application/chat_service.dart';
import 'package:faithconnect/features/chat/data/datasources/chat_remote_datasource.dart';
import 'package:faithconnect/features/chat/data/repositories/chat_repository_impl.dart';
import 'package:faithconnect/features/chat/domain/repositories/chat_repository.dart';
import 'package:faithconnect/features/chat/presentation/blocs/chat_bloc.dart';
import 'package:faithconnect/features/chat/presentation/blocs/group_governance_bloc.dart';
import 'package:faithconnect/features/chat/presentation/blocs/new_group_bloc.dart';
import 'package:faithconnect/features/church/application/church_service.dart';
import 'package:faithconnect/core/services/shared_prefs_Service.dart';
import 'package:faithconnect/core/services/socket/direct_messaging_socket_service.dart';
import 'package:faithconnect/core/services/socket/group_chat_socket_service.dart';
import 'package:faithconnect/core/services/socket/comment_socket.dart';
import 'package:faithconnect/core/services/socket/socket_services.dart';
import 'package:faithconnect/core/services/socket/user_location_socket_service.dart';
import 'package:faithconnect/core/services/user_location_sync_service.dart';
import 'package:faithconnect/features/church/data/datasources/church_remote_datasource.dart';
import 'package:faithconnect/features/church/data/repositories/church_repository_impl.dart';
import 'package:faithconnect/features/church/domain/repositories/church_repository.dart';
import 'package:faithconnect/features/church/presentation/bloc/church_bloc.dart';
import 'package:faithconnect/features/church/presentation/bloc/church_moderators_bloc.dart';
import 'package:faithconnect/features/home/application/home_service.dart';
import 'package:faithconnect/features/home/data/datasources/home_remote_datasource.dart';
import 'package:faithconnect/features/home/data/repositories/home_repository_impl.dart';
import 'package:faithconnect/features/home/domain/repositories/home_repository.dart';
import 'package:faithconnect/features/home/gift/application/gift_service.dart';
import 'package:faithconnect/features/home/gift/data/datasources/gift_remote_datasource.dart';
import 'package:faithconnect/features/home/gift/data/repositories/gift_repository_impl.dart';
import 'package:faithconnect/features/home/gift/domain/repositories/gift_repository.dart';
import 'package:faithconnect/features/home/gift/presentation/bloc/gift_bloc.dart';
import 'package:faithconnect/features/home/presentation/blocs/home_bloc.dart';
import 'package:faithconnect/features/home/presentation/blocs/home_search_bloc.dart';
import 'package:faithconnect/features/home/presentation/home_shell_mode_notifier.dart';
import 'package:faithconnect/features/live_streaming/application/live_stream_service.dart';
import 'package:faithconnect/features/live_streaming/data/datasources/live_stream_remote_datasource.dart';
import 'package:faithconnect/features/live_streaming/data/repositories/live_stream_repository_impl.dart';
import 'package:faithconnect/features/live_streaming/domain/repositories/live_stream_repository.dart';
import 'package:faithconnect/features/live_streaming/presentation/blocs/live_stream_bloc.dart';
import 'package:faithconnect/features/live_streaming/data/datasources/station_remote_datasource.dart';
import 'package:faithconnect/features/live_streaming/data/repositories/station_repository_impl.dart';
import 'package:faithconnect/features/live_streaming/domain/repositories/station_repository.dart';
import 'package:faithconnect/features/live_streaming/presentation/blocs/station_bloc.dart';
import 'package:faithconnect/features/onboarding/presentation/blocs/onboarding_bloc.dart';
import 'package:faithconnect/features/scripture/application/scripture_service.dart';
import 'package:faithconnect/features/scripture/presentation/bloc/new_post_bloc.dart';
import 'package:faithconnect/core/services/media_upload_service.dart';
import 'package:faithconnect/features/scripture/data/datasources/scripture_remote_datasource.dart';
import 'package:faithconnect/features/scripture/data/repositories/scripture_repository_impl.dart';
import 'package:faithconnect/features/scripture/domain/repositories/scripture_repository.dart';
import 'package:faithconnect/features/comment/application/comments_service.dart';
import 'package:faithconnect/features/comment/data/datasources/comments_remote_datasource.dart';
import 'package:faithconnect/features/comment/data/repositories/comments_repository_impl.dart';
import 'package:faithconnect/features/comment/domain/repositories/comments_repository.dart';
import 'package:faithconnect/features/post/application/post_compose_service.dart';
import 'package:faithconnect/features/post/application/post_service.dart';
import 'package:faithconnect/features/post/presentation/bloc/post_compose_bloc.dart';
import 'package:faithconnect/features/post/data/datasources/post_remote_datasource.dart';
import 'package:faithconnect/features/post/data/datasources/posts_remote_datasource.dart';
import 'package:faithconnect/features/post/data/repositories/post_repository_impl.dart';
import 'package:faithconnect/features/post/domain/repositories/post_repository.dart';
import 'package:faithconnect/features/shortvideo/application/short_video_service.dart';
import 'package:faithconnect/features/shortvideo/data/datasources/short_video_remote_datasource.dart';
import 'package:faithconnect/features/shortvideo/data/repositories/short_video_repository_impl.dart';
import 'package:faithconnect/features/shortvideo/domain/repositories/short_video_repository.dart';
import 'package:faithconnect/features/profile/application/profile_service.dart';
import 'package:faithconnect/features/profile/data/datasources/profile_remote_datasource.dart';
import 'package:faithconnect/features/profile/data/repositories/profile_repository_impl.dart';
import 'package:faithconnect/features/profile/domain/repositories/profile_repository.dart';
import 'package:faithconnect/features/profile/presentation/bloc/account_profile_bloc.dart';
import 'package:faithconnect/features/profile/presentation/bloc/live_viewers_bloc.dart';
import 'package:faithconnect/features/profile/presentation/bloc/monthly_gifts_bloc.dart';
import 'package:faithconnect/features/profile/presentation/bloc/subscribers_bloc.dart';
import 'package:faithconnect/features/user/application/user_service.dart';
import 'package:faithconnect/features/user/data/datasources/user_remote_datasource.dart';
import 'package:faithconnect/features/user/data/repositories/user_repository_impl.dart';
import 'package:faithconnect/features/user/domain/repositories/user_repository.dart';
import 'package:faithconnect/features/event/application/event_service.dart';
import 'package:faithconnect/features/event/data/datasources/event_remote_datasource.dart';
import 'package:faithconnect/features/event/data/repositories/event_repository_impl.dart';
import 'package:faithconnect/features/event/domain/repositories/event_repository.dart';
import 'package:faithconnect/features/event/presentation/bloc/events_feed_bloc.dart';
import 'package:faithconnect/core/services/notification_service/notification_service.dart';
import 'package:faithconnect/features/notifications/application/notifications_service.dart';
import 'package:faithconnect/features/notifications/data/datasources/notifications_remote_datasource.dart';
import 'package:faithconnect/features/notifications/data/repositories/notifications_repository_impl.dart';
import 'package:faithconnect/features/notifications/domain/repositories/notifications_repository.dart';
import 'package:faithconnect/features/notifications/presentation/bloc/notifications_bloc.dart';
import 'package:faithconnect/features/campaign/application/campaign_service.dart';
import 'package:faithconnect/features/campaign/data/datasources/campaign_remote_datasource.dart';
import 'package:faithconnect/features/campaign/data/repositories/campaign_repository_impl.dart';
import 'package:faithconnect/features/campaign/domain/repositories/campaign_repository.dart';
import 'package:faithconnect/features/campaign/presentation/bloc/campaign_detail_bloc.dart';
import 'package:faithconnect/features/campaign/presentation/bloc/campaigns_hub_bloc.dart';
import 'package:faithconnect/features/campaign/presentation/bloc/new_campaign_bloc.dart';
import 'package:faithconnect/features/discovery/application/discovery_service.dart';
import 'package:faithconnect/features/discovery/data/datasources/discovery_remote_datasource.dart';
import 'package:faithconnect/features/discovery/data/repositories/discovery_repository_impl.dart';
import 'package:faithconnect/features/discovery/domain/repositories/discovery_repository.dart';
import 'package:faithconnect/features/discovery/presentation/bloc/discovery_bloc.dart';
import 'package:faithconnect/features/discovery/presentation/bloc/nearby_bloc.dart';
import 'package:faithconnect/features/wallet/application/wallet_service.dart';
import 'package:faithconnect/features/wallet/data/datasources/wallet_remote_datasource.dart';
import 'package:faithconnect/features/wallet/data/repositories/wallet_repository_impl.dart';
import 'package:faithconnect/features/wallet/domain/repositories/wallet_repository.dart';
import 'package:faithconnect/features/wallet/presentation/bloc/wallet_bloc.dart';
import 'package:faithconnect/core/locale/locale_cubit.dart';
import 'package:faithconnect/core/network/auth_session_coordinator.dart';
import 'package:faithconnect/core/network/auth_token_refresh_service.dart';
import 'package:faithconnect/core/network/dio_client.dart';
import 'package:faithconnect/core/theme/theme_cubit.dart';
import 'package:dio/dio.dart';
import 'package:get_it/get_it.dart';

final sl = GetIt.instance;

Future<void> setupInjection() async {
  if (!sl.isRegistered<HomeShellModeNotifier>()) {
    sl.registerLazySingleton<HomeShellModeNotifier>(
      () => HomeShellModeNotifier(),
    );
  }

  if (!sl.isRegistered<ThemeCubit>()) {
    sl.registerLazySingleton<ThemeCubit>(() => ThemeCubit());
  }

  if (!sl.isRegistered<LocaleCubit>()) {
    sl.registerLazySingleton<LocaleCubit>(() => LocaleCubit());
  }

  if (!sl.isRegistered<AuthSessionCoordinator>()) {
    sl.registerLazySingleton<AuthSessionCoordinator>(
      () => AuthSessionCoordinator(),
    );
  }

  if (!sl.isRegistered<AuthTokenRefreshService>()) {
    sl.registerLazySingleton<AuthTokenRefreshService>(
      () => AuthTokenRefreshService(),
    );
  }

  if (!sl.isRegistered<Dio>()) {
    sl.registerLazySingleton<Dio>(
      () => DioClient.create(
        tokenRefresh: sl<AuthTokenRefreshService>(),
        sessionCoordinator: sl<AuthSessionCoordinator>(),
      ),
    );
  }

  if (!sl.isRegistered<SocketService>()) {
    sl.registerLazySingleton<SocketService>(
      () => SocketServiceImpl(sessionCoordinator: sl<AuthSessionCoordinator>()),
    );
  }

  if (!sl.isRegistered<DirectMessagingSocketService>()) {
    sl.registerLazySingleton<DirectMessagingSocketService>(
      () =>
          DirectMessagingSocketServiceImpl(socketService: sl<SocketService>()),
    );
  }

  if (!sl.isRegistered<GroupChatSocketService>()) {
    sl.registerLazySingleton<GroupChatSocketService>(
      () => GroupChatSocketServiceImpl(socketService: sl<SocketService>()),
    );
  }

  // Auth — real API via [EnvConfig.apiBaseUrl].
  sl.registerLazySingleton<GoogleAuthService>(
    () => GoogleAuthService(remoteDataSource: sl<AuthRemoteDataSource>()),
  );
  sl.registerLazySingleton<AuthRemoteDataSource>(
    () => AuthRemoteDataSourceImpl(dio: sl()),
  );
  sl.registerLazySingleton<AuthLocalDataSource>(
    () => AuthLocalDataSourceImpl(),
  );
  sl.registerLazySingleton<AuthRepository>(
    () => AuthRepositoryImpl(
      remoteDataSource: sl(),
      localDataSource: sl(),
      tokenRefresh: sl<AuthTokenRefreshService>(),
      googleAuthService: sl<GoogleAuthService>(),
    ),
  );
  sl.registerLazySingleton<AuthService>(() => AuthService(sl()));
  sl.registerFactory<AuthBloc>(() => AuthBloc(authService: sl()));
  sl.registerFactory<ForgotPasswordBloc>(
    () => ForgotPasswordBloc(authService: sl()),
  );

  // Posts list (`GET /v1/posts`)
  sl.registerLazySingleton<PostsRemoteDataSource>(
    () => PostsRemoteDataSourceImpl(dio: sl()),
  );

  // Home
  sl.registerLazySingleton<HomeRemoteDataSource>(
    () => HomeRemoteDataSourceImpl(
      dio: sl(),
      postsRemote: sl<PostsRemoteDataSource>(),
      scriptureRemote: sl<ScriptureRemoteDataSource>(),
    ),
  );
  sl.registerLazySingleton<HomeRepository>(
    () => HomeRepositoryImpl(remoteDataSource: sl()),
  );
  sl.registerLazySingleton<HomeService>(() => HomeService(sl()));
  sl.registerFactory<HomeBloc>(() => HomeBloc(homeService: sl()));
  sl.registerFactory<HomeSearchBloc>(
    () => HomeSearchBloc(
      postsRemoteDataSource: sl(),
      eventService: sl(),
    ),
  );

  // Gift (home community flow)
  sl.registerLazySingleton<GiftRemoteDataSource>(
    () => GiftRemoteDataSourceImpl(sl()),
  );
  sl.registerLazySingleton<GiftRepository>(
    () => GiftRepositoryImpl(remoteDataSource: sl()),
  );
  sl.registerLazySingleton<GiftService>(() => GiftService(sl()));
  sl.registerFactory<GiftBloc>(() => GiftBloc(giftService: sl()));

  // User
  sl.registerLazySingleton<UserRemoteDataSource>(
    () => UserRemoteDataSourceImpl(dio: sl()),
  );
  sl.registerLazySingleton<UserRepository>(
    () => UserRepositoryImpl(remoteDataSource: sl()),
  );
  sl.registerLazySingleton<UserService>(() => UserService(sl()));

  // Church
  sl.registerLazySingleton<UserLocationSyncService>(
    () => UserLocationSyncService(dio: sl()),
  );
  sl.registerLazySingleton<ChurchRemoteDataSource>(
    () => ChurchRemoteDataSourceImpl(
      dio: sl(),
      locationSync: sl<UserLocationSyncService>(),
    ),
  );
  sl.registerLazySingleton<UserLocationSocketService>(
    () => UserLocationSocketService(socketService: sl()),
  );
  sl.registerLazySingleton<CommentSocketService>(
    () => CommentSocketService(sl()),
  );

  sl.registerLazySingleton<ChurchRepository>(
    () => ChurchRepositoryImpl(remoteDataSource: sl()),
  );
  sl.registerLazySingleton<ChurchService>(() => ChurchService(sl()));
  sl.registerFactoryParam<ChurchBloc, String, void>(
    (profileId, _) => ChurchBloc(churchService: sl(), profileId: profileId),
  );
  sl.registerFactory<ChurchModeratorsBloc>(
    () => ChurchModeratorsBloc(churchService: sl(), userService: sl()),
  );

  // Chat
  sl.registerLazySingleton<ChatRemoteDataSource>(
    () => ChatRemoteDataSourceImpl(dio: sl()),
  );
  sl.registerLazySingleton<ChatRepository>(
    () => ChatRepositoryImpl(remoteDataSource: sl()),
  );
  sl.registerLazySingleton<ChatService>(() => ChatService(sl()));
  sl.registerLazySingleton<ChatBloc>(
    () => ChatBloc(
      chatService: sl(),
      socketService: sl<SocketService>(),
      directMessagingSocket: sl<DirectMessagingSocketService>(),
      groupChatSocket: sl<GroupChatSocketService>(),
    ),
  );
  sl.registerFactory<NewGroupBloc>(() => NewGroupBloc(chatService: sl()));
  sl.registerFactoryParam<GroupGovernanceBloc, String, void>(
    (groupId, _) => GroupGovernanceBloc(
      chatService: sl(),
      groupChatSocket: sl(),
      groupId: groupId,
    ),
  );

  // Live streaming
  sl.registerLazySingleton<LiveStreamRemoteDataSource>(
    () => LiveStreamRemoteDataSourceImpl(dio: sl()),
  );
  sl.registerLazySingleton<LiveStreamRepository>(
    () => LiveStreamRepositoryImpl(remoteDataSource: sl()),
  );
  sl.registerLazySingleton<LiveStreamService>(() => LiveStreamService(sl()));
  sl.registerFactory<LiveStreamBloc>(
    () => LiveStreamBloc(liveStreamService: sl()),
  );

  // Stations
  sl.registerLazySingleton<StationRemoteDataSource>(
    () => StationRemoteDataSourceImpl(sl()),
  );
  sl.registerLazySingleton<StationRepository>(
    () => StationRepositoryImpl(remoteDataSource: sl()),
  );
  sl.registerFactory<StationBloc>(() => StationBloc(repository: sl()));

  // Scripture
  sl.registerLazySingleton<ScriptureRemoteDataSource>(
    () => ScriptureRemoteDataSourceImpl(dio: sl()),
  );
  sl.registerLazySingleton<ScriptureRepository>(
    () => ScriptureRepositoryImpl(remoteDataSource: sl()),
  );
  sl.registerLazySingleton<ScriptureService>(() => ScriptureService(sl()));
  sl.registerLazySingleton<MediaUploadService>(() => MediaUploadService());
  sl.registerFactory<NewPostBloc>(
    () => NewPostBloc(scriptureService: sl(), postComposeService: sl()),
  );

  // Comments
  sl.registerLazySingleton<CommentsRemoteDataSource>(
    () => CommentsRemoteDataSourceImpl(dio: sl()),
  );
  sl.registerLazySingleton<CommentsRepository>(
    () => CommentsRepositoryImpl(remoteDataSource: sl()),
  );
  sl.registerLazySingleton<CommentsService>(() => CommentsService(sl()));

  // Post
  sl.registerLazySingleton<PostRemoteDataSource>(
    () => PostRemoteDataSourceImpl(dio: sl()),
  );
  sl.registerLazySingleton<PostRepository>(
    () => PostRepositoryImpl(remoteDataSource: sl()),
  );
  sl.registerLazySingleton<PostService>(() => PostService(sl()));
  // Event
  sl.registerLazySingleton<EventRemoteDataSource>(
    () => EventRemoteDataSourceImpl(dio: sl()),
  );
  sl.registerLazySingleton<EventRepository>(
    () => EventRepositoryImpl(remoteDataSource: sl()),
  );
  sl.registerLazySingleton<EventService>(() => EventService(sl()));
  sl.registerFactory<EventsFeedBloc>(() => EventsFeedBloc(eventService: sl()));

  sl.registerLazySingleton<PostComposeService>(
    () => PostComposeService(sl(), sl(), sl()),
  );
  sl.registerFactory<PostComposeBloc>(
    () => PostComposeBloc(composeService: sl()),
  );

  // Short video
  sl.registerLazySingleton<ShortVideoRemoteDataSource>(
    () => ShortVideoRemoteDataSourceImpl(dio: sl()),
  );
  sl.registerLazySingleton<ShortVideoRepository>(
    () => ShortVideoRepositoryImpl(remoteDataSource: sl()),
  );
  sl.registerLazySingleton<ShortVideoService>(() => ShortVideoService(sl()));

  // Profile / account
  sl.registerLazySingleton<ProfileRemoteDataSource>(
    () => ProfileRemoteDataSourceImpl(
      churchRemote: sl(),
      postsRemote: sl(),
      shortsRemote: sl(),
      eventRemote: sl(),
      campaignRemote: sl(),
    ),
  );
  sl.registerLazySingleton<ProfileRepository>(
    () => ProfileRepositoryImpl(remoteDataSource: sl()),
  );
  sl.registerLazySingleton<ProfileService>(() => ProfileService(sl()));
  sl.registerFactory<AccountProfileBloc>(
    () => AccountProfileBloc(profileService: sl(), userService: sl()),
  );
  sl.registerFactory<MonthlyGiftsBloc>(
    () => MonthlyGiftsBloc(profileService: sl()),
  );
  sl.registerFactory<SubscribersBloc>(
    () => SubscribersBloc(profileService: sl()),
  );
  sl.registerFactory<LiveViewersBloc>(
    () => LiveViewersBloc(profileService: sl()),
  );

  // Campaign
  sl.registerLazySingleton<CampaignRemoteDataSource>(
    () => CampaignRemoteDataSourceImpl(dio: sl()),
  );
  sl.registerLazySingleton<CampaignRepository>(
    () => CampaignRepositoryImpl(remoteDataSource: sl()),
  );
  sl.registerLazySingleton<CampaignService>(() => CampaignService(sl()));
  sl.registerFactory<CampaignsHubBloc>(
    () => CampaignsHubBloc(campaignService: sl()),
  );
  sl.registerFactory<NewCampaignBloc>(
    () => NewCampaignBloc(campaignService: sl()),
  );
  sl.registerFactoryParam<CampaignDetailBloc, String, void>(
    (campaignId, _) =>
        CampaignDetailBloc(campaignService: sl(), campaignId: campaignId),
  );

  // Discovery
  sl.registerLazySingleton<DiscoveryRemoteDataSource>(
    () => DiscoveryRemoteDataSourceImpl(churchRemote: sl(), dio: sl()),
  );
  sl.registerLazySingleton<DiscoveryRepository>(
    () => DiscoveryRepositoryImpl(remoteDataSource: sl()),
  );
  sl.registerLazySingleton<DiscoveryService>(() => DiscoveryService(sl()));
  sl.registerLazySingleton<DiscoveryBloc>(
    () => DiscoveryBloc(discoveryService: sl()),
  );
  sl.registerFactory<NearbyBloc>(() => NearbyBloc(discoveryService: sl()));

  // Notifications
  sl.registerLazySingleton<NotificationsRemoteDataSource>(
    () => NotificationsRemoteDataSourceImpl(dio: sl()),
  );
  sl.registerLazySingleton<NotificationsRepository>(
    () => NotificationsRepositoryImpl(remoteDataSource: sl()),
  );
  sl.registerLazySingleton<NotificationService>(() => NotificationService());
  sl.registerLazySingleton<NotificationsService>(
    () => NotificationsService(sl(), pushService: sl()),
  );
  sl.registerFactory<NotificationsBloc>(() => NotificationsBloc(service: sl()));

  // Onboarding
  sl.registerFactory<OnboardingBloc>(() => OnboardingBloc());

  // Wallet
  sl.registerLazySingleton<WalletRemoteDataSource>(
    () => WalletRemoteDataSourceImpl(dio: sl()),
  );
  sl.registerLazySingleton<WalletRepository>(
    () => WalletRepositoryImpl(remoteDataSource: sl()),
  );
  sl.registerLazySingleton<WalletService>(() => WalletService(sl()));
  sl.registerFactory<WalletBloc>(() => WalletBloc(walletService: sl()));
    // Analytics
    sl.registerLazySingleton<AnalyticsRepository>(( ) => AnalyticsRepositoryImpl(sl()));
    sl.registerLazySingleton<GetAnalytics>(( ) => GetAnalytics(sl()));
    sl.registerFactory<AnalyticsBloc>(( ) => AnalyticsBloc(getAnalytics: sl()));
    
  await SharedPrefsService.getAccessToken();
}
