import 'package:faithconnect/core/core.dart';
import 'package:faithconnect/core/services/push/firebase_messaging_background.dart';
import 'package:faithconnect/features/auth/application/google_auth_service.dart';
import 'package:faithconnect/features/auth/presentation/blocs/auth_bloc.dart';
import 'package:faithconnect/features/auth/presentation/blocs/auth_state.dart';
import 'package:faithconnect/features/chat/presentation/blocs/chat_bloc.dart';
import 'package:faithconnect/features/discovery/presentation/bloc/discovery_bloc.dart';
import 'package:faithconnect/features/discovery/presentation/bloc/nearby_bloc.dart';
import 'package:faithconnect/features/event/presentation/bloc/events_feed_bloc.dart';
import 'package:faithconnect/features/home/presentation/blocs/home_bloc.dart';
import 'package:faithconnect/features/home/presentation/home_shell_mode_notifier.dart';
import 'package:faithconnect/features/home/presentation/home_shell_mode_scope.dart';
import 'package:faithconnect/features/live_streaming/presentation/blocs/live_stream_bloc.dart';
import 'package:faithconnect/features/notifications/application/notifications_service.dart';
import 'package:faithconnect/features/notifications/presentation/bloc/notifications_bloc.dart';
import 'package:faithconnect/features/notifications/presentation/bloc/notifications_event.dart';
import 'package:faithconnect/features/onboarding/presentation/blocs/onboarding_bloc.dart';
import 'package:faithconnect/core/network/auth_session_coordinator.dart';
import 'package:faithconnect/injection.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_i18n/flutter_i18n.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

Future<void> _initializeFirebase() async {
  try {
    await Firebase.initializeApp();
    FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);
  } catch (e) {
    FaithLogger.e('main', 'Firebase init failed: $e');
  }
}

Future<void> _initializePushNotifications() async {
  final notificationsService = sl<NotificationsService>();

  await notificationsService.initializePush(
    onInboundPush: (_) {
      final context = rootNavigatorKey.currentContext;
      if (context == null || !context.mounted) return;
      context.read<NotificationsBloc>().add(const NotificationsRefreshed());
      context.read<NotificationsBloc>().add(
            const NotificationsUnreadCountRequested(),
          );
    },
  );
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await EnvConfig.init();
  await SharedPrefsService.clearLegacyDemoLoginCredentials();
  await setupInjection();
  await _initializeFirebase();
  await _initializePushNotifications();

  await sl<GoogleAuthService>().initialize();

  sl<AuthSessionCoordinator>().onSessionExpired = () async {
    final context = rootNavigatorKey.currentContext;
    if (context != null && context.mounted) {
      context.go(RoutesConstant.login);
    }
  };

  final shellModeNotifier = sl<HomeShellModeNotifier>();
  await shellModeNotifier.load();
  await sl<ThemeCubit>().load();
  await sl<LocaleCubit>().load();
  runApp(MyApp(shellModeNotifier: shellModeNotifier));
}

class MyApp extends StatefulWidget {
  final HomeShellModeNotifier shellModeNotifier;

  const MyApp({super.key, required this.shellModeNotifier});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  late final GoRouter _router;

  @override
  void initState() {
    super.initState();
    _router = createRouter();
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => sl<ThemeCubit>()),
        BlocProvider(create: (_) => sl<LocaleCubit>()),
        BlocProvider(create: (_) => sl<AuthBloc>()),
        BlocProvider(create: (_) => sl<HomeBloc>()),
        BlocProvider(create: (_) => sl<DiscoveryBloc>()),
        BlocProvider(create: (_) => sl<NearbyBloc>()),
        BlocProvider(create: (_) => sl<EventsFeedBloc>()),
        BlocProvider(create: (_) => sl<ChatBloc>()),
        BlocProvider(create: (_) => sl<LiveStreamBloc>()),
        BlocProvider(create: (_) => sl<OnboardingBloc>()),
        BlocProvider(create: (_) => sl<NotificationsBloc>()),
      ],
      child: BlocListener<AuthBloc, AuthState>(
        listenWhen: (previous, current) => current is AuthAuthenticated,
        listener: (context, state) {
          sl<NotificationsService>().registerDeviceToken();
        },
        child: ScreenUtilInit(
          designSize: const Size(375, 812),
          minTextAdapt: true,
          builder: (context, child) {
            return HomeShellModeScope(
              notifier: widget.shellModeNotifier,
              child: BlocBuilder<LocaleCubit, AppLanguage>(
                builder: (context, appLanguage) {
                  return BlocBuilder<ThemeCubit, ThemeMode>(
                    builder: (context, themeMode) {
                      return MaterialApp.router(
                        debugShowCheckedModeBanner: false,
                        title: EnvConfig.instance.appName,
                        theme: buildLightTheme(context),
                        darkTheme: buildDarkTheme(context),
                        themeMode: themeMode,
                        locale: appLanguage.materialLocale,
                        supportedLocales:
                            AppLanguage.materialSupportedLocales,
                        localeListResolutionCallback: (_, _) =>
                            appLanguage.materialLocale,
                        localizationsDelegates: FaithLocalization.delegates,
                        builder: FlutterI18n.rootAppBuilder(),
                        routerConfig: _router,
                      );
                    },
                  );
                },
              ),
            );
          },
        ),
      ),
    );
  }
}
