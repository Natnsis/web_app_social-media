import 'package:dio/dio.dart';
import 'package:faithconnect/core/constants/api_endpoint.dart';
import 'package:faithconnect/core/network/api_error_mapper.dart';
import 'package:faithconnect/core/network/api_list_response.dart';
import 'package:faithconnect/features/notifications/data/dto/device_registration_dto.dart';
import 'package:faithconnect/features/notifications/data/dto/notification_api_dto.dart';
import 'package:faithconnect/features/notifications/data/dto/notification_preferences_dto.dart';
import 'package:faithconnect/features/notifications/domain/entities/app_notification.dart';
import 'package:faithconnect/features/notifications/domain/entities/notification_preferences.dart';

abstract class NotificationsRemoteDataSource {
  Future<List<AppNotification>> fetchNotifications();

  Future<int> getUnreadCount();

  Future<NotificationPreferences> getPreferences();

  Future<void> updatePreferences(NotificationPreferences preferences);

  Future<void> markAsRead(String notificationId);

  Future<void> markAllAsRead();

  Future<void> registerDevice(DeviceRegistrationDto dto);

  Future<void> unregisterDevice(String deviceId);
}

class NotificationsRemoteDataSourceImpl implements NotificationsRemoteDataSource {
  final Dio _dio;

  NotificationsRemoteDataSourceImpl({required Dio dio}) : _dio = dio;

  @override
  Future<List<AppNotification>> fetchNotifications() async {
    try {
      final response = await _dio.get<dynamic>(NotificationsApiEndpoint.base);
      final apiList = ApiListResponse.parse(
        response.data,
        NotificationApiDto.fromJson,
      );
      return apiList.data.map((dto) => dto.toEntity()).toList();
    } on DioException catch (e) {
      throw ApiErrorMapper.authExceptionFrom(e);
    }
  }

  @override
  Future<int> getUnreadCount() async {
    try {
      final response = await _dio.get<Map<String, dynamic>>(NotificationsApiEndpoint.unreadCount);
      final count = response.data?['data']?['unreadCount'] as int?;
      return count ?? 0;
    } on DioException catch (e) {
      throw ApiErrorMapper.authExceptionFrom(e);
    }
  }

  @override
  Future<NotificationPreferences> getPreferences() async {
    try {
      final response = await _dio.get<Map<String, dynamic>>(NotificationsApiEndpoint.preferences);
      final data = response.data?['data'] as Map<String, dynamic>? ?? {};
      return NotificationPreferencesDto.fromJson(data).toEntity();
    } on DioException catch (e) {
      throw ApiErrorMapper.authExceptionFrom(e);
    }
  }

  @override
  Future<void> updatePreferences(NotificationPreferences preferences) async {
    try {
      final dto = NotificationPreferencesDto.fromEntity(preferences);
      await _dio.patch<dynamic>(
        NotificationsApiEndpoint.preferences,
        data: dto.toMap(),
      );
    } on DioException catch (e) {
      throw ApiErrorMapper.authExceptionFrom(e);
    }
  }

  @override
  Future<void> markAsRead(String notificationId) async {
    try {
      await _dio.patch<dynamic>(NotificationsApiEndpoint.read(notificationId));
    } on DioException catch (e) {
      throw ApiErrorMapper.authExceptionFrom(e);
    }
  }

  @override
  Future<void> markAllAsRead() async {
    try {
      await _dio.patch<dynamic>(NotificationsApiEndpoint.readAll);
    } on DioException catch (e) {
      throw ApiErrorMapper.authExceptionFrom(e);
    }
  }

  @override
  Future<void> registerDevice(DeviceRegistrationDto dto) async {
    try {
      await _dio.post<dynamic>(
        NotificationsApiEndpoint.registerDevice,
        data: dto.toMap(),
      );
    } on DioException catch (e) {
      throw ApiErrorMapper.authExceptionFrom(e);
    }
  }

  @override
  Future<void> unregisterDevice(String deviceId) async {
    try {
      await _dio.delete<dynamic>(
        NotificationsApiEndpoint.device(deviceId),
      );
    } on DioException catch (e) {
      throw ApiErrorMapper.authExceptionFrom(e);
    }
  }
}
