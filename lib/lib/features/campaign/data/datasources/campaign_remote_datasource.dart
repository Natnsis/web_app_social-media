import 'package:dio/dio.dart';
import 'package:faithconnect/core/constants/api_endpoint.dart';
import 'package:faithconnect/core/network/api_create_response.dart';
import 'package:faithconnect/core/network/api_error_mapper.dart';
import 'package:faithconnect/core/network/api_list_response.dart';
import 'package:faithconnect/core/network/payment_checkout_info.dart';
import 'package:faithconnect/features/auth/data/auth_exception.dart';
import 'package:faithconnect/features/campaign/data/dto/donate_campaign_dto.dart';
import 'package:faithconnect/features/campaign/data/dto/campaign_api_dto.dart';
import 'package:faithconnect/features/campaign/data/dto/campaign_detail_api_dto.dart';
import 'package:faithconnect/features/campaign/data/mappers/campaign_detail_mapper.dart';
import 'package:faithconnect/features/campaign/data/mappers/create_campaign_mapper.dart';
import 'package:faithconnect/features/campaign/domain/entities/campaign.dart';
import 'package:faithconnect/features/campaign/domain/entities/campaign_detail.dart';
import 'package:faithconnect/features/campaign/domain/entities/campaign_hub_content.dart';
import 'package:faithconnect/features/campaign/domain/entities/campaign_hub_filter.dart';
import 'package:faithconnect/features/campaign/domain/entities/campaign_status.dart';
import 'package:faithconnect/features/campaign/domain/entities/following_campaigns_query_filter.dart';
import 'package:faithconnect/features/campaign/domain/entities/new_campaign_draft.dart';
import 'package:faithconnect/core/media/uploaded_media.dart';
import 'dart:io';

abstract class CampaignRemoteDataSource {
  Future<CampaignHubContent> fetchHubContent(
    CampaignHubFilter filter, {
    String? search,
  });

  Future<List<Campaign>> fetchCampaigns({
    FollowingCampaignsQueryFilter filter = const FollowingCampaignsQueryFilter(),
  });

  Future<CampaignDetail> fetchCampaignDetail(String id);

  Future<String> launchCampaign(NewCampaignDraft draft);

  Future<PaymentCheckoutInfo> donateToCampaign({
    required String campaignId,
    required DonateCampaignDto dto,
  });

  Future<String> checkTransactionStatus(String txRef);

  Future<void> updateCampaign({
    required String campaignId,
    required String title,
    int? goal,
    String? endDate,
    String? description,
    UploadedMedia? newMedia,
    bool removeExistingMedia = false,
  });

  Future<void> deleteCampaign(String campaignId);
}

class CampaignRemoteDataSourceImpl implements CampaignRemoteDataSource {
  CampaignRemoteDataSourceImpl({required Dio dio}) : _dio = dio;

  final Dio _dio;

  @override
  Future<CampaignHubContent> fetchHubContent(
    CampaignHubFilter filter, {
    String? search,
  }) async {
    try {
      final trimmedSearch = search?.trim();
      final query = (trimmedSearch == null || trimmedSearch.isEmpty)
          ? null
          : trimmedSearch;
      final listQuery = FollowingCampaignsQueryFilter(
        page: 1,
        limit: filter == CampaignHubFilter.following ? 20 : 50,
        search: query,
      );

      final campaigns = switch (filter) {
        CampaignHubFilter.following =>
          await _fetchFollowingCampaigns(query: listQuery),
        _ => await _fetchAllCampaigns(query: listQuery),
      };

      return _buildHubContent(campaigns, filter, searchQuery: query ?? '');
    } on DioException catch (e) {
      throw ApiErrorMapper.authExceptionFrom(e);
    }
  }

  @override
  Future<List<Campaign>> fetchCampaigns({
    FollowingCampaignsQueryFilter filter =
        const FollowingCampaignsQueryFilter(),
  }) async {
    try {
      return await _fetchAllCampaigns(query: filter);
    } on DioException catch (e) {
      throw ApiErrorMapper.authExceptionFrom(e);
    }
  }

  Future<List<Campaign>> _fetchFollowingCampaigns({
    FollowingCampaignsQueryFilter query =
        const FollowingCampaignsQueryFilter(),
  }) async {
    final response = await _dio.get<dynamic>(
      CampaignsApiEndpoint.following,
      queryParameters: query.toQueryParameters(),
    );

    return _parseCampaignList(response.data);
  }

  Future<List<Campaign>> _fetchAllCampaigns({
    FollowingCampaignsQueryFilter query =
        const FollowingCampaignsQueryFilter(page: 1, limit: 50),
  }) async {
    final response = await _dio.get<dynamic>(
      CampaignsApiEndpoint.list,
      queryParameters: query.toQueryParameters(),
    );

    return _parseCampaignList(response.data);
  }

  List<Campaign> _parseCampaignList(dynamic body) {
    final parsed = ApiListResponse.parse(
      body,
      CampaignApiDto.fromJson,
    );

    return parsed.data
        .where((dto) => dto.id.isNotEmpty)
        .map((dto) => dto.toCampaign())
        .toList();
  }

  CampaignHubContent _buildHubContent(
    List<Campaign> all,
    CampaignHubFilter filter, {
    String searchQuery = '',
  }) {
    final active = all.where((c) => c.status == CampaignStatus.active).toList();
    final completed =
        all.where((c) => c.status == CampaignStatus.completed).toList();

    final filteredActive = _applyHubFilter(active, filter);
    final featured = filteredActive.isNotEmpty ? filteredActive.first : null;
    final list = filteredActive
        .where((c) => featured == null || c.id != featured.id)
        .toList();

    return CampaignHubContent(
      filter: filter,
      searchQuery: searchQuery,
      featuredCampaign: featured,
      campaigns: list,
      completedCampaigns: completed,
    );
  }

