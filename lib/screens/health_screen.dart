import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../models/health_models.dart';
import '../router/app_router.dart';
import '../services/health_service.dart';
import '../services/premium_service.dart';
import '../theme.dart';
import '../widgets/vihtal_app_bar.dart';

/// Panel de Salud / Adherencia con datos reales (Firestore).
class HealthScreen extends StatefulWidget {
  const HealthScreen({super.key});

  @override
  State<HealthScreen> createState() => _HealthScreenState();
}

class _HealthScreenState extends State<HealthScreen> {
  final HealthService _service = HealthService();

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
          const _PremiumUpsellBanner(),
          _MedicationSection(service: _service),
          const SizedBox(height: 14),
          _AdherenceSection(service: _service),
          const SizedBox(height: 14),
          _AppointmentSection(service: _service),
          const SizedBox(height: 14),
          _SymptomSection(service: _service),
          const SizedBox(height: 14),
          const _CentersEntryCard(),
        ],
      ),
    );
  }
}

// =============================================================================
// Medicación: próxima dosis + lista + agregar
// =============================================================================

class _MedicationSection extends StatelessWidget {
  const _MedicationSection({required this.service});

  final HealthService service;

  @override
  Widget build(BuildContext context) {
    final todayKey = HealthService.dayKeyOf(DateTime.now());
    return StreamBuilder<List<Medication>>(
      stream: service.watchMedications(),
      builder: (context, medSnap) {
        final meds = medSnap.data ?? const <Medication>[];
        return StreamBuilder<List<Intake>>(
          stream: service.watchIntakes([todayKey]),
          builder: (context, intakeSnap) {
            final takenIds =
                (intakeSnap.data ?? const <Intake>[]).map((i) => i.medId).toSet();

            if (meds.isEmpty) {
              return _Card(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const _CardTitle(
                        icon: Icons.medication_rounded, text: 'Medicación'),
                    const SizedBox(height: 10),
                    const Text(
                      'Aún no agregas medicamentos. Añade el primero para recibir '
                      'recordatorios y registrar tu adherencia.',
                      style: TextStyle(
                          color: AppColors.textSecondary, height: 1.4),
                    ),
                    const SizedBox(height: 12),
                    _AddButton(
                      label: 'Agregar medicación',
                      onTap: () => _showAddMedication(context, service),
                    ),
                  ],
                ),
              );
            }

            final pending = meds.where((m) => !takenIds.contains(m.id)).toList()
              ..sort((a, b) =>
                  (a.hour * 60 + a.minute).compareTo(b.hour * 60 + b.minute));
            final next = pending.isNotEmpty ? pending.first : null;

            return Column(
              children: [
                if (next != null)
                  _NextDoseCard(
                    med: next,
                    onTaken: () => service.markTaken(next.id),
                  )
                else
                  _AllDoneCard(),
                const SizedBox(height: 14),
                _Card(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const _CardTitle(
                              icon: Icons.list_alt_rounded,
                              text: 'Mis medicamentos'),
                          const Spacer(),
                          IconButton(
                            visualDensity: VisualDensity.compact,
                            onPressed: () =>
                                _showAddMedication(context, service),
                            icon: const Icon(Icons.add_circle_outline_rounded,
                                color: AppColors.primary),
                            tooltip: 'Agregar',
                          ),
                        ],
                      ),
                      for (final m in meds)
                        _MedRow(
                          med: m,
                          taken: takenIds.contains(m.id),
                          onToggle: () => takenIds.contains(m.id)
                              ? service.undoTaken(m.id)
                              : service.markTaken(m.id),
                          onDelete: () => service.removeMedication(m.id),
                        ),
                    ],
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }
}

class _NextDoseCard extends StatelessWidget {
  const _NextDoseCard({required this.med, required this.onTaken});

  final Medication med;
  final VoidCallback onTaken;

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
              Text('Próxima dosis',
                  style: TextStyle(
                      color: Colors.white, fontWeight: FontWeight.w600)),
            ],
          ),
          const SizedBox(height: 14),
          Text(
            med.timeLabel,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 40,
              fontWeight: FontWeight.w800,
              height: 1,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            '${med.name}${med.dose.isNotEmpty ? ' · ${med.dose}' : ''}',
            style: const TextStyle(color: Colors.white70, fontSize: 13),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: _WhiteButton(
              label: 'Tomé mi dosis',
              icon: Icons.check_circle_rounded,
              onTap: () {
                onTaken();
                _snack(context, 'Dosis registrada.');
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _AllDoneCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return _Card(
      child: Row(
        children: const [
          Icon(Icons.check_circle_rounded, color: AppColors.primary, size: 26),
          SizedBox(width: 12),
          Expanded(
            child: Text(
              '¡Listo por hoy! Tomaste toda tu medicación. 🎉',
              style: TextStyle(
                  color: AppColors.textPrimary, fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }
}

class _MedRow extends StatelessWidget {
  const _MedRow({
    required this.med,
    required this.taken,
    required this.onToggle,
    required this.onDelete,
  });

  final Medication med;
  final bool taken;
  final VoidCallback onToggle;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 12),
      child: Row(
        children: [
          GestureDetector(
            onTap: onToggle,
            child: Container(
              width: 28,
              height: 28,
              decoration: BoxDecoration(
                color: taken ? AppColors.primary : AppColors.surfaceSoft,
                shape: BoxShape.circle,
              ),
              child: Icon(
                taken ? Icons.check : Icons.circle_outlined,
                size: 16,
                color: taken ? Colors.white : AppColors.textSecondary,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  med.name,
                  style: const TextStyle(
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                Text(
                  '${med.timeLabel}${med.dose.isNotEmpty ? '  ·  ${med.dose}' : ''}',
                  style: const TextStyle(
                      color: AppColors.textSecondary, fontSize: 12.5),
                ),
              ],
            ),
          ),
          IconButton(
            visualDensity: VisualDensity.compact,
            onPressed: onDelete,
            icon: const Icon(Icons.delete_outline_rounded,
                color: AppColors.textSecondary, size: 20),
            tooltip: 'Eliminar',
          ),
        ],
      ),
    );
  }
}

// =============================================================================
// Adherencia semanal
// =============================================================================

class _AdherenceSection extends StatelessWidget {
  const _AdherenceSection({required this.service});

  final HealthService service;

  static const _dayLetters = ['L', 'M', 'M', 'J', 'V', 'S', 'D'];

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final keys = HealthService.lastDayKeys(now, 7);

    return StreamBuilder<List<Medication>>(
      stream: service.watchMedications(),
      builder: (context, medSnap) {
        final medCount = (medSnap.data ?? const <Medication>[]).length;
        return StreamBuilder<List<Intake>>(
          stream: service.watchIntakes(keys),
          builder: (context, intakeSnap) {
            final intakes = intakeSnap.data ?? const <Intake>[];
            final countByDay = <String, int>{};
            for (final i in intakes) {
              countByDay[i.dayKey] = (countByDay[i.dayKey] ?? 0) + 1;
            }
            final completeDays = keys
                .where((k) =>
                    medCount > 0 && (countByDay[k] ?? 0) >= medCount)
                .length;

            // El día de la semana del primer key, para etiquetar L-D.
            final firstDate = now.subtract(const Duration(days: 6));

            return _Card(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const _CardTitle(
                          icon: Icons.insights_rounded, text: 'Adherencia (7 días)'),
                      Text('$completeDays/7 días',
                          style: Theme.of(context).textTheme.labelLarge),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      for (var i = 0; i < keys.length; i++)
                        _DayDot(
                          letter: _dayLetters[
                              (firstDate.add(Duration(days: i)).weekday - 1) % 7],
                          complete:
                              medCount > 0 && (countByDay[keys[i]] ?? 0) >= medCount,
                          partial: (countByDay[keys[i]] ?? 0) > 0,
                        ),
                    ],
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}

class _DayDot extends StatelessWidget {
  const _DayDot({
    required this.letter,
    required this.complete,
    required this.partial,
  });

  final String letter;
  final bool complete;
  final bool partial;

  @override
  Widget build(BuildContext context) {
    final Color bg;
    final IconData icon;
    final Color fg;
    if (complete) {
      bg = AppColors.primary;
      icon = Icons.check;
      fg = Colors.white;
    } else if (partial) {
      bg = AppColors.surfaceSoft;
      icon = Icons.remove;
      fg = AppColors.primary;
    } else {
      bg = AppColors.surfaceSoft;
      icon = Icons.remove;
      fg = AppColors.textSecondary;
    }
    return Column(
      children: [
        Container(
          width: 30,
          height: 30,
          decoration: BoxDecoration(color: bg, shape: BoxShape.circle),
          child: Icon(icon, size: 16, color: fg),
        ),
        const SizedBox(height: 6),
        Text(letter,
            style:
                const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
      ],
    );
  }
}

// =============================================================================
// Citas
// =============================================================================

class _AppointmentSection extends StatelessWidget {
  const _AppointmentSection({required this.service});

  final HealthService service;

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<Appointment>>(
      stream: service.watchAppointments(),
      builder: (context, snap) {
        final all = snap.data ?? const <Appointment>[];
        final now = DateTime.now();
        final upcoming =
            all.where((a) => a.dateTime.isAfter(now)).toList();

        return _Card(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const _CardTitle(
                      icon: Icons.event_rounded, text: 'Citas médicas'),
                  const Spacer(),
                  IconButton(
                    visualDensity: VisualDensity.compact,
                    onPressed: () => _showAddAppointment(context, service),
                    icon: const Icon(Icons.add_circle_outline_rounded,
                        color: AppColors.primary),
                    tooltip: 'Agregar',
                  ),
                ],
              ),
              if (upcoming.isEmpty)
                const Padding(
                  padding: EdgeInsets.only(top: 8),
                  child: Text(
                    'No tienes citas próximas.',
                    style: TextStyle(color: AppColors.textSecondary),
                  ),
                )
              else
                for (final a in upcoming.take(3))
                  Padding(
                    padding: const EdgeInsets.only(top: 12),
                    child: Row(
                      children: [
                        Container(
                          width: 42,
                          height: 42,
                          decoration: const BoxDecoration(
                            color: AppColors.surfaceSoft,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.event_rounded,
                              color: AppColors.primary, size: 20),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(a.title,
                                  style: const TextStyle(
                                      color: AppColors.textPrimary,
                                      fontWeight: FontWeight.w700)),
                              Text(
                                '${a.whenLabel}${a.location.isNotEmpty ? '  ·  ${a.location}' : ''}',
                                style: const TextStyle(
                                    color: AppColors.textSecondary,
                                    fontSize: 12.5),
                              ),
                            ],
                          ),
                        ),
                        IconButton(
                          visualDensity: VisualDensity.compact,
                          onPressed: () => service.removeAppointment(a.id),
                          icon: const Icon(Icons.delete_outline_rounded,
                              color: AppColors.textSecondary, size: 20),
                        ),
                      ],
                    ),
                  ),
            ],
          ),
        );
      },
    );
  }
}

// =============================================================================
// Síntomas / ánimo
// =============================================================================

class _SymptomSection extends StatelessWidget {
  const _SymptomSection({required this.service});

  final HealthService service;

  static const _moods = [
    (1, '😞', 'Mal'),
    (2, '😕', 'Regular'),
    (3, '😐', 'Normal'),
    (4, '🙂', 'Bien'),
    (5, '😄', 'Genial'),
  ];

  @override
  Widget build(BuildContext context) {
    return _Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _CardTitle(
              icon: Icons.favorite_rounded, text: '¿Cómo te sientes hoy?'),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              for (final m in _moods)
                GestureDetector(
                  onTap: () => _logMood(context, service, m.$1, m.$3),
                  child: Column(
                    children: [
                      Text(m.$2, style: const TextStyle(fontSize: 30)),
                      const SizedBox(height: 4),
                      Text(m.$3,
                          style: const TextStyle(
                              fontSize: 11, color: AppColors.textSecondary)),
                    ],
                  ),
                ),
            ],
          ),
          StreamBuilder<List<SymptomEntry>>(
            stream: service.watchSymptoms(limit: 3),
            builder: (context, snap) {
              final entries = snap.data ?? const <SymptomEntry>[];
              if (entries.isEmpty) return const SizedBox.shrink();
              return Padding(
                padding: const EdgeInsets.only(top: 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Divider(color: AppColors.border, height: 1),
                    const SizedBox(height: 8),
                    for (final e in entries)
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 3),
                        child: Row(
                          children: [
                            Text(_emojiFor(e.mood),
                                style: const TextStyle(fontSize: 16)),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                e.note.isEmpty ? 'Registro de ánimo' : e.note,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                    color: AppColors.textSecondary,
                                    fontSize: 13),
                              ),
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  static String _emojiFor(int mood) {
    switch (mood) {
      case 1:
        return '😞';
      case 2:
        return '😕';
      case 3:
        return '😐';
      case 4:
        return '🙂';
      default:
        return '😄';
    }
  }
}

// =============================================================================
// Formularios (bottom sheets)
// =============================================================================

Future<void> _showAddMedication(
    BuildContext context, HealthService service) async {
  final nameCtrl = TextEditingController();
  final doseCtrl = TextEditingController();
  TimeOfDay time = const TimeOfDay(hour: 8, minute: 0);

  await showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    backgroundColor: AppColors.surface,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
    ),
    builder: (sheetContext) {
      return StatefulBuilder(
        builder: (sheetContext, setSheet) {
          return Padding(
            padding: EdgeInsets.fromLTRB(
                20, 18, 20, 18 + MediaQuery.of(sheetContext).viewInsets.bottom),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const _SheetTitle('Agregar medicación'),
                const SizedBox(height: 16),
                _SheetField(controller: nameCtrl, hint: 'Nombre (ej. Antirretroviral)'),
                const SizedBox(height: 12),
                _SheetField(controller: doseCtrl, hint: 'Dosis (ej. 1 comprimido)'),
                const SizedBox(height: 12),
                _SheetPickerRow(
                  icon: Icons.schedule_rounded,
                  label: 'Hora',
                  value: time.format(sheetContext),
                  onTap: () async {
                    final picked = await showTimePicker(
                        context: sheetContext, initialTime: time);
                    if (picked != null) setSheet(() => time = picked);
                  },
                ),
                const SizedBox(height: 18),
                _SheetSaveButton(
                  label: 'Guardar',
                  onPressed: () async {
                    if (nameCtrl.text.trim().isEmpty) return;
                    await service.addMedication(
                      name: nameCtrl.text,
                      dose: doseCtrl.text,
                      hour: time.hour,
                      minute: time.minute,
                    );
                    if (sheetContext.mounted) Navigator.of(sheetContext).pop();
                  },
                ),
              ],
            ),
          );
        },
      );
    },
  );
  nameCtrl.dispose();
  doseCtrl.dispose();
}

Future<void> _showAddAppointment(
    BuildContext context, HealthService service) async {
  final titleCtrl = TextEditingController();
  final locationCtrl = TextEditingController();
  DateTime date = DateTime.now().add(const Duration(days: 1));
  TimeOfDay time = const TimeOfDay(hour: 10, minute: 0);

  await showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    backgroundColor: AppColors.surface,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
    ),
    builder: (sheetContext) {
      return StatefulBuilder(
        builder: (sheetContext, setSheet) {
          String dateLabel =
              '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
          return Padding(
            padding: EdgeInsets.fromLTRB(
                20, 18, 20, 18 + MediaQuery.of(sheetContext).viewInsets.bottom),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const _SheetTitle('Agregar cita'),
                const SizedBox(height: 16),
                _SheetField(controller: titleCtrl, hint: 'Motivo (ej. Control de carga viral)'),
                const SizedBox(height: 12),
                _SheetField(controller: locationCtrl, hint: 'Lugar (opcional)'),
                const SizedBox(height: 12),
                _SheetPickerRow(
                  icon: Icons.calendar_today_rounded,
                  label: 'Fecha',
                  value: dateLabel,
                  onTap: () async {
                    final picked = await showDatePicker(
                      context: sheetContext,
                      initialDate: date,
                      firstDate: DateTime.now(),
                      lastDate: DateTime.now().add(const Duration(days: 730)),
                    );
                    if (picked != null) setSheet(() => date = picked);
                  },
                ),
                const SizedBox(height: 10),
                _SheetPickerRow(
                  icon: Icons.schedule_rounded,
                  label: 'Hora',
                  value: time.format(sheetContext),
                  onTap: () async {
                    final picked = await showTimePicker(
                        context: sheetContext, initialTime: time);
                    if (picked != null) setSheet(() => time = picked);
                  },
                ),
                const SizedBox(height: 18),
                _SheetSaveButton(
                  label: 'Guardar',
                  onPressed: () async {
                    if (titleCtrl.text.trim().isEmpty) return;
                    final dt = DateTime(
                        date.year, date.month, date.day, time.hour, time.minute);
                    await service.addAppointment(
                      title: titleCtrl.text,
                      location: locationCtrl.text,
                      dateTime: dt,
                    );
                    if (sheetContext.mounted) Navigator.of(sheetContext).pop();
                  },
                ),
              ],
            ),
          );
        },
      );
    },
  );
  titleCtrl.dispose();
  locationCtrl.dispose();
}

