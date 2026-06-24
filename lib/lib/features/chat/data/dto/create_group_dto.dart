import 'dart:io';

import 'package:dio/dio.dart';

/// Multipart body for `POST /v1/groups`.
class CreateGroupDto {
  final String name;
  final String? description;
  final bool isPrivate;
  final String? imagePath;

  const CreateGroupDto({
    required this.name,
    this.description,
    this.isPrivate = false,
    this.imagePath,
  });

  Future<FormData> toFormData() async {
    final form = FormData();

    form.fields.add(MapEntry('name', name));
    form.fields.add(MapEntry('isPrivate', isPrivate.toString()));

    final desc = description?.trim();
    if (desc != null && desc.isNotEmpty) {
      form.fields.add(MapEntry('description', desc));
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
