import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';

/// Error de ubicación con un mensaje claro para mostrar al usuario.
class LocationException implements Exception {
  const LocationException(this.message);
  final String message;
  @override
  String toString() => message;
}

/// Obtiene la ubicación del usuario gestionando permisos y servicio.
class LocationService {
  Future<LatLng> getCurrentLocation() async {
    final enabled = await Geolocator.isLocationServiceEnabled();
    if (!enabled) {
      throw const LocationException('Activa la ubicación del dispositivo.');
    }

    var permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }
    if (permission == LocationPermission.denied) {
      throw const LocationException('Permiso de ubicación denegado.');
    }
    if (permission == LocationPermission.deniedForever) {
      throw const LocationException(
          'Permiso de ubicación bloqueado. Actívalo en los ajustes del sistema.');
    }

    final pos = await Geolocator.getCurrentPosition();
    return LatLng(pos.latitude, pos.longitude);
  }

  /// Distancia en kilómetros entre dos puntos.
  double distanceKm(LatLng a, LatLng b) =>
      Geolocator.distanceBetween(
        a.latitude,
        a.longitude,
        b.latitude,
        b.longitude,
      ) /
      1000;
}
