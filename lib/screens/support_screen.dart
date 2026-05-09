import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../router/app_router.dart';
import '../theme.dart';

/// Vista de apoyo/donaciones ("Apoya a VIHTAL").
/// Basada en el HTML de referencia (Tailwind) para mantener jerarquía y espaciados.
class SupportScreen extends StatelessWidget {
  const SupportScreen({super.key});

  void _goBack(BuildContext context) {
    if (context.canPop()) {
      context.pop();
    } else {
      context.go(AppRoutes.home);
    }
  }

  @override
  Widget build(BuildContext context) {
    final media = MediaQuery.of(context);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.only(bottom: 24 + media.viewInsets.bottom),
          child: ConstrainedBox(
            constraints: BoxConstraints(minHeight: media.size.height - media.padding.vertical),
            child: IntrinsicHeight(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Header
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                    child: Row(
                      children: [
                        InkWell(
                          onTap: () => _goBack(context),
                          borderRadius: BorderRadius.circular(999),
                          child: Container(
                            width: 48,
                            height: 48,
                            decoration: BoxDecoration(
                              color: AppColors.primary.withValues(alpha: 0.10),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(Icons.arrow_back, color: AppColors.primary),
                          ),
                        ),
                        const Spacer(),
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              width: 32,
                              height: 32,
                              decoration: BoxDecoration(
                                color: AppColors.primary,
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: const Icon(Icons.health_and_safety, color: Colors.white, size: 18),
                            ),
                            const SizedBox(width: 10),
                            const Text(
                              'VIHTAL',
                              style: TextStyle(fontWeight: FontWeight.w800, fontSize: 18, letterSpacing: -0.2),
                            ),
                          ],
                        ),
                        const Spacer(),
                        const SizedBox(width: 48, height: 48),
                      ],
                    ),
                  ),

                  // Content
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 22),
                        const Text(
                          'Apoya a VIHTAL',
                          style: TextStyle(
                            fontSize: 32,
                            fontWeight: FontWeight.w900,
                            height: 1.1,
                            letterSpacing: -0.4,
                          ),
                        ),
                        const SizedBox(height: 14),
                        Text(
                          'Tu apoyo nos ayuda a mantener y mejorar VIHTAL Companion.\n\nPuedes contribuir con una donación o apoyarnos compartiendo la app.',
                          style: TextStyle(
                            fontSize: 16,
                            height: 1.55,
                            color: Colors.white.withValues(alpha: 0.65),
                          ),
                        ),
                        const SizedBox(height: 24),

                        Center(
                          child: Container(
                            width: 96,
                            height: 96,
                            decoration: BoxDecoration(
                              color: AppColors.primary.withValues(alpha: 0.07),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(Icons.volunteer_activism, color: AppColors.primary, size: 44),
                          ),
                        ),

                        const SizedBox(height: 28),

                        _SupportCard(
                          icon: Icons.favorite,
                          title: 'Donar',
                          subtitle: 'Aporta para que podamos seguir construyendo nuevas funciones.',
                          onPressed: () => context.go(AppRoutes.donate),
                        ),
                        const SizedBox(height: 12),
                        _SupportCard(
                          icon: Icons.share,
                          title: 'Compartir la app',
                          subtitle: 'Recomiéndanos con tus amigos y familiares.',
                          onPressed: () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Función compartir pendiente de implementar.')),
                            );
                          },
                        ),
                        const SizedBox(height: 12),
                        _SupportCard(
                          icon: Icons.star_rate,
                          title: 'Calificar',
                          subtitle: 'Una reseña positiva ayuda muchísimo al proyecto.',
                          onPressed: () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Link a la tienda pendiente de implementar.')),
                            );
                          },
                        ),
                      ],
                    ),
                  ),

                  const Spacer(),

                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
                    child: TextButton(
                      onPressed: () => context.go(AppRoutes.home),
                      style: TextButton.styleFrom(
                        foregroundColor: AppColors.primary,
                        textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
                      ),
                      child: const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.home_outlined, size: 18),
                          SizedBox(width: 10),
                          Text('Volver al Inicio'),
                        ],
                      ),
                    ),
                  ),

                  Center(
                    child: Container(
                      width: 120,
                      height: 5,
                      margin: const EdgeInsets.only(bottom: 10),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withValues(alpha: 0.18),
                        borderRadius: BorderRadius.circular(999),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _SupportCard extends StatelessWidget {
  const _SupportCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    this.cta,
    required this.onPressed,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final String? cta;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onPressed,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.03),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.primary.withValues(alpha: 0.12)),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: AppColors.primary),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 15)),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: TextStyle(color: Colors.white.withValues(alpha: 0.65), fontSize: 12, height: 1.35),
                  ),
                  if (cta != null) ...[
                    const SizedBox(height: 10),
                    Text(
                      cta!,
                      style: TextStyle(
                        color: AppColors.primary.withValues(alpha: 0.95),
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            Icon(Icons.chevron_right, color: Colors.white.withValues(alpha: 0.35)),
          ],
        ),
      ),
    );
  }
}
