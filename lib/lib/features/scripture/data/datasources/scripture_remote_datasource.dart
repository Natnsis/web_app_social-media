import 'package:dio/dio.dart';
import 'package:faithconnect/core/constants/api_endpoint.dart';
import 'package:faithconnect/core/network/api_error_mapper.dart';
import 'package:faithconnect/core/network/api_list_response.dart';
import 'package:faithconnect/features/auth/data/auth_exception.dart';
import 'package:faithconnect/features/church/data/dto/church_api_dto.dart';
import 'package:faithconnect/features/scripture/data/dto/create_scryper_dto.dart';
import 'package:faithconnect/features/scripture/data/dto/scryper_api_dto.dart';
import 'package:faithconnect/features/scripture/data/mappers/scryper_mapper.dart';
import 'package:faithconnect/features/scripture/data/models/scripture_post_model.dart';

abstract class ScriptureRemoteDataSource {
  /// Returns the authenticated user's church id, or throws [AuthException].
  Future<String> resolveMyChurchId();

  /// Active daily verse for a church; `null` when none exists (404).
  Future<ScryperApiDto?> fetchActiveScryper(String churchId);

  /// Browse scrypers across churches (`GET /v1/churches/scrypers`).
  Future<List<ScryperApiDto>> fetchScrypers({
    int page = 1,
    int limit = 20,
  });

  Future<ScripturePostModel> publishScripturePost({
    required String bibleReference,
    required String verseText,
    required bool allowComments,
    required bool notifyCommunity,
  });
}

class ScriptureRemoteDataSourceImpl implements ScriptureRemoteDataSource {
  ScriptureRemoteDataSourceImpl({required Dio dio}) : _dio = dio;

  final Dio _dio;

  @override
  Future<String> resolveMyChurchId() => _resolveMyChurchId();

  @override
  Future<List<ScryperApiDto>> fetchScrypers({
    int page = 1,
    int limit = 20,
  }) async {
    try {
      final response = await _dio.get<dynamic>(
        ChurchesApiEndpoint.scrypersAll,
        queryParameters: {'page': page, 'limit': limit},
      );

      final parsed = ApiListResponse.parse(
        response.data,
        ScryperApiDto.fromJson,
      );

      return parsed.data.where((dto) => dto.id.isNotEmpty).toList();
    } on DioException catch (e) {
      throw ApiErrorMapper.authExceptionFrom(e);
    }
  }

  @override
  Future<ScryperApiDto?> fetchActiveScryper(String churchId) async {
    final id = churchId.trim();
    if (id.isEmpty) return null;

    try {
      final response = await _dio.get<dynamic>(
        ChurchesApiEndpoint.scryper(id),
      );

      final dto = ScryperApiDto.parseResponse(response.data);
      if (dto.verse.trim().isEmpty && dto.reference.trim().isEmpty) {
        return null;
      }
      return dto;
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) return null;
      throw ApiErrorMapper.authExceptionFrom(e);
    }
  }

  @override
  Future<ScripturePostModel> publishScripturePost({
    required String bibleReference,
    required String verseText,
    required bool allowComments,
    required bool notifyCommunity,
  }) async {
    final reference = bibleReference.trim();
    final verse = verseText.trim();

    if (reference.isEmpty || verse.isEmpty) {
      throw const AuthException('Bible reference and verse text are required.');
    }

    try {
      final churchId = await _resolveMyChurchId();
      final payload = CreateScryperDto(verse: verse, reference: reference);

      final response = await _dio.post<dynamic>(
        ChurchesApiEndpoint.scryper(churchId),
        data: payload.toJson(),
      );

      final dto = ScryperApiDto.parseResponse(response.data);
      return ScryperMapper.toScripturePost(
        dto,
        allowComments: allowComments,
        notifyCommunity: notifyCommunity,
      );
    } on DioException catch (e) {
      throw ApiErrorMapper.authExceptionFrom(e);
    } on FormatException catch (e) {
      throw AuthException(e.message);
    }
  }

  Future<String> _resolveMyChurchId() async {
    final response = await _dio.get<dynamic>(ChurchesApiEndpoint.myChurch);
    final church = ChurchApiDto.parseSingle(response.data);

    if (church == null || church.id.isEmpty) {
      throw const AuthException(
        'You need a church profile to publish a daily verse.',
      );
    }

    return church.id;
  }
}
