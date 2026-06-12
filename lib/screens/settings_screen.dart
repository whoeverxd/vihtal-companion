import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../router/app_router.dart';
import '../services/app_prefs.dart';
import '../services/auth_service.dart';
import '../theme.dart';
import '../widgets/vihtal_app_bar.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key, this.authService, this.prefs});

  final AuthService? authService;
  final AppPrefs? prefs;

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  late final AuthService _authService = widget.authService ?? AuthService();
  late final AppPrefs _prefs = widget.prefs ?? AppPrefs();

  bool _notifications = true;

  @override
  void initState() {
    super.initState();
    _prefs.notificationsEnabled().then((value) {
      if (mounted) setState(() => _notifications = value);
    });
  }

  Future<void> _logout() async {
    await _authService.signOut();
    if (mounted) context.go(AppRoutes.login);
  }

  void _showInfo(String title, String body) {
    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(title),
        content: SingleChildScrollView(child: Text(body)),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Cerrar'),
          ),
        ],
      ),
    );
  }

  Future<void> _confirmDelete() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Eliminar cuenta'),
        content: const Text(
          'Esta acción es permanente y borrará tu acceso. ¿Seguro que deseas '
          'eliminar tu cuenta?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            style: TextButton.styleFrom(foregroundColor: AppColors.primary),
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    try {
      await _authService.deleteAccount();
      if (mounted) context.go(AppRoutes.login);
    } catch (e) {
      if (!mounted) return;
      final msg = e.toString().contains('requires-recent-login')
          ? 'Por seguridad, vuelve a iniciar sesión y reinténtalo.'
          : 'No se pudo eliminar la cuenta: $e';
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
      if (e.toString().contains('requires-recent-login')) {
        await _authService.signOut();
        if (mounted) context.go(AppRoutes.login);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: VihtalAppBar(
        showDonateAction: false,
        showNotificationAction: false,
        leading: BackButton(
          color: AppColors.primary,
          onPressed: () => Navigator.of(context).maybePop(),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
        children: [
          Text('Ajustes', style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 18),
          const _SectionLabel('Cuenta'),
          _SettingsGroup(children: [
            _SettingsTile(
              icon: Icons.person_outline_rounded,
              title: 'Información personal',
              onTap: () => context.push(AppRoutes.editProfile),
            ),
            const _Sep(),
            _SettingsTile(
              icon: Icons.logout_rounded,
              title: 'Cerrar sesión',
              onTap: _logout,
            ),
          ]),
          const SizedBox(height: 22),
          const _SectionLabel('Preferencias'),
          _SettingsGroup(children: [
            _SwitchTile(
              icon: Icons.notifications_none_rounded,
              title: 'Notificaciones',
              value: _notifications,
              onChanged: (v) {
                setState(() => _notifications = v);
                _prefs.setNotificationsEnabled(v);
              },
            ),
          ]),
          const SizedBox(height: 22),
          const _SectionLabel('Privacidad'),
          _SettingsGroup(children: [
            _SettingsTile(
              icon: Icons.medical_information_outlined,
              title: 'Aviso médico',
              onTap: () => _showInfo(
                'Aviso médico',
                'VIHTAL ofrece información y orientación general sobre salud '
                    'sexual y VIH. NO sustituye la consulta, diagnóstico ni '
                    'tratamiento de un profesional de la salud. Ante síntomas '
                    'graves o una urgencia, acude de inmediato a un centro médico.',
              ),
            ),
            const _Sep(),
            _SettingsTile(
              icon: Icons.privacy_tip_outlined,
              title: 'Política de privacidad',
              onTap: () => _showInfo(
                'Política de privacidad',
                'Tus datos sensibles se manejan con confidencialidad y solo se '
                    'usan para brindarte el servicio. No compartimos información '
                    'personal con terceros sin tu consentimiento. (Documento '
                    'completo pendiente de publicar.)',
              ),
            ),
          ]),
          const SizedBox(height: 22),
          const _SectionLabel('Acerca de'),
          _SettingsGroup(children: const [
            _SettingsTile(
              icon: Icons.info_outline_rounded,
              title: 'Versión',
              trailing: Text('1.0.0',
                  style: TextStyle(color: AppColors.textSecondary)),
            ),
          ]),
          const SizedBox(height: 26),
          Center(
            child: TextButton.icon(
              onPressed: _confirmDelete,
              icon: const Icon(Icons.delete_outline_rounded, size: 18),
              label: const Text('Eliminar mi cuenta'),
              style: TextButton.styleFrom(foregroundColor: AppColors.primary),
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  const _SectionLabel(this.text);
  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 8),
      child: Text(
        text.toUpperCase(),
        style: const TextStyle(
          color: AppColors.textSecondary,
          fontSize: 12,
          fontWeight: FontWeight.w800,
          letterSpacing: 1.0,
        ),
      ),
    );
  }
}

class _SettingsGroup extends StatelessWidget {
  const _SettingsGroup({required this.children});
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(children: children),
    );
  }
}

class _Sep extends StatelessWidget {
  const _Sep();

  @override
  Widget build(BuildContext context) {
    return const Divider(height: 1, color: AppColors.border, indent: 56);
  }
}

class _SettingsTile extends StatelessWidget {
  const _SettingsTile({
    required this.icon,
    required this.title,
    this.onTap,
    this.trailing,
  });

  final IconData icon;
  final String title;
  final VoidCallback? onTap;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(18),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          children: [
            Icon(icon, color: AppColors.primary, size: 22),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                title,
                style: const TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            trailing ??
                (onTap != null
                    ? const Icon(Icons.chevron_right_rounded,
                        color: AppColors.textSecondary)
                    : const SizedBox.shrink()),
          ],
        ),
      ),
    );
  }
}

class _SwitchTile extends StatelessWidget {
  const _SwitchTile({
    required this.icon,
    required this.title,
    required this.value,
    required this.onChanged,
  });

  final IconData icon;
  final String title;
  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 4, 8, 4),
      child: Row(
        children: [
          Icon(icon, color: AppColors.primary, size: 22),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              title,
              style: const TextStyle(
                color: AppColors.textPrimary,
                fontSize: 15,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          Switch(
            value: value,
            activeThumbColor: AppColors.primary,
            onChanged: onChanged,
          ),
        ],
      ),
    );
  }
}
