import 'dart:io';

import 'package:dio/dio.dart';

/// Request body for `POST /v1/comments/{id}/replies` (multipart).
class CreateCommentReplyDto {
  final String body;
  final String? mediaPath;

  const CreateCommentReplyDto({
    required this.body,
    this.mediaPath,
  });

  Future<FormData> toFormData() async {
    final form = FormData();
    form.fields.add(MapEntry('body', body.trim()));

    final path = mediaPath?.trim();
    if (path != null && path.isNotEmpty) {
      final file = File(path);
      if (await file.exists()) {
        final segments = path.split(Platform.pathSeparator);
        final filename = segments.isNotEmpty ? segments.last : 'reply.jpg';
        form.files.add(
          MapEntry(
            'media',
            await MultipartFile.fromFile(path, filename: filename),
          ),
        );
      }
    }

    return form;
  }
}
