import 'package:faithconnect/core/core.dart';
import 'package:faithconnect/features/comment/application/comments_service.dart';
import 'package:faithconnect/features/shortvideo/application/short_video_service.dart';
import 'package:faithconnect/features/shortvideo/domain/entities/reflection.dart';
import 'package:faithconnect/features/shortvideo/presentation/bloc/reflections_bloc.dart';
import 'package:faithconnect/features/shortvideo/presentation/bloc/reflections_event.dart';
import 'package:faithconnect/features/shortvideo/presentation/bloc/reflections_state.dart';
import 'package:faithconnect/features/shortvideo/presentation/widgets/reflection_tile.dart';
import 'package:faithconnect/injection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';

class ReflectionsBottomSheet extends StatefulWidget {
  final String shortVideoId;
  final ValueChanged<int>? onCountChanged;

  const ReflectionsBottomSheet({
    super.key,
    required this.shortVideoId,
    this.onCountChanged,
  });

  static Future<int?> show(
    BuildContext context,
    String shortVideoId, {
    ValueChanged<int>? onCountChanged,
  }) {
    return showModalBottomSheet<int>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => BlocProvider(
        create: (_) => ReflectionsBloc(
          shortVideoService: sl<ShortVideoService>(),
          commentsService: sl<CommentsService>(),
          shortVideoId: shortVideoId,
        ),
        child: ReflectionsBottomSheet(
          shortVideoId: shortVideoId,
          onCountChanged: onCountChanged,
        ),
      ),
    );
  }

  @override
  State<ReflectionsBottomSheet> createState() => _ReflectionsBottomSheetState();
}

class _ReflectionsBottomSheetState extends State<ReflectionsBottomSheet> {
  final _controller = TextEditingController();
  final _focusNode = FocusNode();
  String? _replyParentId;
  String? _replyParentAuthor;
  Reflection? _editingReflection;

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  int? _countFromState(ReflectionsState state) {
    if (state is ReflectionsLoaded) {
      return state.feed.totalReflecting;
    }
    return null;
  }

