import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../router/app_router.dart';
import '../services/auth_service.dart';
import '../services/user_profile_service.dart';
import '../theme.dart';
import '../widgets/vihtal_app_bar.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  static const _pageBg = Color(0xFFF8F3F4);
  static const _title = Color(0xFF221619);
  static const _body = Color(0xFF4A3438);
  static const _cardSoft = Color(0xFFF3E8EA);
  static const _accent = Color(0xFFD5001A);

  final _profileService = UserProfileService();
  final _authService = AuthService();

  bool _loading = true;
  String _fullName = '';
  String _email = '';
  String? _photoUrl;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final profile = await _profileService.getCurrentUserProfile();
      if (!mounted) return;

      final name = profile.fullName.trim();
      setState(() {
        _fullName = name.isEmpty ? 'Usuario' : name;
        _email = profile.email;
        _photoUrl = profile.photoUrl;
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => _loading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('No se pudo cargar el perfil: $e')),
      );
    }
  }

  Future<void> _signOut() async {
    try {
      await _authService.signOut();
      if (!mounted) return;
      // El redirect del router nos llevará al login.
      context.go(AppRoutes.login);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('No se pudo cerrar sesión: $e')),
      );
    }
  }

  Widget _profileHero() {
    final avatar = ClipOval(
      child: SizedBox(
        width: 92,
        height: 92,
        child: _photoUrl != null && _photoUrl!.isNotEmpty
            ? Image.network(
                _photoUrl!,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) {
                  return const ColoredBox(
                    color: Color(0xFFEAB7AE),
                    child: Center(
                      child: Icon(Icons.person_rounded, size: 54, color: Color(0xFF4A3438)),
                    ),
                  );
                },
              )
            : const ColoredBox(
                color: Color(0xFFEAB7AE),
                child: Center(
                  child: Icon(Icons.person_rounded, size: 54, color: Color(0xFF4A3438)),
                ),
              ),
      ),
    );

    return Column(
      children: [
        Container(
          width: 118,
          height: 118,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: const Color(0xFFF5D2CF),
            border: Border.all(color: const Color(0xFFF0C2BE), width: 6),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.08),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Center(child: avatar),
        ),
        const SizedBox(height: 18),
        Text(
          _fullName,
          style: const TextStyle(
            color: _title,
            fontSize: 28,
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          _email,
          style: const TextStyle(color: _body, fontSize: 14),
        ),
      ],
    );
  }

  Widget _personalInfoTile() {
    return InkWell(
      onTap: () => context.push(AppRoutes.editProfile),
      borderRadius: BorderRadius.circular(999),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: _cardSoft,
          borderRadius: BorderRadius.circular(999),
          border: Border.all(color: const Color(0xFFEBD7DA)),
        ),
        child: const Row(
          children: [
            CircleAvatar(
              radius: 20,
              backgroundColor: Color(0xFFF0CDD1),
              child: Icon(Icons.person_outline_rounded, color: _accent),
            ),
            SizedBox(width: 14),
            Expanded(
              child: Text(
                'Información Personal',
                style: TextStyle(color: _title, fontSize: 18, fontWeight: FontWeight.w700),
              ),
            ),
            Icon(Icons.chevron_right_rounded, color: Color(0xFF8A7478), size: 30),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _pageBg,
      appBar: VihtalAppBar(
        backgroundColor: _pageBg,
        actions: [
          IconButton(
            onPressed: _signOut,
            icon: const Icon(Icons.logout_rounded, color: _body),
            tooltip: 'Cerrar sesión',
          ),
        ],
      ),
      body: SafeArea(
        top: false,
        child: _loading
            ? const Center(child: CircularProgressIndicator())
            : SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 18),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const SizedBox(height: 18),
                    Center(child: _profileHero()),
                    const SizedBox(height: 24),
                    _personalInfoTile(),
                    const SizedBox(height: 18),
                    SizedBox(
                      height: 56,
                      child: OutlinedButton.icon(
                        onPressed: _signOut,
                        icon: const Icon(Icons.logout_rounded, color: AppColors.primary),
                        label: const Text(
                          'Cerrar sesión',
                          style: TextStyle(
                            color: AppColors.primary,
                            fontSize: 16,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        style: OutlinedButton.styleFrom(
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(999)),
                          side: BorderSide(color: AppColors.primary.withValues(alpha: 0.35)),
                          backgroundColor: Colors.white.withValues(alpha: 0.35),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
      ),
    );
  }
}
