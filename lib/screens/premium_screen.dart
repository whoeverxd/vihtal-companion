import 'package:flutter/material.dart';

import '../services/premium_service.dart';
import '../theme.dart';
import '../widgets/vihtal_app_bar.dart';

/// Pantalla de venta del plan Premium + gestión del estado (modo prueba).
class PremiumScreen extends StatefulWidget {
  const PremiumScreen({super.key, this.service});

  final PremiumService? service;

  @override
  State<PremiumScreen> createState() => _PremiumScreenState();
}

class _PremiumScreenState extends State<PremiumScreen> {
  late final PremiumService _service = widget.service ?? PremiumService();
  bool _busy = false;

  static const _benefits = <_Benefit>[
    _Benefit(Icons.all_inclusive_rounded, 'Chat con IA ilimitado',
        'Sin límite diario de mensajes.'),
    _Benefit(Icons.medication_rounded, 'Adherencia y recordatorios',
        'Medicación, citas y seguimiento del tratamiento.'),
    _Benefit(Icons.lock_rounded, 'Historial encriptado',
        'Guarda tus consultas y tu evolución de forma segura.'),
    _Benefit(Icons.support_agent_rounded, 'Soporte humano',
        'Acceso a consejeros y profesionales aliados.'),
  ];

  Future<void> _setPremium(bool value) async {
    setState(() => _busy = true);
    try {
      await _service.setPremium(value);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(value
                ? '¡Premium activado (modo prueba)!'
                : 'Premium desactivado.'),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('No se pudo actualizar: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  void _onBuy() {
    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Pagos próximamente'),
        content: const Text(
          'La pasarela de pago aún no está integrada. Por ahora puedes usar el '
          'interruptor de modo prueba para simular el plan Premium.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Entendido'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: VihtalAppBar(
        showDonateAction: false,
        leading: BackButton(
          color: AppColors.primary,
          onPressed: () => Navigator.of(context).maybePop(),
        ),
      ),
      body: StreamBuilder<bool>(
        stream: _service.watchIsPremium(),
        builder: (context, snapshot) {
          final isPremium = snapshot.data ?? false;
          return ListView(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 28),
            children: [
              _Hero(isPremium: isPremium),
              const SizedBox(height: 24),
              const Text(
                'Todo lo que incluye',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 14),
              for (final b in _benefits) _BenefitRow(benefit: b),
              const SizedBox(height: 24),
              if (!isPremium) ...[
                _PriceCard(onBuy: _onBuy),
                const SizedBox(height: 20),
              ],
              _TestModeCard(
                isPremium: isPremium,
                busy: _busy,
                onChanged: _setPremium,
              ),
            ],
          );
        },
      ),
    );
  }
}

class _Benefit {
  const _Benefit(this.icon, this.title, this.subtitle);
  final IconData icon;
  final String title;
  final String subtitle;
}

class _Hero extends StatelessWidget {
  const _Hero({required this.isPremium});

  final bool isPremium;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppColors.primary, AppColors.primaryDark],
        ),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const Icon(Icons.workspace_premium_rounded,
                    color: Colors.white, size: 28),
              ),
              const Spacer(),
              if (isPremium)
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: const Text(
                    'ACTIVO',
                    style: TextStyle(
                      color: AppColors.primary,
                      fontSize: 11,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 16),
          const Text(
            'VIHTAL Premium',
            style: TextStyle(
              color: Colors.white,
              fontSize: 26,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            isPremium
                ? 'Gracias por apoyar el proyecto. Disfrutas de todas las funciones.'
                : 'Acompañamiento personalizado y herramientas avanzadas para tu salud.',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 14,
              height: 1.45,
            ),
          ),
        ],
      ),
    );
  }
}

class _BenefitRow extends StatelessWidget {
  const _BenefitRow({required this.benefit});

  final _Benefit benefit;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: const BoxDecoration(
              color: AppColors.surfaceSoft,
              shape: BoxShape.circle,
            ),
            child: Icon(benefit.icon, color: AppColors.primary, size: 21),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  benefit.title,
                  style: const TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 15,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  benefit.subtitle,
                  style: const TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 13,
                    height: 1.3,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _PriceCard extends StatelessWidget {
  const _PriceCard({required this.onBuy});

  final VoidCallback onBuy;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        children: [
          const Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(
                '\$4.99',
                style: TextStyle(
                  fontSize: 36,
                  fontWeight: FontWeight.w800,
                  color: AppColors.textPrimary,
                ),
              ),
              SizedBox(width: 4),
              Text(
                '/ mes',
                style: TextStyle(
                  fontSize: 15,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          const Text(
            'Cancela cuando quieras',
            style: TextStyle(color: AppColors.textSecondary, fontSize: 12.5),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            height: 54,
            child: ElevatedButton(
              onPressed: onBuy,
              style: ElevatedButton.styleFrom(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              child: const Text(
                'Hazte Premium',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _TestModeCard extends StatelessWidget {
  const _TestModeCard({
    required this.isPremium,
    required this.busy,
    required this.onChanged,
  });

  final bool isPremium;
  final bool busy;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 6, 8, 6),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Modo prueba',
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
                Text(
                  'Simula el plan Premium sin pagar (solo desarrollo).',
                  style:
                      TextStyle(color: AppColors.textSecondary, fontSize: 12.5),
                ),
              ],
            ),
          ),
          if (busy)
            const Padding(
              padding: EdgeInsets.all(12),
              child: SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(strokeWidth: 2.2),
              ),
            )
          else
            Switch(
              value: isPremium,
              activeThumbColor: AppColors.primary,
              onChanged: onChanged,
            ),
        ],
      ),
    );
  }
}
