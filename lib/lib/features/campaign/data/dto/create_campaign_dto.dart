import 'dart:io';

import 'package:dio/dio.dart';

/// Request body for `POST /v1/campaigns`.
class CreateCampaignDto {
  final String title;
  final String description;
  final double goalAmount;
  final String startAt;
  final String? endAt;
  final bool isActive;
  final String? status;
  final String? imagePath;

  const CreateCampaignDto({
    required this.title,
    required this.description,
    required this.goalAmount,
    required this.startAt,
    this.endAt,
    this.isActive = true,
    this.status,
    this.imagePath,
  });

  bool get hasImage =>
      imagePath != null && imagePath!.trim().isNotEmpty;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{
      'title': title,
      'description': description,
      'goalAmount': goalAmount,
      'startAt': startAt,
      'isActive': isActive,
    };
    if (endAt != null && endAt!.isNotEmpty) {
      map['endAt'] = endAt;
    }
    final statusValue = status?.trim();
    if (statusValue != null && statusValue.isNotEmpty) {
      map['status'] = statusValue;
    }
    return map;
  }

  Future<FormData> toFormData() async {
    final form = FormData();

    form.fields.add(MapEntry('title', title));
    form.fields.add(MapEntry('description', description));
    form.fields.add(MapEntry('goalAmount', goalAmount.toString()));
    form.fields.add(MapEntry('startAt', startAt));
    form.fields.add(MapEntry('isActive', isActive.toString()));

    if (endAt != null && endAt!.isNotEmpty) {
      form.fields.add(MapEntry('endAt', endAt!));
    }

    final statusValue = status?.trim();
    if (statusValue != null && statusValue.isNotEmpty) {
      form.fields.add(MapEntry('status', statusValue));
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
