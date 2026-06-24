import 'package:dio/dio.dart';
import 'package:faithconnect/core/constants/api_endpoint.dart';
import 'package:faithconnect/core/models/user_entity.dart';
import 'package:faithconnect/core/services/shared_prefs_Service.dart';
import 'package:faithconnect/core/network/api_error_mapper.dart';
import 'package:faithconnect/core/network/api_list_response.dart';
import 'package:faithconnect/features/auth/data/auth_exception.dart';
import 'package:faithconnect/features/user/data/dto/update_user_profile_dto.dart';
import 'package:faithconnect/features/user/data/dto/user_search_api_dto.dart';
import 'package:faithconnect/features/user/data/mappers/user_mapper.dart';

abstract class UserRemoteDataSource {
  Future<List<UserSearchApiDto>> searchUsers({
    String? query,
    int page = 1,
    int limit = 20,
  });

  Future<User> getCurrentUserProfile();

  Future<User> updateCurrentUserProfile(UpdateUserProfileDto payload);
}

class UserRemoteDataSourceImpl implements UserRemoteDataSource {
  UserRemoteDataSourceImpl({required Dio dio}) : _dio = dio;

  final Dio _dio;

  @override
  Future<List<UserSearchApiDto>> searchUsers({
    String? query,
    int page = 1,
    int limit = 20,
  }) async {
    try {
      final trimmed = query?.trim();
      final response = await _dio.get<dynamic>(
        UsersApiEndpoint.search,
        queryParameters: {
          if (trimmed != null && trimmed.isNotEmpty) 'q': trimmed,
          'page': page,
          'limit': limit.clamp(1, 100),
        },
      );

      final parsed = ApiListResponse.parse(
        response.data,
        UserSearchApiDto.fromJson,
      );

      return parsed.data.where((dto) => dto.id.isNotEmpty).toList();
    } on DioException catch (e) {
      throw ApiErrorMapper.authExceptionFrom(e);
    }
  }

  @override
  Future<User> getCurrentUserProfile() async {
    try {
      final response = await _dio.get<dynamic>(UsersApiEndpoint.me);
      return _parseMeResponse(response.data);
    } on DioException catch (e) {
      throw ApiErrorMapper.authExceptionFrom(e);
    }
  }

  @override
  Future<User> updateCurrentUserProfile(UpdateUserProfileDto payload) async {
    try {
      final response = await _dio.patch<dynamic>(
        UsersApiEndpoint.me,
        data: await payload.toFormData(),
        options: Options(contentType: 'multipart/form-data'),
      );
      return _parseMeResponse(response.data);
    } on DioException catch (e) {
      throw ApiErrorMapper.authExceptionFrom(e);
    }
  }

  Future<User> _parseMeResponse(dynamic data) async {
    if (data == null || data['success'] != true) {
      throw const AuthException('Failed to fetch user profile');
    }
    final userMap = data['data'] as Map<String, dynamic>;
    final stored = await SharedPrefsService.getUser();
    return UserMapper.fromMeApiMap(userMap, stored: stored);
  }
}
