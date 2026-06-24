import 'package:flutter/foundation.dart';

enum Environment { dev, prod }

/// App-wide environment (API base URL, logging).
///
/// Call [init] once at startup before [instance] or [setupInjection].
class EnvConfig {
  final Environment environment;
  final String baseUrl;
  final String appName;
  final bool enableLogs;

  final String novaAppId;

  static late EnvConfig _instance;
  static bool _initialized = false;

  EnvConfig._({
    required this.environment,
    required this.baseUrl,
    required this.appName,
    required this.enableLogs,
  
    required this.novaAppId,
  });

  

  /// Nova Player application id (`--dart-define=NOVA_APP_ID=...`).
  static const String novaAppIdFromEnvironment = String.fromEnvironment(
    'NOVA_APP_ID',
  );

  /// Resolves env from `--dart-define=ENV=dev|prod`, else release → prod.
  static Environment resolveEnvironment() {
    const envFromDefine = String.fromEnvironment('ENV');
    if (envFromDefine == 'prod') return Environment.prod;
    if (envFromDefine == 'dev') return Environment.dev;
    return kReleaseMode ? Environment.prod : Environment.dev;
  }

  static Future<void> init([Environment? environment]) async {
    final env = environment ?? resolveEnvironment();


    switch (env) {
      case Environment.dev:
        _instance = EnvConfig._(
          environment: Environment.dev,
          baseUrl: 'https://api.churchs.pitrontech.et',
          appName: 'FaithConnect Dev',
          enableLogs: true,
         
          novaAppId: novaAppIdFromEnvironment,
        );
        break;
      case Environment.prod:
        _instance = EnvConfig._(
          environment: Environment.prod,
          baseUrl: 'https://api.churchs.pitrontech.et',
          appName: 'FaithConnect',
          enableLogs: false,
        
          novaAppId: novaAppIdFromEnvironment,
        );
        break;
    }
    _initialized = true;
  }

  static EnvConfig get instance {
    assert(
      _initialized,
      'EnvConfig.init() must be called before accessing EnvConfig.instance',
    );
    return _instance;
  }

  /// Normalized REST root used by [Dio] (no trailing slash).
  String get apiBaseUrl {
    final trimmed = baseUrl.trim();
    return trimmed.endsWith('/')
        ? trimmed.substring(0, trimmed.length - 1)
        : trimmed;
  }

  bool get isDev => environment == Environment.dev;
  bool get isProd => environment == Environment.prod;



  /// True when `NOVA_APP_ID` was passed via `--dart-define`.
  bool get isNovaPlayerConfigured => novaAppId.trim().isNotEmpty;


}
