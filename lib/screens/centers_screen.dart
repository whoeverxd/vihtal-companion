import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:url_launcher/url_launcher.dart';

import '../models/health_center.dart';
import '../services/location_service.dart';
import '../theme.dart';
import '../widgets/vihtal_app_bar.dart';

/// Directorio de centros de salud con mapa real y ubicación del usuario.
class CentersScreen extends StatefulWidget {
  const CentersScreen({super.key, this.locationService});

  final LocationService? locationService;

  @override
  State<CentersScreen> createState() => _CentersScreenState();
}

class _CentersScreenState extends State<CentersScreen> {
  final MapController _mapController = MapController();
  late final LocationService _locationService =
      widget.locationService ?? LocationService();

  final List<HealthCenter> _centers = List.of(HealthCenter.demoData);
  String? _selectedId;

  LatLng? _userLocation;
  bool _locating = false;
  String? _locError;

  @override
  void initState() {
    super.initState();
    _locate();
  }

  Future<void> _locate() async {
    setState(() {
      _locating = true;
      _locError = null;
    });
    try {
      final loc = await _locationService.getCurrentLocation();
      _centers.sort((a, b) => _locationService
          .distanceKm(loc, a.location)
          .compareTo(_locationService.distanceKm(loc, b.location)));
      if (!mounted) return;
      setState(() => _userLocation = loc);
      _mapController.move(loc, 13);
    } catch (e) {
      if (!mounted) return;
      setState(() => _locError = e.toString());
    } finally {
      if (mounted) setState(() => _locating = false);
    }
  }

  double _distanceFor(HealthCenter c) => _userLocation != null
      ? _locationService.distanceKm(_userLocation!, c.location)
      : c.distanceKm;

  void _select(HealthCenter center, {bool moveMap = true}) {
    setState(() => _selectedId = center.id);
    if (moveMap) _mapController.move(center.location, 15);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: VihtalAppBar(
        showDonateAction: false,
        leading: BackButton(
            color: AppColors.primary,
            onPressed: () => Navigator.of(context).maybePop()),
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
                    initialCenter:
                        _userLocation ?? HealthCenter.defaultMapCenter,
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
                        if (_userLocation != null)
                          Marker(
                            point: _userLocation!,
                            width: 24,
                            height: 24,
                            child: const _UserDot(),
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
                if (_userLocation != null)
                  Positioned(
                    right: 12,
                    bottom: 12,
                    child: _RecenterButton(
                      onTap: () => _mapController.move(_userLocation!, 14),
                    ),
                  ),
              ],
            ),
          ),
          _LocationStatus(
            locating: _locating,
            error: _locError,
            located: _userLocation != null,
            onRetry: _locate,
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
                  distanceKm: _distanceFor(c),
                  selected: c.id == _selectedId,
                  onTap: () => _select(c),
                  onCall: () => _callCenter(context, c),
                  onDirections: () => _openDirections(context, c),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _LocationStatus extends StatelessWidget {
  const _LocationStatus({
    required this.locating,
    required this.error,
    required this.located,
    required this.onRetry,
  });

  final bool locating;
  final String? error;
  final bool located;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    Widget content;
    if (locating) {
      content = Row(
        children: const [
          SizedBox(
            width: 16,
            height: 16,
            child: CircularProgressIndicator(strokeWidth: 2),
          ),
          SizedBox(width: 10),
          Text('Buscando tu ubicación…',
              style: TextStyle(color: AppColors.textSecondary, fontSize: 13)),
        ],
      );
    } else if (error != null) {
      content = Row(
        children: [
          const Icon(Icons.location_off_rounded,
              size: 18, color: AppColors.textSecondary),
          const SizedBox(width: 8),
          Expanded(
            child: Text(error!,
                style: const TextStyle(
                    color: AppColors.textSecondary, fontSize: 12.5)),
          ),
          TextButton(
            onPressed: onRetry,
            style: TextButton.styleFrom(
                foregroundColor: AppColors.primary,
                visualDensity: VisualDensity.compact),
            child: const Text('Reintentar'),
          ),
        ],
      );
    } else if (located) {
      content = Row(
        children: const [
          Icon(Icons.near_me_rounded, size: 16, color: AppColors.primary),
          SizedBox(width: 8),
          Text('Ordenado por cercanía a ti',
              style: TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 13,
                  fontWeight: FontWeight.w600)),
        ],
      );
    } else {
      content = const SizedBox.shrink();
    }

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
      child: Row(
        children: [
          Expanded(child: content),
          Text('${_visibleCount(context)} centros',
              style: Theme.of(context).textTheme.labelLarge),
        ],
      ),
    );
  }

  int _visibleCount(BuildContext context) => HealthCenter.demoData.length;
}

class _UserDot extends StatelessWidget {
  const _UserDot();

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF1A73E8),
        shape: BoxShape.circle,
        border: Border.all(color: Colors.white, width: 3),
        boxShadow: const [
          BoxShadow(color: Colors.black26, blurRadius: 4, offset: Offset(0, 2)),
        ],
      ),
    );
  }
}

class _RecenterButton extends StatelessWidget {
  const _RecenterButton({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.surface,
      shape: const CircleBorder(),
      elevation: 2,
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: onTap,
        child: const Padding(
          padding: EdgeInsets.all(10),
          child: Icon(Icons.my_location_rounded,
              color: AppColors.primary, size: 22),
        ),
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
    required this.distanceKm,
    required this.selected,
    required this.onTap,
    required this.onCall,
    required this.onDirections,
  });

  final HealthCenter center;
  final double distanceKm;
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
              color: selected ? AppColors.primary : AppColors.border,
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
                text:
                    '${center.hours}  ·  ${distanceKm.toStringAsFixed(1)} km',
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
                        side: const BorderSide(color: AppColors.border),
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
        border: Border.all(color: AppColors.border),
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

/// Abre el marcador del teléfono con el número del centro.
Future<void> _callCenter(BuildContext context, HealthCenter center) async {
  final uri = Uri(scheme: 'tel', path: center.phone.replaceAll(' ', ''));
  if (!await launchUrl(uri) && context.mounted) {
    _snack(context, 'No se pudo abrir el marcador.');
  }
}

/// Abre la app de mapas externa con la ubicación del centro.
Future<void> _openDirections(BuildContext context, HealthCenter center) async {
  final lat = center.location.latitude;
  final lng = center.location.longitude;
  final uri = Uri.parse(
    'https://www.google.com/maps/search/?api=1&query=$lat,$lng',
  );
  if (!await launchUrl(uri, mode: LaunchMode.externalApplication) &&
      context.mounted) {
    _snack(context, 'No se pudo abrir el mapa.');
  }
}
