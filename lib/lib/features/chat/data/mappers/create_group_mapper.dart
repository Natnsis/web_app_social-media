import 'package:faithconnect/features/chat/data/dto/create_group_dto.dart';
import 'package:faithconnect/features/chat/domain/entities/new_group_draft.dart';

abstract final class CreateGroupMapper {
  CreateGroupMapper._();

  static CreateGroupDto fromDraft(NewGroupDraft draft) {
    return CreateGroupDto(
      name: draft.name.trim(),
      description: draft.description.trim(),
      isPrivate: draft.isPrivate,
      imagePath: draft.coverImagePath,
    );
  }
}
