import 'package:equatable/equatable.dart';
import 'package:faithconnect/core/network/api_list_response.dart';
import 'package:faithconnect/features/church/domain/entities/following_church.dart';

class FollowingChurchesResult extends Equatable {
  final List<FollowingChurch> churches;
  final ApiListMeta meta;

  const FollowingChurchesResult({
    required this.churches,
    required this.meta,
  });

  @override
  List<Object?> get props => [churches, meta];
}
