import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../router/app_router.dart';
import '../theme.dart';

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const SizedBox(height: 24),
            // Logo and titles
            Column(
              children: [
                const SizedBox(height: 40),
                // Logo circle
                Container(
                  width: 160,
                  height: 160,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppColors.darkCircle,
                    boxShadow: [
                      BoxShadow(color: AppColors.darkCircle.withAlpha((0.6 * 255).round()), blurRadius: 30, spreadRadius: 10),
                    ],
                  ),
                  child: const Center(
                    child: Icon(Icons.favorite, size: 72, color: AppColors.primary),
                  ),
                ),
                const SizedBox(height: 36),
                Text('VIHTAL', style: textTheme.headlineLarge?.copyWith(color: AppColors.whiteText)),
                const SizedBox(height: 8),
                Text('Companion', style: textTheme.headlineMedium?.copyWith(color: AppColors.primary)),
                const SizedBox(height: 12),
                Text('SALUD Y BIENESTAR', style: textTheme.labelLarge?.copyWith(letterSpacing: 4)),
              ],
            ),

            // Bottom area: dots + button
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 36.0),
              child: Column(
                children: [
                  // Dots indicator
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _dot(false),
                      const SizedBox(width: 8),
                      _dot(false),
                      const SizedBox(width: 8),
                      _dot(true),
                    ],
                  ),
                  const SizedBox(height: 20),
                  // Button
                  SizedBox(
                    width: 300,
                    height: 56,
                    child: OutlinedButton.icon(
                      style: OutlinedButton.styleFrom(
                        backgroundColor: Colors.black.withAlpha((0.16 * 255).round()),
                        side: BorderSide(color: AppColors.primaryDark.withAlpha((0.6 * 255).round())),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(32)),
                      ),
                      onPressed: () => context.go(AppRoutes.login),
                      icon: const Icon(Icons.lock, color: AppColors.primary),
                      label: Text('Seguro y Privado', style: textTheme.titleMedium?.copyWith(color: AppColors.whiteText)),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _dot(bool active) {
    return Container(
      width: 10,
      height: 10,
      decoration: BoxDecoration(
        color: active ? AppColors.primary : AppColors.mutedText.withAlpha((0.6 * 255).round()),
        shape: BoxShape.circle,
      ),
    );
  }
}
