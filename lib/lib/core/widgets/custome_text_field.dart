import 'package:emoji_picker_flutter/emoji_picker_flutter.dart' as emoji;
import 'package:faithconnect/core/theme/app_theme_extensions.dart';
import 'package:faithconnect/core/theme/dark_theme.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';

/// Toggles the emoji panel for [CustomMessageTextField] / [CustomEmojiPickerPanel].
class MessageComposerEmojiController extends ChangeNotifier {
  bool _isVisible = false;

  bool get isVisible => _isVisible;

  void toggle() {
    _isVisible = !_isVisible;
    notifyListeners();
  }

  void show() {
    if (_isVisible) return;
    _isVisible = true;
    notifyListeners();
  }

  void hide() {
    if (!_isVisible) return;
    _isVisible = false;
    notifyListeners();
  }
}

/// Branded emoji panel for comments and chat composers.
class CustomEmojiPickerPanel extends StatelessWidget {
  final TextEditingController textController;
  final MessageComposerEmojiController? emojiController;
  final double? height;

  const CustomEmojiPickerPanel({
    super.key,
    required this.textController,
    this.emojiController,
    this.height,
  });

  static emoji.Config _pickerConfig(BuildContext context, {double? height}) {
    final colors = context.faithColors;
    final emojiMax = 28.0 *
        (defaultTargetPlatform == TargetPlatform.iOS ? 1.20 : 1.0);

    return emoji.Config(
      height: height ?? 280,
      checkPlatformCompatibility: true,
      emojiViewConfig: emoji.EmojiViewConfig(
        backgroundColor: colors.scaffoldBackground,
        emojiSizeMax: emojiMax,
        columns: 7,
      ),
      categoryViewConfig: emoji.CategoryViewConfig(
        backgroundColor: colors.cardBackground,
        iconColor: colors.iconMuted,
        iconColorSelected: colors.brandBlue,
        indicatorColor: colors.brandBlue,
        backspaceColor: colors.iconMuted,
      ),
      bottomActionBarConfig: emoji.BottomActionBarConfig(
        backgroundColor: colors.cardBackground,
        buttonColor: colors.iconMuted,
        buttonIconColor: colors.primaryText,
      ),
      searchViewConfig: emoji.SearchViewConfig(
        backgroundColor: colors.cardBackground,
        hintText: 'Search emoji',
        hintTextStyle: TextStyle(color: colors.mutedText),
        buttonIconColor: colors.iconMuted,
      ),
      skinToneConfig: emoji.SkinToneConfig(
        dialogBackgroundColor: colors.cardBackground,
        indicatorColor: colors.brandBlue,
      ),
      viewOrderConfig: const emoji.ViewOrderConfig(
        top: emoji.EmojiPickerItem.categoryBar,
        middle: emoji.EmojiPickerItem.emojiView,
        bottom: emoji.EmojiPickerItem.searchBar,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.faithColors;

    return DecoratedBox(
      decoration: BoxDecoration(
        color: colors.scaffoldBackground,
        border: Border(
          top: BorderSide(
            color: context.isDarkMode
                ? Colors.white.withValues(alpha: 0.08)
                : colors.divider,
          ),
        ),
      ),
      child: emoji.EmojiPicker(
        textEditingController: textController,
        onBackspacePressed: () {},
        onEmojiSelected: (_, _) => emojiController?.hide(),
        config: _pickerConfig(context, height: height ?? 280.h),
      ),
    );
  }
}

/// Pill-style input for chat and comments with optional emoji launcher.
class CustomMessageTextField extends StatelessWidget {
  final TextEditingController? controller;
  final FocusNode? focusNode;
  final String hint;
  final bool enabled;
  final int maxLines;
  final TextInputAction? textInputAction;
  final ValueChanged<String>? onSubmitted;
  final MessageComposerEmojiController? emojiController;
  final bool showEmojiButton;
  final bool showAttachmentButton;
  final VoidCallback? onAttachmentTap;
  final String? attachmentName;
  final VoidCallback? onAttachmentRemove;

  const CustomMessageTextField({
    super.key,
    this.controller,
    this.focusNode,
    this.hint = 'Type a message...',
    this.enabled = true,
    this.maxLines = 4,
    this.textInputAction,
    this.onSubmitted,
    this.emojiController,
    this.showEmojiButton = true,
    this.showAttachmentButton = false,
    this.onAttachmentTap,
    this.attachmentName,
    this.onAttachmentRemove,
  });

  void _onEmojiPressed(BuildContext context) {
    if (!enabled) return;
    final node = focusNode;
    if (node != null && node.hasFocus) {
      node.unfocus();
    }
    emojiController?.toggle();
  }

  void _onFieldTap() {
    emojiController?.hide();
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.faithColors;
    final showEmoji = showEmojiButton && emojiController != null;
    final showAttachment = showAttachmentButton && onAttachmentTap != null;
    final hasAttachment =
        attachmentName != null && attachmentName!.trim().isNotEmpty;
    final trailingIconCount = (showAttachment ? 1 : 0) + (showEmoji ? 1 : 0);
    final trailingWidth = trailingIconCount == 2 ? 84.w : 48.w;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (hasAttachment) ...[
          Container(
            margin: EdgeInsets.only(bottom: 8.h),
            padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 8.h),
            decoration: BoxDecoration(
              color: colors.tagBackground,
              borderRadius: BorderRadius.circular(16.r),
              border: Border.all(
                color: context.isDarkMode
                    ? Colors.white.withValues(alpha: 0.08)
                    : colors.divider,
              ),
            ),
            child: Row(
              children: [
                Icon(
                  Iconsax.document,
                  size: 16.r,
                  color: colors.iconMuted,
                ),
                SizedBox(width: 8.w),
                Expanded(
                  child: Text(
                    attachmentName!.trim(),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.inter(
                      color: colors.primaryText,
                      fontSize: 12.sp,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                if (onAttachmentRemove != null)
                  IconButton(
                    onPressed: enabled ? onAttachmentRemove : null,
                    visualDensity: VisualDensity.compact,
                    icon: Icon(
                      Icons.close_rounded,
                      size: 18.r,
                      color: colors.iconMuted,
                    ),
                  ),
              ],
            ),
          ),
        ],
        TextField(
          controller: controller,
          focusNode: focusNode,
          enabled: enabled,
          maxLines: maxLines,
          minLines: 1,
          textInputAction: textInputAction,
          style: GoogleFonts.inter(
            color: enabled ? colors.primaryText : colors.mutedText,
            fontSize: 15.sp,
          ),
          onSubmitted: onSubmitted,
          onTap: _onFieldTap,
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: GoogleFonts.inter(
              color: colors.mutedText,
              fontSize: 15.sp,
            ),
            filled: true,
            fillColor: colors.inputBackground,
            contentPadding:
                EdgeInsets.symmetric(horizontal: 18.w, vertical: 14.h),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(28.r),
              borderSide: BorderSide.none,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(28.r),
              borderSide: BorderSide(
                color: context.isDarkMode ? Colors.transparent : colors.divider,
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(28.r),
              borderSide: BorderSide(color: colors.brandBlue, width: 1),
            ),
            suffixIcon: trailingIconCount == 0
                ? null
                : SizedBox(
                    width: trailingWidth,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (showAttachment)
                          IconButton(
                            onPressed: enabled ? onAttachmentTap : null,
                            icon: Icon(
                              Iconsax.paperclip_2,
                              color: colors.iconMuted,
                              size: 20.r,
                            ),
                          ),
                        if (showEmoji)
                          ListenableBuilder(
                            listenable: emojiController!,
                            builder: (context, _) {
                              final active = emojiController!.isVisible;
                              return IconButton(
                                onPressed:
                                    enabled ? () => _onEmojiPressed(context) : null,
                                icon: Icon(
                                  Iconsax.emoji_happy,
                                  color:
                                      active ? colors.brandBlue : colors.iconMuted,
                                  size: 22.r,
                                ),
                              );
                            },
                          ),
                      ],
                    ),
                  ),
          ),
        ),
      ],
    );
  }
}

