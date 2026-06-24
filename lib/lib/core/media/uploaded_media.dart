import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

enum MediaUploadKind {
  image,
  video,
}

enum MediaContentAlignment {
  left,
  center,
  right,
}

enum MediaDisplayFit {
  cover,
  contain,
  fitWidth,
}

extension MediaContentAlignmentX on MediaContentAlignment {
  String get label => switch (this) {
        MediaContentAlignment.left => 'Left',
        MediaContentAlignment.center => 'Center',
        MediaContentAlignment.right => 'Right',
      };

  Alignment get alignment => switch (this) {
        MediaContentAlignment.left => Alignment.centerLeft,
        MediaContentAlignment.center => Alignment.center,
        MediaContentAlignment.right => Alignment.centerRight,
      };
}

extension MediaDisplayFitX on MediaDisplayFit {
  String get label => switch (this) {
        MediaDisplayFit.cover => 'Cover',
        MediaDisplayFit.contain => 'Contain',
        MediaDisplayFit.fitWidth => 'Fit width',
      };

  BoxFit get boxFit => switch (this) {
        MediaDisplayFit.cover => BoxFit.cover,
        MediaDisplayFit.contain => BoxFit.contain,
        MediaDisplayFit.fitWidth => BoxFit.fitWidth,
      };
}

/// Local file selected for a post (image or video) with display preferences.
class UploadedMedia extends Equatable {
  final String filePath;
  final MediaUploadKind kind;
  final MediaContentAlignment alignment;
  final MediaDisplayFit displayFit;

  const UploadedMedia({
    required this.filePath,
    required this.kind,
    this.alignment = MediaContentAlignment.center,
    this.displayFit = MediaDisplayFit.cover,
  });

  UploadedMedia copyWith({
    String? filePath,
    MediaUploadKind? kind,
    MediaContentAlignment? alignment,
    MediaDisplayFit? displayFit,
  }) {
    return UploadedMedia(
      filePath: filePath ?? this.filePath,
      kind: kind ?? this.kind,
      alignment: alignment ?? this.alignment,
      displayFit: displayFit ?? this.displayFit,
    );
  }

  @override
  List<Object?> get props => [filePath, kind, alignment, displayFit];
}
