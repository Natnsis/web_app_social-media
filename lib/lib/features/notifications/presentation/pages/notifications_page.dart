import 'package:faithconnect/core/core.dart';
import 'package:faithconnect/features/notifications/presentation/bloc/notifications_bloc.dart';
import 'package:faithconnect/features/notifications/presentation/bloc/notifications_event.dart';
import 'package:faithconnect/features/notifications/presentation/bloc/notifications_state.dart';
import 'package:faithconnect/features/notifications/presentation/widgets/notification_list_tile.dart';
import 'package:faithconnect/features/notifications/presentation/widgets/notifications_app_bar.dart';
import 'package:faithconnect/features/notifications/presentation/widgets/notifications_background.dart';
import 'package:faithconnect/features/notifications/presentation/widgets/notifications_shimmer.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';

class NotificationsPage extends StatefulWidget {
  const NotificationsPage({super.key});

  @override
  State<NotificationsPage> createState() => _NotificationsPageState();
}

class _NotificationsPageState extends State<NotificationsPage> {
  @override
  void initState() {
    super.initState();
    context.read<NotificationsBloc>().add(const NotificationsRequested());
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.faithColors;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: context.faithStatusBarOverlay,
      child: Scaffold(
        backgroundColor: Colors.transparent,
        extendBodyBehindAppBar: true,
        appBar: const NotificationsAppBarHost(),
        body: NotificationsBackground(
          child: BlocBuilder<NotificationsBloc, NotificationsState>(
            builder: (context, state) {
              if (state.status == NotificationsStatus.failure) {
                return _ErrorBody(
                  message: state.errorMessage ?? 'An error occurred',
                  onRetry: () => context
                      .read<NotificationsBloc>()
                      .add(const NotificationsRequested()),
                );
              }

              if (state.status == NotificationsStatus.initial ||
                  state.status == NotificationsStatus.loading) {
                return Padding(
                  padding:
                      EdgeInsets.only(top: NotificationsAppBar.topInset(context)),
                  child: const NotificationsShimmer(),
                );
              }

              final items = state.visibleNotifications;

              return RefreshIndicator(
                color: colors.brandBlue,
                backgroundColor: colors.cardBackground,
                onRefresh: () async {
                  context
                      .read<NotificationsBloc>()
                      .add(const NotificationsRefreshed());
                  await context.read<NotificationsBloc>().stream.firstWhere(
                        (s) =>
                            s.status == NotificationsStatus.loaded ||
                            s.status == NotificationsStatus.failure,
                      );
                },
                child: CustomScrollView(
                  physics: const AlwaysScrollableScrollPhysics(
                    parent: BouncingScrollPhysics(),
                  ),
                  slivers: [
                    SliverToBoxAdapter(
                      child: SizedBox(
                        height: NotificationsAppBar.topInset(context),
                      ),
                    ),
                    SliverToBoxAdapter(
                      child: _HeaderSummary(unreadCount: state.globalUnreadCount),
                    ),
                    if (items.isEmpty)
                      SliverFillRemaining(
                        hasScrollBody: false,
                        child: Padding(
                          padding: AppSpacing.screenPadding,
                          child: FaithEmptyState(
                            icon: Iconsax.notification,
                            title: 'No notifications yet',
                            subtitle:
                                'When your community interacts with you, it will show up here.',
                          ),
                        ),
                      )
                    else
                      SliverPadding(
                        padding: EdgeInsets.symmetric(horizontal: 16.w),
                        sliver: SliverList(
                          delegate: SliverChildBuilderDelegate(
                            (context, index) {
                              final item = items[index];
                              return NotificationListTile(
                                notification: item,
                                onTap: () {
                                  if (!item.isRead) {
                                    context.read<NotificationsBloc>().add(
                                          NotificationMarkedRead(item.id),
                                        );
                                  }
                                },
                              );
                            },
                            childCount: items.length,
                          ),
                        ),
                      ),
                    SliverToBoxAdapter(child: AppSpacing.v24),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}

class _HeaderSummary extends StatelessWidget {
  final int unreadCount;

  const _HeaderSummary({required this.unreadCount});

  @override
  Widget build(BuildContext context) {
    final colors = context.faithColors;

    return Padding(
      padding: EdgeInsets.fromLTRB(16.w, 0, 16.w, 12.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Stay in the loop',
            style: GoogleFonts.inter(
              color: colors.primaryText,
              fontSize: 26.sp,
              fontWeight: FontWeight.w700,
              letterSpacing: -0.6,
              height: 1.1,
            ),
          ),
          AppSpacing.v8,
          Text(
            unreadCount > 0
                ? 'You have $unreadCount new update${unreadCount == 1 ? '' : 's'} from your community.'
                : 'Your feed is quiet — check back for likes, lives, and campaigns.',
            style: GoogleFonts.inter(
              color: colors.mutedText,
              fontSize: 14.sp,
              height: 1.45,
            ),
          ),
        ],
      ),
    );
  }
}

class _ErrorBody extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const _ErrorBody({
    required this.message,
    required this.onRetry,
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
            Text(
              message,
              textAlign: TextAlign.center,
              style: TextStyle(color: colors.primaryText),
            ),
            AppSpacing.v16,
            PrimaryButton.feedAction(text: 'Retry', onPressed: onRetry),
          ],
        ),
      ),
    );
  }
}
