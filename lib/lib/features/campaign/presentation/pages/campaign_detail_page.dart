import 'package:faithconnect/core/core.dart';
import 'package:faithconnect/features/campaign/presentation/bloc/campaign_detail_bloc.dart';
import 'package:faithconnect/features/campaign/presentation/bloc/campaign_detail_event.dart';
import 'package:faithconnect/features/campaign/presentation/bloc/campaign_detail_state.dart';
import 'package:faithconnect/features/campaign/presentation/widgets/campaign_amount_row.dart';
import 'package:faithconnect/features/campaign/presentation/widgets/campaign_donor_row.dart';
import 'package:faithconnect/features/campaign/presentation/widgets/campaign_metric_tile.dart';
import 'package:faithconnect/features/campaign/presentation/widgets/campaign_progress_bar.dart';
import 'package:faithconnect/core/widgets/in_app_webview_page.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';

class CampaignDetailPage extends StatefulWidget {
  final String campaignId;
  final bool autoOpenDonate;

  const CampaignDetailPage({
    super.key,
    required this.campaignId,
    this.autoOpenDonate = false,
  });

  @override
  State<CampaignDetailPage> createState() => _CampaignDetailPageState();
}

class _CampaignDetailPageState extends State<CampaignDetailPage> {
  @override
  void initState() {
    super.initState();
    context.read<CampaignDetailBloc>().add(const CampaignDetailRequested());
    if (widget.autoOpenDonate) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _showDonationModal(context);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.faithColors;
    final isDark = context.isDarkMode;
    final pageBackground = colors.scaffoldBackground;
    final titleColor = isDark ? Colors.white : colors.primaryText;
    final mutedColor = isDark ? DarkTheme.feedMutedText : colors.mutedText;
    final overlayBottomColor =
        (isDark ? Colors.black : colors.scaffoldBackground).withValues(
          alpha: 0.85,
        );

    return Scaffold(
      backgroundColor: pageBackground,
      body: BlocConsumer<CampaignDetailBloc, CampaignDetailState>(
        listener: (context, state) async {
          if (state is CampaignDetailLoaded) {
            if (state.feedbackMessage != null) {
              if (state.feedbackIsError) {
                showWarning(context, state.feedbackMessage!);
              } else {
                if (state.feedbackMessage?.toUpperCase() == 'SUCCESS') {
                  showDialog(
                    context: context,
                    builder: (ctx) => AlertDialog(
                      title: const Text('Payment Successful'),
                      content: const Text('Your campaign donation has been successfully processed!'),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.of(ctx).pop(),
                          child: const Text('OK'),
                        ),
                      ],
                    ),
                  );
                } else {
                  showSuccess(context, state.feedbackMessage!);
                }
              }
              context.read<CampaignDetailBloc>().add(
                const CampaignFeedbackDismissed(),
              );
            }
            if (state.checkoutUrl != null) {
              final url = state.checkoutUrl!;
              final txRef = state.txRef;
              context.read<CampaignDetailBloc>().add(
                const CampaignFeedbackDismissed(),
              );
              await Navigator.of(context).push<bool>(
                MaterialPageRoute(
                  builder: (_) => InAppWebViewPage(
                    url: url,
                    title: 'Complete Donation',
                    returnUrl: 'google.com',
                  ),
                ),
              );

              if (txRef != null && context.mounted) {
                context.read<CampaignDetailBloc>().add(
                  TransactionStatusChecked(txRef),
                );
              }
            }
          }
        },
        builder: (context, state) {
          if (state is CampaignDetailLoading) {
            return const Center(
              child: CircularProgressIndicator(color: DarkTheme.brandBlue),
            );
          }

          if (state is CampaignDetailFailure) {
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
                      onPressed: () => context.read<CampaignDetailBloc>().add(
                        const CampaignDetailRequested(),
                      ),
                    ),
                  ],
                ),
              ),
            );
          }

          if (state is! CampaignDetailLoaded) {
            return const SizedBox.shrink();
          }

          final detail = state.detail;
          final campaign = detail.campaign;

          return CustomScrollView(
            slivers: [
              SliverAppBar(
                expandedHeight: 260.h,
                pinned: true,
                backgroundColor: pageBackground,
                leading: IconButton(
                  icon: Icon(
                    CupertinoIcons.back,
                    color: titleColor,
                    size: 22.r,
                  ),
                  onPressed: () => context.pop(),
                ),
                actions: [
                  IconButton(
                    icon: Icon(Iconsax.export_3, color: titleColor, size: 22.r),
                    onPressed: () => ContentShare.shareCampaign(
                      title: campaign.title,
                      organizationName: campaign.organizationName,
                      description: campaign.description,
                    ),
                  ),
                ],
                flexibleSpace: FlexibleSpaceBar(
                  background: Stack(
                    fit: StackFit.expand,
                    children: [
                      if (campaign.imageUrl != null)
                        Image.network(
                          campaign.imageUrl!,
                          fit: BoxFit.cover,
                          errorBuilder: (_, _, _) =>
                              Container(color: DarkTheme.feedTagBackground),
                        )
                      else
                        Container(color: DarkTheme.feedTagBackground),
                      DecoratedBox(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [Colors.transparent, overlayBottomColor],
                          ),
                        ),
                      ),
                      Positioned(
                        left: 16.w,
                        right: 16.w,
                        bottom: 16.h,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              padding: EdgeInsets.symmetric(
                                horizontal: 10.w,
                                vertical: 5.h,
                              ),
                              decoration: BoxDecoration(
                                color: DarkTheme.brandBlue,
                                borderRadius: BorderRadius.circular(999.r),
                              ),
                              child: Text(
                                campaign.statusBadge,
                                style: GoogleFonts.inter(
                                  color: Colors.white,
                                  fontSize: 11.sp,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                            SizedBox(height: 10.h),
                            Text(
                              campaign.title,
                              style: GoogleFonts.inter(
                                color: Colors.white,
                                fontSize: 24.sp,
                                fontWeight: FontWeight.w700,
                                height: 1.2,
                              ),
                            ),
                            SizedBox(height: 8.h),
                            Row(
                              children: [
                                Icon(
                                  Iconsax.building,
                                  size: 14.r,
                                  color: Colors.white.withValues(alpha: 0.86),
                                ),
                                SizedBox(width: 6.w),
                                Expanded(
                                  child: Text(
                                    campaign.organizationName,
                                    style: GoogleFonts.inter(
                                      color: Colors.white.withValues(
                                        alpha: 0.86,
                                      ),
                                      fontSize: 13.sp,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            if (campaign.location != null) ...[
                              SizedBox(height: 4.h),
                              Row(
                                children: [
                                  Icon(
                                    Iconsax.location,
                                    size: 14.r,
                                    color: Colors.white.withValues(alpha: 0.86),
                                  ),
                                  SizedBox(width: 6.w),
                                  Expanded(
                                    child: Text(
                                      campaign.location!,
                                      style: GoogleFonts.inter(
                                        color: Colors.white.withValues(
                                          alpha: 0.86,
                                        ),
                                        fontSize: 13.sp,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.fromLTRB(16.w, 16.h, 16.w, 100.h),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      CampaignAmountRow(
                        raisedEtb: campaign.raisedAmountEtb,
                        goalEtb: campaign.goalAmountEtb,
                        largeRaised: true,
                      ),
                      SizedBox(height: 12.h),
                      CampaignProgressBar(
                        progress: campaign.progressPercent / 100,
                        height: 8,
                      ),
                      SizedBox(height: 8.h),
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              '${campaign.progressPercentRounded}% of funding goal reached',
                              style: GoogleFonts.inter(
                                color: mutedColor,
                                fontSize: 12.sp,
                              ),
                            ),
                          ),
                          Text(
                            detail.supportLabel,
                            style: GoogleFonts.inter(
                              color: mutedColor,
                              fontSize: 12.sp,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 24.h),
                      Text(
                        'Mission Overview',
                        style: GoogleFonts.inter(
                          color: titleColor,
                          fontSize: 18.sp,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      SizedBox(height: 10.h),
                      Text(
                        detail.missionOverview,
                        style: GoogleFonts.inter(
                          color: mutedColor,
                          fontSize: 14.sp,
                          height: 1.55,
                        ),
                      ),
                      SizedBox(height: 20.h),
                      CampaignMetricTile(
                        icon: Iconsax.people,
                        label: 'Total Donors',
                        value: '${detail.totalDonors}',
                      ),
                      SizedBox(height: 10.h),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: EdgeInsets.fromLTRB(16.w, 8.h, 16.w, 12.h),
          child: BlocBuilder<CampaignDetailBloc, CampaignDetailState>(
            builder: (context, state) {
              final isDonating =
                  state is CampaignDetailLoaded && state.isDonating;
              return PrimaryButton(
                text: isDonating ? 'Processing...' : 'Give (ETB)',
                onPressed: isDonating
                    ? null
                    : () => _showDonationModal(context),
                isGradient: true,
                width: double.infinity,
                height: 52.h,
                prefixIcon: Icon(
                  Iconsax.heart,
                  color: Colors.white,
                  size: 20.r,
                ),
                radiusVariant: ButtonRadius.full,
              );
            },
          ),
        ),
      ),
    );
  }

  void _showDonationModal(BuildContext context) {
    double amount = 500;
    String message = 'Keep up the great work!';

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: context.faithColors.cardBackground,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
      ),
      builder: (_) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.viewInsetsOf(context).bottom + 20.h,
            left: 20.w,
            right: 20.w,
            top: 24.h,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'Make a Donation',
                style: GoogleFonts.inter(
                  fontSize: 18.sp,
                  fontWeight: FontWeight.w700,
                  color: context.faithColors.primaryText,
                ),
              ),
              SizedBox(height: 16.h),
              TextFormField(
                initialValue: '500',
                keyboardType: TextInputType.number,
                style: TextStyle(color: context.faithColors.primaryText),
                decoration: InputDecoration(
                  labelText: 'Amount (ETB)',
                  labelStyle: TextStyle(color: context.faithColors.mutedText),
                  border: const OutlineInputBorder(),
                ),
                onChanged: (val) => amount = double.tryParse(val) ?? 0,
              ),
              SizedBox(height: 16.h),
              TextFormField(
                initialValue: message,
                style: TextStyle(color: context.faithColors.primaryText),
                decoration: InputDecoration(
                  labelText: 'Message (Optional)',
                  labelStyle: TextStyle(color: context.faithColors.mutedText),
                  border: const OutlineInputBorder(),
                ),
                onChanged: (val) => message = val,
              ),
              SizedBox(height: 24.h),
              PrimaryButton.feedAction(
                text: 'Proceed to Payment',
                onPressed: () {
                  if (amount <= 0) {
                    showWarning(context, 'Enter a valid amount');
                    return;
                  }
                  Navigator.of(context).pop();
                  context.read<CampaignDetailBloc>().add(
                    CampaignDonateRequested(
                      amountEtb: amount,
                      donorMessage: message,
                    ),
                  );
                },
              ),
            ],
          ),
        );
      },
    );
  }
}
