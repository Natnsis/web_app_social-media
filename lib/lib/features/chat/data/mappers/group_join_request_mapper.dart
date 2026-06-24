import 'package:faithconnect/core/utils/media_url_resolver.dart';
import 'package:faithconnect/features/chat/data/dto/group_join_request_api_dto.dart';
import 'package:faithconnect/features/chat/domain/entities/group_join_request.dart';

abstract final class GroupJoinRequestMapper {
  GroupJoinRequestMapper._();

  static GroupJoinRequest fromDto(GroupJoinRequestApiDto dto) {
    return GroupJoinRequest(
      id: dto.id,
      userId: dto.userId,
      userName: dto.userName,
      avatarUrl: MediaUrlResolver.normalize(dto.avatarUrl, imageOnly: true),
      requestedAt: dto.requestedAt,
    );
  }
}
