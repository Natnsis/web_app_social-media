import 'package:faithconnect/core/core.dart';
import 'package:faithconnect/features/event/presentation/bloc/events_feed_bloc.dart';
import 'package:faithconnect/features/event/presentation/bloc/events_feed_event.dart';
import 'package:faithconnect/features/event/presentation/bloc/events_feed_state.dart';
import 'package:faithconnect/features/event/presentation/widgets/event_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';

class EventsPage extends StatefulWidget {
  const EventsPage({super.key});

  @override
  State<EventsPage> createState() => _EventsPageState();
}

class _EventsPageState extends State<EventsPage> {
  @override
  void initState() {
    super.initState();
    context.read<EventsFeedBloc>().add(const EventsFeedRequested());
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.faithColors;

    return Scaffold(
      backgroundColor: colors.scaffoldBackground,
      appBar: AppBar(
        backgroundColor: colors.scaffoldBackground,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Iconsax.arrow_left, color: colors.primaryText),
          onPressed: () => context.pop(),
        ),
        title: Text(
          'Events',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                color: colors.primaryText,
                fontWeight: FontWeight.w700,
              ),
        ),
      ),
      body: BlocBuilder<EventsFeedBloc, EventsFeedState>(
        builder: (context, state) {
          if (state is EventsFeedLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is EventsFeedFailure) {
            return Center(
              child: Padding(
                padding: AppSpacing.screenPadding,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(state.message, textAlign: TextAlign.center),
                    AppSpacing.v16,
                    PrimaryButton.feedAction(
                      text: 'Retry',
                      onPressed: () => context
                          .read<EventsFeedBloc>()
                          .add(const EventsFeedRequested()),
                    ),
                  ],
                ),
              ),
            );
          }

          if (state is EventsFeedLoaded && state.events.isEmpty) {
            return _EventsFeedEmpty(
              onCreateEvent: () => context.push(RoutesConstant.newPost),
              onRefresh: () => context
                  .read<EventsFeedBloc>()
                  .add(const EventsFeedRequested()),
            );
          }

          if (state is! EventsFeedLoaded) {
            return const SizedBox.shrink();
          }

          return RefreshIndicator(
            color: colors.brandBlue,
            onRefresh: () async {
              context.read<EventsFeedBloc>().add(const EventsFeedRefreshed());
              await context.read<EventsFeedBloc>().stream.firstWhere(
                    (s) => s is EventsFeedLoaded || s is EventsFeedFailure,
                  );
            },
            child: ListView.builder(
              physics: const AlwaysScrollableScrollPhysics(
                parent: BouncingScrollPhysics(),
              ),
              padding: EdgeInsets.only(top: 8.h, bottom: 24.h),
              itemCount: state.events.length,
              itemBuilder: (context, index) {
                return EventCard(event: state.events[index]);
              },
            ),
          );
        },
      ),
    );
  }
}

class _EventsFeedEmpty extends StatelessWidget {
  final VoidCallback onCreateEvent;
  final VoidCallback onRefresh;

  const _EventsFeedEmpty({
    required this.onCreateEvent,
    required this.onRefresh,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.faithColors;

    return Center(
      child: Padding(
        padding: AppSpacing.screenPadding,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Iconsax.calendar, size: 56.r, color: colors.mutedText),
            AppSpacing.v16,
            Text(
              'No upcoming events yet',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: colors.primaryText,
                    fontWeight: FontWeight.w600,
                  ),
            ),
            AppSpacing.v8,
            Text(
              'Church events from your community will appear here.',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: colors.mutedText,
                  ),
            ),
            AppSpacing.v20,
            PrimaryButton.feedAction(
              text: 'Create event',
              onPressed: onCreateEvent,
            ),
            AppSpacing.v12,
            TextButton(
              onPressed: onRefresh,
              child: const Text('Refresh'),
            ),
          ],
        ),
      ),
    );
  }
}
