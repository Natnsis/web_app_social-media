import 'package:faithconnect/core/core.dart';
import 'package:faithconnect/core/theme/app_theme_extensions.dart';
import 'package:faithconnect/core/widgets/primary_button.dart';
import 'package:faithconnect/features/campaign/domain/entities/campaign.dart';
import 'package:faithconnect/injection.dart';
import 'package:faithconnect/core/services/media_upload_service.dart';
import 'package:faithconnect/core/widgets/compose_media_upload_field.dart';
import 'package:faithconnect/core/media/uploaded_media.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';

class EditCampaignPage extends StatefulWidget {
  final Campaign campaign;

  const EditCampaignPage({super.key, required this.campaign});

  @override
  State<EditCampaignPage> createState() => _EditCampaignPageState();
}

class _EditCampaignPageState extends State<EditCampaignPage> {
  late final TextEditingController _titleController;
  late final TextEditingController _goalController;
  late final TextEditingController _endDateController;
  late final TextEditingController _descriptionController;

  UploadedMedia? _newMedia;
  bool _removeExistingMedia = false;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.campaign.title);
    _goalController = TextEditingController(
      text: widget.campaign.goalAmountEtb.toString(),
    );

    // Calculate an approximate end date if progress > 0 or default to 30 days.
    // Since Campaign entity doesn't have endDate out of the box in the summary,
    // we just default to today + 30 or empty if not available in your model.
    final now = DateTime.now();
    final defaultEndDate = now.add(const Duration(days: 30));
    _endDateController = TextEditingController(
      text:
          '${defaultEndDate.month.toString().padLeft(2, '0')}/${defaultEndDate.day.toString().padLeft(2, '0')}/${defaultEndDate.year}',
    );

    _descriptionController = TextEditingController(
      text: widget.campaign.description,
    );
  }

  @override
  void dispose() {
    _titleController.dispose();
    _goalController.dispose();
    _endDateController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _pickEndDate() async {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    final picked = await showDatePicker(
      context: context,
      initialDate: today.add(const Duration(days: 30)),
      firstDate: today,
      lastDate: today.add(const Duration(days: 365 * 3)),
    );

    if (picked == null || !mounted) return;

    setState(() {
      _endDateController.text =
          '${picked.month.toString().padLeft(2, '0')}/${picked.day.toString().padLeft(2, '0')}/${picked.year}';
    });
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
                  'Change cover image',
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
              ],
            ),
          ),
        );
      },
    );

    if (!context.mounted || choice == null) return;

    final service = sl<MediaUploadService>();
    final picked = await service.pickImage();

    if (!context.mounted || picked == null) return;

    setState(() {
      _newMedia = picked;
      _removeExistingMedia = true;
    });
  }

  void _onSave() {
    final title = _titleController.text.trim();
    if (title.isEmpty) return;

    final goal = int.tryParse(_goalController.text.trim());

    context.pop({
      'title': title,
      'goal': goal,
      'description': _descriptionController.text.trim(),
      'newMedia': _newMedia,
      'removeExistingMedia': _removeExistingMedia,
    });
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.faithColors;
    final isDark = context.isDarkMode;
    final hintIconColor = isDark ? DarkTheme.feedMutedText : colors.iconMuted;
    final suffixColor = isDark ? DarkTheme.brandBlue : colors.brandBlue;

    final hasExistingMedia = widget.campaign.imageUrl != null && widget.campaign.imageUrl!.isNotEmpty;
    final showExistingMedia = hasExistingMedia && !_removeExistingMedia && _newMedia == null;

    return Scaffold(
      backgroundColor: colors.scaffoldBackground,
      appBar: AppBar(
        backgroundColor: colors.scaffoldBackground,
        elevation: 0,
        title: Text(
          'Edit Campaign',
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
          padding: EdgeInsets.fromLTRB(16.w, 8.h, 16.w, 16.h),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: 10.h),
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
                onTap: _pickEndDate,
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
                        child: Image.network(
                          widget.campaign.imageUrl!,
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
                        'Remove cover image',
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
                  allowVideo: false,
                  emptyTitle: 'Add Cover Image',
                  emptySubtitle: 'Replace current image or add new',
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class CustomTextField extends StatelessWidget {
  final String label;
  final String hint;
  final TextEditingController controller;
  final int maxLines;
  final bool readOnly;
  final VoidCallback? onTap;
  final Widget? suffixIcon;
  final TextInputType? keyboardType;

  const CustomTextField({
    super.key,
    required this.label,
    required this.hint,
    required this.controller,
    this.maxLines = 1,
    this.readOnly = false,
    this.onTap,
    this.suffixIcon,
    this.keyboardType,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.faithColors;
    final isDark = context.isDarkMode;
    final cardFill = isDark ? colors.cardBackground : colors.tagBackground;
    final titleColor = isDark ? Colors.white : colors.primaryText;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.inter(
            color: titleColor,
            fontSize: 13.sp,
            fontWeight: FontWeight.w600,
          ),
        ),
        SizedBox(height: 8.h),
        GestureDetector(
          onTap: onTap,
          child: Container(
            decoration: BoxDecoration(
              color: cardFill,
              borderRadius: BorderRadius.circular(12.r),
              border: Border.all(
                color: isDark ? colors.tagBackground : Colors.transparent,
              ),
            ),
            padding: EdgeInsets.symmetric(
              horizontal: 16.w,
              vertical: maxLines > 1 ? 12.h : 4.h,
            ),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: controller,
                    maxLines: maxLines,
                    readOnly: readOnly,
                    onTap: onTap,
                    keyboardType: keyboardType,
                    style: GoogleFonts.inter(
                      fontSize: 15.sp,
                      color: colors.primaryText,
                      fontWeight: FontWeight.w500,
                    ),
                    cursorColor: colors.brandBlue,
                    decoration: InputDecoration(
                      hintText: hint,
                      hintStyle: GoogleFonts.inter(
                        fontSize: 15.sp,
                        color: colors.mutedText,
                      ),
                      border: InputBorder.none,
                      isDense: true,
                    ),
                  ),
                ),
                if (suffixIcon != null) ...[SizedBox(width: 8.w), suffixIcon!],
              ],
            ),
          ),
        ),
      ],
    );
  }
}
