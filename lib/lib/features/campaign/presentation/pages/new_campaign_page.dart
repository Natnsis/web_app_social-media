import 'dart:io';

import 'package:faithconnect/core/core.dart';
import 'package:faithconnect/features/campaign/domain/entities/new_campaign_draft.dart';
import 'package:faithconnect/injection.dart';
import 'package:faithconnect/features/campaign/presentation/bloc/new_campaign_bloc.dart';
import 'package:faithconnect/features/campaign/presentation/bloc/new_campaign_event.dart';
import 'package:faithconnect/features/campaign/presentation/bloc/new_campaign_state.dart';
import 'package:faithconnect/features/campaign/presentation/widgets/campaign_app_bar.dart';
import 'package:faithconnect/features/campaign/presentation/widgets/campaign_giving_options_card.dart';
import 'package:faithconnect/features/campaign/presentation/widgets/campaign_live_preview_card.dart';
import 'package:faithconnect/features/campaign/presentation/widgets/new_campaign_mission_header.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';

class NewCampaignPage extends StatefulWidget {
  const NewCampaignPage({super.key});

  @override
  State<NewCampaignPage> createState() => _NewCampaignPageState();
}

class _NewCampaignPageState extends State<NewCampaignPage> {
  final _titleController = TextEditingController();
  final _goalController = TextEditingController();
  final _endDateController = TextEditingController();
  final _descriptionController = TextEditingController();

  @override
  void initState() {
    super.initState();
    void onFieldChanged() {
      if (!mounted) return;
      final state = context.read<NewCampaignBloc>().state;
      final base = switch (state) {
        NewCampaignEditing(:final draft) => draft,
        NewCampaignFailure(:final draft) => draft,
        _ => const NewCampaignDraft(),
      };
      _syncDraft(base);
    }

    _titleController.addListener(onFieldChanged);
    _goalController.addListener(onFieldChanged);
    _descriptionController.addListener(onFieldChanged);
  }