class CustomTextField extends StatefulWidget {
  final String? label;
  final String hint;
  final bool isPassword;
  final TextEditingController? controller;
  final TextInputType keyboardType;
  final Widget? suffixIcon;
  final Widget? prefixIcon;
  final int? maxLines;
  final bool enabled;
  /// When true, the field stays tappable (e.g. date pickers) but cannot be edited.
  final bool readOnly;
  final VoidCallback? onTap;
  final String? errorText;
  final FormFieldValidator<String>? validator;
  final Color? titleColor;

  const CustomTextField({
    super.key,
    this.label,
    required this.hint,
    this.isPassword = false,
    this.controller,
    this.keyboardType = TextInputType.text,
    this.suffixIcon,
    this.prefixIcon,
    this.maxLines,
    this.enabled = true,
    this.readOnly = false,
    this.onTap,
    this.errorText,
    this.validator,
    this.titleColor,
  });

  @override
  State<CustomTextField> createState() => _CustomTextFieldState();
}

class _CustomTextFieldState extends State<CustomTextField> {
  late bool _obscureText;

  @override
  void initState() {
    super.initState();
    _obscureText = widget.isPassword;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final fieldFillColor = isDark ? DarkTheme.authFieldFill : Colors.white;
    final fieldBorderColor = isDark
        ? DarkTheme.authFieldBorder
        : theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.2);
    final hintColor =
        isDark ? DarkTheme.authSubtitle : theme.colorScheme.onSurfaceVariant;
    final labelColor =
        isDark ? DarkTheme.authSubtitle : theme.colorScheme.onSurfaceVariant;
    final iconColor =
        isDark ? DarkTheme.authSubtitle : theme.colorScheme.onSurfaceVariant;

