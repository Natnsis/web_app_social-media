import 'package:faithconnect/core/widgets/app_message.dart';

import 'package:flutter/material.dart';

import 'package:flutter_screenutil/flutter_screenutil.dart';



enum AuthSocialProvider { google, facebook, apple, phone }



class AuthSocialLoginRow extends StatelessWidget {

  final VoidCallback? onGoogleSignIn;

  final bool isLoading;



  const AuthSocialLoginRow({

    super.key,

    this.onGoogleSignIn,

    this.isLoading = false,

  });



  void _onTap(BuildContext context, AuthSocialProvider provider) {

    if (isLoading) return;

    if (provider == AuthSocialProvider.google && onGoogleSignIn != null) {

      onGoogleSignIn!();

      return;

    }

    showInfo(context, '${provider.name} sign-in coming soon');

  }



  @override

  Widget build(BuildContext context) {

    return Row(

      mainAxisAlignment: MainAxisAlignment.spaceEvenly,

      children: [

        _SocialButton(

          onTap: () => _onTap(context, AuthSocialProvider.google),

          enabled: !isLoading,

          child: _GoogleLogo(size: 22.sp),

        ),

        _SocialButton(

          onTap: () => _onTap(context, AuthSocialProvider.facebook),

          enabled: !isLoading,

          child: Icon(Icons.facebook, color: const Color(0xFF1877F2), size: 26.sp),

        ),

        _SocialButton(

          onTap: () => _onTap(context, AuthSocialProvider.apple),

          enabled: !isLoading,

          child: Icon(Icons.apple, color: Colors.black, size: 28.sp),

        ),

        _SocialButton(

          onTap: () => _onTap(context, AuthSocialProvider.phone),

          enabled: !isLoading,

          child: Icon(Icons.smartphone_outlined, color: Colors.black87, size: 24.sp),

        ),

      ],

    );

  }

}



class _SocialButton extends StatelessWidget {

  final Widget child;

  final VoidCallback onTap;

  final bool enabled;



  const _SocialButton({

    required this.child,

    required this.onTap,

    this.enabled = true,

  });



  @override

  Widget build(BuildContext context) {

    return Material(

      color: Colors.white,

      borderRadius: BorderRadius.circular(12.r),

      child: InkWell(

        onTap: enabled ? onTap : null,

        borderRadius: BorderRadius.circular(12.r),

        child: SizedBox(

          width: 56.w,

          height: 56.w,

          child: Center(child: child),

        ),

      ),

    );

  }

}



class _GoogleLogo extends StatelessWidget {

  final double size;



  const _GoogleLogo({required this.size});



  @override

  Widget build(BuildContext context) {

    return SizedBox(

      width: size,

      height: size,

      child: CustomPaint(painter: _GoogleLogoPainter()),

    );

  }

}



class _GoogleLogoPainter extends CustomPainter {

  @override

  void paint(Canvas canvas, Size size) {

    final center = Offset(size.width / 2, size.height / 2);

    final radius = size.width / 2;



    void arc(Color color, double start, double sweep) {

      final paint = Paint()

        ..color = color

        ..style = PaintingStyle.stroke

        ..strokeWidth = size.width * 0.18

        ..strokeCap = StrokeCap.butt;

      canvas.drawArc(

        Rect.fromCircle(center: center, radius: radius * 0.72),

        start,

        sweep,

        false,

        paint,

      );

    }



    arc(const Color(0xFFEA4335), -0.4, 1.2);

    arc(const Color(0xFFFBBC05), 0.8, 1.0);

    arc(const Color(0xFF34A853), 1.8, 1.1);

    arc(const Color(0xFF4285F4), 2.9, 1.0);



    canvas.drawRect(

      Rect.fromCenter(

        center: Offset(center.dx + radius * 0.15, center.dy),

        width: radius * 0.9,

        height: radius * 0.35,

      ),

      Paint()..color = const Color(0xFF4285F4),

    );

  }



  @override

  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;

}