Future<void> _logMood(
    BuildContext context, HealthService service, int mood, String label) async {
  final noteCtrl = TextEditingController();
  await showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    backgroundColor: AppColors.surface,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
    ),
    builder: (sheetContext) {
      return Padding(
        padding: EdgeInsets.fromLTRB(
            20, 18, 20, 18 + MediaQuery.of(sheetContext).viewInsets.bottom),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _SheetTitle('Te sientes: $label'),
            const SizedBox(height: 16),
            _SheetField(
              controller: noteCtrl,
              hint: '¿Quieres anotar algo? (opcional)',
              maxLines: 3,
            ),
            const SizedBox(height: 18),
            _SheetSaveButton(
              label: 'Registrar',
              onPressed: () async {
                await service.addSymptom(mood: mood, note: noteCtrl.text);
                if (sheetContext.mounted) Navigator.of(sheetContext).pop();
              },
            ),
          ],
        ),
      );
    },
  );
  noteCtrl.dispose();
  if (context.mounted) _snack(context, 'Registro guardado.');
}

// =============================================================================
// Widgets compartidos
// =============================================================================

class _PremiumUpsellBanner extends StatelessWidget {
  const _PremiumUpsellBanner();

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<bool>(
      stream: PremiumService().watchIsPremium(),
      builder: (context, snapshot) {
        final isPremium = snapshot.data ?? false;
        if (isPremium) return const SizedBox.shrink();
        return Padding(
          padding: const EdgeInsets.only(bottom: 14),
          child: Material(
            color: Colors.transparent,
            borderRadius: BorderRadius.circular(18),
            child: InkWell(
              borderRadius: BorderRadius.circular(18),
              onTap: () => context.push(AppRoutes.premium),
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [AppColors.primary, AppColors.primaryDark],
                  ),
                  borderRadius: BorderRadius.circular(18),
                ),
                child: Row(
                  children: const [
                    Icon(Icons.workspace_premium_rounded,
                        color: Colors.white, size: 26),
                    SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Adherencia con Premium',
                              style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w800,
                                  fontSize: 15)),
                          SizedBox(height: 2),
                          Text('Recordatorios y seguimiento avanzado',
                              style: TextStyle(
                                  color: Colors.white70, fontSize: 13)),
                        ],
                      ),
                    ),
                    Icon(Icons.chevron_right_rounded, color: Colors.white),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

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
                Text('Centros de salud cercanos',
                    style: TextStyle(
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary)),
                SizedBox(height: 2),
                Text('Encuentra pruebas, tratamiento y apoyo en el mapa',
                    style:
                        TextStyle(color: AppColors.textSecondary, fontSize: 13)),
              ],
            ),
          ),
          const Icon(Icons.chevron_right_rounded, color: AppColors.textSecondary),
        ],
      ),
    );
  }
}

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
        border: Border.all(color: AppColors.border),
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
        Text(text,
            style: const TextStyle(
                fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
      ],
    );
  }
}

