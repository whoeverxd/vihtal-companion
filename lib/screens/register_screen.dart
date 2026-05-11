import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../router/app_router.dart';
import '../services/auth_service.dart';
import '../theme.dart';
import '../widgets/brand_logo.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key, required this.authService});

  final AuthService authService;

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();

  DateTime? _birthDate;
  String? _country;
  bool _loading = false;
  String? _error;
  bool _obscure = true;

  static const _pageBackground = Color(0xFFFCF4F2);
  static const _cardColor = Color(0xFFFDEEEE);
  static const _fieldColor = Color(0xFFFCE8E7);
  static const _fieldBorder = Color(0xFFF3DADA);
  static const _titleColor = Color(0xFF372728);
  static const _bodyColor = Color(0xFF6D5251);
  static const _buttonColor = Color(0xFFE1061B);

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _firstNameController.dispose();
    _lastNameController.dispose();
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
              surface: AppColors.surfaceSoft,
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

  String _formatBirthDate(DateTime? date) {
    if (date == null) return 'mm/dd/yyyy';
    String two(int value) => value.toString().padLeft(2, '0');
    return '${two(date.month)}/${two(date.day)}/${date.year}';
  }

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

  @override
  Widget build(BuildContext context) {
    final media = MediaQuery.of(context);

    return Scaffold(
      backgroundColor: _pageBackground,
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final compact = constraints.maxHeight < 880;

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
                            color: const Color(0xFFCBB5B1).withValues(alpha: 0.38),
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
                            color: const Color(0xFFD8C4C0).withValues(alpha: 0.42),
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
                      constraints: const BoxConstraints(maxWidth: 440),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Center(child: BrandLogo(width: compact ? 210 : 250)),
                          SizedBox(height: compact ? 22 : 34),
                          Container(
                            padding: EdgeInsets.fromLTRB(
                              compact ? 18 : 26,
                              compact ? 24 : 34,
                              compact ? 18 : 26,
                              compact ? 24 : 30,
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
                                    'Crear cuenta',
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      color: _titleColor,
                                      fontSize: compact ? 30 : 36,
                                      fontWeight: FontWeight.w800,
                                    ),
                                  ),
                                  SizedBox(height: compact ? 10 : 16),
                                  const Text(
                                    'Completa tus datos para comenzar\ntu acompanamiento con VIHTAL.',
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      color: _bodyColor,
                                      fontSize: 18,
                                      height: 1.45,
                                    ),
                                  ),
                                  SizedBox(height: compact ? 26 : 34),
                                  _label('Nombre'),
                                  const SizedBox(height: 14),
                                  TextFormField(
                                    controller: _firstNameController,
                                    style: const TextStyle(
                                      color: _bodyColor,
                                      fontSize: 18,
                                    ),
                                    decoration: _fieldDecoration(
                                      hint: 'Ej. Ana',
                                      icon: Icons.person_outline_rounded,
                                    ),
                                    validator: (v) {
                                      if (v == null || v.trim().isEmpty) {
                                        return 'Ingresa tu nombre';
                                      }
                                      return null;
                                    },
                                  ),
                                  SizedBox(height: compact ? 20 : 26),
                                  _label('Apellidos'),
                                  const SizedBox(height: 14),
                                  TextFormField(
                                    controller: _lastNameController,
                                    style: const TextStyle(
                                      color: _bodyColor,
                                      fontSize: 18,
                                    ),
                                    decoration: _fieldDecoration(
                                      hint: 'Ej. Garcia',
                                      icon: Icons.badge_outlined,
                                    ),
                                    validator: (v) {
                                      if (v == null || v.trim().isEmpty) {
                                        return 'Ingresa tus apellidos';
                                      }
                                      return null;
                                    },
                                  ),
                                  SizedBox(height: compact ? 20 : 26),
                                  _label('Fecha de nacimiento'),
                                  const SizedBox(height: 14),
                                  InkWell(
                                    onTap: _pickBirthDate,
                                    borderRadius: BorderRadius.circular(999),
                                    child: InputDecorator(
                                      decoration: _fieldDecoration(
                                        hint: 'mm/dd/yyyy',
                                        icon: Icons.calendar_month_outlined,
                                        suffix: const Icon(
                                          Icons.calendar_today_outlined,
                                          color: _bodyColor,
                                          size: 24,
                                        ),
                                      ),
                                      child: Text(
                                        _formatBirthDate(_birthDate),
                                        style: TextStyle(
                                          color: _birthDate == null
                                              ? const Color(0xFF9C7E7B)
                                              : _bodyColor,
                                          fontSize: 18,
                                        ),
                                      ),
                                    ),
                                  ),
                                  SizedBox(height: compact ? 20 : 26),
                                  _label('Pais'),
                                  const SizedBox(height: 14),
                                  DropdownButtonFormField<String>(
                                    value: _country,
                                    decoration: _fieldDecoration(
                                      hint: 'Selecciona tu pais',
                                      icon: Icons.public,
                                    ),
                                    dropdownColor: _fieldColor,
                                    iconEnabledColor: _bodyColor,
                                    style: const TextStyle(
                                      color: _bodyColor,
                                      fontSize: 18,
                                    ),
                                    items: const [
                                      DropdownMenuItem(value: 'ES', child: Text('Espana')),
                                      DropdownMenuItem(value: 'MX', child: Text('Mexico')),
                                      DropdownMenuItem(value: 'CO', child: Text('Colombia')),
                                      DropdownMenuItem(value: 'AR', child: Text('Argentina')),
                                      DropdownMenuItem(value: 'US', child: Text('Estados Unidos')),
                                    ],
                                    onChanged: (v) => setState(() => _country = v),
                                    validator: (v) {
                                      if (v == null || v.isEmpty) {
                                        return 'Selecciona un pais';
                                      }
                                      return null;
                                    },
                                  ),
                                  SizedBox(height: compact ? 20 : 26),
                                  _label('Correo electronico'),
                                  const SizedBox(height: 14),
                                  TextFormField(
                                    controller: _emailController,
                                    keyboardType: TextInputType.emailAddress,
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
                                      if (value.isEmpty) return 'Ingresa tu correo';
                                      if (!value.contains('@')) return 'Correo invalido';
                                      return null;
                                    },
                                  ),
                                  SizedBox(height: compact ? 20 : 26),
                                  _label('Contrasena'),
                                  const SizedBox(height: 14),
                                  TextFormField(
                                    controller: _passwordController,
                                    obscureText: _obscure,
                                    style: const TextStyle(
                                      color: _bodyColor,
                                      fontSize: 24,
                                      letterSpacing: 2.6,
                                      height: 1,
                                    ),
                                    decoration: _fieldDecoration(
                                      hint: '••••••••',
                                      icon: Icons.lock_outline_rounded,
                                      suffix: IconButton(
                                        onPressed: () {
                                          setState(() => _obscure = !_obscure);
                                        },
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
                                        return 'Ingresa tu contrasena';
                                      }
                                      if (v.length < 6) {
                                        return 'Minimo 6 caracteres';
                                      }
                                      return null;
                                    },
                                  ),
                                  if (_error != null) ...[
                                    const SizedBox(height: 12),
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
                                  SizedBox(height: compact ? 20 : 24),
                                  SizedBox(
                                    height: compact ? 70 : 76,
                                    child: DecoratedBox(
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(999),
                                        boxShadow: [
                                          BoxShadow(
                                            color: _buttonColor.withValues(alpha: 0.26),
                                            blurRadius: 24,
                                            offset: const Offset(0, 10),
                                          ),
                                        ],
                                      ),
                                      child: ElevatedButton(
                                        onPressed: _loading ? null : _register,
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: _buttonColor,
                                          foregroundColor: Colors.white,
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(999),
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
                                                      AlwaysStoppedAnimation<Color>(
                                                    Colors.white,
                                                  ),
                                                ),
                                              )
                                            : const Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.center,
                                                children: [
                                                  Text(
                                                    'Registrar',
                                                    style: TextStyle(
                                                      fontSize: 20,
                                                      fontWeight: FontWeight.w800,
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
                          SizedBox(height: compact ? 20 : 28),
                          Wrap(
                            alignment: WrapAlignment.center,
                            crossAxisAlignment: WrapCrossAlignment.center,
                            spacing: 6,
                            runSpacing: 2,
                            children: [
                              const Text(
                                'Ya tienes una cuenta?',
                                style: TextStyle(
                                  color: _bodyColor,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w400,
                                ),
                              ),
                              TextButton(
                                onPressed: () => context.go(AppRoutes.login),
                                style: TextButton.styleFrom(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 4,
                                    vertical: 2,
                                  ),
                                  minimumSize: Size.zero,
                                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                ),
                                child: const Text(
                                  'Inicia sesion',
                                  style: TextStyle(
                                    color: AppColors.primary,
                                    fontSize: 16,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: compact ? 24 : 32),
                          const Text(
                            'EMPATIA  •  AUTORIDAD  •  SALUD',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: Color(0xFF9C8582),
                              fontSize: 12,
                              letterSpacing: 1.1,
                            ),
                          ),
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
