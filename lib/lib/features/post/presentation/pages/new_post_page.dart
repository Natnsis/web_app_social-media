import 'package:faithconnect/core/core.dart';
import 'package:faithconnect/features/post/domain/entities/post_compose_draft.dart';
import 'package:faithconnect/features/post/domain/entities/post_compose_type.dart';
import 'package:faithconnect/features/event/presentation/bloc/events_feed_bloc.dart';
import 'package:faithconnect/features/event/presentation/bloc/events_feed_event.dart';
import 'package:faithconnect/features/post/presentation/bloc/post_compose_bloc.dart';
import 'package:faithconnect/features/post/presentation/bloc/post_compose_event.dart';
import 'package:faithconnect/features/post/presentation/bloc/post_compose_state.dart';
import 'package:faithconnect/features/post/presentation/widgets/compose/event_compose_body.dart';
import 'package:faithconnect/features/post/presentation/widgets/compose/media_compose_body.dart';
import 'package:faithconnect/features/post/presentation/widgets/compose/post_compose_caption_field.dart';
import 'package:faithconnect/features/post/presentation/widgets/compose/scripture_compose_body.dart';
import 'package:faithconnect/features/post/presentation/widgets/short_publish_countdown_overlay.dart';
import 'package:faithconnect/features/shortvideo/presentation/navigation/shorts_navigation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';

class NewPostPage extends StatefulWidget {
  const NewPostPage({super.key});

  @override
  State<NewPostPage> createState() => _NewPostPageState();
}

class _NewPostPageState extends State<NewPostPage> {
  static const List<PostComposeType> _supportedTypes = [
    PostComposeType.post,
    PostComposeType.short,
    PostComposeType.event,
    PostComposeType.scripture,
  ];

  bool _showShortPublishCountdown = false;

  void _onPublishSuccess(BuildContext context, PostComposePublishSuccess state) {
    if (state.composeType == PostComposeType.short) {
      setState(() => _showShortPublishCountdown = true);
      return;
    }

    if (state.message == 'Event published') {
      context.read<EventsFeedBloc>().add(const EventsFeedRefreshed());
    }
    showSuccess(context, state.message);
    context.pop();
  }

