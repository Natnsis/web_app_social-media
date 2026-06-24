import 'package:faithconnect/core/core.dart';
import 'package:faithconnect/features/post/domain/entities/post_compose_draft.dart';
import 'package:faithconnect/features/post/presentation/bloc/post_compose_bloc.dart';
import 'package:faithconnect/features/post/presentation/bloc/post_compose_event.dart';
import 'package:faithconnect/features/post/presentation/widgets/compose/post_compose_caption_field.dart';
import 'package:faithconnect/features/post/presentation/widgets/compose/post_compose_settings.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
class ImageComposeBody extends StatefulWidget {
  final PostComposeDraft draft;

  const ImageComposeBody({super.key, required this.draft});

  @override
  State<ImageComposeBody> createState() => _ImageComposeBodyState();
}

class _ImageComposeBodyState extends State<ImageComposeBody> {
  late final TextEditingController _captionController;

  @override
  void initState() {
    super.initState();
    _captionController = TextEditingController(text: widget.draft.caption);
  }

  @override
  void dispose() {
    _captionController.dispose();
    super.dispose();
  }

  void _updateDraft(PostComposeDraft draft) {
    context.read<PostComposeBloc>().add(PostComposeDraftUpdated(draft));
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        ComposeMediaUploadField(
          media: widget.draft.uploadedMedia,
          onMediaChanged: (media) => _updateDraft(
            widget.draft.copyWith(
              uploadedMedia: media,
              clearUploadedMedia: media == null,
            ),
          ),
          allowImage: true,
          allowVideo: false,
          emptyTitle: 'Add Image',
          emptySubtitle: 'High resolution recommended',
        ),
        SizedBox(height: 20.h),
        PostComposeCaptionField(
          controller: _captionController,
          onChanged: (value) =>
              _updateDraft(widget.draft.copyWith(caption: value)),
        ),
        SizedBox(height: 16.h),
        const PostComposeSettings(showNotifyCommunity: false),
      ],
    );
  }
}

class VideoComposeBody extends StatefulWidget {
  final PostComposeDraft draft;

  const VideoComposeBody({super.key, required this.draft});

  @override
  State<VideoComposeBody> createState() => _VideoComposeBodyState();
}

class _VideoComposeBodyState extends State<VideoComposeBody> {
  late final TextEditingController _descriptionController;

  @override
  void initState() {
    super.initState();
    _descriptionController =
        TextEditingController(text: widget.draft.description);
  }

  @override
  void dispose() {
    _descriptionController.dispose();
    super.dispose();
  }

  void _updateDraft(PostComposeDraft draft) {
    context.read<PostComposeBloc>().add(PostComposeDraftUpdated(draft));
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        ComposeMediaUploadField(
          media: widget.draft.uploadedMedia,
          onMediaChanged: (media) => _updateDraft(
            widget.draft.copyWith(
              uploadedMedia: media,
              clearUploadedMedia: media == null,
            ),
          ),
          allowImage: false,
          allowVideo: true,
          previewHeight: 200,
          emptyTitle: 'Upload Video',
          emptySubtitle: 'MP4, MOV up to 500MB',
        ),
        SizedBox(height: 20.h),
        PostComposeDescriptionField(
          controller: _descriptionController,
          onChanged: (value) =>
              _updateDraft(widget.draft.copyWith(description: value)),
        ),
        SizedBox(height: 16.h),
        const PostComposeSettings(showNotifyCommunity: false),
      ],
    );
  }
}

class ShortComposeBody extends StatefulWidget {
  final PostComposeDraft draft;

  const ShortComposeBody({super.key, required this.draft});

  @override
  State<ShortComposeBody> createState() => _ShortComposeBodyState();
}

class _ShortComposeBodyState extends State<ShortComposeBody> {
  late final TextEditingController _captionController;

  @override
  void initState() {
    super.initState();
    _captionController = TextEditingController(text: widget.draft.caption);
  }

  @override
  void dispose() {
    _captionController.dispose();
    super.dispose();
  }

  void _updateDraft(PostComposeDraft draft) {
    context.read<PostComposeBloc>().add(PostComposeDraftUpdated(draft));
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        ComposeMediaUploadField(
          media: widget.draft.uploadedMedia,
          onMediaChanged: (media) {
            if (media != null && media.kind != MediaUploadKind.video) {
              showWarning(context, 'Shorts require a vertical video.');
              return;
            }
            _updateDraft(
              widget.draft.copyWith(
                uploadedMedia: media,
                clearUploadedMedia: media == null,
              ),
            );
          },
          allowImage: false,
          allowVideo: true,
          previewHeight: 320,
          emptyTitle: 'Tap to Upload Short',
          emptySubtitle: 'Vertical video (up to 60s)',
        ),
        SizedBox(height: 20.h),
        PostComposeCaptionField(
          controller: _captionController,
          onChanged: (value) =>
              _updateDraft(widget.draft.copyWith(caption: value)),
        ),
        SizedBox(height: 16.h),
        const PostComposeSettings(),
      ],
    );
  }
}

class AttachmentComposeBody extends StatefulWidget {
  final PostComposeDraft draft;

  const AttachmentComposeBody({super.key, required this.draft});

  @override
  State<AttachmentComposeBody> createState() => _AttachmentComposeBodyState();
}

class _AttachmentComposeBodyState extends State<AttachmentComposeBody> {
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        ComposeMediaUploadField(
          media: widget.draft.uploadedMedia,
          onMediaChanged: (media) => context.read<PostComposeBloc>().add(
                PostComposeDraftUpdated(
                  widget.draft.copyWith(
                    uploadedMedia: media,
                    clearUploadedMedia: media == null,
                  ),
                ),
              ),
          allowImage: true,
          allowVideo: true,
          previewHeight: 200,
          emptyTitle: 'Add Attachment',
          emptySubtitle: 'Image or video files',
        ),
        SizedBox(height: 16.h),
        const PostComposeSettings(),
      ],
    );
  }
}
