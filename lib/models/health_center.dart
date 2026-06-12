import 'package:latlong2/latlong.dart';

/// Tipo de establecimiento del directorio.
enum CenterType { hospital, laboratorio, ong, centroPrueba }

extension CenterTypeLabel on CenterType {
  String get label {
    switch (this) {
      case CenterType.hospital:
        return 'Hospital';
      case CenterType.laboratorio:
        return 'Laboratorio';
      case CenterType.ong:
        return 'ONG';
      case CenterType.centroPrueba:
        return 'Centro de prueba';
    }
  }
}

/// Un centro de salud / laboratorio del directorio.
///
/// MVP / placeholder: los datos son simulados (ver [HealthCenter.demoData]).
/// Cuando se conecte el backend, vendrán de Firestore (o de una API de centros)
/// y la distancia se calculará contra la ubicación real del usuario.
class HealthCenter {
  const HealthCenter({
    required this.id,
    required this.name,
    required this.type,
    required this.address,
    required this.location,
    required this.phone,
    required this.hours,
    required this.distanceKm,
    required this.services,
  });

  final String id;
  final String name;
  final CenterType type;
  final String address;
  final LatLng location;
  final String phone;
  final String hours;
  final double distanceKm;
  final List<String> services;

  /// Centro del mapa por defecto (Caracas, Venezuela) hasta tener ubicación real.
  static final LatLng defaultMapCenter = LatLng(10.4880, -66.8792);

  /// Datos simulados para la demo. NO son centros reales.
  static final List<HealthCenter> demoData = <HealthCenter>[
    HealthCenter(
      id: 'huc',
      name: 'Hospital Universitario de Caracas',
      type: CenterType.hospital,
      address: 'Ciudad Universitaria, Los Chaguaramos',
      location: LatLng(10.4936, -66.8916),
      phone: '+58 212 000 0001',
      hours: 'Lun–Dom · 24 h',
      distanceKm: 1.2,
      services: ['Prueba VIH', 'Tratamiento', 'Urgencias'],
    ),
    HealthCenter(
      id: 'accion-solidaria',
      name: 'Acción Solidaria',
      type: CenterType.ong,
      address: 'Av. Andrés Bello, Maripérez',
      location: LatLng(10.5020, -66.8990),
      phone: '+58 212 000 0002',
      hours: 'Lun–Vie · 8:00–16:00',
      distanceKm: 2.4,
      services: ['Prueba gratuita', 'PrEP', 'Acompañamiento'],
    ),
    HealthCenter(
      id: 'lab-salud-sexual',
      name: 'Laboratorio Salud Sexual',
      type: CenterType.laboratorio,
      address: 'Av. Francisco de Miranda, Chacao',
      location: LatLng(10.4920, -66.8530),
      phone: '+58 212 000 0003',
      hours: 'Lun–Sáb · 7:00–15:00',
      distanceKm: 3.1,
      services: ['Prueba VIH', 'ITS', 'Carga viral'],
    ),
    HealthCenter(
      id: 'centro-prueba-gratuita',
      name: 'Centro de Prueba Gratuita',
      type: CenterType.centroPrueba,
      address: 'Parroquia La Candelaria',
      location: LatLng(10.5061, -66.9046),
      phone: '+58 212 000 0004',
      hours: 'Lun–Vie · 9:00–17:00',
      distanceKm: 3.8,
      services: ['Prueba rápida', 'Consejería'],
    ),
    HealthCenter(
      id: 'fundacion-vivir',
      name: 'Fundación Vivir',
      type: CenterType.ong,
      address: 'Av. Libertador, Bello Campo',
      location: LatLng(10.4795, -66.8665),
      phone: '+58 212 000 0005',
      hours: 'Lun–Vie · 8:30–15:30',
      distanceKm: 4.5,
      services: ['Apoyo emocional', 'Grupos', 'Orientación'],
    ),
  ];
}
