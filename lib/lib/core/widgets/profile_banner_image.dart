import 'package:faithconnect/core/constants/branding_assets.dart';
import 'package:faithconnect/core/theme/dark_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

/// Profile header banner: branded asset fallback with optional network image on top.
class ProfileBannerImage extends StatelessWidget {
  final String? imageUrl;
  final double height;
  final bool showGradientOverlay;
  final double extraTopInset;

  const ProfileBannerImage({
    super.key,
    this.imageUrl,
    this.height = 200,
    this.showGradientOverlay = true,
    this.extraTopInset = 0,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: height.h + extraTopInset,
      width: double.infinity,
      child: Stack(
        fit: StackFit.expand,
        children: [
          _buildBannerImage(),
          if (showGradientOverlay)
            DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.black.withValues(alpha: 0.35),
                    Colors.transparent,
                    Colors.black.withValues(alpha: 0.5),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildBannerImage() {
    final fallback = Image.asset(
      BrandingAssets.churchprofileBackgrounddrakmode,
      fit: BoxFit.cover,
      width: double.infinity,
      height: double.infinity,
    );

    final url = imageUrl?.trim();
    if (url == null || url.isEmpty) {
      return fallback;
    }

    return Image.network(
      url,
      fit: BoxFit.cover,
      width: double.infinity,
      height: double.infinity,
      loadingBuilder: (context, child, loadingProgress) {
        if (loadingProgress == null) return child;
        return Stack(
          fit: StackFit.expand,
          children: [
            fallback,
            Center(
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: DarkTheme.brandBlue.withValues(alpha: 0.8),
              ),
            ),
          ],
        );
      },
      errorBuilder: (context, error, stackTrace) => fallback,
    );
  }
}
