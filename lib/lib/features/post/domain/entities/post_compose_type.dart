import 'package:flutter/material.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';

enum PostComposeType {
  post,
  image,
  video,
  short,
  event,
  scripture,
  attachment;

  String get label {
    switch (this) {
      case PostComposeType.post:
        return 'Post';
      case PostComposeType.image:
        return 'Image';
      case PostComposeType.video:
        return 'Video';
      case PostComposeType.short:
        return 'Short';
      case PostComposeType.event:
        return 'Event';
      case PostComposeType.scripture:
        return 'Scripture';
      case PostComposeType.attachment:
        return 'Attachment';
    }
  }

  IconData? get icon {
    switch (this) {
      case PostComposeType.post:
        return Iconsax.document_text;
      case PostComposeType.image:
        return Iconsax.gallery;
      case PostComposeType.video:
        return Iconsax.video;
      case PostComposeType.short:
        return Iconsax.video_play;
      case PostComposeType.event:
        return Iconsax.calendar;
      case PostComposeType.scripture:
        return Iconsax.book;
      case PostComposeType.attachment:
        return Iconsax.paperclip;
    }
  }

  static const List<PostComposeType> tabOrder = [
    PostComposeType.post,
    PostComposeType.image,
    PostComposeType.video,
    PostComposeType.short,
    PostComposeType.event,
    PostComposeType.scripture,
    PostComposeType.attachment,
  ];
}
