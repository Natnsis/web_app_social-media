import 'dart:ui';

import 'package:faithconnect/core/constants/spacing_radius.dart';
import 'package:faithconnect/core/theme/app_theme_extensions.dart';
import 'package:faithconnect/core/theme/dark_theme.dart';
import 'package:faithconnect/core/widgets/custome_text_field.dart';
import 'package:faithconnect/core/widgets/primary_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';

/// Visual style for [CardFormCard].
enum CardFormVariant {
  material,
  glass,
}

/// Glass card layout helpers (colors from [DarkTheme]).
abstract final class CardFormGlassTheme {
  CardFormGlassTheme._();

  static const Color titleColor = Colors.white;
  static Color get subtitleColor => DarkTheme.authSubtitle;
  static Color get cardTint => DarkTheme.authCardTint;
  static Color get cardBorder => DarkTheme.authCardBorder;

  static BoxDecoration decoration({required BorderRadius borderRadius}) {
    return DarkTheme.authGlassCardDecoration.copyWith(
      borderRadius: borderRadius,
    );
  }
}

/// Scaffold with a top [AppBar] and scrollable body — shared by feed and form pages.
class AppBarPageScaffold extends StatelessWidget {
  final Key? scaffoldKey;
  final PreferredSizeWidget? appBar;
  final Widget body;
  final Widget? drawer;
  final Color? backgroundColor;
  final Widget? floatingActionButton;
  final FloatingActionButtonLocation? floatingActionButtonLocation;
  final bool extendBodyBehindAppBar;

  const AppBarPageScaffold({
    super.key,
    this.scaffoldKey,
    this.appBar,
    required this.body,
    this.drawer,
    this.backgroundColor,
    this.floatingActionButton,
    this.floatingActionButtonLocation,
    this.extendBodyBehindAppBar = false,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: scaffoldKey,
      backgroundColor:
          backgroundColor ?? Theme.of(context).scaffoldBackgroundColor,
      extendBodyBehindAppBar: extendBodyBehindAppBar,
      appBar: appBar,
      drawer: drawer,
      drawerEnableOpenDragGesture: drawer != null,
      floatingActionButton: floatingActionButton,
      floatingActionButtonLocation: floatingActionButtonLocation,
      body: body,
    );
  }
}

/// Branded gradient shell for splash and marketing screens.
class BrandedGradientScaffold extends StatelessWidget {
  final Widget body;
  final Gradient? gradient;
  final Color? backgroundColor;

  const BrandedGradientScaffold({
    super.key,
    required this.body,
    this.gradient,
    this.backgroundColor,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final defaultGradient = isDark
        ? DarkTheme.brandingFallbackGradient
        : const LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFFFFFFFF), Color(0xFFFFFFFF)],
          );

    return Scaffold(
      backgroundColor: backgroundColor ??
          (isDark ? DarkTheme.brandNavy : Theme.of(context).scaffoldBackgroundColor),
      body: DecoratedBox(
        decoration: BoxDecoration(
          gradient: gradient ?? defaultGradient,
        ),
        child: SafeArea(child: body),
      ),
    );
  }
}

/// Material layout: [AppBar] + [CardFormCard] (single-field form).
class CardFormScaffold extends StatefulWidget {
  final String title;
  final Widget? leading;
  final List<Widget>? actions;
  final bool centerTitle;

  final String? cardTitle;
  final String? cardSubtitle;
  final String inputLabel;
  final String inputHint;
  final TextEditingController? controller;
  final TextInputType keyboardType;
  final bool obscureText;
  final Widget? inputPrefixIcon;
  final Widget? inputSuffixIcon;
  final String? Function(String?)? validator;

  final String buttonLabel;
  final VoidCallback? onSubmit;
  final bool isLoading;
  final bool isButtonEnabled;

  final Widget? footer;
  final EdgeInsetsGeometry? bodyPadding;
  final Color? scaffoldBackgroundColor;

  const CardFormScaffold({
    super.key,
    required this.title,
    this.leading,
    this.actions,
    this.centerTitle = true,
    this.cardTitle,
    this.cardSubtitle,
    required this.inputLabel,
    required this.inputHint,
    this.controller,
    this.keyboardType = TextInputType.text,
    this.obscureText = false,
    this.inputPrefixIcon,
    this.inputSuffixIcon,
    this.validator,
    required this.buttonLabel,
    this.onSubmit,
    this.isLoading = false,
    this.isButtonEnabled = true,
    this.footer,
    this.bodyPadding,
    this.scaffoldBackgroundColor,
  });

  @override
  State<CardFormScaffold> createState() => _CardFormScaffoldState();
}

class _CardFormScaffoldState extends State<CardFormScaffold> {
  final _formKey = GlobalKey<FormState>();

  void _handleSubmit() {
    if (widget.onSubmit == null) return;
    if (_formKey.currentState?.validate() ?? true) {
      widget.onSubmit!();
    }
  }

