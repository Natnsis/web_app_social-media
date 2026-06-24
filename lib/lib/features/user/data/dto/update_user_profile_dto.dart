import 'dart:io';

import 'package:dio/dio.dart';

/// Multipart body for `PATCH /v1/users/me`.
class UpdateUserProfileDto {
  final String fullName;
  final String? bio;
  final String email;
  final String phoneNumber;
  final String? avatarPath;

  const UpdateUserProfileDto({
    required this.fullName,
    this.bio,
    required this.email,
    required this.phoneNumber,
    this.avatarPath,
  });

  Future<FormData> toFormData() async {
    final form = FormData();

    form.fields.add(MapEntry('fullName', fullName.trim()));

    final trimmedBio = bio?.trim();
    if (trimmedBio != null && trimmedBio.isNotEmpty) {
      form.fields.add(MapEntry('bio', trimmedBio));
    }

    form.fields.add(MapEntry('email', email.trim()));
    form.fields.add(MapEntry('phoneNumber', phoneNumber.trim()));

    final path = avatarPath?.trim();
    if (path != null && path.isNotEmpty) {
      final file = File(path);
      if (!await file.exists()) {
        throw const FormatException('Profile photo file not found.');
      }
      final segments = path.split(Platform.pathSeparator);
      final filename = segments.isNotEmpty ? segments.last : 'avatar.jpg';
      form.files.add(
        MapEntry(
          'avatar',
          await MultipartFile.fromFile(path, filename: filename),
        ),
      );
    }

    return form;
  }
}
