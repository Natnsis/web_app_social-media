import 'dart:io';

import 'package:faithconnect/core/core.dart';
import 'package:faithconnect/features/profile/presentation/widgets/profile_hub_app_bar.dart';
import 'package:faithconnect/features/user/application/user_service.dart';
import 'package:faithconnect/features/user/data/dto/update_user_profile_dto.dart';
import 'package:faithconnect/injection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';

class EditProfilePage extends StatefulWidget {
  const EditProfilePage({super.key});

  @override
  State<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _bioController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  bool _loading = true;
  bool _saving = false;
  String? _avatarUrl;
  UploadedMedia? _pickedAvatar;

  @override
  void initState() {
    super.initState();
    _loadUser();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _bioController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  Future<void> _loadUser() async {
    final result = await sl<UserService>().getCurrentUserProfile();
    if (!mounted) return;

    result.fold(
      (failure) {
        showError(context, failure.message);
        setState(() => _loading = false);
      },
      (user) {
        _nameController.text = user.name?.trim() ?? '';
        _bioController.text = user.bio?.trim() ?? '';
        _emailController.text = user.email?.trim() ?? '';
        _phoneController.text = user.phone?.trim() ?? '';
        _avatarUrl = user.avatar;
        setState(() => _loading = false);
      },
    );
  }

  Future<void> _pickAvatar() async {
    final picked = await sl<MediaUploadService>().pickImage();
    if (!mounted || picked == null) return;
    setState(() => _pickedAvatar = picked);
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _saving = true);

    final result = await sl<UserService>().updateCurrentUserProfile(
      UpdateUserProfileDto(
        fullName: _nameController.text.trim(),
        bio: _bioController.text.trim(),
        email: _emailController.text.trim(),
        phoneNumber: _phoneController.text.trim(),
        avatarPath: _pickedAvatar?.filePath,
      ),
    );

    if (!mounted) return;
    setState(() => _saving = false);

    result.fold(
      (failure) => showError(context, failure.message),
      (_) {
        showSuccess(context, 'Profile updated');
        context.pop(true);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.faithColors;

    return Scaffold(
      backgroundColor: colors.scaffoldBackground,
      appBar: const ProfileHubAppBar(title: 'Edit profile'),
      body: _loading
          ? const Center(
              child: CircularProgressIndicator(color: DarkTheme.brandBlue),
            )
          : SingleChildScrollView(
              padding: EdgeInsets.fromLTRB(16.w, 8.h, 16.w, 24.h),
              physics: const BouncingScrollPhysics(),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      'Update your personal details. Changes are saved to your account.',
                      style: GoogleFonts.inter(
                        color: DarkTheme.feedMutedText,
                        fontSize: 13.sp,
                        height: 1.45,
                      ),
                    ),
                    SizedBox(height: 24.h),
                    Center(child: _buildAvatarPicker(context)),
                    SizedBox(height: 24.h),
                    CustomTextField(
                      label: 'Full name',
                      hint: 'Your name',
                      controller: _nameController,
                      keyboardType: TextInputType.name,
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Name is required';
                        }
                        return null;
                      },
                    ),
                    SizedBox(height: 16.h),
                    CustomTextField(
                      label: 'Bio',
                      hint: 'Tell your community about yourself',
                      controller: _bioController,
                      keyboardType: TextInputType.multiline,
                      maxLines: 4,
                    ),
                    SizedBox(height: 16.h),
                    CustomTextField(
                      label: 'Email',
                      hint: 'you@example.com',
                      controller: _emailController,
                      keyboardType: TextInputType.emailAddress,
                      validator: (value) {
                        final text = value?.trim() ?? '';
                        if (text.isEmpty) return 'Email is required';
                        if (!text.contains('@')) {
                          return 'Enter a valid email';
                        }
                        return null;
                      },
                    ),
                    SizedBox(height: 16.h),
                    CustomTextField(
                      label: 'Phone number',
                      hint: '+251912345678',
                      controller: _phoneController,
                      keyboardType: TextInputType.phone,
                      validator: (value) {
                        final text = value?.trim() ?? '';
                        if (text.isEmpty) return 'Phone number is required';
                        if (text.length < 9) {
                          return 'Enter a valid phone number';
                        }
                        return null;
                      },
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
        Iconsax.user,
        size: 40.r,
        color: colors.mutedText,
      ),
    );
  }
}
