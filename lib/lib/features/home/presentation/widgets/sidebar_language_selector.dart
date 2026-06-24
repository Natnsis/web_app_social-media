import 'package:faithconnect/core/core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';

/// Language picker for the home sidebar (English, Amharic, Afaan Oromo, Sidama).
class SidebarLanguageSelector extends StatelessWidget {
  final Color? containerColor;
  final Color? containerBorderColor;
  final bool popOnSelect;
  final AppLanguage? selectedLanguage;
  final ValueChanged<AppLanguage>? onLanguageChanged;
  final List<AppLanguage> languages;

  const SidebarLanguageSelector({
    super.key,
    this.containerColor,
    this.containerBorderColor,
    this.popOnSelect = false,
    this.selectedLanguage,
    this.onLanguageChanged,
    this.languages = AppLanguage.values,
  });

  @override
  Widget build(BuildContext context) {
    final deferApply = onLanguageChanged != null;

    if (deferApply) {
      return _buildList(
        context,
        selected: selectedLanguage ?? context.read<LocaleCubit>().state,
        onLanguageTap: onLanguageChanged!,
      );
    }

    return BlocBuilder<LocaleCubit, AppLanguage>(
      builder: (context, selected) {
        return _buildList(
          context,
          selected: selected,
          onLanguageTap: (language) =>
              _onSelect(context, language, popOnSelect),
        );
      },
    );
  }

  Widget _buildList(
    BuildContext context, {
    required AppLanguage selected,
    required ValueChanged<AppLanguage> onLanguageTap,
  }) {
    final colors = context.faithColors;
    final isDark = context.isDarkMode;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.only(left: 4.w, bottom: 8.h),
          child: Text(
            'LANGUAGE',
            style: GoogleFonts.inter(
              color: isDark
                  ? DarkTheme.sidebarSectionLabel
                  : colors.mutedText,
              fontSize: 11.sp,
              fontWeight: FontWeight.w600,
              letterSpacing: 1.4,
            ),
          ),
        ),
        Container(
          padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 4.h),
          decoration: BoxDecoration(
            color: containerColor ??
                (isDark ? DarkTheme.sidebarSurface : colors.tagBackground),
            borderRadius: BorderRadius.circular(14.r),
            border: isDark && containerBorderColor == null
                ? null
                : Border.all(
                    color: containerBorderColor ??
                        (isDark
                            ? DarkTheme.sidebarSurface
                            : colors.divider),
                  ),
          ),
          child: Column(
            children: languages.map((language) {
              final isSelected = language == selected;
              return _LanguageTile(
                language: language,
                isSelected: isSelected,
                onTap: () => onLanguageTap(language),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }

  void _onSelect(
    BuildContext context,
    AppLanguage language,
    bool popOnSelect,
  ) {
    final cubit = context.read<LocaleCubit>();
    if (popOnSelect && context.mounted) {
      context.pop();
    }
    if (cubit.state != language) {
      cubit.setLanguage(language);
    }
    if (context.mounted) {
      showInfo(context, 'Language set to ${language.label}');
    }
  }
}

class _LanguageTile extends StatelessWidget {
  final AppLanguage language;
  final bool isSelected;
  final VoidCallback onTap;

  const _LanguageTile({
    required this.language,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.faithColors;
    final isDark = context.isDarkMode;
    final selectedColor =
        isDark ? DarkTheme.sidebarSelected : colors.brandBlue;
    final textColor = isDark ? Colors.white : colors.primaryText;
    final mutedColor = isDark ? DarkTheme.sidebarItemText : colors.mutedText;

    return Padding(
      padding: EdgeInsets.symmetric(vertical: 2.h),
      child: Material(
        color: isSelected ? selectedColor : Colors.transparent,
        borderRadius: BorderRadius.circular(10.r),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(10.r),
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 10.h),
            child: Row(
              children: [
                Icon(
                  Iconsax.language_circle,
                  size: 18.sp,
                  color: isSelected ? Colors.white : mutedColor,
                ),
                SizedBox(width: 10.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        language.label,
                        style: GoogleFonts.inter(
                          color: isSelected ? Colors.white : textColor,
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Text(
                        language.nativeLabel,
                        style: GoogleFonts.inter(
                          color: isSelected
                              ? Colors.white.withValues(alpha: 0.85)
                              : mutedColor,
                          fontSize: 11.sp,
                        ),
                      ),
                    ],
                  ),
                ),
                if (isSelected)
                  Icon(
                    Icons.check_rounded,
                    size: 18.r,
                    color: Colors.white,
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
