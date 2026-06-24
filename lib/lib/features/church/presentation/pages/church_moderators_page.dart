import 'dart:async';

import 'package:faithconnect/core/core.dart';
import 'package:faithconnect/features/church/application/church_service.dart';
import 'package:faithconnect/features/church/domain/entities/church_member.dart';
import 'package:faithconnect/features/church/presentation/bloc/church_moderators_bloc.dart';
import 'package:faithconnect/features/church/presentation/bloc/church_moderators_event.dart';
import 'package:faithconnect/features/church/presentation/bloc/church_moderators_state.dart';
import 'package:faithconnect/features/profile/presentation/widgets/profile_hub_app_bar.dart';
import 'package:faithconnect/features/user/application/user_service.dart';
import 'package:faithconnect/features/user/domain/entities/searched_user.dart';
import 'package:faithconnect/injection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';

class ChurchModeratorsPage extends StatefulWidget {
  const ChurchModeratorsPage({super.key});

  @override
  State<ChurchModeratorsPage> createState() => _ChurchModeratorsPageState();
}

class _ChurchModeratorsPageState extends State<ChurchModeratorsPage> {
  late final ChurchModeratorsBloc _bloc;

  @override
  void initState() {
    super.initState();
    _bloc = ChurchModeratorsBloc(
      churchService: sl<ChurchService>(),
      userService: sl<UserService>(),
    );
  }

  @override
  void dispose() {
    _bloc.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: _bloc,
      child: const _ChurchModeratorsView(),
    );
  }
}

class _ChurchModeratorsView extends StatefulWidget {
  const _ChurchModeratorsView();

  @override
  State<_ChurchModeratorsView> createState() => _ChurchModeratorsViewState();
}

class _ChurchModeratorsViewState extends State<_ChurchModeratorsView> {
  final _searchController = TextEditingController();
  Timer? _searchDebounce;

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _searchDebounce?.cancel();
    _searchController
      ..removeListener(_onSearchChanged)
      ..dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    _searchDebounce?.cancel();
    _searchDebounce = Timer(const Duration(milliseconds: 350), () {
      if (!mounted) return;
      context.read<ChurchModeratorsBloc>().add(
            ChurchModeratorUserSearchRequested(_searchController.text),
          );
    });
  }

  void _assignUser(String userId) {
    context
        .read<ChurchModeratorsBloc>()
        .add(ChurchModeratorAssignSubmitted(userId));
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<ChurchModeratorsBloc, ChurchModeratorsState>(
      listener: (context, state) {
        if (state is ChurchModeratorsFailure) {
          showWarning(context, state.message);
        } else if (state is ChurchModeratorsLoaded) {
          if (state.errorMessage != null) {
            showWarning(context, state.errorMessage!);
          } else if (state.searchErrorMessage != null) {
            showWarning(context, state.searchErrorMessage!);
          }
        }
      },
      builder: (context, state) {
        final colors = context.faithColors;
        final loaded = state is ChurchModeratorsLoaded ? state : null;
        final isBusy = loaded?.isAssigning == true;

        return Scaffold(
          backgroundColor: colors.scaffoldBackground,
          appBar: const ProfileHubAppBar(
            title: 'Manage Admins',
            useWhiteInDarkMode: true,
          ),
          body: Column(
            children: [
              Padding(
                padding: EdgeInsets.fromLTRB(16.w, 12.h, 16.w, 8.h),
                child: AppCompactCard(
                  padding: EdgeInsets.all(16.r),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text(
                        'Assign moderator',
                        style: GoogleFonts.inter(
                          color: colors.primaryText,
                          fontSize: 16.sp,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      SizedBox(height: 8.h),
                      Text(
                        'Search by name or phone number, then tap a user to assign them as a moderator.',
                        style: GoogleFonts.inter(
                          color: colors.mutedText,
                          fontSize: 13.sp,
                          height: 1.4,
                        ),
                      ),
                      SizedBox(height: 12.h),
                      CustomMessageTextField(
                        controller: _searchController,
                        hint: 'Search users...',
                        enabled: !isBusy,
                        showEmojiButton: false,
                      ),
                      if (loaded != null && loaded.isSearchingUsers) ...[
                        SizedBox(height: 12.h),
                        Center(
                          child: SizedBox(
                            width: 22.r,
                            height: 22.r,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: colors.brandBlue,
                            ),
                          ),
                        ),
                      ] else if (loaded != null &&
                          loaded.searchQuery.isNotEmpty) ...[
                        SizedBox(height: 8.h),
                        _UserSearchResults(
                          results: loaded.searchResults,
                          isAssigning: loaded.isAssigning,
                          onAssign: (user) => _assignUser(user.id),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
              Expanded(child: _buildBody(context, state)),
            ],
          ),
        );
      },
    );
  }

  Widget _buildBody(BuildContext context, ChurchModeratorsState state) {
    final colors = context.faithColors;

    if (state is ChurchModeratorsLoading) {
      return Center(
        child: CircularProgressIndicator(color: colors.brandBlue),
      );
    }

    if (state is ChurchModeratorsFailure) {
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
                    .read<ChurchModeratorsBloc>()
                    .add(const ChurchModeratorsRequested()),
              ),
            ],
          ),
        ),
      );
    }

    if (state is! ChurchModeratorsLoaded) {
      return const SizedBox.shrink();
    }

    if (state.members.isEmpty) {
      return Center(
        child: Padding(
          padding: AppSpacing.screenPadding,
          child: Text(
            'No moderators assigned yet.',
            textAlign: TextAlign.center,
            style: GoogleFonts.inter(
              color: colors.mutedText,
              fontSize: 14.sp,
            ),
          ),
        ),
      );
    }

    return ListView.separated(
      padding: EdgeInsets.fromLTRB(16.w, 8.h, 16.w, 24.h),
      itemCount: state.members.length,
      separatorBuilder: (_, _) => SizedBox(height: 10.h),
      itemBuilder: (context, index) {
        return _ModeratorTile(member: state.members[index]);
      },
    );
  }
}

