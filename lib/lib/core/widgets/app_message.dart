import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:faithconnect/core/core.dart';

enum MessageType { success, error, warning, info }

void showMessage(
  BuildContext context,
  String message,
  MessageType type, {
  String? title,
  Duration duration = const Duration(seconds: 4),
  String? actionLabel,
  VoidCallback? onAction,
  bool isLoading = false,
  bool? isTop,
}) {
  HapticFeedback.mediumImpact();

  // Highlight: Default all messages to Top position for premium prominence
  final bool shouldShowOnTop = isTop ?? true;

  AppSnackBar.show(
    context,
    title: title ?? _getDefaultTitle(type),
    message: message,
    type: _mapMessageType(type),
    actionLabel: actionLabel,
    onAction: onAction,
    isLoading: isLoading,
    duration: duration,
    isTop: shouldShowOnTop,
  );
}

String _getDefaultTitle(MessageType type) {
  switch (type) {
    case MessageType.success:
      return 'Success';
    case MessageType.error:
      return 'Error';
    case MessageType.warning:
      return 'Warning';
    case MessageType.info:
      return 'Information';
  }
}

AppSnackBarType _mapMessageType(MessageType type) {
  switch (type) {
    case MessageType.success:
      return AppSnackBarType.success;
    case MessageType.error:
      return AppSnackBarType.error;
    case MessageType.warning:
      return AppSnackBarType.warning;
    case MessageType.info:
      return AppSnackBarType.info;
  }
}

void showSuccess(
  BuildContext context,
  String message, {
  String? title,
  Duration duration = const Duration(seconds: 4),
}) {
  showMessage(context, message, MessageType.success, title: title, duration: duration);
}

void showError(
  BuildContext context,
  String message, {
  String? title,
  Duration duration = const Duration(seconds: 4),
  String? actionLabel,
  VoidCallback? onAction,
}) {
  if (GroupAccessErrors.isNonMemberMessage(message)) return;

  showMessage(
    context,
    message,
    MessageType.error,
    title: title,
    duration: duration,
    actionLabel: actionLabel,
    onAction: onAction,
  );
}

void showWarning(
  BuildContext context,
  String message, {
  String? title,
  Duration duration = const Duration(seconds: 4),
}) {
  showMessage(context, message, MessageType.warning, title: title, duration: duration);
}

void showInfo(
  BuildContext context,
  String message, {
  String? title,
  Duration duration = const Duration(seconds: 4),
}) {
  showMessage(context, message, MessageType.info, title: title, duration: duration);
}

void showLoadingMessage(
  BuildContext context,
  String message, {
  String? title,
  Duration duration = const Duration(seconds: 4),
}) {
  showMessage(
    context,
    message,
    MessageType.info,
    title: title,
    duration: duration,
    isLoading: true,
  );
}

void showFailure(
  BuildContext context,
  Failure failure, {
  String? title,
  Duration duration = const Duration(seconds: 4),
  String? actionLabel,
  VoidCallback? onAction,
}) {
  _displayFailure(context, failure, title, duration, actionLabel, onAction);
}

void _displayFailure(
  BuildContext context,
  Failure failure,
  String? title,
  Duration duration,
  String? actionLabel,
  VoidCallback? onAction,
) {
  final MessageType messageType = _getMessageTypeFromFailure(failure);
  final String? retryLabel =
      actionLabel ?? (messageType == MessageType.error ? 'Retry' : null);
  final VoidCallback? retryCallback = onAction;

  showMessage(
    context,
    failure.message,
    messageType,
    title: title,
    duration: duration,
    actionLabel: retryLabel,
    onAction: retryCallback,
  );
}

MessageType _getMessageTypeFromFailure(Failure failure) {
  if (failure is NetworkFailure || failure is TimeoutFailure) {
    return MessageType.warning;
  }
  return MessageType.error;
}

