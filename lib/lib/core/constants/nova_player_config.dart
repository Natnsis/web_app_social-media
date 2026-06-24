import 'package:faithconnect/core/config/env_config.dart';

/// Nova Player settings (`nova_player.md`: `appId` + `streamCode`).
abstract final class NovaPlayerConfig {
  NovaPlayerConfig._();

  /// Resolved Nova application id (`--dart-define=NOVA_APP_ID=...`).
  static String get appId => EnvConfig.instance.novaAppId.trim();

  static bool get isConfigured => appId.isNotEmpty;

  /// Nova-hosted CDN URLs require [streamCode] + nova_player — not direct HTTP playback.
  static bool isNovaHostedMediaUrl(String? url) {
    final candidate = url?.trim();
    if (candidate == null || candidate.isEmpty) return false;
    final host = Uri.tryParse(candidate)?.host.toLowerCase() ?? '';
    return host.contains('novastream.et') || host.contains('nova-stream');
  }
}
