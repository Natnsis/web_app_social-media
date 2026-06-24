import 'dart:io';

import 'package:dio/dio.dart';

/// Request body for `POST /v1/events` (multipart/form-data).
class CreateEventDto {
  final String title;
  final String description;
  final String date;
  final String time;
  final bool isActive;
  final String? imagePath;

  const CreateEventDto({
    required this.title,
    required this.description,
    required this.date,
    required this.time,
    this.isActive = true,
    this.imagePath,
  });

  bool get hasImage =>
      imagePath != null && imagePath!.trim().isNotEmpty;

  Future<FormData> toFormData() async {
    final form = FormData();

    form.fields.add(MapEntry('title', title));
    form.fields.add(MapEntry('date', date));
    form.fields.add(MapEntry('time', time));
    form.fields.add(MapEntry('isActive', isActive.toString()));

    final descriptionValue = description.trim();
    if (descriptionValue.isNotEmpty) {
      form.fields.add(MapEntry('description', descriptionValue));
    }

    final path = imagePath?.trim();
    if (path != null && path.isNotEmpty) {
      final file = File(path);
      if (await file.exists()) {
        final segments = path.split(Platform.pathSeparator);
        final filename = segments.isNotEmpty ? segments.last : 'cover.jpg';
        form.files.add(
          MapEntry(
            'image',
            await MultipartFile.fromFile(path, filename: filename),
          ),
        );
      }
    }

    return form;
  }
}
