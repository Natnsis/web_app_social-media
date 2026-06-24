import 'dart:io';

import 'package:faithconnect/core/media/uploaded_media.dart';
import 'package:faithconnect/core/theme/dark_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';

/// Renders [UploadedMedia] with saved alignment and fit for feed / detail views.
class UploadedMediaPreview extends StatelessWidget {
  final UploadedMedia media;
  final double height;
  final BorderRadius? borderRadius;

  const UploadedMediaPreview({
    super.key,
    required this.media,
    this.height = 220,
    this.borderRadius,
  });

  @override
  Widget build(BuildContext context) {
    final radius = borderRadius ?? BorderRadius.circular(16.r);

    return ClipRRect(
      borderRadius: radius,
      child: SizedBox(
        height: height.h,
        width: double.infinity,
        child: Stack(
          fit: StackFit.expand,
          children: [
            ColoredBox(color: DarkTheme.feedTagBackground),
            Align(
              alignment: media.alignment.alignment,
              child: _buildMedia(),
            ),
            if (media.kind == MediaUploadKind.video)
              Center(
                child: Icon(
                  Icons.play_circle_fill,
                  color: Colors.white.withValues(alpha: 0.9),
                  size: 48.r,
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildMedia() {
    final file = File(media.filePath);
    if (!file.existsSync()) {
      return Icon(Iconsax.gallery_slash, color: DarkTheme.feedMutedText);
    }

    if (media.kind == MediaUploadKind.image) {
      return Image.file(
        file,
        fit: media.displayFit.boxFit,
        width: media.displayFit == MediaDisplayFit.fitWidth
            ? double.infinity
            : null,
      );
    }

    return const SizedBox.shrink();
  }
}
