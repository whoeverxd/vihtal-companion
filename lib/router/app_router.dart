import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:go_router/go_router.dart';

import '../screens/home_screen.dart';
import '../screens/login_screen.dart';
import '../screens/register_screen.dart';
import '../screens/splash_screen.dart';
import '../screens/forgot_password_screen.dart';
import '../screens/support_screen.dart';
import '../screens/donate_screen.dart';
import '../services/auth_service.dart';

class AppRoutes {
  static const String splash = '/';
  static const String login = '/login';
  static const String register = '/register';
  static const String home = '/home';
  static const String forgotPassword = '/forgot-password';
  static const String support = '/support';
  static const String donate = '/donate';
}

class AuthStateNotifier extends ChangeNotifier {
  AuthStateNotifier(Stream<dynamic> stream) {
    _sub = stream.listen((_) => notifyListeners());
  }

  late final StreamSubscription<dynamic> _sub;

  @override
  void dispose() {
    _sub.cancel();
    super.dispose();
  }
}

GoRouter createAppRouter(AuthService authService) {
  final authNotifier = AuthStateNotifier(authService.authStateChanges());

  return GoRouter(
    initialLocation: AppRoutes.splash,
    refreshListenable: authNotifier,
    // Importante: GoRouter no gestiona el dispose de refreshListenable,
    // pero al ser algo global en esta app (mientras vive MyApp) está OK.
    // Si más adelante quieres, se puede mover a un Provider.
    redirect: (BuildContext context, GoRouterState state) {
      final user = authService.currentUser;
      final location = state.matchedLocation;

      final isGoingToLogin = location == AppRoutes.login;
      final isGoingToRegister = location == AppRoutes.register;
      final isGoingToSplash = location == AppRoutes.splash;

      if (user == null && location == AppRoutes.home) {
        return AppRoutes.login;
      }

      if (user != null && (isGoingToLogin || isGoingToRegister || isGoingToSplash)) {
        return AppRoutes.home;
      }

      return null;
    },
    routes: <RouteBase>[
      GoRoute(
        path: AppRoutes.splash,
        builder: (BuildContext context, GoRouterState state) => const SplashScreen(),
      ),
      GoRoute(
        path: AppRoutes.login,
        builder: (BuildContext context, GoRouterState state) => LoginScreen(authService: authService),
      ),
      GoRoute(
        path: AppRoutes.register,
        builder: (BuildContext context, GoRouterState state) => RegisterScreen(authService: authService),
      ),
      GoRoute(
        path: AppRoutes.home,
        builder: (BuildContext context, GoRouterState state) => HomeScreen(authService: authService),
      ),
      GoRoute(
        path: AppRoutes.forgotPassword,
        builder: (BuildContext context, GoRouterState state) => const ForgotPasswordScreen(),
      ),
      GoRoute(
        path: AppRoutes.support,
        builder: (BuildContext context, GoRouterState state) => const SupportScreen(),
      ),
      GoRoute(
        path: AppRoutes.donate,
        builder: (BuildContext context, GoRouterState state) => const DonateScreen(),
      ),
    ],
  );
}
