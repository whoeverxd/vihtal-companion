import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../router/app_router.dart';
import '../services/auth_service.dart';
import '../services/premium_service.dart';
import '../services/user_profile_service.dart';
import '../theme.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _profileService = UserProfileService();
  final _authService = AuthService();
  final _premiumService = PremiumService();

  bool _loading = true;
  String? _error;
  _ProfileViewData? _data;

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final profile = await _profileService.getCurrentUserProfile();
      if (!mounted) return;

      final name = profile.fullName.trim().isEmpty ? 'Usuario' : profile.fullName.trim();
      final email = profile.email.trim();

      setState(() {
        _data = _ProfileViewData(
          name: name,
          email: email.isEmpty ? 'Sin correo' : email,
          photoUrl: profile.photoUrl,
        );
      });
    } catch (_) {
      // Fallback local desde auth actual cacheada
      final user = _authService.currentUser;
      if (!mounted) return;

      if (user != null) {
        final fallbackName = (user.displayName ?? '').trim();
        setState(() {
          _data = _ProfileViewData(
            name: fallbackName.isEmpty ? 'Usuario' : fallbackName,
            email: (user.email ?? '').isEmpty ? 'Sin correo' : user.email!,
            photoUrl: user.photoURL,
          );
        });
      } else {
        setState(() => _error = 'No se pudo cargar el perfil.');
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _logout() async {
    await _authService.signOut();
    if (!mounted) return;
    context.go(AppRoutes.login);
  }

  Widget _topActions(BuildContext context) {
    return Row(
      children: [
        IconButton(
          onPressed: () => context.push(AppRoutes.donate),
          icon: const Icon(
            Icons.favorite_border_rounded,
            color: AppColors.primary,
          ),
          tooltip: 'Donar',
        ),
        const Spacer(),
        Stack(
          clipBehavior: Clip.none,
          children: [
            IconButton(
              onPressed: () {},
              icon: const Icon(
                Icons.notifications_none_rounded,
                color: AppColors.textSecondary,
              ),
              tooltip: 'Notificaciones',
            ),
            Positioned(
              right: 6,
              top: 6,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: BorderRadius.circular(999),
                ),
                child: const Text(
                  '0',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final data = _data;

    return ColoredBox(
      color: AppColors.background,
      child: RefreshIndicator(
        onRefresh: _loadProfile,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 18, 16, 18),
          children: [
            _topActions(context),
            const SizedBox(height: 8),
            const Text(
              'Perfil',
              style: TextStyle(
                color: AppColors.textPrimary,
                fontSize: 30,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 22),
            if (_loading)
              const Center(
                child: Padding(
                  padding: EdgeInsets.all(24),
                  child: CircularProgressIndicator(),
                ),
              )
            else if (_error != null)
              Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Text(
                  _error!,
                  style: const TextStyle(
                    color: Colors.redAccent,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              )
            else if (data != null) ...[
              Center(
                child: CircleAvatar(
                  radius: 54,
                  backgroundColor: AppColors.surfaceSoft,
                  backgroundImage: (data.photoUrl != null && data.photoUrl!.isNotEmpty)
                      ? NetworkImage(data.photoUrl!)
                      : null,
                  child: (data.photoUrl == null || data.photoUrl!.isEmpty)
                      ? const Icon(
                          Icons.person_rounded,
                          size: 56,
                          color: AppColors.primary,
                        )
                      : null,
                ),
              ),
              const SizedBox(height: 14),
              Text(
                data.name,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 28,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                data.email,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 15,
                ),
              ),
              const SizedBox(height: 24),
              StreamBuilder<bool>(
                stream: _premiumService.watchIsPremium(),
                builder: (context, snapshot) {
                  return _PlanCard(isPremium: snapshot.data ?? false);
                },
              ),
              const SizedBox(height: 12),
              _ProfileTile(
                icon: Icons.person_outline_rounded,
                label: 'Información personal',
                onTap: () => context.push(AppRoutes.editProfile),
              ),
              const SizedBox(height: 12),
              _ProfileTile(
                icon: Icons.settings_outlined,
                label: 'Ajustes',
                onTap: () => context.push(AppRoutes.settings),
              ),
              const SizedBox(height: 24),
              SizedBox(
                height: 54,
                child: OutlinedButton.icon(
                  onPressed: _logout,
                  icon: const Icon(Icons.logout_rounded),
                  label: const Text(
                    'Cerrar sesión',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
                  ),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.primary,
                    side: const BorderSide(color: AppColors.border),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _ProfileViewData {
  const _ProfileViewData({
    required this.name,
    required this.email,
    this.photoUrl,
  });

  final String name;
  final String email;
  final String? photoUrl;
}

/// Tarjeta de plan actual (Gratis / Premium) con acceso a la pantalla Premium.
class _PlanCard extends StatelessWidget {
  const _PlanCard({required this.isPremium});

  final bool isPremium;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(18),
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: () => context.push(AppRoutes.premium),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            gradient: isPremium
                ? const LinearGradient(
                    colors: [AppColors.primary, AppColors.primaryDark],
                  )
                : null,
            color: isPremium ? null : AppColors.surface,
            borderRadius: BorderRadius.circular(18),
            border: isPremium ? null : Border.all(color: AppColors.border),
          ),
          child: Row(
            children: [
              Icon(
                Icons.workspace_premium_rounded,
                color: isPremium ? Colors.white : AppColors.primary,
                size: 28,
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      isPremium ? 'VIHTAL Premium' : 'Plan Gratis',
                      style: TextStyle(
                        color:
                            isPremium ? Colors.white : AppColors.textPrimary,
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      isPremium
                          ? 'Tienes todas las funciones activas'
                          : 'Hazte Premium para más funciones',
                      style: TextStyle(
                        color: isPremium
                            ? Colors.white70
                            : AppColors.textSecondary,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.chevron_right_rounded,
                color: isPremium ? Colors.white : AppColors.textSecondary,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Fila genérica de opción del perfil.
class _ProfileTile extends StatelessWidget {
  const _ProfileTile({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.surface,
      borderRadius: BorderRadius.circular(18),
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: AppColors.border),
          ),
          child: Row(
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: const BoxDecoration(
                  color: AppColors.surfaceSoft,
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: AppColors.primary),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Text(
                  label,
                  style: const TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              const Icon(Icons.chevron_right_rounded,
                  color: AppColors.textSecondary),
            ],
          ),
        ),
      ),
    );
  }
}
