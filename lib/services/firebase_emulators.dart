import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';

/// Configura emuladores durante desarrollo local.
///
/// En web, suele ser la forma más rápida de evitar bloqueos por reglas/CORS
/// mientras desarrollas en localhost.
Future<void> configureFirebaseEmulatorsIfLocalhost() async {
  // Solo en debug. En release no tocamos endpoints.
  if (kReleaseMode) return;

  if (!kIsWeb) return;

  final uri = Uri.base;
  final isLocal = uri.host == 'localhost' || uri.host == '127.0.0.1';
  if (!isLocal) return;

  // Puertos por defecto de Firebase Emulator Suite.
  // Si usas otros, cámbialos aquí.
  const authHost = 'localhost';
  const authPort = 9099;
  const storageHost = 'localhost';
  const storagePort = 9199;

  try {
    FirebaseAuth.instance.useAuthEmulator(authHost, authPort);
    FirebaseStorage.instance.useStorageEmulator(storageHost, storagePort);
    debugPrint('[Emulators] usando Auth emulator en $authHost:$authPort');
    debugPrint('[Emulators] usando Storage emulator en $storageHost:$storagePort');
  } catch (e) {
    debugPrint('[Emulators] no se pudo configurar emuladores: $e');
  }
}

