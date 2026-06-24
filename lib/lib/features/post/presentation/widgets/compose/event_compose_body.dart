import 'package:faithconnect/core/core.dart';
import 'package:faithconnect/features/post/domain/entities/post_compose_draft.dart';
import 'package:faithconnect/features/post/presentation/bloc/post_compose_bloc.dart';
import 'package:faithconnect/features/post/presentation/bloc/post_compose_event.dart';
import 'package:faithconnect/features/post/presentation/widgets/compose/post_compose_settings.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';

class EventComposeBody extends StatefulWidget {
  final PostComposeDraft draft;

  const EventComposeBody({super.key, required this.draft});

  @override
  State<EventComposeBody> createState() => _EventComposeBodyState();
}

class _EventComposeBodyState extends State<EventComposeBody> {
  late final TextEditingController _titleController;
  late final TextEditingController _detailsController;
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
    _titleController = TextEditingController(text: widget.draft.eventTitle);
    _detailsController =
        TextEditingController(text: widget.draft.eventDetails);
  }

  @override
  void dispose() {
    _titleController.dispose();
    _detailsController.dispose();
    super.dispose();
  }

  void _sync(PostComposeDraft draft) {
    context.read<PostComposeBloc>().add(PostComposeDraftUpdated(draft));
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

    final formattedDate =
        '${_months[picked.month - 1]} ${picked.day}, ${picked.year}';
    _sync(widget.draft.copyWith(eventDateLabel: formattedDate));
  }

  Future<void> _pickTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );

    if (picked == null || !mounted) return;

    final formattedTime = picked.format(context);
    _sync(widget.draft.copyWith(eventTimeLabel: formattedTime));
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.faithColors;
    final cardFill =
        context.isDarkMode ? colors.cardBackground : colors.tagBackground;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          'Event Cover',
          style: GoogleFonts.inter(
            fontSize: 13.sp,
            color: colors.mutedText,
            fontWeight: FontWeight.w500,
          ),
        ),
        SizedBox(height: 8.h),
        ComposeMediaUploadField(
          media: widget.draft.uploadedMedia,
          onMediaChanged: (media) => _sync(
            widget.draft.copyWith(
              uploadedMedia: media,
              clearUploadedMedia: media == null,
            ),
          ),
          allowImage: true,
          allowVideo: false,
          previewHeight: 210,
          emptyTitle: 'Add cover image',
          emptySubtitle: 'Upload an image for your event',
        ),
        SizedBox(height: 24.h),
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
            onChanged: (v) => _sync(widget.draft.copyWith(eventTitle: v)),
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
          value: widget.draft.eventDateLabel,
          onTap: _pickDate,
        ),
        SizedBox(height: 12.h),
        ComposeInfoCard(
          icon: Iconsax.clock,
          label: 'Time',
          value: widget.draft.eventTimeLabel,
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
            onChanged: (v) => _sync(widget.draft.copyWith(eventDetails: v)),
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
        SizedBox(height: 16.h),
        const PostComposeSettings(showNotifyCommunity: false),
      ],
    );
  }
}
