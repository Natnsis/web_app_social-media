import 'package:faithconnect/core/core.dart';
import 'package:faithconnect/features/auth/presentation/navigation/language_navigation.dart';
import 'package:faithconnect/features/auth/presentation/theme/auth_theme.dart';
import 'package:faithconnect/features/auth/presentation/widgets/auth_language_selector.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';

/// Top-bar language control for auth screens — shows icon + active language.
/// By default opens [showAuthLanguagePickerSheet] (login, sign-up). Set
/// [quickSelectOnTap] to false to navigate to the full language page (e.g. drawer).
class AuthLanguageIconButton extends StatelessWidget {
  static const List<AppLanguage> _defaultLanguages = [
    AppLanguage.english,
    AppLanguage.amharic,
    AppLanguage.oromo,
    AppLanguage.sidama,
  ];

  final Color? iconColor;
  final Color? labelColor;
  final Color? backgroundColor;
  final Color? borderColor;
  final bool quickSelectOnTap;
  final List<AppLanguage> quickSelectLanguages;

  const AuthLanguageIconButton({
    super.key,
    this.iconColor,
    this.labelColor,
    this.backgroundColor,
    this.borderColor,
    this.quickSelectOnTap = true,
    this.quickSelectLanguages = _defaultLanguages,
  });

  @override
  Widget build(BuildContext context) {
    final auth = context.authPalette;
    final colors = context.faithColors;
    final isDark = context.isDarkMode;
    final accent = iconColor ?? colors.brandBlue;

    return BlocBuilder<LocaleCubit, AppLanguage>(
      builder: (context, language) {
        return Padding(
          padding: EdgeInsets.only(top: 8.h, right: 12.w),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: () => _onTap(context),
              borderRadius: BorderRadius.circular(22.r),
              child: Tooltip(
                message: language.label,
                child: Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: 12.w,
                    vertical: 8.h,
                  ),
                  decoration: BoxDecoration(
                    color: backgroundColor ??
                        (isDark
                            ? auth.glassFill
                            : Colors.white.withValues(alpha: 0.96)),
                    borderRadius: BorderRadius.circular(22.r),
                    border: Border.all(
                      color: borderColor ??
                          (isDark
                              ? auth.glassBorder
                              : colors.divider),
                      width: 1,
                    ),
                    boxShadow: isDark
                        ? null
                        : [
                            BoxShadow(
                              color: accent.withValues(alpha: 0.1),
                              blurRadius: 10.r,
                              offset: Offset(0, 3.h),
                            ),
                          ],
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Iconsax.language_circle,
                        size: 20.sp,
                        color: accent,
                      ),
                      SizedBox(width: 6.w),
                      Text(
                        language.label,
                        style: GoogleFonts.inter(
                          color: labelColor ?? auth.titleColor,
                          fontSize: 13.sp,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.2,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  void _onTap(BuildContext context) {
    if (!quickSelectOnTap) {
      LanguageNavigation.openLanguage(context);
      return;
    }

    showAuthLanguagePickerSheet(
      context,
      languages: quickSelectLanguages,
    );
  }
}
