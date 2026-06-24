import 'package:dio/dio.dart';
import 'package:faithconnect/core/constants/api_endpoint.dart';
import 'package:faithconnect/core/network/api_error_mapper.dart';
import 'package:faithconnect/core/network/api_list_response.dart';
import 'package:faithconnect/core/network/nearby_churches_meta.dart';
import 'package:faithconnect/features/church/data/mappers/church_profile_feed_mapper.dart';
import 'package:faithconnect/features/church/data/dto/church_api_dto.dart';
import 'package:faithconnect/features/church/data/dto/assign_church_moderator_dto.dart';
import 'package:faithconnect/features/church/data/dto/church_member_api_dto.dart';
import 'package:faithconnect/features/church/domain/entities/church_profile_ids.dart';
import 'package:faithconnect/features/discovery/domain/entities/nearby_churches_filter.dart';
import 'package:faithconnect/features/auth/data/auth_exception.dart';
import 'package:faithconnect/core/services/user_location_sync_service.dart';
import 'package:faithconnect/features/church/data/dto/update_church_profile_dto.dart';
import 'package:faithconnect/features/church/data/models/church_profile_model.dart';

class ChurchesPageResult {
  final List<ChurchApiDto> churches;
  final ApiListMeta meta;

  const ChurchesPageResult({
    required this.churches,
    required this.meta,
  });
}

class NearbyChurchesPageResult {
  final List<ChurchApiDto> churches;
  final NearbyChurchesMeta meta;

  const NearbyChurchesPageResult({
    required this.churches,
    required this.meta,
  });
}

abstract class ChurchRemoteDataSource {
  Future<ChurchesPageResult> fetchChurches({
    int page,
    int limit,
  });

  Future<NearbyChurchesPageResult> fetchNearbyChurches(
    NearbyChurchesFilter filter,
  );

  Future<ChurchProfileFeedModel> getChurchProfile(String profileId);

  Future<void> updateChurchProfile(
    String churchId,
    UpdateChurchProfileDto dto,
  );

  Future<void> toggleFollowChurch({
    required String churchId,
    required bool follow,
  });

  Future<void> unfollowChurch({required String churchId});

  bool? cachedFollowingState(String churchId);

  Future<List<ChurchMemberApiDto>> fetchMyChurchMembers();

  Future<ChurchMemberApiDto> assignModerator({
    required String userId,
  });

  Future<void> revokeModerator({
    required String userId,
  });

  Future<ChurchesPageResult> fetchFollowingChurches({
    int page,
    int limit,
  });
}

class ChurchRemoteDataSourceImpl implements ChurchRemoteDataSource {
  ChurchRemoteDataSourceImpl({
    required Dio dio,
    required UserLocationSyncService locationSync,
  })  : _dio = dio,
        _locationSync = locationSync;

  final Dio _dio;
  final UserLocationSyncService _locationSync;
  final Map<String, bool> _followState = {};

  @override
  Future<ChurchesPageResult> fetchChurches({
    int page = 1,
    int limit = 20,
  }) async {
    try {
      final response = await _dio.get<dynamic>(
        ChurchesApiEndpoint.list,
      );

      final parsed = ApiListResponse.parse(
        response.data,
        ChurchApiDto.fromJson,
      );

      return ChurchesPageResult(
        churches: parsed.data,
        meta: parsed.meta,
      );
    } on DioException catch (e) {
      throw ApiErrorMapper.authExceptionFrom(e);
    }
  }

  @override
  Future<NearbyChurchesPageResult> fetchNearbyChurches(
    NearbyChurchesFilter filter,
  ) async {
    try {
      await _locationSync.ensureSavedForNearby();

      final response = await _dio.get<dynamic>(
        ChurchesApiEndpoint.nearby,
        queryParameters: filter.toQueryParameters(),
      );

      final parsed = ApiListResponse.parse(
        response.data,
        ChurchApiDto.fromJson,
      );

      final root = response.data;
      final metaMap = root is Map ? root['meta'] : null;
      final metaJson = metaMap is Map
          ? Map<String, dynamic>.from(metaMap)
          : null;

      _syncFollowStateFromApi(parsed.data);

      return NearbyChurchesPageResult(
        churches: parsed.data,
        meta: NearbyChurchesMeta.fromJson(metaJson),
      );
    } on DioException catch (e) {
      throw ApiErrorMapper.authExceptionFrom(e);
    }
  }