    Widget? effectiveSuffixIcon;
    if (widget.isPassword && widget.suffixIcon == null) {
      effectiveSuffixIcon = IconButton(
        onPressed: () {
          setState(() {
            _obscureText = !_obscureText;
          });
        },
        icon: Icon(
          _obscureText ? Icons.visibility_off : Icons.visibility,
          color: iconColor,
        ),
      );
    } else {
      effectiveSuffixIcon = widget.suffixIcon;
    }

    final textField = TextFormField(
      controller: widget.controller,
      obscureText: widget.isPassword ? _obscureText : false,
      keyboardType: widget.keyboardType,
      style: theme.textTheme.bodyMedium?.copyWith(
        color: isDark ? Colors.white : null,
      ),
      maxLines: widget.isPassword ? 1 : widget.maxLines,
      enabled: widget.enabled,
      readOnly: widget.readOnly,
      onTap: widget.onTap,
      showCursor: widget.readOnly ? false : null,
      validator: widget.validator,
      decoration: InputDecoration(
        hintText: widget.hint,
        hintStyle: theme.textTheme.bodyMedium?.copyWith(
          color: hintColor,
        ),
        filled: true,
        fillColor: fieldFillColor,
        errorText: widget.errorText,
        prefixIconConstraints: const BoxConstraints(minWidth: 40, minHeight: 0),
        suffixIconConstraints: const BoxConstraints(minWidth: 40, minHeight: 0),
        prefixIcon: widget.prefixIcon,
        suffixIcon: effectiveSuffixIcon,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 10,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(
            color: fieldBorderColor,
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(
            color: fieldBorderColor,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: theme.colorScheme.primary, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: theme.colorScheme.error),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: theme.colorScheme.error, width: 1.5),
        ),
      ),
    );

    if (widget.label == null) {
      return textField;
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          widget.label!,
          style: theme.textTheme.labelMedium?.copyWith(
            color: widget.titleColor ?? labelColor,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        textField,
      ],
    );
  }
}
