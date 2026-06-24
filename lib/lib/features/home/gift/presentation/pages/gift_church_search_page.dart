import 'package:faithconnect/core/core.dart';
import 'package:faithconnect/features/church/application/church_service.dart';
import 'package:faithconnect/features/church/domain/entities/church_profile.dart';
import 'package:faithconnect/features/home/gift/domain/entities/gift_item.dart';
import 'package:faithconnect/injection.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

class GiftChurchSearchPage extends StatefulWidget {
  final GiftItem gift;

  const GiftChurchSearchPage({super.key, required this.gift});

  @override
  State<GiftChurchSearchPage> createState() => _GiftChurchSearchPageState();
}

class _GiftChurchSearchPageState extends State<GiftChurchSearchPage> {
  final TextEditingController _searchController = TextEditingController();
  List<ChurchProfile> _allChurches = [];
  List<ChurchProfile> _filteredChurches = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _fetchChurches();
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _fetchChurches() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    final result = await sl<ChurchService>().getChurches(limit: 100);
    
    if (!mounted) return;

    result.fold(
      (failure) {
        setState(() {
          _error = failure.message;
          _isLoading = false;
        });
      },
      (data) {
        setState(() {
          _allChurches = data.churches;
          _filteredChurches = _allChurches;
          _isLoading = false;
        });
      },
    );
  }

  void _onSearchChanged() {
    final query = _searchController.text.trim().toLowerCase();
    setState(() {
      if (query.isEmpty) {
        _filteredChurches = _allChurches;
      } else {
        _filteredChurches = _allChurches.where((church) {
          return church.name.toLowerCase().contains(query);
        }).toList();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.faithColors;
    final isDark = context.isDarkMode;

    return Scaffold(
      backgroundColor: colors.scaffoldBackground,
      appBar: AppBar(
        backgroundColor: colors.scaffoldBackground,
        elevation: 0,
        leading: IconButton(
          icon: Icon(CupertinoIcons.back, color: colors.iconPrimary),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          'Send to Church',
          style: GoogleFonts.inter(
            color: colors.primaryText,
            fontSize: 16.sp,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
      ),
      body: Column(
        children: [
          Padding(
            padding: EdgeInsets.fromLTRB(16.w, 8.h, 16.w, 16.h),
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 14.w),
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF1B2A3D) : Colors.grey.shade100,
                borderRadius: BorderRadius.circular(12.r),
              ),
              child: TextField(
                controller: _searchController,
                style: GoogleFonts.inter(color: colors.primaryText),
                decoration: InputDecoration(
                  hintText: 'Search churches...',
                  hintStyle: GoogleFonts.inter(color: colors.mutedText),
                  border: InputBorder.none,
                  icon: Icon(CupertinoIcons.search, color: colors.mutedText),
                ),
              ),
            ),
          ),
          Expanded(
            child: _buildBody(colors),
          ),
        ],
      ),
    );
  }

  Widget _buildBody(FaithAppColors colors) {
    if (_isLoading) {
      return Center(
        child: CircularProgressIndicator(color: colors.brandBlue),
      );
    }

    if (_error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              _error!,
              style: TextStyle(color: colors.primaryText),
            ),
            SizedBox(height: 12.h),
            PrimaryButton.feedAction(text: 'Retry', onPressed: _fetchChurches),
          ],
        ),
      );
    }

    if (_filteredChurches.isEmpty) {
      return Center(
        child: Text(
          'No churches found.',
          style: TextStyle(color: colors.mutedText, fontSize: 14.sp),
        ),
      );
    }

    return ListView.builder(
      itemCount: _filteredChurches.length,
      itemBuilder: (context, index) {
        final church = _filteredChurches[index];
        return ListTile(
          contentPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 4.h),
          leading: CircleAvatar(
            backgroundImage: church.avatarUrl != null ? NetworkImage(church.avatarUrl!) : null,
            backgroundColor: colors.tagBackground,
            child: church.avatarUrl == null ? Icon(Icons.church, color: colors.iconMuted) : null,
          ),
          title: Text(
            church.name,
            style: GoogleFonts.inter(
              color: colors.primaryText,
              fontWeight: FontWeight.w600,
            ),
          ),
          subtitle: church.locationLabel != null
              ? Text(
                  church.locationLabel!,
                  style: GoogleFonts.inter(color: colors.mutedText, fontSize: 12.sp),
                )
              : null,
          onTap: () {
            context.pushNamed(
              RoutesConstant.churchProfile,
              pathParameters: {'id': church.id},
              extra: {'pendingGift': widget.gift},
            );
          },
        );
      },
    );
  }
}