  @override
  Future<ChurchProfileFeedModel> getChurchProfile(String profileId) async {
    try {
      final useMyChurch = ChurchProfileIds.isMyChurch(profileId);
      final response = await _dio.get<dynamic>(
        useMyChurch
            ? ChurchesApiEndpoint.myChurch
            : ChurchesApiEndpoint.detail(profileId),
      );

      final dto = ChurchApiDto.parseSingle(response.data);
      if (dto == null || dto.id.isEmpty) {
        throw const AuthException('Church not found.');
      }

      final churchId = dto.id;
      final followKey = useMyChurch ? churchId : profileId;
      final isFollowing = _resolveFollowing(followKey, dto.isFollowingByMe);

      return ChurchProfileFeedMapper.fromDetailDto(
        dto,
        isFollowing: isFollowing,
      );
    } on DioException catch (e) {
      throw ApiErrorMapper.authExceptionFrom(e);
    }
  }

  @override
  Future<void> updateChurchProfile(
    String churchId,
    UpdateChurchProfileDto dto,
  ) async {
    try {
      final formData = await dto.toFormData();
      await _dio.patch<dynamic>(
        ChurchesApiEndpoint.detail(churchId),
        data: formData,
        options: Options(contentType: 'multipart/form-data'),
      );
    } on DioException catch (e) {
      throw ApiErrorMapper.authExceptionFrom(e);
    }
  }

  @override
  Future<void> toggleFollowChurch({
    required String churchId,
    required bool follow,
  }) async {
    try {
      if (follow) {
        await _dio.post<void>(ChurchesApiEndpoint.follow(churchId));
      } else {
        await _dio.delete<void>(ChurchesApiEndpoint.follow(churchId));
      }
      _followState[churchId] = follow;
    } on DioException catch (e) {
      throw ApiErrorMapper.authExceptionFrom(e);
    }
  }

  @override
  Future<void> unfollowChurch({required String churchId}) =>
      toggleFollowChurch(churchId: churchId, follow: false);

  @override
  bool? cachedFollowingState(String churchId) => _followState[churchId];

  bool _resolveFollowing(String churchId, bool apiValue) {
    return _followState[churchId] ?? apiValue;
  }

  void _syncFollowStateFromApi(List<ChurchApiDto> churches) {
    for (final dto in churches) {
      if (dto.id.isEmpty) continue;
      _followState[dto.id] = dto.isFollowingByMe;
    }
  }

  @override
  Future<List<ChurchMemberApiDto>> fetchMyChurchMembers() async {
    try {
      final churchId = await _resolveMyChurchId();
      final response = await _dio.get<dynamic>(
        ChurchesApiEndpoint.members(churchId),
      );
      return ChurchMemberApiDto.parseListResponse(response.data);
    } on DioException catch (e) {
      throw ApiErrorMapper.authExceptionFrom(e);
    }
  }

  @override
  Future<ChurchMemberApiDto> assignModerator({
    required String userId,
  }) async {
    final trimmed = userId.trim();
    if (trimmed.isEmpty) {
      throw const AuthException('User id is required.');
    }

    try {
      final churchId = await _resolveMyChurchId();
      final payload = AssignChurchModeratorDto(userId: trimmed);

      final response = await _dio.post<dynamic>(
        ChurchesApiEndpoint.members(churchId),
        data: payload.toJson(),
      );

      return ChurchMemberApiDto.parseResponse(response.data);
    } on DioException catch (e) {
      throw ApiErrorMapper.authExceptionFrom(e);
    }
  }

  @override
  Future<void> revokeModerator({
    required String userId,
  }) async {
    final trimmed = userId.trim();
    if (trimmed.isEmpty) {
      throw const AuthException('User id is required.');
    }

    try {
      final churchId = await _resolveMyChurchId();
      await _dio.delete<void>(
        ChurchesApiEndpoint.memberRevoke(churchId, trimmed),
      );
    } on DioException catch (e) {
      throw ApiErrorMapper.authExceptionFrom(e);
    }
  }

  @override
  Future<ChurchesPageResult> fetchFollowingChurches({
    int page = 1,
    int limit = 20,
  }) async {
    try {
      final response = await _dio.get<dynamic>(
        ChurchesApiEndpoint.myFollowing,
        queryParameters: {
          'page': page,
          'limit': limit,
        },
      );

      final parsed = ApiListResponse.parse(
        response.data,
        ChurchApiDto.fromJson,
      );

      return ChurchesPageResult(
        churches: parsed.data,
        meta: parsed.meta,
      );
    } on DioException catch (e) {
      throw ApiErrorMapper.authExceptionFrom(e);
    }
  }

  Future<String> _resolveMyChurchId() async {
    final response = await _dio.get<dynamic>(ChurchesApiEndpoint.myChurch);
    final church = ChurchApiDto.parseSingle(response.data);

    if (church == null || church.id.isEmpty) {
      throw const AuthException(
        'You need a church profile to manage moderators.',
      );
    }

    return church.id;
  }
}