  void _onShortPublishCountdownComplete(BuildContext context) {
    if (!mounted) return;
    showSuccess(context, 'Short published');
    ShortsNavigation.openAfterPublish(context);
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.faithColors;

    return Stack(
      children: [
        Scaffold(
          backgroundColor: colors.scaffoldBackground,
          body: SafeArea(
            child: BlocConsumer<PostComposeBloc, PostComposeState>(
              listener: (context, state) {
                if (state is PostComposePublishSuccess) {
                  _onPublishSuccess(context, state);
                } else if (state is PostComposeFailure) {
                  showWarning(context, state.message);
                  context.read<PostComposeBloc>().add(
                        PostComposeEditingRestored(state.draft),
                      );
                }
              },
              builder: (context, state) {
            final draft = switch (state) {
              PostComposeEditing(:final draft) => draft,
              PostComposeFailure(:final draft) => draft,
              _ => const PostComposeDraft(),
            };
            final isPublishing = draft.isPublishing;
            final selectedIndex = _supportedTypes
                .indexOf(draft.selectedType)
                .clamp(0, _supportedTypes.length - 1);

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _NewPostAppBar(onClose: () => context.pop()),
                    SizedBox(height: 8.h),
                    PostTypeTabSelector(
                      items: _supportedTypes
                          .map(
                            (type) => PostTypeTabItem(
                              label: type.label,
                              icon: type.icon,
                            ),
                          )
                          .toList(),
                      selectedIndex: selectedIndex,
                      onChanged: (index) => context.read<PostComposeBloc>().add(
                            PostComposeTypeChanged(
                              _supportedTypes[index],
                            ),
                          ),
                    ),
                    SizedBox(height: 20.h),
                    Expanded(
                      child: SingleChildScrollView(
                        padding: EdgeInsets.symmetric(horizontal: 20.w),
                        child: _ComposeBody(draft: draft),
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.fromLTRB(20.w, 8.h, 20.w, 16.h),
                      child: SizedBox(
                        width: double.infinity,
                        child: PrimaryButton.publish(
                          isLoading: isPublishing,
                          onPressed: isPublishing || _showShortPublishCountdown
                              ? null
                              : () => context.read<PostComposeBloc>().add(
                                    const PostComposePublishRequested(),
                                  ),
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        ),
        if (_showShortPublishCountdown)
          ShortPublishCountdownOverlay(
            onComplete: () => _onShortPublishCountdownComplete(context),
          ),
      ],
    );
  }
}

class _ComposeBody extends StatelessWidget {
  final PostComposeDraft draft;

  const _ComposeBody({required this.draft});

  @override
  Widget build(BuildContext context) {
    return switch (draft.selectedType) {
      PostComposeType.post || PostComposeType.image =>
        _UnifiedTextImageComposeBody(draft: draft),
      PostComposeType.video => VideoComposeBody(draft: draft),
      PostComposeType.short => _ShortComposeBodyWithoutNotify(draft: draft),
      PostComposeType.event => EventComposeBody(draft: draft),
      PostComposeType.scripture => ScriptureComposeBody(draft: draft),
      PostComposeType.attachment => AttachmentComposeBody(draft: draft),
    };
  }
}

class _UnifiedTextImageComposeBody extends StatefulWidget {
  final PostComposeDraft draft;

  const _UnifiedTextImageComposeBody({required this.draft});

  @override
  State<_UnifiedTextImageComposeBody> createState() =>
      _UnifiedTextImageComposeBodyState();
}

class _UnifiedTextImageComposeBodyState
    extends State<_UnifiedTextImageComposeBody> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.draft.textBody);
  }

  @override
  void didUpdateWidget(_UnifiedTextImageComposeBody oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.draft.textBody != widget.draft.textBody &&
        _controller.text != widget.draft.textBody) {
      _controller.text = widget.draft.textBody;
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _updateDraft(PostComposeDraft draft) {
    context.read<PostComposeBloc>().add(PostComposeDraftUpdated(draft));
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.faithColors;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SizedBox(
          height: 220.h,
          child: TextField(
            controller: _controller,
            onChanged: (value) =>
                _updateDraft(widget.draft.copyWith(textBody: value)),
            maxLines: null,
            expands: true,
            textAlignVertical: TextAlignVertical.top,
            style: GoogleFonts.inter(
              fontSize: 22.sp,
              fontWeight: FontWeight.w500,
              color: colors.primaryText,
              height: 1.45,
            ),
            cursorColor: colors.brandBlue,
            decoration: InputDecoration(
              hintText: 'Write your post...',
              hintStyle: GoogleFonts.inter(
                fontSize: 22.sp,
                fontWeight: FontWeight.w500,
                color: colors.mutedText.withValues(alpha: 0.65),
                height: 1.45,
              ),
              border: InputBorder.none,
            ),
          ),
        ),
        SizedBox(height: 20.h),
        ComposeMediaUploadField(
          media: widget.draft.uploadedMedia,
          onMediaChanged: (media) => _updateDraft(
            widget.draft.copyWith(
              uploadedMedia: media,
              clearUploadedMedia: media == null,
            ),
          ),
          allowImage: true,
          allowVideo: true,
          emptyTitle: 'Add Image or Video (optional)',
          emptySubtitle: 'Text only or with an image or video',
        ),
        SizedBox(height: 16.h),
        const _PostComposeSettingsWithoutNotify(),
      ],
    );
  }
}

class _PostComposeSettingsWithoutNotify extends StatelessWidget {
  const _PostComposeSettingsWithoutNotify();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<PostComposeBloc, PostComposeState>(
      buildWhen: (previous, current) => current is PostComposeEditing,
      builder: (context, state) {
        final draft = switch (state) {
          PostComposeEditing(:final draft) => draft,
          PostComposeFailure(:final draft) => draft,
          _ => null,
        };
        if (draft == null) return const SizedBox.shrink();

        return Column(
          children: [
            AppSettingsSwitchTile(
              title: 'Allow Comments',
              subtitle: 'Let people share their reflections',
              value: draft.allowComments,
              onChanged: (_) => context.read<PostComposeBloc>().add(
                    const PostComposeAllowCommentsToggled(),
                  ),
            ),
            SizedBox(height: 8.h),
          ],
        );
      },
    );
  }
}

class _ShortComposeBodyWithoutNotify extends StatefulWidget {
  final PostComposeDraft draft;

  const _ShortComposeBodyWithoutNotify({required this.draft});

  @override
  State<_ShortComposeBodyWithoutNotify> createState() =>
      _ShortComposeBodyWithoutNotifyState();
}

class _ShortComposeBodyWithoutNotifyState
    extends State<_ShortComposeBodyWithoutNotify> {
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
        const _PostComposeSettingsWithoutNotify(),
      ],
    );
  }
}

class _NewPostAppBar extends StatelessWidget {
  final VoidCallback onClose;

  const _NewPostAppBar({required this.onClose});

  @override
  Widget build(BuildContext context) {
    final colors = context.faithColors;

    return Padding(
      padding: EdgeInsets.fromLTRB(4.w, 8.h, 16.w, 0),
      child: Stack(
        alignment: Alignment.center,
        children: [
          Align(
            alignment: Alignment.centerLeft,
            child: IconButton(
              icon: Icon(
                Iconsax.close_circle,
                color: colors.iconMuted,
                size: 26.r,
              ),
              onPressed: onClose,
            ),
          ),
          Text(
            'New Post',
            style: GoogleFonts.inter(
              fontSize: 18.sp,
              fontWeight: FontWeight.w600,
              color: colors.headerTitle,
            ),
          ),
        ],
      ),
    );
  }
}