  @override
  Widget build(BuildContext context) {
    return AppBarPageScaffold(
      backgroundColor: widget.scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(widget.title),
        centerTitle: widget.centerTitle,
        leading: widget.leading,
        actions: widget.actions,
        elevation: 0,
        scrolledUnderElevation: 3,
        surfaceTintColor: context.colorScheme.surfaceTint,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: widget.bodyPadding ??
              EdgeInsets.symmetric(horizontal: 16.w, vertical: 24.h),
          child: Align(
            alignment: Alignment.topCenter,
            child: ConstrainedBox(
              constraints: BoxConstraints(maxWidth: 480.w),
              child: CardFormCard(
                formKey: _formKey,
                cardTitle: widget.cardTitle,
                cardSubtitle: widget.cardSubtitle,
                inputLabel: widget.inputLabel,
                inputHint: widget.inputHint,
                controller: widget.controller,
                keyboardType: widget.keyboardType,
                obscureText: widget.obscureText,
                inputPrefixIcon: widget.inputPrefixIcon,
                inputSuffixIcon: widget.inputSuffixIcon,
                validator: widget.validator,
                buttonLabel: widget.buttonLabel,
                onSubmit: _handleSubmit,
                isLoading: widget.isLoading,
                isButtonEnabled: widget.isButtonEnabled,
                footer: widget.footer,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Card with optional title, custom [children], or a single field + button.
class CardFormCard extends StatelessWidget {
  final GlobalKey<FormState>? formKey;
  final CardFormVariant variant;
  final String? cardTitle;
  final String? cardSubtitle;
  final List<Widget>? children;

  final String? inputLabel;
  final String? inputHint;
  final TextEditingController? controller;
  final TextInputType keyboardType;
  final bool obscureText;
  final Widget? inputPrefixIcon;
  final Widget? inputSuffixIcon;
  final String? Function(String?)? validator;

  final String? buttonLabel;
  final VoidCallback? onSubmit;
  final bool isLoading;
  final bool isButtonEnabled;
  final Widget? actionButton;
  final Widget? footer;
  final EdgeInsetsGeometry? padding;

  const CardFormCard({
    super.key,
    this.formKey,
    this.variant = CardFormVariant.material,
    this.cardTitle,
    this.cardSubtitle,
    this.children,
    this.inputLabel,
    this.inputHint,
    this.controller,
    this.keyboardType = TextInputType.text,
    this.obscureText = false,
    this.inputPrefixIcon,
    this.inputSuffixIcon,
    this.validator,
    this.buttonLabel,
    this.onSubmit,
    this.isLoading = false,
    this.isButtonEnabled = true,
    this.actionButton,
    this.footer,
    this.padding,
  }) : assert(
          children != null ||
              (inputLabel != null && inputHint != null && buttonLabel != null),
          'Provide children or inputLabel, inputHint, and buttonLabel',
        );

  bool get _isCustomForm => children != null;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = context.colorScheme;
    final isGlass = variant == CardFormVariant.glass;

    final content = Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (cardTitle != null) ...[
          Text(
            cardTitle!,
            textAlign: isGlass ? TextAlign.center : TextAlign.start,
            style: isGlass
                ? GoogleFonts.inter(
                    color: CardFormGlassTheme.titleColor,
                    fontSize: 28.sp,
                    fontWeight: FontWeight.w700,
                  )
                : theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
          ),
          if (cardSubtitle != null) AppSpacing.v8,
        ],
        if (cardSubtitle != null)
          Text(
            cardSubtitle!,
            textAlign: isGlass ? TextAlign.center : TextAlign.start,
            style: isGlass
                ? GoogleFonts.inter(
                    color: CardFormGlassTheme.subtitleColor,
                    fontSize: 14.sp,
                    height: 1.4,
                  )
                : theme.textTheme.bodyMedium?.copyWith(
                    color: scheme.onSurfaceVariant,
                  ),
          ),
        if (cardTitle != null || cardSubtitle != null)
          SizedBox(height: isGlass ? 28.h : 20.h),
        if (_isCustomForm) ...[
          ...children!,
        ] else ...[
          CustomTextField(
            label: inputLabel!,
            hint: inputHint!,
            controller: controller,
            keyboardType: keyboardType,
            isPassword: obscureText,
            prefixIcon: inputPrefixIcon,
            suffixIcon: inputSuffixIcon,
            validator: validator,
          ),
        ],
        if (buttonLabel != null || actionButton != null) ...[
          SizedBox(height: _isCustomForm ? 22.h : 20.h),
          _buildAction(context),
        ],
        if (footer != null) ...[
          SizedBox(height: isGlass ? 24.h : 16.h),
          footer!,
        ],
      ],
    );

    final padded = Padding(
      padding: padding ??
          (isGlass
              ? EdgeInsets.symmetric(horizontal: 24.w, vertical: 28.h)
              : AppSpacing.cardPadding),
      child: formKey != null ? Form(key: formKey, child: content) : content,
    );

    if (isGlass) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(24.r),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
          child: Container(
            width: double.infinity,
            decoration: CardFormGlassTheme.decoration(
              borderRadius: BorderRadius.circular(24.r),
            ),
            child: padded,
          ),
        ),
      );
    }

    return Card(
      elevation: 1,
      shadowColor: scheme.shadow.withValues(alpha: 0.12),
      shape: RoundedRectangleBorder(
        borderRadius: AppRadius.large,
        side: BorderSide(
          color: scheme.outlineVariant.withValues(alpha: 0.4),
        ),
      ),
      clipBehavior: Clip.antiAlias,
      child: padded,
    );
  }

  Widget _buildAction(BuildContext context) {
    if (actionButton != null) return actionButton!;

    return SizedBox(
      width: double.infinity,
      height: AppSpacing.buttonHeight,
      child: PrimaryButton(
        onPressed: isButtonEnabled && !isLoading ? onSubmit : null,
        text: buttonLabel!,
        isLoading: isLoading,
        isDisabled: !isButtonEnabled,
        radiusVariant: ButtonRadius.rounded,
        width: double.infinity,
        height: AppSpacing.buttonHeight,
      ),
    );
  }
}
