import 'package:faithconnect/core/core.dart';
import 'package:faithconnect/features/auth/presentation/theme/auth_theme.dart';
import 'package:faithconnect/features/auth/presentation/widgets/auth_background.dart';
import 'package:faithconnect/features/auth/presentation/widgets/auth_language_selector.dart';
import 'package:faithconnect/features/auth/presentation/widgets/auth_primary_button.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

class LanguagePage extends StatefulWidget {
  const LanguagePage({super.key});

  @override
  State<LanguagePage> createState() => _LanguagePageState();
}

class _LanguagePageState extends State<LanguagePage> {
  static const List<AppLanguage> _authLanguages = [
    AppLanguage.english,
    AppLanguage.amharic,
    AppLanguage.oromo,
    AppLanguage.sidama,
  ];

  late AppLanguage _pendingLanguage;

  @override
  void initState() {
    super.initState();
    _pendingLanguage = context.read<LocaleCubit>().state;
  }

  Future<void> _confirmSelection() async {
    final current = context.read<LocaleCubit>().state;
    if (_pendingLanguage != current) {
      await context.read<LocaleCubit>().setLanguage(_pendingLanguage);
    }
    if (!mounted) return;
    showInfo(context, 'Language set to ${_pendingLanguage.label}');
    context.pop();
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.authPalette;
    final colors = context.faithColors;
    final savedLanguage = context.watch<LocaleCubit>().state;
    final hasChanges = _pendingLanguage != savedLanguage;

    return Scaffold(
      backgroundColor: auth.formBackgroundColor ?? colors.scaffoldBackground,
      body: AuthBackground(
        child: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Padding(
                padding: EdgeInsets.fromLTRB(4.w, 4.h, 8.w, 0),
                child: Row(
                  children: [
                    IconButton(
                      onPressed: () => context.pop(),
                      icon: Icon(
                        CupertinoIcons.back,
                        size: 22.r,
                        color: colors.iconPrimary,
                      ),
                    ),
                    Expanded(
                      child: Text(
                        'Language',
                        style: GoogleFonts.inter(
                          color: auth.titleColor,
                          fontSize: 20.sp,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: EdgeInsets.fromLTRB(20.w, 8.h, 20.w, 16.h),
                child: Text(
                  'Choose your preferred language: English, Amharic, Oromo, or Sidama.',
                  style: GoogleFonts.inter(
                    color: auth.subtitleColor,
                    fontSize: 14.sp,
                    height: 1.45,
                  ),
                ),
              ),
              Expanded(
                child: SingleChildScrollView(
                  padding: EdgeInsets.fromLTRB(20.w, 0, 20.w, 16.h),
                  physics: const BouncingScrollPhysics(),
                  child: AuthLanguageSelector(
                    selectedLanguage: _pendingLanguage,
                    onLanguageChanged: (language) {
                      setState(() => _pendingLanguage = language);
                    },
                    languages: _authLanguages,
                  ),
                ),
              ),
              Padding(
                padding: EdgeInsets.fromLTRB(20.w, 0, 20.w, 16.h),
                child: AuthPrimaryButton(
                  label: hasChanges ? 'Confirm language' : 'Done',
                  onPressed: _confirmSelection,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
