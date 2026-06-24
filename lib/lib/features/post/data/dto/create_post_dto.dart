import 'dart:convert';
import 'dart:io';

import 'package:dio/dio.dart';

/// Request body for `POST /v1/posts`.
class CreatePostDto {
  final String? title;
  final String content;
  final bool isTagged;
  final List<String> novaFileIds;
  final List<String> filePaths;

  const CreatePostDto({
    this.title,
    required this.content,
    this.isTagged = false,
    this.novaFileIds = const [],
    this.filePaths = const [],
  });

  bool get hasMultipartPayload => filePaths.isNotEmpty;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{
      'content': content,
      'isTagged': isTagged,
    };
    final trimmedTitle = title?.trim();
    if (trimmedTitle != null && trimmedTitle.isNotEmpty) {
      map['title'] = trimmedTitle;
    }
    if (novaFileIds.isNotEmpty) {
      map['novaFileIds'] = jsonEncode(novaFileIds);
    }
    return map;
  }

  Future<FormData> toFormData() async {
    final form = FormData();

    final trimmedTitle = title?.trim();
    if (trimmedTitle != null && trimmedTitle.isNotEmpty) {
      form.fields.add(MapEntry('title', trimmedTitle));
    }

    form.fields.add(MapEntry('content', content));
    form.fields.add(MapEntry('isTagged', isTagged.toString()));

    if (novaFileIds.isNotEmpty) {
      form.fields.add(MapEntry('novaFileIds', jsonEncode(novaFileIds)));
    }

    for (final path in filePaths) {
      final file = File(path);
      if (!await file.exists()) continue;

      final segments = path.split(Platform.pathSeparator);
      final filename = segments.isNotEmpty ? segments.last : 'upload';
      form.files.add(
        MapEntry(
          'files',
          await MultipartFile.fromFile(
            path,
            filename: filename,
          ),
        ),
      );
    }

    return form;
  }

}
