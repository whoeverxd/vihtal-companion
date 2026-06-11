import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../router/app_router.dart';
import '../services/auth_service.dart';
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
      color: const Color(0xFFF8F3F4),
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
                  backgroundColor: const Color(0xFFF0CDD1),
                  backgroundImage: (data.photoUrl != null && data.photoUrl!.isNotEmpty)
                      ? NetworkImage(data.photoUrl!)
                      : null,
                  child: (data.photoUrl == null || data.photoUrl!.isEmpty)
                      ? const Icon(
                          Icons.person_rounded,
                          size: 56,
                          color: AppColors.accent,
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
              InkWell(
                onTap: () => context.push(AppRoutes.editProfile),
                borderRadius: BorderRadius.circular(999),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF3E8EA),
                    borderRadius: BorderRadius.circular(999),
                    border: Border.all(color: const Color(0xFFEBD7DA)),
                  ),
                  child: const Row(
                    children: [
                      CircleAvatar(
                        radius: 20,
                        backgroundColor: Color(0xFFF0CDD1),
                        child: Icon(
                          Icons.person_outline_rounded,
                          color: AppColors.primary,
                        ),
                      ),
                      SizedBox(width: 14),
                      Expanded(
                        child: Text(
                          'Informacion personal',
                          style: TextStyle(
                            color: AppColors.textPrimary,
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                      Icon(
                        Icons.chevron_right_rounded,
                        color: Color(0xFF8A7478),
                        size: 30,
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 14),
              SizedBox(
                height: 54,
                child: ElevatedButton.icon(
                  onPressed: _logout,
                  icon: const Icon(Icons.logout_rounded),
                  label: const Text(
                    'Cerrar sesion',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
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
