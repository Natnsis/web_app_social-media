import 'package:faithconnect/core/core.dart';
import 'package:faithconnect/features/auth/presentation/theme/auth_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';

/// Auth language list with animated selection (page + bottom sheet).
class AuthLanguageSelector extends StatelessWidget {
  final AppLanguage selectedLanguage;
  final ValueChanged<AppLanguage> onLanguageChanged;
  final List<AppLanguage> languages;
  final bool showSectionLabel;

  const AuthLanguageSelector({
    super.key,
    required this.selectedLanguage,
    required this.onLanguageChanged,
    this.languages = const [
      AppLanguage.english,
      AppLanguage.amharic,
      AppLanguage.oromo,
      AppLanguage.sidama,
    ],
    this.showSectionLabel = true,
  });

  @override
  Widget build(BuildContext context) {
    final auth = context.authPalette;
    final colors = context.faithColors;
    final isDark = context.isDarkMode;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (showSectionLabel) ...[
          Padding(
            padding: EdgeInsets.only(left: 4.w, bottom: 10.h),
            child: Text(
              'SELECT LANGUAGE',
              style: GoogleFonts.inter(
                color: isDark ? auth.subtitleColor : colors.mutedText,
                fontSize: 11.sp,
                fontWeight: FontWeight.w600,
                letterSpacing: 1.2,
              ),
            ),
          ),
        ],
        Container(
          padding: EdgeInsets.all(8.w),
          decoration: BoxDecoration(
            color: isDark ? auth.surfaceFill : colors.cardBackground,
            borderRadius: BorderRadius.circular(16.r),
            border: Border.all(
              color: isDark ? auth.surfaceBorder : colors.divider,
            ),
            boxShadow: isDark
                ? null
                : [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.04),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
          ),
          child: Column(
            children: [
              for (var i = 0; i < languages.length; i++) ...[
                if (i > 0) SizedBox(height: 6.h),
                _AuthLanguageOptionTile(
                  language: languages[i],
                  isSelected: languages[i] == selectedLanguage,
                  onTap: () => onLanguageChanged(languages[i]),
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }
}

class _AuthLanguageOptionTile extends StatelessWidget {
  final AppLanguage language;
  final bool isSelected;
  final VoidCallback onTap;

  const _AuthLanguageOptionTile({
    required this.language,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.faithColors;
    final isDark = context.isDarkMode;

    final selectedBg = colors.brandBlue;
    final selectedBorder = colors.brandBlue;
    final idleBorder =
        isDark ? Colors.white.withValues(alpha: 0.06) : colors.divider;
    final titleColor = isSelected
        ? Colors.white
        : (isDark ? Colors.white : colors.primaryText);
    final subtitleColor = isSelected
        ? Colors.white.withValues(alpha: 0.88)
        : colors.mutedText;
    final iconColor = isSelected ? Colors.white : colors.brandBlue;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12.r),
        splashColor: selectedBg.withValues(alpha: 0.12),
        highlightColor: selectedBg.withValues(alpha: 0.08),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 240),
          curve: Curves.easeOutCubic,
          padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 12.h),
          decoration: BoxDecoration(
            color: isSelected
                ? selectedBg
                : (isDark
                    ? Colors.white.withValues(alpha: 0.04)
                    : colors.tagBackground),
            borderRadius: BorderRadius.circular(12.r),
            border: Border.all(
              color: isSelected ? selectedBorder : idleBorder,
              width: isSelected ? 1.5 : 1,
            ),
            boxShadow: isSelected && !isDark
                ? [
                    BoxShadow(
                      color: selectedBg.withValues(alpha: 0.22),
                      blurRadius: 10,
                      offset: const Offset(0, 3),
                    ),
                  ]
                : null,
          ),
          child: Row(
            children: [
              AnimatedContainer(
                duration: const Duration(milliseconds: 240),
                curve: Curves.easeOutCubic,
                width: 40.r,
                height: 40.r,
                decoration: BoxDecoration(
                  color: isSelected
                      ? Colors.white.withValues(alpha: 0.18)
                      : colors.brandBlue.withValues(alpha: isDark ? 0.18 : 0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Iconsax.language_circle,
                  size: 22.r,
                  color: iconColor,
                ),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    AnimatedDefaultTextStyle(
                      duration: const Duration(milliseconds: 200),
                      style: GoogleFonts.inter(
                        color: titleColor,
                        fontSize: 15.sp,
                        fontWeight: FontWeight.w700,
                      ),
                      child: Text(language.label),
                    ),
                    SizedBox(height: 2.h),
                    AnimatedDefaultTextStyle(
                      duration: const Duration(milliseconds: 200),
                      style: GoogleFonts.inter(
                        color: subtitleColor,
                        fontSize: 12.sp,
                        fontWeight: FontWeight.w500,
                      ),
                      child: Text(language.nativeLabel),
                    ),
                  ],
                ),
              ),
              AnimatedScale(
                scale: isSelected ? 1.0 : 0.0,
                duration: const Duration(milliseconds: 220),
                curve: Curves.easeOutBack,
                child: AnimatedOpacity(
                  opacity: isSelected ? 1.0 : 0.0,
                  duration: const Duration(milliseconds: 180),
                  child: Icon(
                    Icons.check_circle_rounded,
                    size: 22.r,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Themed bottom sheet for quick language pick on login / sign-up.
class AuthLanguagePickerSheet extends StatefulWidget {
  final List<AppLanguage> languages;
  final bool applyImmediately;

  const AuthLanguagePickerSheet({
    super.key,
    this.languages = const [
      AppLanguage.english,
      AppLanguage.amharic,
      AppLanguage.oromo,
      AppLanguage.sidama,
    ],
    this.applyImmediately = true,
  });

  @override
  State<AuthLanguagePickerSheet> createState() =>
      _AuthLanguagePickerSheetState();
}

class _AuthLanguagePickerSheetState extends State<AuthLanguagePickerSheet> {
  late AppLanguage _selected;

  @override
  void initState() {
    super.initState();
    _selected = context.read<LocaleCubit>().state;
  }

  Future<void> _onPick(AppLanguage language) async {
    setState(() => _selected = language);
    if (!widget.applyImmediately) return;

    final cubit = context.read<LocaleCubit>();
    if (!mounted) return;
    Navigator.of(context).pop();

    if (cubit.state != language) {
      await cubit.setLanguage(language);
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.faithColors;
    final auth = context.authPalette;

    return Padding(
      padding: EdgeInsets.fromLTRB(20.w, 8.h, 20.w, 20.h),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Center(
            child: Container(
              width: 40.w,
              height: 4.h,
              decoration: BoxDecoration(
                color: colors.mutedText.withValues(alpha: 0.35),
                borderRadius: BorderRadius.circular(999.r),
              ),
            ),
          ),
          SizedBox(height: 16.h),
          Text(
            'Language',
            textAlign: TextAlign.center,
            style: GoogleFonts.inter(
              color: auth.titleColor,
              fontSize: 18.sp,
              fontWeight: FontWeight.w700,
            ),
          ),
          SizedBox(height: 6.h),
          Text(
            'Choose your preferred language',
            textAlign: TextAlign.center,
            style: GoogleFonts.inter(
              color: auth.subtitleColor,
              fontSize: 13.sp,
            ),
          ),
          SizedBox(height: 18.h),
          AuthLanguageSelector(
            selectedLanguage: _selected,
            onLanguageChanged: _onPick,
            languages: widget.languages,
            showSectionLabel: false,
          ),
        ],
      ),
    );
  }
}

Future<void> showAuthLanguagePickerSheet(
  BuildContext context, {
  List<AppLanguage> languages = const [
    AppLanguage.english,
    AppLanguage.amharic,
    AppLanguage.oromo,
    AppLanguage.sidama,
  ],
}) {
  final colors = context.faithColors;
  final materialLocale = context.read<LocaleCubit>().state.materialLocale;

  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    backgroundColor: colors.cardBackground,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
    ),
    builder: (sheetContext) {
      return FaithLocalization.scope(
        locale: materialLocale,
        child: SafeArea(
          child: AuthLanguagePickerSheet(languages: languages),
        ),
      );
    },
  );
}
