import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../router/app_router.dart';
import '../theme.dart';
import '../widgets/vihtal_app_bar.dart';

/// Panel de Salud / Adherencia (sub-proyecto B).
///
/// MVP / placeholder: muestra la estructura de las funciones de acompañamiento
/// (próxima dosis, adherencia, citas, síntomas) con datos simulados y sin
/// backend. Cuando se conecte Firestore, cada tarjeta leerá datos reales del
/// usuario; varias de estas funciones serán premium.
class HealthScreen extends StatelessWidget {
  const HealthScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: const VihtalAppBar(),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
        children: [
          Text('Tu salud', style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 4),
          const Text(
            'Lleva el control de tu tratamiento y bienestar.',
            style: TextStyle(color: AppColors.textSecondary, height: 1.35),
          ),
          const SizedBox(height: 20),
          const _NextDoseCard(),
          const SizedBox(height: 14),
          const _AdherenceCard(),
          const SizedBox(height: 14),
          const _AppointmentCard(),
          const SizedBox(height: 14),
          const _SymptomLogCard(),
          const SizedBox(height: 14),
          const _CentersEntryCard(),
        ],
      ),
    );
  }
}

/// Acceso al directorio de centros de salud cercanos (mapa).
class _CentersEntryCard extends StatelessWidget {
  const _CentersEntryCard();

  @override
  Widget build(BuildContext context) {
    return _Card(
      onTap: () => context.push(AppRoutes.centers),
      child: Row(
        children: [
          Container(
            width: 46,
            height: 46,
            decoration: const BoxDecoration(
              color: AppColors.surfaceSoft,
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.map_rounded, color: AppColors.primary),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                Text(
                  'Centros de salud cercanos',
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
                SizedBox(height: 2),
                Text(
                  'Encuentra pruebas, tratamiento y apoyo en el mapa',
                  style: TextStyle(color: AppColors.textSecondary, fontSize: 13),
                ),
              ],
            ),
          ),
          const Icon(Icons.chevron_right_rounded, color: AppColors.textSecondary),
        ],
      ),
    );
  }
}

/// Tarjeta destacada: próxima toma de medicación.
class _NextDoseCard extends StatelessWidget {
  const _NextDoseCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.primary,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: const [
              Icon(Icons.medication_rounded, color: Colors.white, size: 20),
              SizedBox(width: 8),
              Text(
                'Próxima dosis',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          const Text(
            '20:00',
            style: TextStyle(
              color: Colors.white,
              fontSize: 40,
              fontWeight: FontWeight.w800,
              height: 1,
            ),
          ),
          const SizedBox(height: 4),
          const Text(
            'Antirretroviral · 1 comprimido',
            style: TextStyle(color: Colors.white70, fontSize: 13),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _SoftButton(
                  label: 'Tomé mi dosis',
                  icon: Icons.check_circle_rounded,
                  onTap: () => _snack(context, 'Dosis registrada (demo).'),
                ),
              ),
              const SizedBox(width: 10),
              _SoftButton(
                label: 'Posponer',
                icon: Icons.snooze_rounded,
                compact: true,
                onTap: () => _snack(context, 'Recordatorio pospuesto (demo).'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// Botón claro sobre fondo rojo (para la tarjeta de dosis).
class _SoftButton extends StatelessWidget {
  const _SoftButton({
    required this.label,
    required this.icon,
    required this.onTap,
    this.compact = false,
  });

  final String label;
  final IconData icon;
  final VoidCallback onTap;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(999),
      child: InkWell(
        borderRadius: BorderRadius.circular(999),
        onTap: onTap,
        child: Padding(
          padding: EdgeInsets.symmetric(
            horizontal: compact ? 14 : 16,
            vertical: 11,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 18, color: AppColors.primary),
              if (!compact) ...[
                const SizedBox(width: 8),
                Text(
                  label,
                  style: const TextStyle(
                    color: AppColors.primary,
                    fontWeight: FontWeight.w700,
                    fontSize: 14,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

/// Tarjeta de adherencia semanal con puntos por día.
class _AdherenceCard extends StatelessWidget {
  const _AdherenceCard();

  static const _days = ['L', 'M', 'M', 'J', 'V', 'S', 'D'];
  // Estado simulado: true = tomada, false = pendiente/olvidada.
  static const _taken = [true, true, true, true, true, false, false];

  @override
  Widget build(BuildContext context) {
    return _Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const _CardTitle(icon: Icons.insights_rounded, text: 'Adherencia'),
              Text(
                '5/7 días',
                style: Theme.of(context).textTheme.labelLarge,
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              for (var i = 0; i < _days.length; i++)
                Column(
                  children: [
                    Container(
                      width: 30,
                      height: 30,
                      decoration: BoxDecoration(
                        color: _taken[i]
                            ? AppColors.primary
                            : AppColors.surfaceSoft,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        _taken[i] ? Icons.check : Icons.remove,
                        size: 16,
                        color: _taken[i]
                            ? Colors.white
                            : AppColors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      _days[i],
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
            ],
          ),
        ],
      ),
    );
  }
}

/// Tarjeta de próxima cita médica.
class _AppointmentCard extends StatelessWidget {
  const _AppointmentCard();

  @override
  Widget build(BuildContext context) {
    return _Card(
      child: Row(
        children: [
          Container(
            width: 46,
            height: 46,
            decoration: const BoxDecoration(
              color: AppColors.surfaceSoft,
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.event_rounded, color: AppColors.primary),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                Text(
                  'Próxima cita',
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
                SizedBox(height: 2),
                Text(
                  '23 jun · 10:30 · Control de carga viral',
                  style: TextStyle(color: AppColors.textSecondary, fontSize: 13),
                ),
              ],
            ),
          ),
          const Icon(Icons.chevron_right_rounded, color: AppColors.textSecondary),
        ],
      ),
    );
  }
}

/// Acción rápida: registrar síntomas / cómo me siento.
class _SymptomLogCard extends StatelessWidget {
  const _SymptomLogCard();

  @override
  Widget build(BuildContext context) {
    return _Card(
      onTap: () => _snack(context, 'Registro de síntomas (demo).'),
      child: Row(
        children: [
          Container(
            width: 46,
            height: 46,
            decoration: const BoxDecoration(
              color: AppColors.surfaceSoft,
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.favorite_rounded, color: AppColors.primary),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                Text(
                  '¿Cómo te sientes hoy?',
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
                SizedBox(height: 2),
                Text(
                  'Registra síntomas y estado de ánimo',
                  style: TextStyle(color: AppColors.textSecondary, fontSize: 13),
                ),
              ],
            ),
          ),
          const Icon(Icons.add_circle_outline_rounded, color: AppColors.primary),
        ],
      ),
    );
  }
}

// -----------------------------------------------------------------------------
// Helpers de UI compartidos en esta pantalla.
// -----------------------------------------------------------------------------

class _Card extends StatelessWidget {
  const _Card({required this.child, this.onTap});

  final Widget child;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final content = Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.subtle),
      ),
      child: child,
    );

    if (onTap == null) return content;
    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(18),
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: onTap,
        child: content,
      ),
    );
  }
}

class _CardTitle extends StatelessWidget {
  const _CardTitle({required this.icon, required this.text});

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 18, color: AppColors.primary),
        const SizedBox(width: 8),
        Text(
          text,
          style: const TextStyle(
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary,
          ),
        ),
      ],
    );
  }
}

void _snack(BuildContext context, String message) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(content: Text(message), duration: const Duration(seconds: 2)),
  );
}