  List<Campaign> _applyHubFilter(
    List<Campaign> campaigns,
    CampaignHubFilter filter,
  ) {
    return switch (filter) {
      CampaignHubFilter.following => campaigns,
      CampaignHubFilter.ourCampaigns => campaigns,
    };
  }

  @override
  Future<CampaignDetail> fetchCampaignDetail(String id) async {
    try {
      final response = await _dio.get<dynamic>(
        CampaignsApiEndpoint.detail(id),
      );

      final item = _extractCampaignJson(response.data);
      if (item == null) {
        throw const AuthException('Campaign not found.');
      }

      final dto = CampaignDetailApiDto.fromJson(item);
      return CampaignDetailMapper.fromDto(dto);
    } on DioException catch (e) {
      throw ApiErrorMapper.authExceptionFrom(e);
    }
  }

  Map<String, dynamic>? _extractCampaignJson(dynamic body) {
    if (body is Map<String, dynamic>) {
      final data = body['data'];
      if (data is Map<String, dynamic>) return data;
      if (body['id'] != null) return body;
    } else if (body is Map) {
      final map = Map<String, dynamic>.from(body);
      final data = map['data'];
      if (data is Map) return Map<String, dynamic>.from(data);
      if (map['id'] != null) return map;
    }
    return null;
  }

  @override
  Future<String> launchCampaign(NewCampaignDraft draft) async {
    final payload = CreateCampaignMapper.fromDraft(draft);

    if (payload.title.isEmpty) {
      throw const AuthException('Campaign title is required.');
    }
    if (payload.description.isEmpty) {
      throw const AuthException('Description is required.');
    }
    if (payload.goalAmount <= 0) {
      throw const AuthException('Enter a valid goal amount in ETB.');
    }

    try {
      final Response<dynamic> response;

      if (payload.hasImage) {
        response = await _dio.post<dynamic>(
          CampaignsApiEndpoint.list,
          data: await payload.toFormData(),
          options: Options(
            contentType: 'multipart/form-data',
            sendTimeout: const Duration(minutes: 5),
            receiveTimeout: const Duration(minutes: 2),
          ),
        );
      } else {
        response = await _dio.post<dynamic>(
          CampaignsApiEndpoint.list,
          data: payload.toJson(),
        );
      }

      return ApiCreateResponse.parseId(response.data);
    } on DioException catch (e) {
      throw ApiErrorMapper.authExceptionFrom(e);
    } on FormatException catch (e) {
      throw AuthException(e.message);
    }
  }

  @override
  Future<PaymentCheckoutInfo> donateToCampaign({
    required String campaignId,
    required DonateCampaignDto dto,
  }) async {
    try {
      final response = await _dio.post<dynamic>(
        BillingApiEndpoint.campaignDonate(campaignId),
        data: dto.toJson(),
      );
      final data = response.data['data'] as Map<String, dynamic>;
      return PaymentCheckoutInfo.fromJson(data);
    } on DioException catch (e) {
      throw ApiErrorMapper.authExceptionFrom(e);
    }
  }

  @override
  Future<String> checkTransactionStatus(String txRef) async {
    try {
      final response = await _dio.get<dynamic>(
        BillingApiEndpoint.transactionStatus(txRef),
      );
      final data = response.data['data'] as Map<String, dynamic>;
      return data['status'] as String? ?? 'UNKNOWN';
    } on DioException catch (e) {
      throw ApiErrorMapper.authExceptionFrom(e);
    }
  }

  @override
  Future<void> updateCampaign({
    required String campaignId,
    required String title,
    int? goal,
    String? endDate,
    String? description,
    UploadedMedia? newMedia,
    bool removeExistingMedia = false,
  }) async {
    try {
      if (newMedia != null) {
        final form = FormData();
        form.fields.add(MapEntry('title', title));
        if (goal != null) form.fields.add(MapEntry('goalAmount', goal.toString()));
        if (description != null) form.fields.add(MapEntry('description', description));

        final path = newMedia.filePath;
        final file = File(path);
        if (await file.exists()) {
          final segments = path.split(Platform.pathSeparator);
          final filename = segments.isNotEmpty ? segments.last : 'cover.jpg';
          form.files.add(
            MapEntry(
              'image',
              await MultipartFile.fromFile(path, filename: filename),
            ),
          );
        }

        await _dio.patch<dynamic>(
          CampaignsApiEndpoint.detail(campaignId),
          data: form,
          options: Options(
            contentType: 'multipart/form-data',
          ),
        );
      } else {
        final payload = <String, dynamic>{
          'title': title,
        };
        if (goal != null) payload['goalAmount'] = goal;
        if (description != null) payload['description'] = description;
        if (removeExistingMedia) {
          payload['imageUrl'] = null;
        }

        await _dio.patch<dynamic>(
          CampaignsApiEndpoint.detail(campaignId),
          data: payload,
        );
      }
    } on DioException catch (e) {
      throw ApiErrorMapper.authExceptionFrom(e);
    }
  }

  @override
  Future<void> deleteCampaign(String campaignId) async {
    try {
      await _dio.delete<void>(
        CampaignsApiEndpoint.detail(campaignId),
      );
    } on DioException catch (e) {
      throw ApiErrorMapper.authExceptionFrom(e);
    }
  }
}
