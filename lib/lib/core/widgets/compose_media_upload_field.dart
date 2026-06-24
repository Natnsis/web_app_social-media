import 'dart:io';

import 'package:faithconnect/core/core.dart';
import 'package:faithconnect/injection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';

/// Gallery picker with alignment / fit controls and live preview.
class ComposeMediaUploadField extends StatelessWidget {
  final UploadedMedia? media;
  final ValueChanged<UploadedMedia?> onMediaChanged;
  final bool allowImage;
  final bool allowVideo;
  final double previewHeight;
  final String emptyTitle;
  final String emptySubtitle;

  const ComposeMediaUploadField({
    super.key,
    required this.media,
    required this.onMediaChanged,
    this.allowImage = true,
    this.allowVideo = true,
    this.previewHeight = 220,
    this.emptyTitle = 'Add media',
    this.emptySubtitle = 'Tap to upload an image or video',
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.faithColors;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _MediaPreview(
          media: media,
          height: previewHeight,
          emptyTitle: emptyTitle,
          emptySubtitle: emptySubtitle,
          onTap: () => _openPicker(context),
        ),
        if (media != null) ...[
          SizedBox(height: 16.h),
          _OptionSection(
            title: 'Alignment',
            child: _ChipRow<MediaContentAlignment>(
              values: MediaContentAlignment.values,
              selected: media!.alignment,
              labelBuilder: (v) => v.label,
              onSelected: (value) => onMediaChanged(media!.copyWith(alignment: value)),
            ),
          ),
          SizedBox(height: 12.h),
          _OptionSection(
            title: 'Formatting',
            child: _ChipRow<MediaDisplayFit>(
              values: MediaDisplayFit.values,
              selected: media!.displayFit,
              labelBuilder: (v) => v.label,
              onSelected: (value) => onMediaChanged(media!.copyWith(displayFit: value)),
            ),
          ),
          SizedBox(height: 12.h),
          TextButton.icon(
            onPressed: () => onMediaChanged(null),
            icon: Icon(Iconsax.trash, size: 18.r, color: colors.mutedText),
            label: Text(
              'Remove media',
              style: GoogleFonts.inter(
                color: colors.mutedText,
                fontSize: 14.sp,
              ),
            ),
          ),
        ],
      ],
    );
  }

  Future<void> _openPicker(BuildContext context) async {
    final service = sl<MediaUploadService>();
    final sheetColors = context.faithColors;
    final choice = await showModalBottomSheet<_MediaPickAction>(
      context: context,
      backgroundColor: sheetColors.cardBackground,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
      ),
      builder: (context) => _MediaPickSheet(
        allowImage: allowImage,
        allowVideo: allowVideo,
      ),
    );

    if (!context.mounted || choice == null) return;

    final picked = switch (choice) {
      _MediaPickAction.image => await service.pickImage(),
      _MediaPickAction.video => await service.pickVideo(),
    };

    if (!context.mounted || picked == null) return;

    onMediaChanged(
      picked.copyWith(
        alignment: media?.alignment ?? MediaContentAlignment.center,
        displayFit: media?.displayFit ?? MediaDisplayFit.cover,
      ),
    );
  }
}

enum _MediaPickAction { image, video }

class _MediaPickSheet extends StatelessWidget {
  final bool allowImage;
  final bool allowVideo;

  const _MediaPickSheet({
    required this.allowImage,
    required this.allowVideo,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.faithColors;

    return SafeArea(
      child: Padding(
        padding: EdgeInsets.fromLTRB(16.w, 12.h, 16.w, 16.h),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40.w,
              height: 4.h,
              decoration: BoxDecoration(
                color: colors.mutedText.withValues(alpha: 0.35),
                borderRadius: BorderRadius.circular(999.r),
              ),
            ),
            SizedBox(height: 16.h),
            Text(
              'Upload media',
              style: GoogleFonts.inter(
                color: colors.primaryText,
                fontSize: 17.sp,
                fontWeight: FontWeight.w600,
              ),
            ),
            SizedBox(height: 16.h),
            if (allowImage)
              ListTile(
                leading: Icon(Iconsax.gallery, color: colors.brandBlue),
                title: Text(
                  'Photo from gallery',
                  style: TextStyle(color: colors.primaryText),
                ),
                onTap: () => Navigator.pop(context, _MediaPickAction.image),
              ),
            if (allowVideo)
              ListTile(
                leading: Icon(Iconsax.video, color: colors.brandBlue),
                title: Text(
                  'Video from gallery',
                  style: TextStyle(color: colors.primaryText),
                ),
                onTap: () => Navigator.pop(context, _MediaPickAction.video),
              ),
          ],
        ),
      ),
    );
  }
}

