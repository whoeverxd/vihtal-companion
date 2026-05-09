// Archivo placeholder.
//
// Importante: este archivo normalmente lo genera el CLI de FlutterFire con:
//   flutterfire configure
//
// Cuando lo ejecutes, reemplaza este archivo por el generado para tu proyecto
// e incluirá las opciones reales (API key, projectId, etc.) por plataforma.

import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart' show TargetPlatform, defaultTargetPlatform, kIsWeb;

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      return web;
    }
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.iOS:
        return ios;
      case TargetPlatform.macOS:
        return macos;
      case TargetPlatform.windows:
        return windows;
      case TargetPlatform.linux:
      case TargetPlatform.fuchsia:
        throw UnsupportedError('DefaultFirebaseOptions no está configurado para esta plataforma.');
    }
  }

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyAi3YjvkO-5Jzy03CGZwJgU4iN6cCHJZCg',
    appId: '1:659512196164:web:36d3921874af44e45fd011',
    messagingSenderId: '659512196164',
    projectId: 'vihtal-companion',
    authDomain: 'vihtal-companion.firebaseapp.com',
    storageBucket: 'vihtal-companion.firebasestorage.app',
    measurementId: 'G-NF69WLCX1D',
  );

  // NOTA: Estos valores son marcadores. Serán reemplazados por FlutterFire CLI.

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyBzcSbqM6vJzHqOCQKlIXUS7V9caSq4G0A',
    appId: '1:659512196164:android:18ecb257e18a0f555fd011',
    messagingSenderId: '659512196164',
    projectId: 'vihtal-companion',
    storageBucket: 'vihtal-companion.firebasestorage.app',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyDeOTXeCRUKgt8jUS0KQls47YgVXRWwQzQ',
    appId: '1:659512196164:ios:c69ab76f089a3ef25fd011',
    messagingSenderId: '659512196164',
    projectId: 'vihtal-companion',
    storageBucket: 'vihtal-companion.firebasestorage.app',
    iosBundleId: 'space.vihtal',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'REPLACE_ME',
    appId: 'REPLACE_ME',
    messagingSenderId: 'REPLACE_ME',
    projectId: 'REPLACE_ME',
  );

  static const FirebaseOptions windows = FirebaseOptions(
    apiKey: 'REPLACE_ME',
    appId: 'REPLACE_ME',
    messagingSenderId: 'REPLACE_ME',
    projectId: 'REPLACE_ME',
  );
}