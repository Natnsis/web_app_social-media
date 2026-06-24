import 'dart:io';

import 'package:faithconnect/core/core.dart';
import 'package:faithconnect/features/chat/domain/entities/new_group_draft.dart';
import 'package:faithconnect/injection.dart';
import 'package:faithconnect/features/chat/presentation/blocs/new_group_bloc.dart';
import 'package:faithconnect/features/chat/presentation/blocs/new_group_event.dart';
import 'package:faithconnect/features/chat/presentation/blocs/new_group_state.dart';
import 'package:faithconnect/features/chat/presentation/widgets/chat_form_app_bar.dart';
import 'package:faithconnect/features/chat/presentation/widgets/group_governance_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';

class NewGroupPage extends StatefulWidget {
  const NewGroupPage({super.key});

  @override
  State<NewGroupPage> createState() => _NewGroupPageState();
}

class _NewGroupPageState extends State<NewGroupPage> {
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();

  @override
  void initState() {
    super.initState();
    context.read<NewGroupBloc>().add(const NewGroupStarted());

    void onFieldChanged() {
      if (!mounted) return;
      final state = context.read<NewGroupBloc>().state;
      _syncDraft(_currentDraft(state));
    }

    _nameController.addListener(onFieldChanged);
    _descriptionController.addListener(onFieldChanged);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  void _syncDraft(NewGroupDraft base) {
    if (!mounted) return;
    context.read<NewGroupBloc>().add(
          NewGroupDraftUpdated(
            base.copyWith(
              name: _nameController.text,
              description: _descriptionController.text,
            ),
          ),
        );
  }

  NewGroupDraft _currentDraft(NewGroupState state) => switch (state) {
        NewGroupEditing(:final draft) => draft,
        NewGroupFailure(:final draft) => draft,
        _ => const NewGroupDraft(),
      };


  @override
  Widget build(BuildContext context) {
    final colors = context.faithColors;
    final isDark = context.isDarkMode;
    final titleColor = isDark ? Colors.white : colors.primaryText;

    return Scaffold(
      backgroundColor: colors.scaffoldBackground,
      appBar: const ChatFormAppBar(title: 'New Group'),
      body: BlocConsumer<NewGroupBloc, NewGroupState>(
        listener: (context, state) {
          if (state is NewGroupSuccess) {
            showSuccess(context, 'Group created successfully');
            context.pop(state.roomId);
          } else if (state is NewGroupFailure && state.moderators.isEmpty) {
            showWarning(context, state.message);
          } else if (state is NewGroupFailure) {
            showWarning(context, state.message);
          }
        },
        builder: (context, state) {
          if (state is NewGroupLoading || state is NewGroupInitial) {
            return const SizedBox.shrink();
          }

          final editing = switch (state) {
            NewGroupEditing() => state,
            NewGroupFailure(:final draft, :final moderators) => NewGroupEditing(
                draft: draft,
                moderators: moderators,
              ),
            _ => null,
          };

          if (editing == null) {
            return const SizedBox.shrink();
          }

          final draft = editing.draft;

          return Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  padding: EdgeInsets.fromLTRB(16.w, 8.h, 16.w, 16.h),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Cover Image',
                        style: GoogleFonts.inter(
                          color: titleColor,
                          fontSize: 15.sp,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      SizedBox(height: 10.h),
                      _GroupCoverUpload(
                        coverImagePath: draft.coverImagePath,
                        onPick: () => _pickCoverImage(context, draft),
                      ),
                      SizedBox(height: 20.h),
                      CustomTextField(
                        label: 'Group Name',
                        hint: 'e.g., New Sanctuary Sound System',
                        controller: _nameController,
                      ),
                      SizedBox(height: 14.h),
                      CustomDropdownField(
                        label: 'Category',
                        hint: 'Select category',
                        items: NewGroupDraft.categories,
                        value: draft.category,
                        onChanged: (value) {
                          if (value == null) return;
                          context.read<NewGroupBloc>().add(
                                NewGroupDraftUpdated(
                                  draft.copyWith(category: value),
                                ),
                              );
                        },
                      ),
                      SizedBox(height: 14.h),
                      CustomTextField(
                        label: 'Description',
                        hint:
                            'Briefly describe the purpose of this group...',
                        controller: _descriptionController,
                        maxLines: 4,
                      ),
                      SizedBox(height: 20.h),
                      GroupGovernanceCard(
                        isPrivate: draft.isPrivate,
                        allowMemberInvitations: draft.allowMemberInvitations,
                        onPrivateChanged: (value) => context
                            .read<NewGroupBloc>()
                            .add(
                              NewGroupDraftUpdated(
                                draft.copyWith(isPrivate: value),
                              ),
                            ),
                        onInvitationsChanged: (value) => context
                            .read<NewGroupBloc>()
                            .add(
                              NewGroupDraftUpdated(
                                draft.copyWith(allowMemberInvitations: value),
                              ),
                            ),
                      ),

                    ],
                  ),
                ),
              ),
              Padding(
                padding: EdgeInsets.fromLTRB(16.w, 8.h, 16.w, 16.h),
                child: PrimaryButton(
                  text: 'Create Group',
                  onPressed: draft.isSubmitting
                      ? null
                      : () => context
                          .read<NewGroupBloc>()
                          .add(const NewGroupSubmitted()),
                  isLoading: draft.isSubmitting,
                  isGradient: true,
                  width: double.infinity,
                  height: 52.h,
                  radiusVariant: ButtonRadius.full,
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Future<void> _pickCoverImage(
    BuildContext context,
    NewGroupDraft draft,
  ) async {
    final picked = await sl<MediaUploadService>().pickImage();
    if (!context.mounted || picked == null) return;

    context.read<NewGroupBloc>().add(
          NewGroupDraftUpdated(
            draft.copyWith(coverImagePath: picked.filePath),
          ),
        );
  }
}

class _GroupCoverUpload extends StatelessWidget {
  final String? coverImagePath;
  final VoidCallback onPick;

  const _GroupCoverUpload({
    required this.coverImagePath,
    required this.onPick,
  });

  @override
  Widget build(BuildContext context) {
    final path = coverImagePath?.trim();
    if (path != null && path.isNotEmpty && File(path).existsSync()) {
      return GestureDetector(
        onTap: onPick,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16.r),
          child: Stack(
            alignment: Alignment.bottomRight,
            children: [
              Image.file(
                File(path),
                height: 160.h,
                width: double.infinity,
                fit: BoxFit.cover,
              ),
              Padding(
                padding: EdgeInsets.all(8.w),
                child: CircleAvatar(
                  backgroundColor: Colors.black54,
                  child: Icon(Iconsax.gallery_add, color: Colors.white, size: 20.r),
                ),
              ),
            ],
          ),
        ),
      );
    }

    return MediaUploadPlaceholder(
      icon: Iconsax.gallery_add,
      title: 'Upload Cover Image',
      subtitle: 'Recommended: 16:9 Aspect Ratio',
      height: 160,
      onTap: onPick,
    );
  }
}