class _UserSearchResults extends StatelessWidget {
  final List<SearchedUser> results;
  final bool isAssigning;
  final ValueChanged<SearchedUser> onAssign;

  const _UserSearchResults({
    required this.results,
    required this.isAssigning,
    required this.onAssign,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.faithColors;

    if (results.isEmpty) {
      return Padding(
        padding: EdgeInsets.symmetric(vertical: 8.h),
        child: Text(
          'No users found.',
          style: GoogleFonts.inter(
            color: colors.mutedText,
            fontSize: 13.sp,
          ),
        ),
      );
    }

    return ConstrainedBox(
      constraints: BoxConstraints(maxHeight: 220.h),
      child: ListView.separated(
        shrinkWrap: true,
        padding: EdgeInsets.zero,
        itemCount: results.length,
        separatorBuilder: (_, _) => SizedBox(height: 4.h),
        itemBuilder: (context, index) {
          final user = results[index];
          return Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: isAssigning ? null : () => onAssign(user),
              borderRadius: BorderRadius.circular(12.r),
              child: Padding(
                padding: EdgeInsets.symmetric(vertical: 8.h),
                child: Row(
                  children: [
                    AppAvatar(
                      imageUrl: user.avatarUrl,
                      initials: AppAvatar.initialsFromName(user.fullName),
                      size: 40,
                    ),
                    SizedBox(width: 12.w),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            user.fullName,
                            style: GoogleFonts.inter(
                              color: colors.primaryText,
                              fontSize: 14.sp,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          if (user.phoneNumber != null) ...[
                            SizedBox(height: 2.h),
                            Text(
                              user.phoneNumber!,
                              style: GoogleFonts.inter(
                                color: colors.mutedText,
                                fontSize: 12.sp,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                    Icon(
                      Iconsax.add_circle,
                      color: isAssigning ? colors.iconMuted : colors.brandBlue,
                      size: 22.r,
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class _ModeratorTile extends StatelessWidget {
  final ChurchMember member;

  const _ModeratorTile({required this.member});

  Future<void> _confirmRevoke(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Revoke moderator?'),
        content: Text('Are you sure you want to revoke ${member.name}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Revoke'),
          ),
        ],
      ),
    );

    if (confirmed != true || !context.mounted) return;
    context
        .read<ChurchModeratorsBloc>()
        .add(ChurchModeratorRevokeSubmitted(member.userId));
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.faithColors;

    return AppCompactCard(
      padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 12.h),
      child: Row(
        children: [
          AppAvatar(
            imageUrl: member.avatarUrl,
            initials: AppAvatar.initialsFromName(member.name),
            size: 44,
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  member.name,
                  style: GoogleFonts.inter(
                    color: colors.primaryText,
                    fontSize: 15.sp,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                if (member.role != null && member.role!.isNotEmpty) ...[
                  SizedBox(height: 2.h),
                  Text(
                    member.role!,
                    style: GoogleFonts.inter(
                      color: colors.mutedText,
                      fontSize: 12.sp,
                    ),
                  ),
                ],
              ],
            ),
          ),
          IconButton(
            icon: Icon(Iconsax.trash, color: colors.iconMuted, size: 20.r),
            onPressed: () => _confirmRevoke(context),
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
          ),
          SizedBox(width: 8.w),
          Icon(Iconsax.shield_tick, color: colors.brandBlue, size: 20.r),
        ],
      ),
    );
  }
}
