import 'package:flutter/material.dart';

/// Semantic colors that follow the active light / dark [ThemeData].
@immutable
class FaithAppColors extends ThemeExtension<FaithAppColors> {
  final Color scaffoldBackground;
  final Color cardBackground;
  final Color navBarBackground;
  final Color mutedText;
  final Color tagBackground;
  final Color primaryText;
  final Color secondaryText;
  final Color headerTitle;
  final Color iconPrimary;
  final Color iconMuted;
  final Color brandBlue;
  final Color brandSky;
  final Color divider;
  final Color error;
  final Color sidebarBackground;
  final Color sidebarSurface;
  final Color inputBackground;
  final Color shimmerBase;
  final Color shimmerHighlight;

  const FaithAppColors({
    required this.scaffoldBackground,
    required this.cardBackground,
    required this.navBarBackground,
    required this.mutedText,
    required this.tagBackground,
    required this.primaryText,
    required this.secondaryText,
    required this.headerTitle,
    required this.iconPrimary,
    required this.iconMuted,
    required this.brandBlue,
    required this.brandSky,
    required this.divider,
    required this.error,
    required this.sidebarBackground,
    required this.sidebarSurface,
    required this.inputBackground,
    required this.shimmerBase,
    required this.shimmerHighlight,
  });

  static const FaithAppColors dark = FaithAppColors(
    scaffoldBackground: Color(0xFF0F1115),
    cardBackground: Color(0xFF1A1D23),
    navBarBackground: Color(0xFF141820),
    mutedText: Color(0xFF8B929E),
    tagBackground: Color(0xFF252A33),
    primaryText: Color(0xFFFFFFFF),
    secondaryText: Color(0xFFE2E8F0),
    headerTitle: Color(0xFF33B5FF),
    iconPrimary: Color(0xFFFFFFFF),
    iconMuted: Color(0xFF8B929E),
    brandBlue: Color(0xFF0096FF),
    brandSky: Color(0xFF33B5FF),
    divider: Color(0xFF2A3038),
    error: Color(0xFFFF4C4C),
    sidebarBackground: Color(0xFF12151C),
    sidebarSurface: Color(0xFF1C2129),
    inputBackground: Color(0xFF1A1D23),
    shimmerBase: Color(0xFF1A1D23),
    shimmerHighlight: Color(0xFF252A33),
  );

  static const FaithAppColors light = FaithAppColors(
    scaffoldBackground: Color(0xFFFFFFFF),
    cardBackground: Color(0xFFFFFFFF),
    navBarBackground: Color(0xFFFFFFFF),
    mutedText: Color(0xFF64748B),
    tagBackground: Color(0xFFF1F5F9),
    primaryText: Color(0xFF0F172A),
    secondaryText: Color(0xFF334155),
    headerTitle: Color(0xFF0877BC),
    iconPrimary: Color(0xFF0F172A),
    iconMuted: Color(0xFF64748B),
    brandBlue: Color(0xFF0096FF),
    brandSky: Color(0xFF0A92E7),
    divider: Color(0xFFE2E8F0),
    error: Color(0xFFB00020),
    sidebarBackground: Color(0xFFFFFFFF),
    sidebarSurface: Color(0xFFF1F5F9),
    inputBackground: Color(0xFFFFFFFF),
    shimmerBase: Color(0xFFE2E8F0),
    shimmerHighlight: Color(0xFFF8FAFC),
  );

  static FaithAppColors of(BuildContext context) {
    return Theme.of(context).extension<FaithAppColors>() ?? dark;
  }

  static FaithAppColors forBrightness(Brightness brightness) {
    return brightness == Brightness.dark ? dark : light;
  }

  @override
  Object get type => FaithAppColors;

  @override
  FaithAppColors copyWith({
    Color? scaffoldBackground,
    Color? cardBackground,
    Color? navBarBackground,
    Color? mutedText,
    Color? tagBackground,
    Color? primaryText,
    Color? secondaryText,
    Color? headerTitle,
    Color? iconPrimary,
    Color? iconMuted,
    Color? brandBlue,
    Color? brandSky,
    Color? divider,
    Color? error,
    Color? sidebarBackground,
    Color? sidebarSurface,
    Color? inputBackground,
    Color? shimmerBase,
    Color? shimmerHighlight,
  }) {
    return FaithAppColors(
      scaffoldBackground: scaffoldBackground ?? this.scaffoldBackground,
      cardBackground: cardBackground ?? this.cardBackground,
      navBarBackground: navBarBackground ?? this.navBarBackground,
      mutedText: mutedText ?? this.mutedText,
      tagBackground: tagBackground ?? this.tagBackground,
      primaryText: primaryText ?? this.primaryText,
      secondaryText: secondaryText ?? this.secondaryText,
      headerTitle: headerTitle ?? this.headerTitle,
      iconPrimary: iconPrimary ?? this.iconPrimary,
      iconMuted: iconMuted ?? this.iconMuted,
      brandBlue: brandBlue ?? this.brandBlue,
      brandSky: brandSky ?? this.brandSky,
      divider: divider ?? this.divider,
      error: error ?? this.error,
      sidebarBackground: sidebarBackground ?? this.sidebarBackground,
      sidebarSurface: sidebarSurface ?? this.sidebarSurface,
      inputBackground: inputBackground ?? this.inputBackground,
      shimmerBase: shimmerBase ?? this.shimmerBase,
      shimmerHighlight: shimmerHighlight ?? this.shimmerHighlight,
    );
  }

  @override
  FaithAppColors lerp(ThemeExtension<FaithAppColors>? other, double t) {
    if (other is! FaithAppColors) return this;
    Color lerpColor(Color a, Color b) => Color.lerp(a, b, t)!;
    return FaithAppColors(
      scaffoldBackground: lerpColor(scaffoldBackground, other.scaffoldBackground),
      cardBackground: lerpColor(cardBackground, other.cardBackground),
      navBarBackground: lerpColor(navBarBackground, other.navBarBackground),
      mutedText: lerpColor(mutedText, other.mutedText),
      tagBackground: lerpColor(tagBackground, other.tagBackground),
      primaryText: lerpColor(primaryText, other.primaryText),
      secondaryText: lerpColor(secondaryText, other.secondaryText),
      headerTitle: lerpColor(headerTitle, other.headerTitle),
      iconPrimary: lerpColor(iconPrimary, other.iconPrimary),
      iconMuted: lerpColor(iconMuted, other.iconMuted),
      brandBlue: lerpColor(brandBlue, other.brandBlue),
      brandSky: lerpColor(brandSky, other.brandSky),
      divider: lerpColor(divider, other.divider),
      error: lerpColor(error, other.error),
      sidebarBackground: lerpColor(sidebarBackground, other.sidebarBackground),
      sidebarSurface: lerpColor(sidebarSurface, other.sidebarSurface),
      inputBackground: lerpColor(inputBackground, other.inputBackground),
      shimmerBase: lerpColor(shimmerBase, other.shimmerBase),
      shimmerHighlight: lerpColor(shimmerHighlight, other.shimmerHighlight),
    );
  }
}
