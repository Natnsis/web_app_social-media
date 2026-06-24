import 'dart:io';

import 'package:dio/dio.dart';

/// Multipart body for `PATCH /v1/churches/{id}`.
class UpdateChurchProfileDto {
  final String name;
  final String? bio;
  final String? locationLabel;
  final String? avatarPath;
  final String? bannerPath;

  const UpdateChurchProfileDto({
    required this.name,
    this.bio,
    this.locationLabel,
    this.avatarPath,
    this.bannerPath,
  });

  Future<FormData> toFormData() async {
    final form = FormData();

    form.fields.add(MapEntry('name', name.trim()));

    final trimmedBio = bio?.trim();
    if (trimmedBio != null && trimmedBio.isNotEmpty) {
      form.fields.add(MapEntry('description', trimmedBio));
    }

    final trimmedLocation = locationLabel?.trim();
    if (trimmedLocation != null && trimmedLocation.isNotEmpty) {
      form.fields.add(MapEntry('address', trimmedLocation));
    }

    if (avatarPath != null && avatarPath!.trim().isNotEmpty) {
      final path = avatarPath!.trim();
      final file = File(path);
      if (await file.exists()) {
        final segments = path.split(Platform.pathSeparator);
        final filename = segments.isNotEmpty ? segments.last : 'avatar.jpg';
        form.files.add(
          MapEntry(
            'logo',
            await MultipartFile.fromFile(path, filename: filename),
          ),
        );
      }
    }

    if (bannerPath != null && bannerPath!.trim().isNotEmpty) {
      final path = bannerPath!.trim();
      final file = File(path);
      if (await file.exists()) {
        final segments = path.split(Platform.pathSeparator);
        final filename = segments.isNotEmpty ? segments.last : 'banner.jpg';
        form.files.add(
          MapEntry(
            'coverImage',
            await MultipartFile.fromFile(path, filename: filename),
          ),
        );
      }
    }

    return form;
  }
}
