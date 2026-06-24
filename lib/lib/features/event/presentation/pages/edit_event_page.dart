import 'package:faithconnect/core/core.dart';
import 'package:faithconnect/core/theme/app_theme_extensions.dart';
import 'package:faithconnect/core/widgets/app_surface_card.dart';
import 'package:faithconnect/core/widgets/primary_button.dart';
import 'package:faithconnect/features/event/domain/entities/church_event.dart';
import 'package:faithconnect/injection.dart';
import 'package:faithconnect/core/services/media_upload_service.dart';
import 'package:faithconnect/core/widgets/compose_media_upload_field.dart';
import 'package:faithconnect/core/media/uploaded_media.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import 'package:intl/intl.dart';

class EditEventPage extends StatefulWidget {
  final ChurchEvent event;

  const EditEventPage({super.key, required this.event});

  @override
  State<EditEventPage> createState() => _EditEventPageState();
}

class _EditEventPageState extends State<EditEventPage> {
  late final TextEditingController _titleController;
  late final TextEditingController _detailsController;

  late String _dateLabel;
  late String _timeLabel;

  UploadedMedia? _newMedia;
  bool _removeExistingMedia = false;

  static const List<String> _months = [
    'January',
    'February',
    'March',
    'April',
    'May',
    'June',
    'July',
    'August',
    'September',
    'October',
    'November',
    'December',
  ];

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.event.title);
    _detailsController = TextEditingController(text: widget.event.description);
    _dateLabel = widget.event.date;
    _timeLabel = widget.event.time;
  }

  String _formatDate(DateTime date) {
    return '${_months[date.month - 1]} ${date.day}, ${date.year}';
  }

  @override
  void dispose() {
    _titleController.dispose();
    _detailsController.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: now,
      firstDate: DateTime(now.year - 5),
      lastDate: DateTime(now.year + 10),
    );

    if (picked == null || !mounted) return;
    setState(() {
      _dateLabel = _formatDate(picked);
    });
  }

  Future<void> _pickTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );

    if (picked == null || !mounted) return;
    setState(() {
      _timeLabel = picked.format(context);
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

    context.pop({
      'title': title,
      'date': _dateLabel,
      'time': _timeLabel,
      'details': _detailsController.text.trim(),
      'newMedia': _newMedia,
      'removeExistingMedia': _removeExistingMedia,
    });
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.faithColors;
    final cardFill = context.isDarkMode
        ? colors.cardBackground
        : colors.tagBackground;

    final hasExistingMedia = widget.event.imageUrl != null && widget.event.imageUrl!.isNotEmpty;
    final showExistingMedia = hasExistingMedia && !_removeExistingMedia && _newMedia == null;

    return Scaffold(
      backgroundColor: colors.scaffoldBackground,
      appBar: AppBar(
        backgroundColor: colors.scaffoldBackground,
        elevation: 0,
        title: Text(
          'Edit Event',
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
              Text(
                'Event Title',
                style: GoogleFonts.inter(
                  fontSize: 13.sp,
                  color: colors.mutedText,
                  fontWeight: FontWeight.w500,
                ),
              ),
              SizedBox(height: 8.h),
              AppSurfaceCard(
                backgroundColor: cardFill,
                borderRadius: 16,
                padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
                child: TextField(
                  controller: _titleController,
                  style: GoogleFonts.inter(
                    fontSize: 18.sp,
                    fontWeight: FontWeight.w600,
                    color: colors.primaryText,
                  ),
                  cursorColor: colors.brandBlue,
                  decoration: InputDecoration(
                    hintText: 'Enter event title',
                    hintStyle: GoogleFonts.inter(
                      fontSize: 18.sp,
                      fontWeight: FontWeight.w500,
                      color: colors.mutedText.withValues(alpha: 0.75),
                    ),
                    border: InputBorder.none,
                    isDense: true,
                    contentPadding: EdgeInsets.zero,
                  ),
                ),
              ),
              SizedBox(height: 16.h),
              ComposeInfoCard(
                icon: Iconsax.calendar,
                label: 'Date',
                value: _dateLabel,
                onTap: _pickDate,
              ),
              SizedBox(height: 12.h),
              ComposeInfoCard(
                icon: Iconsax.clock,
                label: 'Time',
                value: _timeLabel,
                onTap: _pickTime,
              ),
              SizedBox(height: 20.h),
              Text(
                'Event Details',
                style: GoogleFonts.inter(
                  fontSize: 13.sp,
                  color: colors.mutedText,
                  fontWeight: FontWeight.w500,
                ),
              ),
              SizedBox(height: 8.h),
              AppSurfaceCard(
                backgroundColor: cardFill,
                borderRadius: 16,
                padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
                child: TextField(
                  controller: _detailsController,
                  maxLines: 5,
                  style: GoogleFonts.inter(
                    fontSize: 15.sp,
                    color: colors.primaryText,
                    height: 1.4,
                  ),
                  cursorColor: colors.brandBlue,
                  decoration: InputDecoration(
                    hintText: 'Event details...',
                    hintStyle: GoogleFonts.inter(
                      fontSize: 15.sp,
                      color: colors.mutedText.withValues(alpha: 0.85),
                    ),
                    border: InputBorder.none,
                    isDense: true,
                    contentPadding: EdgeInsets.zero,
                  ),
                ),
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
                          widget.event.imageUrl!,
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

class ComposeInfoCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final VoidCallback onTap;

  const ComposeInfoCard({
    super.key,
    required this.icon,
    required this.label,
    required this.value,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.faithColors;
    final isDark = context.isDarkMode;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
        decoration: BoxDecoration(
          color: isDark ? colors.cardBackground : colors.tagBackground,
          borderRadius: BorderRadius.circular(12.r),
          border: Border.all(
            color: isDark ? colors.tagBackground : Colors.transparent,
          ),
        ),
        child: Row(
          children: [
            Container(
              padding: EdgeInsets.all(8.r),
              decoration: BoxDecoration(
                color: isDark
                    ? colors.tagBackground.withValues(alpha: 0.5)
                    : Colors.white,
                borderRadius: BorderRadius.circular(8.r),
              ),
              child: Icon(icon, size: 20.sp, color: colors.primaryText),
            ),
            SizedBox(width: 12.w),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: GoogleFonts.inter(
                    fontSize: 12.sp,
                    color: colors.mutedText,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                SizedBox(height: 2.h),
                Text(
                  value,
                  style: GoogleFonts.inter(
                    fontSize: 14.sp,
                    color: colors.primaryText,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            const Spacer(),
            Icon(
              Iconsax.arrow_right_3_copy,
              size: 16.sp,
              color: colors.mutedText,
            ),
          ],
        ),
      ),
    );
  }
}
