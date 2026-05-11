import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../router/app_router.dart';
import '../services/auth_service.dart';
import '../theme.dart';
import '../widgets/brand_logo.dart';

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

  static const _pageBackground = Color(0xFFFCF4F2);
  static const _cardColor = Color(0xFFFDEEEE);
  static const _fieldColor = Color(0xFFFCE8E7);
  static const _fieldBorder = Color(0xFFF3DADA);
  static const _titleColor = Color(0xFF372728);
  static const _bodyColor = Color(0xFF6D5251);
  static const _buttonColor = Color(0xFFE1061B);

  InputDecoration _fieldDecoration({
    required String hint,
    required IconData icon,
    Widget? suffix,
  }) {
    final border = OutlineInputBorder(
      borderRadius: BorderRadius.circular(999),
      borderSide: const BorderSide(color: _fieldBorder),
    );

    return InputDecoration(
      hintText: hint,
      filled: true,
      fillColor: _fieldColor,
      contentPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 22),
      hintStyle: const TextStyle(
        color: Color(0xFF9C7E7B),
        fontSize: 18,
        fontWeight: FontWeight.w400,
      ),
      prefixIcon: Icon(icon, color: _bodyColor, size: 30),
      prefixIconConstraints: const BoxConstraints(minWidth: 64),
      suffixIcon: suffix,
      enabledBorder: border,
      focusedBorder: border.copyWith(
        borderSide: const BorderSide(color: AppColors.primary, width: 1.3),
      ),
      errorBorder: border.copyWith(
        borderSide: const BorderSide(color: Colors.redAccent),
      ),
      focusedErrorBorder: border.copyWith(
        borderSide: const BorderSide(color: Colors.redAccent, width: 1.3),
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

  Widget _label(String text) {
    return Text(
      text,
      style: const TextStyle(
        color: _titleColor,
        fontSize: 18,
        fontWeight: FontWeight.w700,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final media = MediaQuery.of(context);

    return Scaffold(
      backgroundColor: _pageBackground,
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final compact = constraints.maxHeight < 780;

            return Stack(
              children: [
                Positioned(
                  top: compact ? 8 : 18,
                  right: compact ? -95 : -110,
                  child: IgnorePointer(
                    child: BrandMark(size: compact ? 260 : 340, opacity: 0.055),
                  ),
                ),
                Positioned(
                  left: compact ? -185 : -215,
                  bottom: compact ? -165 : -195,
                  child: IgnorePointer(
                    child: Transform.rotate(
                      angle: -0.55,
                      child: Container(
                        width: compact ? 300 : 380,
                        height: compact ? 300 : 380,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: const Color(
                              0xFFCBB5B1,
                            ).withValues(alpha: 0.38),
                            width: compact ? 14 : 18,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                Positioned(
                  left: compact ? -120 : -130,
                  bottom: compact ? -120 : -135,
                  child: IgnorePointer(
                    child: Transform.rotate(
                      angle: -0.45,
                      child: Container(
                        width: compact ? 205 : 250,
                        height: compact ? 205 : 250,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: const Color(
                              0xFFD8C4C0,
                            ).withValues(alpha: 0.42),
                            width: compact ? 10 : 12,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                Center(
                  child: SingleChildScrollView(
                    padding: EdgeInsets.fromLTRB(
                      28,
                      compact ? 8 : 22,
                      28,
                      24 + media.viewInsets.bottom,
                    ),
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 430),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Center(child: BrandLogo(width: compact ? 210 : 250)),
                          SizedBox(height: compact ? 24 : 38),
                          Container(
                            padding: EdgeInsets.fromLTRB(
                              compact ? 18 : 26,
                              compact ? 26 : 36,
                              compact ? 18 : 26,
                              compact ? 24 : 32,
                            ),
                            decoration: BoxDecoration(
                              color: _cardColor,
                              borderRadius: BorderRadius.circular(38),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.04),
                                  blurRadius: 22,
                                  offset: const Offset(0, 8),
                                ),
                              ],
                            ),
                            child: Form(
                              key: _formKey,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: [
                                  Text(
                                    'Bienvenido de nuevo',
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      color: _titleColor,
                                      fontSize: compact ? 30 : 36,
                                      fontWeight: FontWeight.w800,
                                    ),
                                  ),
                                  SizedBox(height: compact ? 10 : 16),
                                  const Text(
                                    'Inicia sesión para continuar tu camino\nhacia el bienestar.',
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      color: _bodyColor,
                                      fontSize: 18,
                                      height: 1.45,
                                    ),
                                  ),
                                  SizedBox(height: compact ? 28 : 40),
                                  _label('Correo electrónico'),
                                  const SizedBox(height: 14),
                                  TextFormField(
                                    controller: _emailController,
                                    keyboardType: TextInputType.emailAddress,
                                    autofillHints: const [AutofillHints.email],
                                    style: const TextStyle(
                                      color: _bodyColor,
                                      fontSize: 18,
                                    ),
                                    decoration: _fieldDecoration(
                                      hint: 'nombre@ejemplo.com',
                                      icon: Icons.mail_outline_rounded,
                                    ),
                                    validator: (v) {
                                      final value = (v ?? '').trim();
                                      if (value.isEmpty)
                                        return 'Ingresa tu correo';
                                      if (!value.contains('@'))
                                        return 'Correo inválido';
                                      return null;
                                    },
                                  ),
                                  SizedBox(height: compact ? 24 : 30),
                                  _label('Contraseña'),
                                  const SizedBox(height: 14),
                                  TextFormField(
                                    controller: _passwordController,
                                    obscureText: _obscure,
                                    autofillHints: const [
                                      AutofillHints.password,
                                    ],
                                    style: const TextStyle(
                                      color: _bodyColor,
                                      fontSize: 26,
                                      letterSpacing: 2.8,
                                      height: 1,
                                    ),
                                    decoration: _fieldDecoration(
                                      hint: '••••••••',
                                      icon: Icons.lock_outline_rounded,
                                      suffix: IconButton(
                                        onPressed: () => setState(
                                          () => _obscure = !_obscure,
                                        ),
                                        icon: Icon(
                                          _obscure
                                              ? Icons.visibility_outlined
                                              : Icons.visibility_off_outlined,
                                          color: _bodyColor,
                                          size: 30,
                                        ),
                                      ),
                                    ),
                                    validator: (v) {
                                      if (v == null || v.isEmpty) {
                                        return 'Ingresa tu contraseña';
                                      }
                                      if (v.length < 6) {
                                        return 'Mínimo 6 caracteres';
                                      }
                                      return null;
                                    },
                                  ),
                                  const SizedBox(height: 18),
                                  Align(
                                    alignment: Alignment.centerRight,
                                    child: TextButton(
                                      onPressed: _loading
                                          ? null
                                          : () => context.go(
                                              AppRoutes.forgotPassword,
                                            ),
                                      style: TextButton.styleFrom(
                                        foregroundColor: AppColors.primary,
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 4,
                                          vertical: 6,
                                        ),
                                      ),
                                      child: const Text(
                                        '¿Olvidaste tu contraseña?',
                                        style: TextStyle(
                                          fontSize: 15,
                                          fontWeight: FontWeight.w700,
                                        ),
                                      ),
                                    ),
                                  ),
                                  if (_error != null) ...[
                                    const SizedBox(height: 4),
                                    Text(
                                      _error!,
                                      textAlign: TextAlign.center,
                                      style: const TextStyle(
                                        color: Colors.redAccent,
                                        fontSize: 13,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ],
                                  SizedBox(height: compact ? 18 : 22),
                                  SizedBox(
                                    height: compact ? 70 : 76,
                                    child: DecoratedBox(
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(
                                          999,
                                        ),
                                        boxShadow: [
                                          BoxShadow(
                                            color: _buttonColor.withValues(
                                              alpha: 0.26,
                                            ),
                                            blurRadius: 24,
                                            offset: const Offset(0, 10),
                                          ),
                                        ],
                                      ),
                                      child: ElevatedButton(
                                        onPressed: _loading ? null : _login,
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: _buttonColor,
                                          foregroundColor: Colors.white,
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(
                                              999,
                                            ),
                                          ),
                                          padding: EdgeInsets.zero,
                                        ),
                                        child: _loading
                                            ? const SizedBox(
                                                width: 24,
                                                height: 24,
                                                child: CircularProgressIndicator(
                                                  strokeWidth: 2.4,
                                                  valueColor:
                                                      AlwaysStoppedAnimation<
                                                        Color
                                                      >(Colors.white),
                                                ),
                                              )
                                            : Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.center,
                                                children: const [
                                                  Text(
                                                    'Iniciar sesión',
                                                    style: TextStyle(
                                                      fontSize: 20,
                                                      fontWeight:
                                                          FontWeight.w800,
                                                    ),
                                                  ),
                                                  SizedBox(width: 12),
                                                  Icon(
                                                    Icons.arrow_forward_rounded,
                                                    size: 28,
                                                  ),
                                                ],
                                              ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          SizedBox(height: compact ? 22 : 30),
                          Wrap(
                            alignment: WrapAlignment.center,
                            crossAxisAlignment: WrapCrossAlignment.center,
                            spacing: 6,
                            runSpacing: 2,
                            children: [
                              const Text(
                                '¿No tienes una cuenta?',
                                style: TextStyle(
                                  color: _bodyColor,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w400,
                                ),
                              ),
                              TextButton(
                                onPressed: () => context.go(AppRoutes.register),
                                style: TextButton.styleFrom(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 4,
                                    vertical: 2,
                                  ),
                                  minimumSize: Size.zero,
                                  tapTargetSize:
                                      MaterialTapTargetSize.shrinkWrap,
                                ),
                                child: const Text(
                                  'Regístrate',
                                  style: TextStyle(
                                    color: AppColors.primary,
                                    fontSize: 16,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: compact ? 28 : 38),
                          Wrap(
                            alignment: WrapAlignment.center,
                            spacing: 20,
                            runSpacing: 8,
                            children: const [
                              Text(
                                'POLÍTICA DE PRIVACIDAD',
                                style: TextStyle(
                                  color: Color(0xFF9C8582),
                                  fontSize: 12,
                                  letterSpacing: 1.1,
                                ),
                              ),
                              Text(
                                'TÉRMINOS DE SERVICIO',
                                style: TextStyle(
                                  color: Color(0xFF9C8582),
                                  fontSize: 12,
                                  letterSpacing: 1.1,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
