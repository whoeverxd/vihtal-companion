import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../router/app_router.dart';
import '../services/auth_service.dart';
import '../theme.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key, required this.authService});

  final AuthService authService;

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();

  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  DateTime? _birthDate;
  String? _country;

  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  bool _loading = false;
  String? _error;

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _pickBirthDate() async {
    final now = DateTime.now();
    final initial = _birthDate ?? DateTime(now.year - 18, now.month, now.day);

    final picked = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: DateTime(1900),
      lastDate: now,
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: Theme.of(context).colorScheme.copyWith(
                  primary: AppColors.primary,
                  surface: AppColors.darkCircle,
                ),
          ),
          child: child ?? const SizedBox.shrink(),
        );
      },
    );

    if (picked != null) {
      setState(() => _birthDate = picked);
    }
  }

  String _formatBirthDate(DateTime? d) {
    if (d == null) return 'mm/dd/yyyy';
    String two(int v) => v.toString().padLeft(2, '0');
    return '${two(d.month)}/${two(d.day)}/${d.year}';
  }

  Future<void> _register() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      await widget.authService.registerWithEmailPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text,
      );

      if (!mounted) return;
      context.go(AppRoutes.home);
    } catch (e) {
      setState(() => _error = e.toString());
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  InputDecoration _inputDecoration({required String hintText}) {
    return InputDecoration(
      hintText: hintText,
      filled: true,
      fillColor: AppColors.background,
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide(color: AppColors.primaryDark.withAlpha((0.25 * 255).round())),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide(color: AppColors.primary.withAlpha((0.65 * 255).round())),
      ),
    );
  }

  Widget _featureTile({required IconData icon, required String title, required String subtitle}) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.primary.withAlpha((0.06 * 255).round()),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.primary.withAlpha((0.12 * 255).round())),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: AppColors.primary.withAlpha((0.12 * 255).round()),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: AppColors.primary),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14)),
                const SizedBox(height: 4),
                Text(subtitle, style: TextStyle(color: Colors.white.withAlpha((0.65 * 255).round()), fontSize: 12)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.primary),
          onPressed: () {
            if (context.canPop()) {
              context.pop();
            } else {
              context.go(AppRoutes.login);
            }
          },
        ),
        title: const Text('VIHTAL Premium', style: TextStyle(fontWeight: FontWeight.w700)),
      ),
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Hero
                    Container(
                      height: 200,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(18),
                        border: Border.all(color: AppColors.primary.withAlpha((0.18 * 255).round())),
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            AppColors.primary.withAlpha((0.18 * 255).round()),
                            AppColors.background.withAlpha((0.90 * 255).round()),
                          ],
                        ),
                      ),
                      child: Stack(
                        children: [
                          Positioned.fill(
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(18),
                              child: Opacity(
                                opacity: 0.22,
                                child: Image.network(
                                  'https://lh3.googleusercontent.com/aida-public/AB6AXuC4DHygJIdZCn3y-ooJZ62l_fgv0naZjJN9DOMVqGCNzt4eRqdp8SL1UbZLi6ipwk-zrKGAh7JJ_XC8p-Zc6ZrQStJvQwt-vYwcz2SYQo1OffZu2cMHWOcnZL_R0bCHAAa0rNq114WRa0UCLmVXPbLzQw0Wyk6KZ694FJRqOIO8ZDYVEfT3dOyRjPfoOMaA8ZzGbqFfhQLaeE2C4Q3rkftQX85xv3D0bxHChXgYZMopQiKTz3RNLotfguCMDogmx_qsncPBiX6Yd5t8',
                                  fit: BoxFit.cover,
                                ),
                              ),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                  decoration: BoxDecoration(
                                    color: AppColors.primary,
                                    borderRadius: BorderRadius.circular(999),
                                  ),
                                  child: const Text(
                                    'PREMIUM ACCESS',
                                    style: TextStyle(fontSize: 11, fontWeight: FontWeight.w800, letterSpacing: 1.2),
                                  ),
                                ),
                                const SizedBox(height: 10),
                                const Text(
                                  'Unlock Full\nCompanion Access',
                                  style: TextStyle(fontSize: 26, fontWeight: FontWeight.w900, height: 1.1),
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  'Elevate your health journey with precision and care.',
                                  style: TextStyle(color: Colors.white.withAlpha((0.80 * 255).round())),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 18),

                    // Features
                    _featureTile(
                      icon: Icons.notifications_active,
                      title: 'Medication Reminders',
                      subtitle: 'Smart alerts so you never miss a dose.',
                    ),
                    const SizedBox(height: 10),
                    _featureTile(
                      icon: Icons.calendar_month,
                      title: 'Medical Calendar',
                      subtitle: 'Sync all appointments in one unified view.',
                    ),
                    const SizedBox(height: 10),
                    _featureTile(
                      icon: Icons.verified_user,
                      title: 'Encrypted History',
                      subtitle: 'Privacy-first health data storage.',
                    ),
                    const SizedBox(height: 10),
                    _featureTile(
                      icon: Icons.support_agent,
                      title: 'Expert Support',
                      subtitle: 'Direct access to health specialists.',
                    ),

                    const SizedBox(height: 18),
                  ],
                ),
              ),
            ),

            // Form section (rounded top like the design)
            SliverToBoxAdapter(
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white.withAlpha((0.03 * 255).round()),
                  borderRadius: const BorderRadius.only(topLeft: Radius.circular(22), topRight: Radius.circular(22)),
                  border: Border(top: BorderSide(color: AppColors.primary.withAlpha((0.12 * 255).round()))),
                ),
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 18, 16, 22),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('Nombre', style: TextStyle(color: Colors.white.withAlpha((0.85 * 255).round()), fontWeight: FontWeight.w700)),
                                  const SizedBox(height: 8),
                                  TextFormField(
                                    controller: _firstNameController,
                                    decoration: _inputDecoration(hintText: 'Ej. Juan'),
                                    validator: (v) => (v == null || v.trim().isEmpty) ? 'Requerido' : null,
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('Apellido', style: TextStyle(color: Colors.white.withAlpha((0.85 * 255).round()), fontWeight: FontWeight.w700)),
                                  const SizedBox(height: 8),
                                  TextFormField(
                                    controller: _lastNameController,
                                    decoration: _inputDecoration(hintText: 'Ej. Pérez'),
                                    validator: (v) => (v == null || v.trim().isEmpty) ? 'Requerido' : null,
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 14),

                        Text('Fecha de Nacimiento', style: TextStyle(color: Colors.white.withAlpha((0.85 * 255).round()), fontWeight: FontWeight.w700)),
                        const SizedBox(height: 8),
                        InkWell(
                          onTap: _pickBirthDate,
                          borderRadius: BorderRadius.circular(14),
                          child: InputDecorator(
                            decoration: _inputDecoration(hintText: '').copyWith(
                              suffixIcon: const Icon(Icons.calendar_today, size: 18, color: Colors.white70),
                            ),
                            child: Text(
                              _formatBirthDate(_birthDate),
                              style: TextStyle(color: Colors.white.withAlpha((0.85 * 255).round())),
                            ),
                          ),
                        ),
                        const SizedBox(height: 14),

                        Text('País', style: TextStyle(color: Colors.white.withAlpha((0.85 * 255).round()), fontWeight: FontWeight.w700)),
                        const SizedBox(height: 8),
                        DropdownButtonFormField<String>(
                          value: _country,
                          decoration: _inputDecoration(hintText: 'Selecciona tu país'),
                          dropdownColor: AppColors.darkCircle,
                          iconEnabledColor: Colors.white70,
                          items: const [
                            DropdownMenuItem(value: 'US', child: Text('Estados Unidos')),
                            DropdownMenuItem(value: 'ES', child: Text('España')),
                            DropdownMenuItem(value: 'MX', child: Text('México')),
                            DropdownMenuItem(value: 'CO', child: Text('Colombia')),
                            DropdownMenuItem(value: 'AR', child: Text('Argentina')),
                            DropdownMenuItem(value: 'CL', child: Text('Chile')),
                            DropdownMenuItem(value: 'VE', child: Text('Venezuela')),
                          ],
                          onChanged: (v) => setState(() => _country = v),
                          validator: (v) => (v == null || v.isEmpty) ? 'Selecciona un país' : null,
                        ),
                        const SizedBox(height: 14),

                        Text('Email Address', style: TextStyle(color: Colors.white.withAlpha((0.85 * 255).round()), fontWeight: FontWeight.w700)),
                        const SizedBox(height: 8),
                        TextFormField(
                          controller: _emailController,
                          decoration: _inputDecoration(hintText: 'name@example.com'),
                          keyboardType: TextInputType.emailAddress,
                          validator: (v) {
                            final value = (v ?? '').trim();
                            if (value.isEmpty) return 'Ingresa tu email';
                            final ok = RegExp(r'^[^@\\s]+@[^@\\s]+\\.[^@\\s]+$').hasMatch(value);
                            if (!ok) return 'Correo inválido';
                            return null;
                          },
                        ),
                        const SizedBox(height: 14),

                        Text('Password', style: TextStyle(color: Colors.white.withAlpha((0.85 * 255).round()), fontWeight: FontWeight.w700)),
                        const SizedBox(height: 8),
                        TextFormField(
                          controller: _passwordController,
                          decoration: _inputDecoration(hintText: '••••••••'),
                          obscureText: true,
                          validator: (v) {
                            if (v == null || v.isEmpty) return 'Ingresa una contraseña';
                            if (v.length < 6) return 'Mínimo 6 caracteres';
                            return null;
                          },
                        ),
                        const SizedBox(height: 18),

                        if (_error != null) ...[
                          Text(_error!, style: const TextStyle(color: Colors.redAccent)),
                          const SizedBox(height: 12),
                        ],

                        SizedBox(
                          height: 54,
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primary,
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                            ),
                            onPressed: _loading ? null : _register,
                            child: _loading
                                ? const SizedBox(
                                    width: 22,
                                    height: 22,
                                    child: CircularProgressIndicator(strokeWidth: 2),
                                  )
                                : const Text('Start 14-Day Free Trial', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 16)),
                          ),
                        ),

                        const SizedBox(height: 14),

                        Text(
                          'By subscribing, you agree to our Terms of Service and Privacy Policy. Your data is protected by AES-256 encryption.',
                          textAlign: TextAlign.center,
                          style: TextStyle(fontSize: 11, color: Colors.white.withAlpha((0.60 * 255).round())),
                        ),
                        const SizedBox(height: 14),
                        Divider(color: AppColors.primary.withAlpha((0.12 * 255).round())),
                        const SizedBox(height: 10),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text('Already have an account? ', style: TextStyle(color: Colors.white.withAlpha((0.75 * 255).round()))),
                            TextButton(
                              onPressed: () => context.go(AppRoutes.login),
                              child: const Text('Sign In', style: TextStyle(fontWeight: FontWeight.w800, color: AppColors.primary)),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),

            // Bottom spacing
            const SliverToBoxAdapter(child: SizedBox(height: 16)),
          ],
        ),
      ),
    );
  }
}
