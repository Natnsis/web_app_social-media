import 'package:faithconnect/core/core.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

/// Entry points for live streaming (hub → watch → go live).
abstract final class LiveStreamNavigation {
  LiveStreamNavigation._();

  static void openHub(BuildContext context) {
    context.pushNamed(RoutesConstant.liveStreams);
  }

  static void openWatch(BuildContext context, String streamId) {
    context.pushNamed(
      RoutesConstant.liveStreamDetail,
      pathParameters: {'id': streamId},
    );
  }

  static void openGoLive(BuildContext context) {
    if (!context.readRoleAccess().showCreateActions) {
      showInfo(
        context,
        'Starting a live stream is only available for church administrator accounts.',
      );
      return;
    }
    context.pushNamed(RoutesConstant.goLive);
  }

  /// Opens the immersive watch UI for a live story, or the streams hub otherwise.
  static void openFromLiveNowItem(
    BuildContext context, {
    required bool isLive,
    String? streamId,
  }) {
    if (isLive) {
      if (streamId != null && streamId.trim().isNotEmpty) {
        openWatch(context, streamId);
      } else {
        openHub(context);
      }
      return;
    }
    openHub(context);
  }
}