class _WhiteButton extends StatelessWidget {
  const _WhiteButton(
      {required this.label, required this.icon, required this.onTap});

  final String label;
  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(999),
      child: InkWell(
        borderRadius: BorderRadius.circular(999),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 12),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 18, color: AppColors.primary),
              const SizedBox(width: 8),
              Text(label,
                  style: const TextStyle(
                      color: AppColors.primary,
                      fontWeight: FontWeight.w700,
                      fontSize: 14)),
            ],
          ),
        ),
      ),
    );
  }
}

class _AddButton extends StatelessWidget {
  const _AddButton({required this.label, required this.onTap});

  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return OutlinedButton.icon(
      onPressed: onTap,
      icon: const Icon(Icons.add_rounded, size: 18),
      label: Text(label),
      style: OutlinedButton.styleFrom(
        foregroundColor: AppColors.primary,
        side: const BorderSide(color: AppColors.border),
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(999)),
      ),
    );
  }
}

class _SheetTitle extends StatelessWidget {
  const _SheetTitle(this.text);
  final String text;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(text,
            style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w800,
                color: AppColors.textPrimary)),
        const Spacer(),
        IconButton(
          onPressed: () => Navigator.of(context).maybePop(),
          icon: const Icon(Icons.close_rounded, color: AppColors.textSecondary),
        ),
      ],
    );
  }
}

