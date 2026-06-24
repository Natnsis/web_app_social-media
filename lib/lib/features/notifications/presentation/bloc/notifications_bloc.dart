import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:faithconnect/features/notifications/application/notifications_service.dart';
import 'package:faithconnect/features/notifications/presentation/bloc/notifications_event.dart';
import 'package:faithconnect/features/notifications/presentation/bloc/notifications_state.dart';

class NotificationsBloc extends Bloc<NotificationsEvent, NotificationsState> {
  final NotificationsService _service;

  NotificationsBloc({required NotificationsService service})
      : _service = service,
        super(const NotificationsState()) {
    on<NotificationsRequested>(_onRequested);
    on<NotificationsRefreshed>(_onRefreshed);
    on<NotificationsFilterChanged>(_onFilterChanged);
    on<NotificationMarkedRead>(_onMarkedRead);
    on<NotificationsMarkAllRead>(_onMarkAllRead);
    on<NotificationsUnreadCountRequested>(_onUnreadCountRequested);
    on<NotificationPreferencesRequested>(_onPreferencesRequested);
    on<NotificationPreferencesUpdated>(_onPreferencesUpdated);

    add(const NotificationsUnreadCountRequested());
  }

  Future<void> _onRequested(
    NotificationsRequested event,
    Emitter<NotificationsState> emit,
  ) async {
    await _load(emit, showLoading: true);
  }

  Future<void> _onRefreshed(
    NotificationsRefreshed event,
    Emitter<NotificationsState> emit,
  ) async {
    await _load(emit, showLoading: false);
  }

  void _onFilterChanged(
    NotificationsFilterChanged event,
    Emitter<NotificationsState> emit,
  ) {
    emit(state.copyWith(filter: event.filter));
  }

  Future<void> _onMarkedRead(
    NotificationMarkedRead event,
    Emitter<NotificationsState> emit,
  ) async {
    final optimistic = state.notifications
        .map(
          (item) => item.id == event.notificationId
              ? item.copyWith(isRead: true)
              : item,
        )
        .toList(growable: false);
    
    final currentCount = state.globalUnreadCount;
    final newCount = currentCount > 0 ? currentCount - 1 : 0;
    
    final previousState = state;
    emit(state.copyWith(notifications: optimistic, globalUnreadCount: newCount));

    final result = await _service.markAsRead(event.notificationId);
    result.fold(
      (_) => emit(previousState),
      (_) => null,
    );
  }

  Future<void> _onMarkAllRead(
    NotificationsMarkAllRead event,
    Emitter<NotificationsState> emit,
  ) async {
    final optimistic = state.notifications
        .map((item) => item.copyWith(isRead: true))
        .toList(growable: false);
    
    final previousState = state;
    emit(state.copyWith(notifications: optimistic, globalUnreadCount: 0));

    final result = await _service.markAllAsRead();
    result.fold(
      (_) => emit(previousState),
      (_) => null,
    );
  }

  Future<void> _onUnreadCountRequested(
    NotificationsUnreadCountRequested event,
    Emitter<NotificationsState> emit,
  ) async {
    final result = await _service.getUnreadCount();
    result.fold(
      (failure) => null,
      (count) => emit(state.copyWith(globalUnreadCount: count)),
    );
  }

  Future<void> _onPreferencesRequested(
    NotificationPreferencesRequested event,
    Emitter<NotificationsState> emit,
  ) async {
    final result = await _service.getPreferences();
    result.fold(
      (failure) => null,
      (prefs) => emit(state.copyWith(preferences: prefs)),
    );
  }

  Future<void> _onPreferencesUpdated(
    NotificationPreferencesUpdated event,
    Emitter<NotificationsState> emit,
  ) async {
    final currentPrefs = state.preferences;
    if (currentPrefs == null) return;
    
    final newPrefs = currentPrefs.copyWith(
      emailNotifications: event.emailNotifications,
      pushNotifications: event.pushNotifications,
      smsNotifications: event.smsNotifications,
    );
    
    final previousState = state;
    emit(state.copyWith(preferences: newPrefs));
    
    final result = await _service.updatePreferences(newPrefs);
    result.fold(
      (failure) => emit(previousState),
      (_) => null,
    );
  }

  Future<void> _load(
    Emitter<NotificationsState> emit, {
    required bool showLoading,
  }) async {
    if (showLoading) emit(state.copyWith(status: NotificationsStatus.loading));

    final result = await _service.fetchNotifications();
    result.fold(
      (failure) => emit(state.copyWith(status: NotificationsStatus.failure, errorMessage: failure.message)),
      (notifications) {
         final unreadCount = notifications.where((n) => !n.isRead).length;
         emit(state.copyWith(
           status: NotificationsStatus.loaded,
           notifications: notifications,
           globalUnreadCount: unreadCount,
         ));
      },
    );
  }
}
