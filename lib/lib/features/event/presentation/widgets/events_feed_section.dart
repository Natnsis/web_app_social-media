import 'package:faithconnect/core/core.dart';
import 'package:faithconnect/features/event/presentation/bloc/events_feed_bloc.dart';
import 'package:faithconnect/features/event/presentation/bloc/events_feed_event.dart';
import 'package:faithconnect/features/event/presentation/bloc/events_feed_state.dart';
import 'package:faithconnect/features/event/presentation/widgets/event_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

/// Home feed preview of upcoming events (`GET /v1/events`).
class EventsFeedSection extends StatefulWidget {
  final double topSpacing;
  final double bottomSpacing;

  const EventsFeedSection({
    super.key,
    this.topSpacing = 20,
    this.bottomSpacing = 0,
  });

  @override
  State<EventsFeedSection> createState() => _EventsFeedSectionState();
}

class _EventsFeedSectionState extends State<EventsFeedSection> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final bloc = context.read<EventsFeedBloc>();
      if (bloc.state is EventsFeedInitial) {
        bloc.add(const EventsFeedRequested());
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.faithColors;

    return BlocBuilder<EventsFeedBloc, EventsFeedState>(
      builder: (context, state) {
        if (state is EventsFeedFailure) {
          return Padding(
            padding: EdgeInsets.only(
              top: widget.topSpacing.h,
              bottom: widget.bottomSpacing.h,
              left: 16.w,
              right: 16.w,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _SectionHeader(
                  onSeeAll: () => context.push(RoutesConstant.events),
                ),
                SizedBox(height: 12.h),
                GestureDetector(
                  onTap: () => context
                      .read<EventsFeedBloc>()
                      .add(const EventsFeedRequested()),
                  child: Text(
                    state.message,
                    style: GoogleFonts.inter(
                      color: colors.mutedText,
                      fontSize: 13.sp,
                    ),
                  ),
                ),
              ],
            ),
          );
        }

        if (state is EventsFeedLoading || state is EventsFeedInitial) {
          return Padding(
            padding: EdgeInsets.only(
              top: widget.topSpacing.h,
              bottom: widget.bottomSpacing.h,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16.w),
                  child: _SectionHeader(
                    onSeeAll: () => context.push(RoutesConstant.events),
                  ),
                ),
                SizedBox(height: 12.h),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16.w),
                  child: const LinearProgressIndicator(),
                ),
              ],
            ),
          );
        }

        if (state is! EventsFeedLoaded || state.events.isEmpty) {
          return const SizedBox.shrink();
        }

        final preview = state.events.take(3).toList();

        return Padding(
          padding: EdgeInsets.only(
            top: widget.topSpacing.h,
            bottom: widget.bottomSpacing.h,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 16.w),
                child: _SectionHeader(
                  onSeeAll: () => context.push(RoutesConstant.events),
                ),
              ),
              SizedBox(height: 12.h),
              for (final event in preview) EventCard(event: event),
            ],
          ),
        );
      },
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final VoidCallback onSeeAll;

  const _SectionHeader({required this.onSeeAll});

  @override
  Widget build(BuildContext context) {
    final colors = context.faithColors;

    return Row(
      children: [
        Expanded(
          child: Text(
            'Upcoming Events',
            style: GoogleFonts.inter(
              color: colors.primaryText,
              fontSize: 18.sp,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
        TextButton(
          onPressed: onSeeAll,
          child: Text(
            'See all',
            style: GoogleFonts.inter(
              color: colors.brandBlue,
              fontSize: 14.sp,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }
}
