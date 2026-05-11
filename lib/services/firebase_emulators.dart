import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';

/// Configura emuladores durante desarrollo local.
///
/// IMPORTANTE: por defecto NO conectamos Auth emulator porque rompe el login
/// si no estás corriendo Emulator Suite o si quieres autenticar contra Firebase real.
///
/// Si quieres usar Auth emulator, cambia [enableAuthEmulator] a true y asegúrate
/// de ejecutar `firebase emulators:start`.
Future<void> configureFirebaseEmulatorsIfLocalhost({
  bool enableStorageEmulator = true,
  bool enableAuthEmulator = false,
}) async {
  // Solo en debug. En release no tocamos endpoints.
  if (kReleaseMode) return;

  if (!kIsWeb) return;

  final uri = Uri.base;
  final isLocal = uri.host == 'localhost' || uri.host == '127.0.0.1';
  if (!isLocal) return;

  // Puertos por defecto de Firebase Emulator Suite.
  const authHost = 'localhost';
  const authPort = 9099;
  const storageHost = 'localhost';
  const storagePort = 9199;

  try {
    if (enableAuthEmulator) {
      FirebaseAuth.instance.useAuthEmulator(authHost, authPort);
      debugPrint('[Emulators] usando Auth emulator en $authHost:$authPort');
    } else {
      debugPrint('[Emulators] Auth emulator desactivado (usando Firebase real)');
    }

    if (enableStorageEmulator) {
      FirebaseStorage.instance.useStorageEmulator(storageHost, storagePort);
      debugPrint('[Emulators] usando Storage emulator en $storageHost:$storagePort');
    }
  } catch (e) {
    debugPrint('[Emulators] no se pudo configurar emuladores: $e');
  }
}