class _MediaPreview extends StatelessWidget {
  final UploadedMedia? media;
  final double height;
  final String emptyTitle;
  final String emptySubtitle;
  final VoidCallback onTap;

  const _MediaPreview({
    required this.media,
    required this.height,
    required this.emptyTitle,
    required this.emptySubtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.faithColors;
    final isDark = context.isDarkMode;

    if (media == null) {
      return MediaUploadPlaceholder(
        icon: Iconsax.gallery_add,
        title: emptyTitle,
        subtitle: emptySubtitle,
        height: height,
        onTap: onTap,
      );
    }

    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: height.h,
        width: double.infinity,
        decoration: BoxDecoration(
          color: colors.cardBackground,
          borderRadius: BorderRadius.circular(20.r),
          border: Border.all(
            color: isDark
                ? Colors.white12
                : colors.divider,
          ),
        ),
        clipBehavior: Clip.antiAlias,
        child: Stack(
          fit: StackFit.expand,
          children: [
            Align(
              alignment: media!.alignment.alignment,
              child: _MediaFilePreview(media: media!),
            ),
            if (media!.kind == MediaUploadKind.video)
              Center(
                child: Container(
                  width: 56.r,
                  height: 56.r,
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.5),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.play_arrow_rounded,
                    color: Colors.white,
                    size: 36.r,
                  ),
                ),
              ),
            Positioned(
              top: 10.h,
              right: 10.w,
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.55),
                  borderRadius: BorderRadius.circular(999.r),
                ),
                child: Text(
                  media!.kind == MediaUploadKind.video ? 'VIDEO' : 'IMAGE',
                  style: GoogleFonts.inter(
                    color: Colors.white,
                    fontSize: 10.sp,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.6,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MediaFilePreview extends StatelessWidget {
  final UploadedMedia media;

  const _MediaFilePreview({required this.media});

  @override
  Widget build(BuildContext context) {
    final colors = context.faithColors;
    final file = File(media.filePath);
    if (!file.existsSync()) {
      return Icon(Iconsax.gallery_slash, color: colors.mutedText, size: 40.r);
    }

    if (media.kind == MediaUploadKind.image) {
      return Image.file(
        file,
        fit: media.displayFit.boxFit,
        width: media.displayFit == MediaDisplayFit.fitWidth ? double.infinity : null,
        height: media.displayFit == MediaDisplayFit.contain ? double.infinity : null,
      );
    }

    return Container(
      color: colors.tagBackground,
      width: double.infinity,
      height: double.infinity,
      alignment: Alignment.center,
      child: Icon(Iconsax.video, color: colors.mutedText, size: 48.r),
    );
  }
}

class _OptionSection extends StatelessWidget {
  final String title;
  final Widget child;

  const _OptionSection({required this.title, required this.child});

  @override
  Widget build(BuildContext context) {
    final colors = context.faithColors;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: GoogleFonts.inter(
            color: colors.mutedText,
            fontSize: 12.sp,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.4,
          ),
        ),
        SizedBox(height: 8.h),
        child,
      ],
    );
  }
}

class _ChipRow<T> extends StatelessWidget {
  final List<T> values;
  final T selected;
  final String Function(T) labelBuilder;
  final ValueChanged<T> onSelected;

  const _ChipRow({
    required this.values,
    required this.selected,
    required this.labelBuilder,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.faithColors;
    final isDark = context.isDarkMode;

    return Wrap(
      spacing: 8.w,
      runSpacing: 8.h,
      children: values.map((value) {
        final isSelected = value == selected;
        return GestureDetector(
          onTap: () => onSelected(value),
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 8.h),
            decoration: BoxDecoration(
              color: isSelected ? colors.brandBlue : colors.tagBackground,
              borderRadius: BorderRadius.circular(999.r),
              border: Border.all(
                color: isSelected
                    ? colors.brandBlue
                    : (isDark ? Colors.white12 : colors.divider),
              ),
            ),
            child: Text(
              labelBuilder(value),
              style: GoogleFonts.inter(
                color: isSelected ? Colors.white : colors.mutedText,
                fontSize: 13.sp,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}
