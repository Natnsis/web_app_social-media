import 'dart:async';

import 'package:faithconnect/core/core.dart';
import 'package:faithconnect/features/chat/presentation/navigation/chat_navigation.dart';
import 'package:faithconnect/features/chat/presentation/widgets/chat_form_app_bar.dart';
import 'package:faithconnect/features/user/application/user_service.dart';
import 'package:faithconnect/features/user/domain/entities/searched_user.dart';
import 'package:faithconnect/injection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';

class ChatAddUserPage extends StatefulWidget {
  const ChatAddUserPage({super.key});

  @override
  State<ChatAddUserPage> createState() => _ChatAddUserPageState();
}

class _ChatAddUserPageState extends State<ChatAddUserPage> {
  final _searchController = TextEditingController();
  Timer? _searchDebounce;
  List<SearchedUser> _users = const [];
  bool _loading = true;
  bool _openingChat = false;
  String? _errorMessage;
  String _activeQuery = '';
  int _loadGeneration = 0;

  @override
  void initState() {
    super.initState();
    sl<DirectMessagingSocketService>().ensureConnected();
    _searchController.addListener(_onSearchChanged);
    _loadUsers();
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
      _loadUsers(query: _searchController.text.trim());
    });
  }

  Future<void> _loadUsers({String? query}) async {
    final trimmed = query?.trim() ?? '';
    final generation = ++_loadGeneration;

    setState(() {
      _activeQuery = trimmed;
      _loading = true;
      _errorMessage = null;
    });

    final result = await sl<UserService>().searchUsers(
      query: trimmed.isEmpty ? null : trimmed,
      limit: 50,
    );

    if (!mounted || generation != _loadGeneration) return;

    result.fold(
      (failure) => setState(() {
        _loading = false;
        _errorMessage = failure.message;
        _users = const [];
      }),
      (users) => setState(() {
        _loading = false;
        _users = users;
      }),
    );
  }

  Future<void> _openChat(SearchedUser user) async {
    if (_openingChat) return;
    setState(() => _openingChat = true);

    await ChatNavigation.openDirectChat(
      context: context,
      userId: user.id,
      displayName: user.fullName,
      avatarUrl: user.avatarUrl,
    );

    if (mounted) setState(() => _openingChat = false);
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.faithColors;

    return Scaffold(
      backgroundColor: colors.scaffoldBackground,
      appBar: const ChatFormAppBar(title: 'New Message'),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: EdgeInsets.fromLTRB(16.w, 8.h, 16.w, 12.h),
            child: TextField(
              controller: _searchController,
              style: GoogleFonts.inter(
                color: colors.primaryText,
                fontSize: 15.sp,
              ),
              decoration: InputDecoration(
                hintText: 'Search by name or phone',
                prefixIcon: Icon(
                  Iconsax.search_normal,
                  size: 20.r,
                  color: colors.mutedText,
                ),
                suffixIcon: _activeQuery.isNotEmpty
                    ? IconButton(
                        icon: Icon(
                          Icons.close_rounded,
                          size: 20.r,
                          color: colors.mutedText,
                        ),
                        onPressed: () {
                          _searchController.clear();
                          _loadUsers();
                        },
                      )
                    : null,
                filled: true,
                fillColor: colors.tagBackground,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14.r),
                  borderSide: BorderSide(color: colors.divider),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14.r),
                  borderSide: BorderSide(color: colors.divider),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14.r),
                  borderSide: BorderSide(color: colors.brandBlue),
                ),
                contentPadding: EdgeInsets.symmetric(vertical: 12.h),
              ),
            ),
          ),
          Expanded(child: _buildBody(colors)),
        ],
      ),
    );
  }

  Widget _buildBody(FaithAppColors colors) {
    if (_loading) {
      return Center(child: CircularProgressIndicator(color: colors.brandBlue));
    }

    if (_errorMessage != null) {
      return RefreshIndicator(
        color: colors.brandBlue,
        onRefresh: () => _loadUsers(query: _activeQuery),
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          children: [
            FaithEmptyState(
              icon: Iconsax.warning_2,
              title: 'Couldn\'t load users',
              subtitle: _errorMessage!,
              actionLabel: 'Try again',
              onAction: () => _loadUsers(query: _activeQuery),
            ),
          ],
        ),
      );
    }

    if (_users.isEmpty) {
      return RefreshIndicator(
        color: colors.brandBlue,
        onRefresh: () => _loadUsers(query: _activeQuery),
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          children: [
            FaithEmptyState(
              icon: Iconsax.user,
              title: _activeQuery.isEmpty ? 'No users yet' : 'No users found',
              subtitle: _activeQuery.isEmpty
                  ? 'Users you can message will appear here.'
                  : 'Try a different name or phone number.',
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      color: colors.brandBlue,
      onRefresh: () => _loadUsers(query: _activeQuery),
      child: ListView.separated(
        physics: const AlwaysScrollableScrollPhysics(
          parent: BouncingScrollPhysics(),
        ),
        padding: EdgeInsets.fromLTRB(16.w, 0, 16.w, 24.h),
        itemCount: _users.length,
        separatorBuilder: (_, _) => SizedBox(height: 8.h),
        itemBuilder: (context, index) {
          final user = _users[index];
          return _ChatUserTile(
            user: user,
            onTap: _openingChat ? null : () => _openChat(user),
          );
        },
      ),
    );
  }
}

class _ChatUserTile extends StatelessWidget {
  final SearchedUser user;
  final VoidCallback? onTap;

  const _ChatUserTile({required this.user, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final colors = context.faithColors;

    return Material(
      color: colors.cardBackground,
      borderRadius: BorderRadius.circular(14.r),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14.r),
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 12.h),
          child: Row(
            children: [
              AppAvatar(
                imageUrl: user.avatarUrl,
                initials: AppAvatar.initialsFromName(user.fullName),
                size: 44,
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
              Icon(Iconsax.message, color: colors.brandBlue, size: 22.r),
            ],
          ),
        ),
      ),
    );
  }
}
