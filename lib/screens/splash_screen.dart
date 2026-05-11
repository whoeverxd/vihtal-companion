import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../router/app_router.dart';
import '../theme.dart';
import '../widgets/brand_logo.dart';

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: DecoratedBox(
          decoration: const BoxDecoration(
            gradient: RadialGradient(
              center: Alignment(-0.85, -0.95),
              radius: 0.75,
              colors: [Color(0xFFE8C4CB), Color(0xFFF1D7DC)],
            ),
          ),
          child: LayoutBuilder(
            builder: (context, constraints) {
              final compact = constraints.maxHeight < 740;

              return Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: compact ? 20 : 32,
                  vertical: compact ? 10 : 14,
                ),
                child: Column(
                  children: [
                    Align(
                      alignment: Alignment.topRight,
                      child: Container(
                        width: compact ? 58 : 72,
                        height: compact ? 58 : 72,
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.25),
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.10),
                              blurRadius: 16,
                              offset: const Offset(0, 6),
                            ),
                          ],
                        ),
                        child: IconButton(
                          onPressed: () {},
                          icon: const Icon(Icons.nightlight_round),
                          color: const Color(0xFF0D1B33),
                        ),
                      ),
                    ),
                    const Spacer(),
                    BrandLogo(width: compact ? 210 : 300),
                    SizedBox(height: compact ? 18 : 28),
                    Text(
                      'IA y apoyo humano para VIH\nseguro y privado',
                      textAlign: TextAlign.center,
                      style: textTheme.titleMedium?.copyWith(
                        fontSize: compact ? 18 : 23,
                        fontWeight: FontWeight.w500,
                        color: const Color(0xFF233955),
                        height: 1.45,
                      ),
                    ),
                    const Spacer(flex: 2),
                    SizedBox(
                      width: double.infinity,
                      height: compact ? 64 : 84,
                      child: ElevatedButton(
                        onPressed: () => context.go(AppRoutes.login),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFE8114D),
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
                          elevation: 0,
                        ),
                        child: Text(
                          'EMPEZAR',
                          style: textTheme.titleLarge?.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 2.6,
                            fontSize: compact ? 20 : 26,
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: compact ? 22 : 48),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.lock_outline,
                          size: compact ? 18 : 24,
                          color: const Color(
                            0xFF415773,
                          ).withValues(alpha: 0.95),
                        ),
                        SizedBox(width: compact ? 8 : 12),
                        Text(
                          'ENCRIPTACION DE GRADO MEDICO',
                          style: textTheme.labelLarge?.copyWith(
                            color: const Color(0xFF415773),
                            fontWeight: FontWeight.w700,
                            fontSize: compact ? 11 : 13,
                            letterSpacing: compact ? 1.4 : 2,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: compact ? 18 : 34),
                    Container(
                      width: compact ? 170 : 240,
                      height: compact ? 6 : 8,
                      decoration: BoxDecoration(
                        color: const Color(0xFFE1CDD2),
                        borderRadius: BorderRadius.circular(999),
                      ),
                    ),
                    SizedBox(height: compact ? 8 : 12),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
