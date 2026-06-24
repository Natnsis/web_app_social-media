import 'package:dartz/dartz.dart';
import 'package:faithconnect/core/error/failures.dart';
import 'package:faithconnect/features/live_streaming/domain/entities/station.dart';

abstract class StationRepository {
  Future<Either<Failure, List<Station>>> getStations({int? limit, int? offset});
  Future<Either<Failure, Station>> getStationById(String id);
  Future<Either<Failure, Station>> createStation({required String name, required String description, required String type});
  Future<Either<Failure, Station>> updateStation({required String novaStreamId, required String name, required String description, required String type});
  Future<Either<Failure, void>> deleteStation(String novaStreamId);
}
