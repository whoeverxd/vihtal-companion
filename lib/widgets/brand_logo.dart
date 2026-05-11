import 'package:flutter/material.dart';

import '../theme.dart';

class BrandLogo extends StatelessWidget {
  const BrandLogo({
    super.key,
    this.width = 180,
    this.height,
    this.fit = BoxFit.contain,
  });

  final double width;
  final double? height;
  final BoxFit fit;

  @override
  Widget build(BuildContext context) {
    return Image.asset(
      'assets/logo_transparent.png',
      width: width,
      height: height,
      fit: fit,
      filterQuality: FilterQuality.high,
      errorBuilder: (context, error, stackTrace) {
        return Text(
          'VIHTAL Companion',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            color: AppColors.primary,
            fontWeight: FontWeight.w800,
          ),
        );
      },
    );
  }
}

class BrandMark extends StatelessWidget {
  const BrandMark({super.key, this.size = 88, this.opacity = 1});

  final double size;
  final double opacity;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: Opacity(
        opacity: opacity,
        child: ClipRect(
          child: Align(
            alignment: Alignment.topCenter,
            heightFactor: 0.42,
            child: Image.asset(
              'assets/logo_transparent.png',
              width: size * 1.6,
              fit: BoxFit.contain,
              filterQuality: FilterQuality.high,
              errorBuilder: (context, error, stackTrace) {
                return Icon(
                  Icons.flutter_dash_rounded,
                  size: size,
                  color: AppColors.primary,
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}