  void _notifyCount(ReflectionsState state) {
    final count = _countFromState(state);
    final callback = widget.onCountChanged;
    if (count == null || callback == null) return;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      callback(count);
    });
  }

  void _closeWithCount() {
    final count = _countFromState(context.read<ReflectionsBloc>().state);
    Navigator.of(context).pop(count);
  }

  void _startReply(Reflection reflection) {
    setState(() {
      _replyParentId = reflection.id;
      _replyParentAuthor = reflection.authorName;
    });
    _controller.clear();
    _focusNode.requestFocus();
  }

  void _cancelReply() {
    setState(() {
      _replyParentId = null;
      _replyParentAuthor = null;
    });
  }

  void _startEdit(Reflection reflection) {
    _cancelReply();
    setState(() {
      _editingReflection = reflection;
    });
    _controller.text = reflection.text;
    _focusNode.requestFocus();
  }

  void _cancelEdit() {
    setState(() {
      _editingReflection = null;
    });
    _controller.clear();
  }

  void _submit(BuildContext context) {
    final text = _controller.text.trim();
    if (text.isEmpty) return;

    final bloc = context.read<ReflectionsBloc>();

    if (_editingReflection != null) {
      bloc.add(
        ReflectionEdited(
          commentId: _editingReflection!.id,
          newText: text,
        ),
      );
      _cancelEdit();
      return;
    }

    if (_replyParentId != null) {
      bloc.add(
        ReflectionReplySubmitted(
          parentCommentId: _replyParentId!,
          text: text,
        ),
      );
    } else {
      bloc.add(ReflectionSubmitted(text));
    }

    _controller.clear();
    _cancelReply();
  }

  void _toggleLike(Reflection reflection) {
    context.read<ReflectionsBloc>().add(ReflectionLikeToggled(reflection.id));
  }

  void _loadReplies(Reflection reflection) {
    context
        .read<ReflectionsBloc>()
        .add(ReflectionRepliesRequested(reflection.id));
  }

  Future<void> _confirmDelete(Reflection reflection) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete reflection?'),
        content: const Text('This cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed != true || !mounted) return;
    context.read<ReflectionsBloc>().add(ReflectionDeleted(reflection.id));
  }

  @override
  Widget build(BuildContext context) {
    // Reduced height to 65% to avoid taking up the full page
    final height = MediaQuery.sizeOf(context).height * 0.65;
    final bottomInset = MediaQuery.viewInsetsOf(context).bottom;

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;
        _closeWithCount();
      },
      child: Padding(
        padding: EdgeInsets.only(bottom: bottomInset),
        child: Container(
          height: height,
          decoration: BoxDecoration(
            color: DarkTheme.feedScaffoldBackground,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
          ),
          child: BlocConsumer<ReflectionsBloc, ReflectionsState>(
            listener: (context, state) {
              if (state is ReflectionsFailure) {
                showWarning(context, state.message);
              } else if (state is ReflectionsLoaded) {
                _notifyCount(state);
                final message = state.feedbackMessage;
                if (message != null && message.isNotEmpty) {
                  showWarning(context, message);
                  context
                      .read<ReflectionsBloc>()
                      .add(const ReflectionFeedbackCleared());
                }
              }
            },
            builder: (context, state) {
              return Column(
                children: [
                  const SheetDragHandle(),
                  Padding(
                    padding: EdgeInsets.fromLTRB(20.w, 0, 12.w, 8.h),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Reflections',
                                style: GoogleFonts.inter(
                                  color: DarkTheme.brandSky,
                                  fontSize: 22.sp,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              if (state is ReflectionsLoaded)
                                Text(
                                  '${state.feed.totalReflecting} people reflecting together',
                                  style: GoogleFonts.inter(
                                    color: DarkTheme.feedMutedText,
                                    fontSize: 14.sp,
                                  ),
                                ),
                            ],
                          ),
                        ),
                        IconButton(
                          onPressed: _closeWithCount,
                          icon: Container(
                            width: 36.r,
                            height: 36.r,
                            decoration: const BoxDecoration(
                              color: DarkTheme.feedTagBackground,
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              Iconsax.close_circle,
                              color: DarkTheme.feedMutedText,
                              size: 20.r,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (state is ReflectionsLoading)
                    const Expanded(
                      child: Center(
                        child: CircularProgressIndicator(
                          color: DarkTheme.brandBlue,
                        ),
                      ),
                    ),
                  if (state is ReflectionsFailure)
                    Expanded(
                      child: Center(child: Text(state.message)),
                    ),
                  if (state is ReflectionsLoaded) ...[
                    Expanded(
                      child: Column(
                        children: [
                          SizedBox(
                            height: 48.h,
                            child: ListView.separated(
                              scrollDirection: Axis.horizontal,
                              padding: EdgeInsets.symmetric(horizontal: 16.w),
                              itemCount: state.feed.quickReactions.length,
                              separatorBuilder: (_, _) => SizedBox(width: 8.w),
                              itemBuilder: (context, index) {
                                final reaction = state.feed.quickReactions[index];
                                return QuickReactionChip(
                                  emoji: reaction.emoji,
                                  label: reaction.label,
                                  onTap: () {
                                    _controller.text = '${reaction.emoji} ${reaction.label}';
                                  },
                                );
                              },
                            ),
                          ),
                          Expanded(
                            child: ListView.builder(
                              padding: EdgeInsets.fromLTRB(16.w, 8.h, 16.w, 8.h),
                              itemCount: state.feed.reflections.length,
                              itemBuilder: (context, index) {
                                final reflection =
                                    state.feed.reflections[index];
                                return ReflectionTile(
                                  reflection: reflection,
                                  onReplyTap: _startReply,
                                  onLikeTap: _toggleLike,
                                  onDeleteTap: _confirmDelete,
                                  onEditTap: _startEdit,
                                  onLoadRepliesTap: _loadReplies,
                                  loadingReplyParentIds:
                                      state.loadingReplyParentIds,
                                );
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                    Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (_editingReflection != null)
                          Container(
                            width: double.infinity,
                            padding: EdgeInsets.fromLTRB(16.w, 8.h, 12.w, 0),
                            color: DarkTheme.feedTagBackground,
                            child: Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    'Editing reflection...',
                                    style: GoogleFonts.inter(
                                      color: DarkTheme.feedMutedText,
                                      fontSize: 13.sp,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                                IconButton(
                                  onPressed: _cancelEdit,
                                  icon: Icon(
                                    Iconsax.close_circle,
                                    size: 18.r,
                                    color: DarkTheme.feedMutedText,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        if (_replyParentAuthor != null)
                          Container(
                            width: double.infinity,
                            padding: EdgeInsets.fromLTRB(16.w, 8.h, 12.w, 0),
                            color: DarkTheme.feedTagBackground,
                            child: Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    'Replying to $_replyParentAuthor',
                                    style: GoogleFonts.inter(
                                      color: DarkTheme.feedMutedText,
                                      fontSize: 13.sp,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                                IconButton(
                                  onPressed: _cancelReply,
                                  icon: Icon(
                                    Iconsax.close_circle,
                                    size: 18.r,
                                    color: DarkTheme.feedMutedText,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        CommentComposerBar(
                          controller: _controller,
                          focusNode: _focusNode,
                          hint: _replyParentId == null
                              ? 'Share a reflection...'
                              : 'Write a reply...',
                          isSending: state.isSubmitting,
                          onSend: () => _submit(context),
                          onSubmitted: (_) => _submit(context),
                        ),
                      ],
                    ),
                  ],
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}
