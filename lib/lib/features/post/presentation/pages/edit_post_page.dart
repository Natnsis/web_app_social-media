import 'package:faithconnect/injection.dart';
import 'package:faithconnect/core/services/media_upload_service.dart';
import 'package:faithconnect/core/theme/app_theme_extensions.dart';
import 'package:faithconnect/core/widgets/primary_button.dart';
import 'package:faithconnect/core/widgets/app_avatar.dart';
import 'package:faithconnect/features/home/domain/entities/post.dart';
import 'package:faithconnect/features/post/presentation/widgets/compose/post_compose_caption_field.dart';
import 'package:faithconnect/core/media/uploaded_media.dart';
import 'package:faithconnect/core/widgets/compose_media_upload_field.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';

class EditPostPage extends StatefulWidget {
  final Post post;

  const EditPostPage({super.key, required this.post});

  @override
  State<EditPostPage> createState() => _EditPostPageState();
}

class _EditPostPageState extends State<EditPostPage> {
  late final TextEditingController _controller;
  UploadedMedia? _newMedia;
  bool _removeExistingMedia = false;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.post.content);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _pickNewMedia() async {
    final colors = context.faithColors;
    final choice = await showModalBottomSheet<String>(
      context: context,
      backgroundColor: colors.cardBackground,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
      ),
      builder: (context) {
        return SafeArea(
          child: Padding(
            padding: EdgeInsets.fromLTRB(16.w, 12.h, 16.w, 16.h),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Center(
                  child: Container(
                    width: 40.w,
                    height: 4.h,
                    decoration: BoxDecoration(
                      color: colors.divider,
                      borderRadius: BorderRadius.circular(999.r),
                    ),
                  ),
                ),
                SizedBox(height: 16.h),
                Text(
                  'Change media',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.inter(
                    color: colors.primaryText,
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                SizedBox(height: 12.h),
                ListTile(
                  leading: Icon(Iconsax.image, color: colors.brandBlue),
                  title: Text(
                    'Upload Photo',
                    style: GoogleFonts.inter(color: colors.primaryText),
                  ),
                  onTap: () => Navigator.pop(context, 'image'),
                ),
                ListTile(
                  leading: Icon(Iconsax.video_play, color: colors.brandBlue),
                  title: Text(
                    'Upload Video',
                    style: GoogleFonts.inter(color: colors.primaryText),
                  ),
                  onTap: () => Navigator.pop(context, 'video'),
                ),
              ],
            ),
          ),
        );
      },
    );

    if (!context.mounted || choice == null) return;

    final service = sl<MediaUploadService>();
    final picked = choice == 'image'
        ? await service.pickImage()
        : await service.pickVideo();

    if (!context.mounted || picked == null) return;

    setState(() {
      _newMedia = picked;
      _removeExistingMedia = true;
    });
  }

  void _onSave() {
    final text = _controller.text.trim();
    if (text.isEmpty && _newMedia == null && (_removeExistingMedia || widget.post.imageUrl == null)) return;
    context.pop({
      'content': text,
      'newMedia': _newMedia,
      'removeExistingMedia': _removeExistingMedia,
    });
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.faithColors;
    final hasExistingMedia = widget.post.imageUrl != null && widget.post.imageUrl!.isNotEmpty;
    final showExistingMedia = hasExistingMedia && !_removeExistingMedia && _newMedia == null;

    return Scaffold(
      backgroundColor: colors.scaffoldBackground,
      appBar: AppBar(
        backgroundColor: colors.scaffoldBackground,
        elevation: 0,
        title: Text(
          'Edit Post',
          style: GoogleFonts.inter(
            color: colors.primaryText,
            fontSize: 16.sp,
            fontWeight: FontWeight.w600,
          ),
        ),
        leading: IconButton(
          icon: Icon(Icons.close, color: colors.primaryText),
          onPressed: () => context.pop(),
        ),
        actions: [
          Padding(
            padding: EdgeInsets.only(right: 16.w),
            child: Center(
              child: PrimaryButton(
                text: 'Update',
                onPressed: _onSave,
                height: 32.h,
                paddingVertical: 0,
                paddingHorizontal: 16.w,
                textColor: Colors.white,
              ),
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 20.h),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  AppAvatar(imageUrl: widget.post.authorAvatarUrl, size: 40),
                  SizedBox(width: 12.w),
                  Expanded(
                    child: Text(
                      widget.post.authorName,
                      style: GoogleFonts.inter(
                        color: colors.primaryText,
                        fontSize: 15.sp,
                        fontWeight: FontWeight.w600,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 20.h),
              PostComposeCaptionField(
                label: 'Post Body',
                hint: 'What\'s on your mind?',
                controller: _controller,
                maxLines: 8,
              ),
              SizedBox(height: 20.h),
              if (showExistingMedia)
                Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    GestureDetector(
                      onTap: _pickNewMedia,
                      child: Container(
                        height: 220.h,
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: colors.cardBackground,
                          borderRadius: BorderRadius.circular(20.r),
                          border: Border.all(
                            color: context.isDarkMode ? Colors.white12 : colors.divider,
                          ),
                        ),
                        clipBehavior: Clip.antiAlias,
                        child: Stack(
                          fit: StackFit.expand,
                          children: [
                            Image.network(
                              widget.post.imageUrl!,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              return Center(
                                child: Icon(
                                  Icons.broken_image,
                                  color: colors.mutedText,
                                  size: 40.r,
                                ),
                              );
                            },
                          ),
                          if (widget.post.mediaType == PostMediaType.video)
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
                                widget.post.mediaType == PostMediaType.video ? 'VIDEO' : 'IMAGE',
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
                  ),
                  SizedBox(height: 12.h),
                    TextButton.icon(
                      onPressed: () {
                        setState(() {
                          _removeExistingMedia = true;
                        });
                      },
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
                )
              else
                ComposeMediaUploadField(
                  media: _newMedia,
                  onMediaChanged: (media) {
                    setState(() {
                      _newMedia = media;
                      if (media != null && hasExistingMedia) {
                        _removeExistingMedia = true;
                      }
                    });
                  },
                  allowImage: true,
                  allowVideo: true,
                  emptyTitle: 'Add Image or Video',
                  emptySubtitle: 'Replace current media or add new',
                ),
            ],
          ),
        ),
      ),
    );
  }
}
