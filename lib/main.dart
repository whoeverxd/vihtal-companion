import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';

import 'firebase_options.dart';
import 'router/app_router.dart';
import 'services/auth_service.dart';
import 'services/firebase_emulators.dart';
import 'theme.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
    await configureFirebaseEmulatorsIfLocalhost();
  } catch (e, st) {
    // En tests/u otros entornos, a veces Firebase no está configurado.
    // Pero en ejecución real queremos ver el error.
    debugPrint('Firebase.initializeApp falló: $e');
    debugPrintStack(stackTrace: st);

    // En debug/profile, falla rápido para que el error sea evidente.
    assert(() {
      // ignore: only_throw_errors
      throw e;
    }());
  }

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final authService = AuthService();
    final router = createAppRouter(authService);

    return MaterialApp.router(
      title: 'VIHTAL Companion',
      debugShowCheckedModeBanner: false,
      theme: appTheme,
      routerConfig: router,
    );
  }
}
