import 'package:flutter/material.dart';

/// The RideEase logo (assets/images/logo.png).
class AppLogo extends StatelessWidget {
  const AppLogo({super.key, this.size = 64});
  final double size;

  @override
  Widget build(BuildContext context) => Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(size * 0.22),
          boxShadow: [
            BoxShadow(color: Colors.black.withValues(alpha: 0.25), blurRadius: 14, offset: const Offset(0, 6)),
          ],
        ),
        child: Image.asset('assets/images/logo.png', width: size, height: size, filterQuality: FilterQuality.medium),
      );
}
