import 'package:faithconnect/core/core.dart';
import 'package:faithconnect/features/discovery/presentation/bloc/discovery_bloc.dart';
import 'package:faithconnect/features/discovery/presentation/bloc/discovery_event.dart';
import 'package:faithconnect/features/discovery/presentation/bloc/discovery_state.dart';
import 'package:faithconnect/features/discovery/presentation/bloc/nearby_bloc.dart';
import 'package:faithconnect/features/discovery/presentation/bloc/nearby_event.dart';
import 'package:faithconnect/features/discovery/presentation/widgets/discovery_app_bar.dart';
import 'package:faithconnect/features/discovery/presentation/widgets/discovery_campaigns_section.dart';
import 'package:faithconnect/features/discovery/presentation/widgets/discovery_live_now_section.dart';
import 'package:faithconnect/features/discovery/presentation/widgets/discovery_nearby_section.dart';
import 'package:faithconnect/features/notifications/presentation/navigation/notifications_navigation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

class DiscoveryPage extends StatefulWidget {
  const DiscoveryPage({super.key});

  @override
  State<DiscoveryPage> createState() => _DiscoveryPageState();
}

class _DiscoveryPageState extends State<DiscoveryPage> {
  @override
  void initState() {
    super.initState();
    context.read<DiscoveryBloc>().add(const DiscoveryRequested());
    context.read<NearbyBloc>().add(const NearbyRequested());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: DiscoveryAppBar(
        title: 'Discovery',
        showMenu: true,
        showSearch: true,
        showNotifications: true,
        onMenuTap: () => context.pop(),
        onSearchTap: () => showInfo(context, 'Search coming soon'),
        onNotificationsTap: () => NotificationsNavigation.open(context),
      ),
      body: BlocBuilder<DiscoveryBloc, DiscoveryState>(
        builder: (context, state) {
          if (state is DiscoveryFailure) {
            return ListView(
              padding: AppSpacing.screenPadding,
              children: [
                const DiscoveryNearbySection(
                  topSpacing: 8,
                  bottomSpacing: 20,
                  showFilterAction: true,
                ),
                AppSpacing.v24,
                Text(state.message, textAlign: TextAlign.center),
                AppSpacing.v16,
                PrimaryButton.feedAction(
                  text: 'Retry',
                  onPressed: () => context.read<DiscoveryBloc>().add(
                    const DiscoveryRequested(),
                  ),
                ),
              ],
            );
          }

          if (state is! DiscoveryLoaded) {
            return ListView(
              padding: EdgeInsets.only(bottom: 24.h),
              children: [
                SizedBox(height: 8.h),
                const DiscoveryNearbySection(
                  topSpacing: 0,
                  bottomSpacing: 20,
                  showFilterAction: true,
                ),
                Padding(
                  padding: EdgeInsets.symmetric(vertical: 48.h),
                  child: const Center(
                    child: CircularProgressIndicator(
                      color: DarkTheme.brandBlue,
                    ),
                  ),
                ),
              ],
            );
          }

          final content = state.content;

          return RefreshIndicator(
            color: DarkTheme.brandBlue,
            backgroundColor: DarkTheme.feedCardBackground,
            onRefresh: () async {
              context.read<DiscoveryBloc>().add(const DiscoveryRefreshed());
              context.read<NearbyBloc>().add(
                const NearbyRefreshed(useHomePreview: true),
              );
              await context.read<DiscoveryBloc>().stream.firstWhere(
                (s) => s is DiscoveryLoaded || s is DiscoveryFailure,
              );
            },
            child: ListView(
              padding: EdgeInsets.only(bottom: 24.h),
              children: [
                SizedBox(height: 8.h),
                const DiscoveryNearbySection(
                  topSpacing: 0,
                  bottomSpacing: 20,
                  showFilterAction: true,
                ),
                if (content.liveNow.isNotEmpty)
                  DiscoveryLiveNowSection(liveNow: content.liveNow),
                
                
              
                // if (content.suggested.isNotEmpty) ...[
                //   SizedBox(height: 12.h),
                //   SizedBox(
                //     height: 236.h,
                //     child: ListView.separated(
                //       scrollDirection: Axis.horizontal,
                //       padding: EdgeInsets.symmetric(horizontal: 16.w),
                //       itemCount: content.suggested.length,
                //       separatorBuilder: (_, _) => SizedBox(width: 12.w),
                //       itemBuilder: (context, index) {
                //         final church = content.suggested[index];
                //         return DiscoverySuggestedCard(
                //           church: church,
                //           onTap: () => _openChurchProfile(church.id),
                //         );
                //       },
                //     ),
                //   ),
                //   SizedBox(height: 24.h),
                // ],
                if (content.campaigns.isNotEmpty)
                  DiscoveryCampaignsSection(campaigns: content.campaigns),
              ]
              
              ,
            ),
          );
        },
      ),
   
   
    );
  }
}
