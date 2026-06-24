import 'package:equatable/equatable.dart';
import 'package:faithconnect/core/network/api_list_response.dart';
import 'package:faithconnect/features/church/domain/entities/church_profile.dart';

class ChurchesListResult extends Equatable {
  final List<ChurchProfile> churches;
  final ApiListMeta meta;

  const ChurchesListResult({
    required this.churches,
    required this.meta,
  });

  @override
  List<Object?> get props => [churches, meta];
}
