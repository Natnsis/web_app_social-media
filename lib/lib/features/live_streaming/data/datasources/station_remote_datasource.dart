import 'package:dio/dio.dart';
import 'package:faithconnect/features/live_streaming/data/models/station_model.dart';

abstract class StationRemoteDataSource {
  Future<List<StationModel>> getStations({int? limit, int? offset});
  Future<StationModel> getStationById(String id);
  Future<StationModel> createStation({required String name, required String description, required String type});
  Future<StationModel> updateStation({required String novaStreamId, required String name, required String description, required String type});
  Future<void> deleteStation(String novaStreamId);
}

class StationRemoteDataSourceImpl implements StationRemoteDataSource {
  final Dio _dio;
  static const _base = '/v1/stations';

  StationRemoteDataSourceImpl(this._dio);

  @override
  Future<List<StationModel>> getStations({int? limit, int? offset}) async {
    final params = <String, dynamic>{};
    if (limit != null) params['limit'] = limit;
    if (offset != null) params['offset'] = offset;

    final resp = await _dio.get(_base, queryParameters: params);
    if (resp.statusCode == 200) {
      final data = resp.data as Map<String, dynamic>;
      final dynamic rawData = data['data'];
      
      List<dynamic> list;
      if (rawData is List) {
        list = rawData;
      } else if (rawData is Map) {
        list = [rawData];
      } else {
        list = [];
      }
      
      return list.cast<Map<String, dynamic>>().map((e) => StationModel.fromJson(e)).toList();
    }
    throw Exception('Failed to fetch stations');
  }

  @override
  Future<StationModel> getStationById(String id) async {
    final resp = await _dio.get('$_base/$id');
    if (resp.statusCode == 200) {
      final data = resp.data as Map<String, dynamic>;
      return StationModel.fromJson(data['data'] ?? data);
    }
    throw Exception('Failed to fetch station');
  }

  @override
  Future<StationModel> createStation({required String name, required String description, required String type}) async {
    final resp = await _dio.post(_base, data: {'name': name, 'description': description, 'type': type});
    if (resp.statusCode == 201 || resp.statusCode == 200) {
      final data = resp.data as Map<String, dynamic>;
      return StationModel.fromJson(data['data'] ?? data);
    }
    throw Exception('Failed to create station');
  }

  @override
  Future<StationModel> updateStation({required String novaStreamId, required String name, required String description, required String type}) async {
    final resp = await _dio.patch('$_base/$novaStreamId', data: {'name': name, 'description': description, 'type': type});
    if (resp.statusCode == 200) {
      final data = resp.data as Map<String, dynamic>;
      return StationModel.fromJson(data['data'] ?? data);
    }
    throw Exception('Failed to update station');
  }

  @override
  Future<void> deleteStation(String novaStreamId) async {
    final resp = await _dio.delete('$_base/$novaStreamId');
    if (resp.statusCode == 204 || resp.statusCode == 200) return;
    throw Exception('Failed to delete station');
  }
}
