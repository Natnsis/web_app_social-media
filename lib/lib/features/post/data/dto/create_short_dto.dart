import 'dart:io';

import 'package:dio/dio.dart';

/// Request body for `POST /v1/shorts` (multipart).
class CreateShortDto {
  final String? title;
  final String? description;
  final String videoPath;

  const CreateShortDto({
    this.title,
    this.description,
    required this.videoPath,
  });

  Future<FormData> toFormData() async {
    final form = FormData();

    final trimmedTitle = title?.trim();
    if (trimmedTitle != null && trimmedTitle.isNotEmpty) {
      form.fields.add(MapEntry('title', trimmedTitle));
    }

    final trimmedDescription = description?.trim();
    if (trimmedDescription != null && trimmedDescription.isNotEmpty) {
      form.fields.add(MapEntry('description', trimmedDescription));
    }

    final file = File(videoPath);
    if (!await file.exists()) {
      throw const FormatException('Short video file not found.');
    }

    final segments = videoPath.split(Platform.pathSeparator);
    final filename = segments.isNotEmpty ? segments.last : 'short.mp4';

    form.files.add(
      MapEntry(
        'video',
        await MultipartFile.fromFile(videoPath, filename: filename),
      ),
    );

    return form;
  }
}
