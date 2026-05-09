import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../router/app_router.dart';
import '../services/auth_service.dart';
import '../theme.dart';

const bool _isFlutterTest = bool.fromEnvironment('FLUTTER_TEST');

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key, required this.authService});

  final AuthService authService;

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  bool _loading = false;
  String? _error;
  bool _obscure = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  InputDecoration _fieldDecoration({
    required String hint,
    required IconData icon,
    Widget? suffix,
  }) {
    return InputDecoration(
      hintText: hint,
      filled: true,
      fillColor: const Color(0xFF141723).withAlpha((0.65 * 255).round()),
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
      prefixIcon: Icon(icon, color: Colors.white.withAlpha((0.55 * 255).round())),
      suffixIcon: suffix,
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(18),
        borderSide: BorderSide(color: Colors.white.withAlpha((0.10 * 255).round())),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(18),
        borderSide: BorderSide(color: AppColors.primary.withAlpha((0.55 * 255).round())),
      ),
    );
  }

  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      await widget.authService.signInWithEmailPassword(
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

  Future<void> _resetPassword() async {
    final email = _emailController.text.trim();
    if (email.isEmpty || !email.contains('@')) {
      setState(() => _error = 'Ingresa un correo válido para recuperar tu contraseña.');
      return;
    }

    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      await widget.authService.sendPasswordResetEmail(email: email);
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Te enviamos un correo para restablecer la contraseña.')),
      );
    } catch (e) {
      setState(() => _error = e.toString());
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Widget _bottomImage() {
    // Placeholder decorativo (sin red) para mantener los tests deterministas.
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.white.withAlpha((0.06 * 255).round()),
            AppColors.primary.withAlpha((0.18 * 255).round()),
            Colors.black.withAlpha((0.10 * 255).round()),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Stack(
          children: [
            // Decorative blobs
            Positioned(
              top: -size.height * 0.10,
              left: -size.width * 0.12,
              child: Container(
                width: size.width * 0.55,
                height: size.width * 0.55,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.primary.withAlpha((0.14 * 255).round()),
                ),
              ),
            ),
            Positioned(
              bottom: -size.height * 0.10,
              right: -size.width * 0.12,
              child: Container(
                width: size.width * 0.55,
                height: size.width * 0.55,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.primary.withAlpha((0.08 * 255).round()),
                ),
              ),
            ),

            // Content
            Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 420),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const SizedBox(height: 8),
                      // Header/logo
                      Column(
                        children: [
                          Container(
                            width: 72,
                            height: 72,
                            decoration: BoxDecoration(
                              color: AppColors.primary.withAlpha((0.18 * 255).round()),
                              borderRadius: BorderRadius.circular(18),
                              border: Border.all(color: AppColors.primary.withAlpha((0.22 * 255).round())),
                            ),
                            child: const Icon(Icons.shield, color: AppColors.primary, size: 42),
                          ),
                          const SizedBox(height: 16),
                          const Text(
                            'VIHTAL Companion',
                            textAlign: TextAlign.center,
                            style: TextStyle(fontSize: 34, fontWeight: FontWeight.w900, height: 1.05),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Tu salud, nuestra prioridad y privacidad.',
                            textAlign: TextAlign.center,
                            style: TextStyle(fontSize: 16, color: Colors.white.withAlpha((0.60 * 255).round())),
                          ),
                        ],
                      ),

                      const SizedBox(height: 22),

                      // Card
                      Container(
                        padding: const EdgeInsets.all(18),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(22),
                          color: Colors.white.withAlpha((0.04 * 255).round()),
                          border: Border.all(color: Colors.white.withAlpha((0.10 * 255).round())),
                        ),
                        child: Form(
                          key: _formKey,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              const Text('Iniciar Sesión', style: TextStyle(fontSize: 30, fontWeight: FontWeight.w900)),
                              const SizedBox(height: 18),

                              Text('Correo electrónico', style: TextStyle(color: Colors.white.withAlpha((0.75 * 255).round()), fontWeight: FontWeight.w700)),
                              const SizedBox(height: 10),
                              TextFormField(
                                controller: _emailController,
                                keyboardType: TextInputType.emailAddress,
                                decoration: _fieldDecoration(hint: 'ejemplo@correo.com', icon: Icons.mail_outline),
                                validator: (v) {
                                  if (v == null || v.trim().isEmpty) return 'Ingresa tu correo';
                                  if (!v.contains('@')) return 'Correo inválido';
                                  return null;
                                },
                              ),

                              const SizedBox(height: 18),

                              Wrap(
                                alignment: WrapAlignment.spaceBetween,
                                crossAxisAlignment: WrapCrossAlignment.center,
                                runSpacing: 6,
                                children: [
                                  Text('Contraseña', style: TextStyle(color: Colors.white.withAlpha((0.75 * 255).round()), fontWeight: FontWeight.w700)),
                                  TextButton(
                                    onPressed: _loading ? null : () => context.go(AppRoutes.forgotPassword),
                                    child: const Text('¿Olvidaste tu contraseña?', style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.w800)),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              TextFormField(
                                controller: _passwordController,
                                obscureText: _obscure,
                                decoration: _fieldDecoration(
                                  hint: '••••••••',
                                  icon: Icons.lock_outline,
                                  suffix: IconButton(
                                    onPressed: () => setState(() => _obscure = !_obscure),
                                    icon: Icon(_obscure ? Icons.visibility : Icons.visibility_off, color: Colors.white.withAlpha((0.60 * 255).round())),
                                  ),
                                ),
                                validator: (v) {
                                  if (v == null || v.isEmpty) return 'Ingresa tu contraseña';
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
                                height: 58,
                                child: ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: AppColors.primary,
                                    foregroundColor: Colors.white,
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
                                  ),
                                  onPressed: _loading ? null : _login,
                                  child: _loading
                                      ? const SizedBox(width: 22, height: 22, child: CircularProgressIndicator(strokeWidth: 2))
                                      : const Row(
                                          mainAxisAlignment: MainAxisAlignment.center,
                                          children: [
                                            Text('Acceder', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900)),
                                            SizedBox(width: 10),
                                            Icon(Icons.login),
                                          ],
                                        ),
                                ),
                              ),

                              const SizedBox(height: 18),

                              Wrap(
                                alignment: WrapAlignment.center,
                                crossAxisAlignment: WrapCrossAlignment.center,
                                spacing: 10,
                                runSpacing: 6,
                                children: [
                                  Icon(Icons.verified_user, size: 18, color: Colors.white.withAlpha((0.55 * 255).round())),
                                  Text(
                                    'Conexión cifrada de extremo a extremo',
                                    textAlign: TextAlign.center,
                                    style: TextStyle(color: Colors.white.withAlpha((0.55 * 255).round())),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),

                      const SizedBox(height: 20),

                      // Footer link
                      Wrap(
                        alignment: WrapAlignment.center,
                        crossAxisAlignment: WrapCrossAlignment.center,
                        spacing: 0,
                        children: [
                          Text('¿No tienes una cuenta? ', style: TextStyle(color: Colors.white.withAlpha((0.65 * 255).round()))),
                          TextButton(
                            onPressed: () => context.go(AppRoutes.register),
                            child: const Text('Regístrate', style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.w900)),
                          ),
                        ],
                      ),

                      const SizedBox(height: 10),

                      // Bottom image
                      Container(
                        height: 140,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(18),
                          border: Border.all(color: Colors.white.withAlpha((0.08 * 255).round())),
                        ),
                        clipBehavior: Clip.antiAlias,
                        child: _bottomImage(),
                      ),

                      const SizedBox(height: 10),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
