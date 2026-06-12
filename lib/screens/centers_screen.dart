import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';

import '../models/health_center.dart';
import '../theme.dart';
import '../widgets/vihtal_app_bar.dart';

/// Directorio de centros de salud y laboratorios cercanos (sub-proyecto C).
///
/// MVP / placeholder: mapa real (flutter_map + OpenStreetMap, gratis y sin clave)
/// con marcadores de centros simulados y una lista debajo. La ubicación real del
/// usuario y los datos desde backend quedan como mejora posterior.
class CentersScreen extends StatefulWidget {
  const CentersScreen({super.key});

  @override
  State<CentersScreen> createState() => _CentersScreenState();
}

class _CentersScreenState extends State<CentersScreen> {
  final MapController _mapController = MapController();
  final List<HealthCenter> _centers = HealthCenter.demoData;
  String? _selectedId;

  void _select(HealthCenter center, {bool moveMap = true}) {
    setState(() => _selectedId = center.id);
    if (moveMap) {
      _mapController.move(center.location, 15);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: VihtalAppBar(
        showDonateAction: false,
        leading: BackButton(color: AppColors.primary, onPressed: () => Navigator.of(context).maybePop()),
      ),
      body: Column(
        children: [
          SizedBox(
            height: 280,
            child: Stack(
              children: [
                FlutterMap(
                  mapController: _mapController,
                  options: MapOptions(
                    initialCenter: HealthCenter.defaultMapCenter,
                    initialZoom: 13,
                    onTap: (_, _) => setState(() => _selectedId = null),
                  ),
                  children: [
                    TileLayer(
                      urlTemplate:
                          'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                      userAgentPackageName: 'com.vihtal.companion',
                    ),
                    MarkerLayer(
                      markers: [
                        for (final c in _centers)
                          Marker(
                            point: c.location,
                            width: 44,
                            height: 44,
                            alignment: Alignment.topCenter,
                            child: _MapPin(
                              selected: c.id == _selectedId,
                              onTap: () => _select(c, moveMap: false),
                            ),
                          ),
                      ],
                    ),
                  ],
                ),
                const Positioned(
                  left: 12,
                  bottom: 12,
                  child: _AttributionChip(),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 6),
            child: Row(
              children: [
                Text(
                  'Centros cercanos',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const Spacer(),
                Text(
                  '${_centers.length} resultados',
                  style: Theme.of(context).textTheme.labelLarge,
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView.separated(
              padding: const EdgeInsets.fromLTRB(16, 4, 16, 20),
              itemCount: _centers.length,
              separatorBuilder: (_, _) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final c = _centers[index];
                return _CenterCard(
                  center: c,
                  selected: c.id == _selectedId,
                  onTap: () => _select(c),
                  onCall: () => _snack(context, 'Llamando a ${c.name} (demo).'),
                  onDirections: () =>
                      _snack(context, 'Abriendo ruta a ${c.name} (demo).'),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _MapPin extends StatelessWidget {
  const _MapPin({required this.selected, required this.onTap});

  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Icon(
        Icons.location_on,
        size: selected ? 44 : 34,
        color: selected ? AppColors.primaryDark : AppColors.primary,
        shadows: const [
          Shadow(color: Colors.black26, blurRadius: 4, offset: Offset(0, 2)),
        ],
      ),
    );
  }
}

class _AttributionChip extends StatelessWidget {
  const _AttributionChip();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.85),
        borderRadius: BorderRadius.circular(6),
      ),
      child: const Text(
        '© OpenStreetMap',
        style: TextStyle(fontSize: 10, color: AppColors.textSecondary),
      ),
    );
  }
}

class _CenterCard extends StatelessWidget {
  const _CenterCard({
    required this.center,
    required this.selected,
    required this.onTap,
    required this.onCall,
    required this.onDirections,
  });

  final HealthCenter center;
  final bool selected;
  final VoidCallback onTap;
  final VoidCallback onCall;
  final VoidCallback onDirections;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.surface,
      borderRadius: BorderRadius.circular(18),
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: selected ? AppColors.primary : AppColors.subtle,
              width: selected ? 1.5 : 1,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Text(
                      center.name,
                      style: const TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 15,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  _TypePill(label: center.type.label),
                ],
              ),
              const SizedBox(height: 6),
              _IconLine(icon: Icons.place_outlined, text: center.address),
              const SizedBox(height: 3),
              _IconLine(
                icon: Icons.schedule_outlined,
                text: '${center.hours}  ·  ${center.distanceKm} km',
              ),
              const SizedBox(height: 10),
              Wrap(
                spacing: 6,
                runSpacing: 6,
                children: [
                  for (final s in center.services) _ServiceChip(label: s),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: onCall,
                      icon: const Icon(Icons.call_rounded, size: 18),
                      label: const Text('Llamar'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.primary,
                        side: const BorderSide(color: AppColors.subtle),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(999),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: onDirections,
                      icon: const Icon(Icons.directions_rounded, size: 18),
                      label: const Text('Cómo llegar'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _TypePill extends StatelessWidget {
  const _TypePill({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.surfaceSoft,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        style: const TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w700,
          color: AppColors.accent,
        ),
      ),
    );
  }
}

class _ServiceChip extends StatelessWidget {
  const _ServiceChip({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.subtle),
      ),
      child: Text(
        label,
        style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
      ),
    );
  }
}

class _IconLine extends StatelessWidget {
  const _IconLine({required this.icon, required this.text});

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 15, color: AppColors.textSecondary),
        const SizedBox(width: 6),
        Expanded(
          child: Text(
            text,
            style: const TextStyle(
              fontSize: 13,
              color: AppColors.textSecondary,
              height: 1.3,
            ),
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