  @override
  void dispose() {
    _titleController.dispose();
    _goalController.dispose();
    _endDateController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  NewCampaignDraft _draftFromControllers(NewCampaignDraft base) {
    return base.copyWith(
      title: _titleController.text,
      goalAmount: _goalController.text,
      endDate: _endDateController.text,
      description: _descriptionController.text,
    );
  }

  void _syncDraft(NewCampaignDraft base) {
    context.read<NewCampaignBloc>().add(
          NewCampaignDraftUpdated(_draftFromControllers(base)),
        );
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.faithColors;
    final isDark = context.isDarkMode;
    final titleColor = isDark ? Colors.white : colors.primaryText;
    final suffixColor = isDark ? DarkTheme.brandBlue : colors.brandBlue;
    final hintIconColor = isDark ? DarkTheme.feedMutedText : colors.iconMuted;

    return Scaffold(
      backgroundColor: colors.scaffoldBackground,
      appBar: const CampaignAppBar(title: 'New Campaign'),
      body: BlocConsumer<NewCampaignBloc, NewCampaignState>(
        listener: (context, state) {
          if (state is NewCampaignSuccess) {
            showSuccess(context, 'Campaign launched successfully');
            context.pop(state.campaignId);
          } else if (state is NewCampaignFailure) {
            showWarning(context, state.message);
          }
        },
        builder: (context, state) {
          final draft = switch (state) {
            NewCampaignEditing(:final draft) => draft,
            NewCampaignFailure(:final draft) => draft,
            _ => const NewCampaignDraft(),
          };

          return Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  padding: EdgeInsets.fromLTRB(16.w, 8.h, 16.w, 16.h),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const NewCampaignMissionHeader(),
                      SizedBox(height: 20.h),
                      Text(
                        'Campaign Visual',
                        style: GoogleFonts.inter(
                          color: titleColor,
                          fontSize: 15.sp,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      SizedBox(height: 10.h),
                      _CampaignCoverUpload(
                        coverImagePath: draft.coverImagePath,
                        onPick: () => _pickCoverImage(context, draft),
                      ),
                      SizedBox(height: 20.h),
                      CustomTextField(
                        label: 'Campaign Title',
                        hint: 'e.g., New Sanctuary Sound System',
                        controller: _titleController,
                      ),
                      SizedBox(height: 14.h),
                      CustomTextField(
                        label: 'Goal Amount (ETB)',
                        hint: '500,000',
                        controller: _goalController,
                        keyboardType: TextInputType.number,
                        suffixIcon: Text(
                          'ETB',
                          style: GoogleFonts.inter(
                            color: suffixColor,
                            fontWeight: FontWeight.w600,
                            fontSize: 14.sp,
                          ),
                        ),
                      ),
                      SizedBox(height: 14.h),
                      CustomTextField(
                        label: 'End Date',
                        hint: 'mm/dd/yyyy',
                        controller: _endDateController,
                        readOnly: true,
                        onTap: () => _pickEndDate(draft),
                        suffixIcon: Icon(
                          Iconsax.calendar,
                          color: hintIconColor,
                          size: 20.r,
                        ),
                      ),
                      SizedBox(height: 14.h),
                      CustomTextField(
                        label: 'Description',
                        hint:
                            'Describe the spiritual and community impact of this campaign...',
                        controller: _descriptionController,
                        maxLines: 5,
                      ),
                      SizedBox(height: 20.h),
                      CampaignGivingOptionsCard(
                        allowAnonymous: draft.allowAnonymousGiving,
                        showProgressPublicly: draft.showProgressPublicly,
                        onAnonymousChanged: (value) => context
                            .read<NewCampaignBloc>()
                            .add(
                              NewCampaignDraftUpdated(
                                draft.copyWith(allowAnonymousGiving: value),
                              ),
                            ),
                        onShowProgressChanged: (value) => context
                            .read<NewCampaignBloc>()
                            .add(
                              NewCampaignDraftUpdated(
                                draft.copyWith(showProgressPublicly: value),
                              ),
                            ),
                      ),
                      SizedBox(height: 20.h),
                      CampaignLivePreviewCard(draft: draft),
                    ],
                  ),
                ),
              ),
              Padding(
                padding: EdgeInsets.fromLTRB(16.w, 8.h, 16.w, 16.h),
                child: PrimaryButton(
                  text: 'Launch Campaign',
                  onPressed: draft.isSubmitting
                      ? null
                      : () => context
                          .read<NewCampaignBloc>()
                          .add(const NewCampaignSubmitted()),
                  isLoading: draft.isSubmitting,
                  isGradient: true,
                  width: double.infinity,
                  height: 52.h,
                  prefixIcon: Icon(
                    Icons.rocket_launch_rounded,
                    color: Colors.white,
                    size: 20.r,
                  ),
                  radiusVariant: ButtonRadius.full,
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Future<void> _pickEndDate(NewCampaignDraft draft) async {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    final picked = await showDatePicker(
      context: context,
      initialDate: today.add(const Duration(days: 30)),
      firstDate: today,
      lastDate: today.add(const Duration(days: 365 * 3)),
    );

    if (picked == null || !mounted) return;

    _endDateController.text =
        '${picked.month.toString().padLeft(2, '0')}/${picked.day.toString().padLeft(2, '0')}/${picked.year}';
    _syncDraft(draft);
  }

  Future<void> _pickCoverImage(
    BuildContext context,
    NewCampaignDraft draft,
  ) async {
    final picked = await sl<MediaUploadService>().pickImage();
    if (!context.mounted || picked == null) return;

    context.read<NewCampaignBloc>().add(
          NewCampaignDraftUpdated(
            draft.copyWith(coverImagePath: picked.filePath),
          ),
        );
  }
}

class _CampaignCoverUpload extends StatelessWidget {
  final String? coverImagePath;
  final VoidCallback onPick;

  const _CampaignCoverUpload({
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
                  child: Icon(Iconsax.gallery, color: Colors.white, size: 20.r),
                ),
              ),
            ],
          ),
        ),
      );
    }

    return MediaUploadPlaceholder(
      icon: Iconsax.gallery,
      title: 'Upload Cover Image',
      subtitle: 'Recommended: 16:9 Aspect Ratio',
      height: 160,
      onTap: onPick,
    );
  }
}
