import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:faithconnect/core/error/failures.dart';
import 'package:faithconnect/features/live_streaming/data/datasources/station_remote_datasource.dart';
import 'package:faithconnect/features/live_streaming/domain/entities/station.dart';
import 'package:faithconnect/features/live_streaming/domain/repositories/station_repository.dart';

class StationRepositoryImpl implements StationRepository {
  final StationRemoteDataSource remoteDataSource;

  StationRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Either<Failure, List<Station>>> getStations({int? limit, int? offset}) async {
    try {
      final models = await remoteDataSource.getStations(limit: limit, offset: offset);
      return Right(models);
    } on DioException catch (e) {
      return Left(ServerFailure(message: e.message ?? 'Failed to fetch stations'));
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, Station>> getStationById(String id) async {
    try {
      final model = await remoteDataSource.getStationById(id);
      return Right(model);
    } on DioException catch (e) {
      return Left(ServerFailure(message: e.message ?? 'Failed to fetch station'));
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, Station>> createStation({required String name, required String description, required String type}) async {
    try {
      final model = await remoteDataSource.createStation(name: name, description: description, type: type);
      return Right(model);
    } on DioException catch (e) {
      return Left(ServerFailure(message: e.message ?? 'Failed to create station'));
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, Station>> updateStation({required String novaStreamId, required String name, required String description, required String type}) async {
    try {
      final model = await remoteDataSource.updateStation(novaStreamId: novaStreamId, name: name, description: description, type: type);
      return Right(model);
    } on DioException catch (e) {
      return Left(ServerFailure(message: e.message ?? 'Failed to update station'));
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> deleteStation(String novaStreamId) async {
    try {
      await remoteDataSource.deleteStation(novaStreamId);
      return const Right(null);
    } on DioException catch (e) {
      return Left(ServerFailure(message: e.message ?? 'Failed to delete station'));
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }
}
