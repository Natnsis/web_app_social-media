import 'dart:io';

import 'package:faithconnect/core/core.dart';
import 'package:faithconnect/features/church/application/church_service.dart';
import 'package:faithconnect/features/church/data/dto/update_church_profile_dto.dart';
import 'package:faithconnect/features/church/domain/access/church_edit_access.dart';
import 'package:faithconnect/features/church/domain/entities/church_profile.dart';
import 'package:faithconnect/features/church/domain/entities/church_profile_ids.dart';
import 'package:faithconnect/features/profile/presentation/widgets/profile_hub_app_bar.dart';
import 'package:faithconnect/injection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';

class EditChurchProfilePage extends StatefulWidget {
  final String churchId;
  final ChurchProfile? profile;

  const EditChurchProfilePage({
    super.key,
    required this.churchId,
    this.profile,
  });

  @override
  State<EditChurchProfilePage> createState() => _EditChurchProfilePageState();
}

class _EditChurchProfilePageState extends State<EditChurchProfilePage> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  late final TextEditingController _bioController;
  late final TextEditingController _locationController;

  bool _loading = false;
  bool _saving = false;
  bool _accessDenied = false;
  String? _associatedChurchId;
  ChurchProfile? _profile;

  String? _avatarUrl;
  UploadedMedia? _pickedAvatar;

  String? _bannerUrl;
  UploadedMedia? _pickedBanner;

  @override
  void initState() {
    super.initState();
    _profile = widget.profile;
    _nameController = TextEditingController();
    _bioController = TextEditingController();
    _locationController = TextEditingController();
    _bootstrap();
  }

  Future<void> _bootstrap() async {
    setState(() => _loading = true);

    final user = await SharedPrefsService.getUser();
    _associatedChurchId = user?.churchId?.trim();

    if (_profile == null) {
      final profileId = ChurchProfileIds.isMyChurch(widget.churchId)
          ? ChurchProfileIds.me
          : widget.churchId;
      final result = await sl<ChurchService>().getChurchProfile(profileId);
      if (!mounted) return;

      result.fold(
        (failure) {
          showError(context, failure.message);
          setState(() {
            _loading = false;
            _accessDenied = true;
          });
        },
        (feed) {
          _profile = feed.profile;
          if (_associatedChurchId == null || _associatedChurchId!.isEmpty) {
            _associatedChurchId = feed.profile.id;
          }
          _bindProfileFields(feed.profile);
          setState(() => _loading = false);
        },
      );
      return;
    }

    _bindProfileFields(_profile!);
    if (_associatedChurchId == null || _associatedChurchId!.isEmpty) {
      _associatedChurchId = _profile!.id;
    }
    if (!mounted) return;
    setState(() => _loading = false);
  }

  void _bindProfileFields(ChurchProfile profile) {
    _nameController.text = profile.name;
    _bioController.text = profile.bio;
    _locationController.text = profile.locationLabel ?? '';
    _avatarUrl = profile.avatarUrl;
    _bannerUrl = profile.bannerUrl;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _bioController.dispose();
    _locationController.dispose();
    super.dispose();
  }

  bool get _canEditCurrentChurch {
    final profile = _profile;
    if (profile == null) return false;

    final access = context.readRoleAccess();
    if (!access.canManageChurchContent) return false;

    if (ChurchProfileIds.isMyChurch(widget.churchId)) return true;

    return ChurchEditAccess.canEditChurchId(
      access: access,
      churchId: profile.id,
      associatedChurchId: _associatedChurchId,
    );
  }

  Future<void> _pickAvatar() async {
    final picked = await sl<MediaUploadService>().pickImage();
    if (!mounted || picked == null) return;
    setState(() => _pickedAvatar = picked);
  }

  Future<void> _pickBanner() async {
    final picked = await sl<MediaUploadService>().pickImage();
    if (!mounted || picked == null) return;
    setState(() => _pickedBanner = picked);
  }

  Future<void> _save() async {
    final profile = _profile;
    if (profile == null) return;

    if (!_canEditCurrentChurch) {
      showInfo(
        context,
        'You do not have permission to edit this church profile.',
      );
      return;
    }

    if (!_formKey.currentState!.validate()) return;

    setState(() => _saving = true);

    final result = await sl<ChurchService>().updateChurchProfile(
      profile.id,
      UpdateChurchProfileDto(
        name: _nameController.text.trim(),
        bio: _bioController.text.trim(),
        locationLabel: _locationController.text.trim(),
        avatarPath: _pickedAvatar?.filePath,
        bannerPath: _pickedBanner?.filePath,
      ),
    );

    if (!mounted) return;
    setState(() => _saving = false);

    result.fold(
      (failure) => showError(context, failure.message),
      (_) {
        showSuccess(context, 'Church profile updated');
        context.pop(true);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.faithColors;

    if (_accessDenied) {
      return Scaffold(
        backgroundColor: colors.scaffoldBackground,
        appBar: const ProfileHubAppBar(title: 'Edit Church Profile'),
        body: const SizedBox.shrink(),
      );
    }

    return ChurchContentGuard(
      child: Scaffold(
        backgroundColor: colors.scaffoldBackground,
        appBar: const ProfileHubAppBar(title: 'Edit Church Profile'),
        body: _loading
            ? const Center(child: CircularProgressIndicator())
            : !_canEditCurrentChurch
                ? _AccessDeniedBody(colors: colors)
                : SingleChildScrollView(
                    padding: EdgeInsets.fromLTRB(16.w, 8.h, 16.w, 24.h),
                    physics: const BouncingScrollPhysics(),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Text(
                            'Update your church details. Changes will be visible to everyone.',
                            style: GoogleFonts.inter(
                              color: colors.mutedText,
                              fontSize: 13.sp,
                              height: 1.45,
                            ),
                          ),
                          SizedBox(height: 24.h),
                          _buildBannerPicker(context),
                          SizedBox(height: 16.h),
                          Center(child: _buildAvatarPicker(context)),
                          SizedBox(height: 24.h),
                          CustomTextField(
                            label: 'Church name',
                            hint: 'Name of the church',
                            controller: _nameController,
                            keyboardType: TextInputType.name,
                            validator: (value) {
                              if (value == null || value.trim().isEmpty) {
                                return 'Church name is required';
                              }
                              return null;
                            },
                          ),
                          SizedBox(height: 16.h),
                          CustomTextField(
                            label: 'Bio',
                            hint: 'Tell the community about your church',
                            controller: _bioController,
                            keyboardType: TextInputType.multiline,
                            maxLines: 4,
                          ),
                          SizedBox(height: 16.h),
                          CustomTextField(
                            label: 'Location',
                            hint: 'e.g. Addis Ababa, Ethiopia',
                            controller: _locationController,
                            keyboardType: TextInputType.text,
                          ),
                          SizedBox(height: 28.h),
                          PrimaryButton.feedAction(
                            text: _saving ? 'Saving…' : 'Save changes',
                            onPressed: _saving ? null : _save,
                            width: double.infinity,
                          ),
                        ],
                      ),
                    ),
                  ),
      ),
    );
  }

  Widget _buildAvatarPicker(BuildContext context) {
    final colors = context.faithColors;
    final pickedPath = _pickedAvatar?.filePath;
    final networkUrl = _avatarUrl?.trim();

    Widget avatarChild;
    if (pickedPath != null && pickedPath.isNotEmpty) {
      avatarChild = Image.file(
        File(pickedPath),
        width: 96.r,
        height: 96.r,
        fit: BoxFit.cover,
      );
    } else if (networkUrl != null && networkUrl.isNotEmpty) {
      avatarChild = Image.network(
        networkUrl,
        width: 96.r,
        height: 96.r,
        fit: BoxFit.cover,
        errorBuilder: (_, _, _) => _avatarPlaceholder(colors),
      );
    } else {
      avatarChild = _avatarPlaceholder(colors);
    }

    return GestureDetector(
      onTap: _pickAvatar,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Container(
            width: 96.r,
            height: 96.r,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: colors.divider, width: 2),
            ),
            clipBehavior: Clip.antiAlias,
            child: avatarChild,
          ),
          Positioned(
            right: 0,
            bottom: 0,
            child: Container(
              width: 30.r,
              height: 30.r,
              decoration: BoxDecoration(
                color: colors.brandBlue,
                shape: BoxShape.circle,
                border: Border.all(color: colors.scaffoldBackground, width: 2),
              ),
              child: Icon(
                Iconsax.camera,
                size: 16.r,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _avatarPlaceholder(FaithAppColors colors) {
    return ColoredBox(
      color: colors.tagBackground,
      child: Icon(
        Iconsax.building,
        size: 40.r,
        color: colors.mutedText,
      ),
    );
  }

  Widget _buildBannerPicker(BuildContext context) {
    final colors = context.faithColors;
    final pickedPath = _pickedBanner?.filePath;
    final networkUrl = _bannerUrl?.trim();

    Widget bannerChild;
    if (pickedPath != null && pickedPath.isNotEmpty) {
      bannerChild = Image.file(
        File(pickedPath),
        width: double.infinity,
        height: 120.h,
        fit: BoxFit.cover,
      );
    } else if (networkUrl != null && networkUrl.isNotEmpty) {
      bannerChild = Image.network(
        networkUrl,
        width: double.infinity,
        height: 120.h,
        fit: BoxFit.cover,
        errorBuilder: (_, _, _) => _bannerPlaceholder(colors),
      );
    } else {
      bannerChild = _bannerPlaceholder(colors);
    }

    return GestureDetector(
      onTap: _pickBanner,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Container(
            width: double.infinity,
            height: 120.h,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12.r),
              border: Border.all(color: colors.divider, width: 2),
            ),
            clipBehavior: Clip.antiAlias,
            child: bannerChild,
          ),
          Positioned(
            right: 8.w,
            bottom: 8.h,
            child: Container(
              width: 30.r,
              height: 30.r,
              decoration: BoxDecoration(
                color: colors.brandBlue,
                shape: BoxShape.circle,
                border: Border.all(color: colors.scaffoldBackground, width: 2),
              ),
              child: Icon(
                Iconsax.camera,
                size: 16.r,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _bannerPlaceholder(FaithAppColors colors) {
    return ColoredBox(
      color: colors.tagBackground,
      child: Center(
        child: Icon(
          Iconsax.gallery,
          size: 40.r,
          color: colors.mutedText,
        ),
      ),
    );
  }
}

class _AccessDeniedBody extends StatefulWidget {
  final FaithAppColors colors;

  const _AccessDeniedBody({required this.colors});

  @override
  State<_AccessDeniedBody> createState() => _AccessDeniedBodyState();
}

class _AccessDeniedBodyState extends State<_AccessDeniedBody> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      showInfo(
        context,
        'You can only edit the church linked to your administrator account.',
      );
      if (context.canPop()) {
        context.pop();
      } else {
        context.go(RoutesConstant.home);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: CircularProgressIndicator(color: widget.colors.brandBlue),
    );
  }
}