class _SheetField extends StatelessWidget {
  const _SheetField(
      {required this.controller, required this.hint, this.maxLines = 1});

  final TextEditingController controller;
  final String hint;
  final int maxLines;

  @override
  Widget build(BuildContext context) {
    final border = OutlineInputBorder(
      borderRadius: BorderRadius.circular(14),
      borderSide: const BorderSide(color: AppColors.border),
    );
    return TextField(
      controller: controller,
      maxLines: maxLines,
      style: const TextStyle(fontSize: 15, color: AppColors.textPrimary),
      decoration: InputDecoration(
        hintText: hint,
        filled: true,
        fillColor: AppColors.background,
        hintStyle: const TextStyle(color: AppColors.textSecondary, fontSize: 14),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        enabledBorder: border,
        border: border,
        focusedBorder: border.copyWith(
          borderSide: const BorderSide(color: AppColors.primary, width: 1.4),
        ),
      ),
    );
  }
}

class _SheetPickerRow extends StatelessWidget {
  const _SheetPickerRow({
    required this.icon,
    required this.label,
    required this.value,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final String value;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(14),
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        decoration: BoxDecoration(
          color: AppColors.background,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.border),
        ),
        child: Row(
          children: [
            Icon(icon, size: 20, color: AppColors.primary),
            const SizedBox(width: 12),
            Text(label,
                style: const TextStyle(
                    color: AppColors.textSecondary, fontSize: 14)),
            const Spacer(),
            Text(value,
                style: const TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 15,
                    fontWeight: FontWeight.w700)),
          ],
        ),
      ),
    );
  }
}

class _SheetSaveButton extends StatelessWidget {
  const _SheetSaveButton({required this.label, required this.onPressed});

  final String label;
  final Future<void> Function() onPressed;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 52,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        ),
        child: Text(label,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
      ),
    );
  }
}

void _snack(BuildContext context, String message) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(content: Text(message), duration: const Duration(seconds: 2)),
  );
}
