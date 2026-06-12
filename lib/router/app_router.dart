import 'dart:async';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../screens/home_screen.dart';
import '../screens/community_screen.dart';
import '../screens/ai_screen.dart';
import '../screens/health_screen.dart';
import '../screens/login_screen.dart';
import '../screens/register_screen.dart';
import '../screens/profile_screen.dart';
import '../screens/splash_screen.dart';
import '../screens/forgot_password_screen.dart';
import '../screens/support_screen.dart';
import '../screens/donate_screen.dart';
import '../screens/edit_profile_screen.dart';
import '../screens/centers_screen.dart';
import '../screens/article_screen.dart';
import '../screens/post_detail_screen.dart';

import '../screens/create_post_screen.dart';

import '../models/education_content.dart';
import '../services/community_forum_service.dart';

import '../services/auth_service.dart';
import '../theme.dart';
import '../widgets/vihtal_bottom_navigation_bar.dart';

class AppRoutes {
  static const String splash = '/';
  static const String login = '/login';
  static const String register = '/register';
  static const String home = '/home';
  static const String community = '/comunidad';
  static const String ai = '/ai';
  static const String health = '/health';
  static const String profile = '/profile';
  static const String editProfile = '/profile/edit';
  static const String createPost = '/comunidad/nuevo-post';
  static const String forgotPassword = '/forgot-password';
  static const String support = '/support';
  static const String donate = '/donate';
  static const String centers = '/centros';
  static const String article = '/educacion/articulo';
  static const String postDetail = '/comunidad/post';

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

  int indexFromLocation(String location) {
    if (location == AppRoutes.community) return 1;
    if (location == AppRoutes.ai) return 2;
    if (location == AppRoutes.health) return 3;
    if (location == AppRoutes.profile) return 4;
    return 0;
  }

  String routeFromIndex(int index) {
    switch (index) {
      case 0:
        return AppRoutes.home;
      case 1:
        return AppRoutes.community;
      case 2:
        return AppRoutes.ai;
      case 3:
        return AppRoutes.health;
      case 4:
        return AppRoutes.profile;
      default:
        return AppRoutes.home;
    }
  }

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
      final isProtectedTab =
          location == AppRoutes.home ||
          location == AppRoutes.community ||

          location == AppRoutes.createPost ||

          location == AppRoutes.ai ||
          location == AppRoutes.health ||
          location == AppRoutes.profile;

      if (user == null && isProtectedTab) {
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
      ShellRoute(
        builder: (BuildContext context, GoRouterState state, Widget child) {
          final currentIndex = indexFromLocation(state.matchedLocation);
          return Scaffold(
            backgroundColor: AppColors.background,
            body: SafeArea(child: child),
            bottomNavigationBar: VihtalBottomNavigationBar(
              currentIndex: currentIndex,
              onTap: (index) => context.go(routeFromIndex(index)),
            ),
          );
        },
        routes: <RouteBase>[
          GoRoute(
            path: AppRoutes.home,
            builder: (BuildContext context, GoRouterState state) => const HomeScreen(),
          ),
          GoRoute(
            path: AppRoutes.community,
            builder: (BuildContext context, GoRouterState state) => const CommunityScreen(),
          ),
          GoRoute(
            path: AppRoutes.ai,
            builder: (BuildContext context, GoRouterState state) => const AiScreen(),
          ),
          GoRoute(
            path: AppRoutes.health,
            builder: (BuildContext context, GoRouterState state) => const HealthScreen(),
          ),
          GoRoute(
            path: AppRoutes.profile,
            builder: (BuildContext context, GoRouterState state) => const ProfileScreen(),
          ),
        ],
      ),
      GoRoute(
        path: AppRoutes.editProfile,
        builder: (BuildContext context, GoRouterState state) => const EditProfileScreen(),
      ),
      GoRoute(
        path: AppRoutes.createPost,
        builder: (BuildContext context, GoRouterState state) => const CreatePostScreen(),
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
      GoRoute(
        path: AppRoutes.centers,
        builder: (BuildContext context, GoRouterState state) => const CentersScreen(),
      ),
      GoRoute(
        path: AppRoutes.article,
        builder: (BuildContext context, GoRouterState state) =>
            ArticleScreen(topic: state.extra as EduTopic),
      ),
      GoRoute(
        path: AppRoutes.postDetail,
        builder: (BuildContext context, GoRouterState state) =>
            PostDetailScreen(post: state.extra as ForumPost),
      ),
    ],
  );
}
