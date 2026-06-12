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
                  surface: AppColors.surface,
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
    if (date == null) return 'dd/mm/aaaa';
    String two(int value) => value.toString().padLeft(2, '0');
    return '${two(date.day)}/${two(date.month)}/${date.year}';
  }

  InputDecoration _fieldDecoration({
    required String hint,
    required IconData icon,
    Widget? suffix,
  }) {
    final border = OutlineInputBorder(
      borderRadius: BorderRadius.circular(14),
      borderSide: const BorderSide(color: AppColors.border),
    );

    return InputDecoration(
      hintText: hint,
      filled: true,
      fillColor: AppColors.background,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      hintStyle: const TextStyle(color: AppColors.textSecondary, fontSize: 15),
      prefixIcon: Icon(icon, color: AppColors.textSecondary, size: 20),
      suffixIcon: suffix,
      enabledBorder: border,
      focusedBorder: border.copyWith(
        borderSide: const BorderSide(color: AppColors.primary, width: 1.4),
      ),
      errorBorder: border.copyWith(
        borderSide: const BorderSide(color: AppColors.primary),
      ),
      focusedErrorBorder: border.copyWith(
        borderSide: const BorderSide(color: AppColors.primary, width: 1.4),
      ),
    );
  }

  Widget _label(String text) {
    return Text(
      text,
      style: const TextStyle(
        color: AppColors.textPrimary,
        fontSize: 14,
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
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Stack(
          children: [
            Positioned(
              top: 12,
              right: -90,
              child: IgnorePointer(
                child: BrandMark(size: 300, opacity: 0.04),
              ),
            ),
            Center(
              child: SingleChildScrollView(
                padding: EdgeInsets.fromLTRB(24, 16, 24, 24 + media.viewInsets.bottom),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 440),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Center(child: BrandLogo(width: 180)),
                      const SizedBox(height: 24),
                      Container(
                        padding: const EdgeInsets.fromLTRB(22, 28, 22, 26),
                        decoration: BoxDecoration(
                          color: AppColors.surface,
                          borderRadius: BorderRadius.circular(24),
                          border: Border.all(color: AppColors.border),
                          boxShadow: kCardShadow,
                        ),
                        child: Form(
                          key: _formKey,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              Text(
                                'Crear cuenta',
                                textAlign: TextAlign.center,
                                style: Theme.of(context).textTheme.headlineMedium,
                              ),
                              const SizedBox(height: 8),
                              const Text(
                                'Completa tus datos para comenzar tu acompañamiento con VIHTAL.',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  color: AppColors.textSecondary,
                                  fontSize: 15,
                                  height: 1.4,
                                ),
                              ),
                              const SizedBox(height: 26),
                              _label('Nombre'),
                              const SizedBox(height: 8),
                              TextFormField(
                                controller: _firstNameController,
                                style: const TextStyle(
                                    color: AppColors.textPrimary, fontSize: 15),
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
                              const SizedBox(height: 16),
                              _label('Apellidos'),
                              const SizedBox(height: 8),
                              TextFormField(
                                controller: _lastNameController,
                                style: const TextStyle(
                                    color: AppColors.textPrimary, fontSize: 15),
                                decoration: _fieldDecoration(
                                  hint: 'Ej. García',
                                  icon: Icons.badge_outlined,
                                ),
                                validator: (v) {
                                  if (v == null || v.trim().isEmpty) {
                                    return 'Ingresa tus apellidos';
                                  }
                                  return null;
                                },
                              ),
                              const SizedBox(height: 16),
                              _label('Fecha de nacimiento'),
                              const SizedBox(height: 8),
                              InkWell(
                                onTap: _pickBirthDate,
                                borderRadius: BorderRadius.circular(14),
                                child: InputDecorator(
                                  decoration: _fieldDecoration(
                                    hint: 'dd/mm/aaaa',
                                    icon: Icons.calendar_month_outlined,
                                    suffix: const Icon(
                                      Icons.calendar_today_outlined,
                                      color: AppColors.textSecondary,
                                      size: 18,
                                    ),
                                  ),
                                  child: Text(
                                    _formatBirthDate(_birthDate),
                                    style: TextStyle(
                                      color: _birthDate == null
                                          ? AppColors.textSecondary
                                          : AppColors.textPrimary,
                                      fontSize: 15,
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 16),
                              _label('País'),
                              const SizedBox(height: 8),
                              DropdownButtonFormField<String>(
                                initialValue: _country,
                                decoration: _fieldDecoration(
                                  hint: 'Selecciona tu país',
                                  icon: Icons.public,
                                ),
                                dropdownColor: AppColors.surface,
                                iconEnabledColor: AppColors.textSecondary,
                                style: const TextStyle(
                                    color: AppColors.textPrimary, fontSize: 15),
                                items: const [
                                  DropdownMenuItem(value: 'VE', child: Text('Venezuela')),
                                  DropdownMenuItem(value: 'CO', child: Text('Colombia')),
                                  DropdownMenuItem(value: 'MX', child: Text('México')),
                                  DropdownMenuItem(value: 'AR', child: Text('Argentina')),
                                  DropdownMenuItem(value: 'ES', child: Text('España')),
                                  DropdownMenuItem(value: 'US', child: Text('Estados Unidos')),
                                ],
                                onChanged: (v) => setState(() => _country = v),
                                validator: (v) {
                                  if (v == null || v.isEmpty) {
                                    return 'Selecciona un país';
                                  }
                                  return null;
                                },
                              ),
                              const SizedBox(height: 16),
                              _label('Correo electrónico'),
                              const SizedBox(height: 8),
                              TextFormField(
                                controller: _emailController,
                                keyboardType: TextInputType.emailAddress,
                                style: const TextStyle(
                                    color: AppColors.textPrimary, fontSize: 15),
                                decoration: _fieldDecoration(
                                  hint: 'nombre@ejemplo.com',
                                  icon: Icons.mail_outline_rounded,
                                ),
                                validator: (v) {
                                  final value = (v ?? '').trim();
                                  if (value.isEmpty) return 'Ingresa tu correo';
                                  if (!value.contains('@')) return 'Correo inválido';
                                  return null;
                                },
                              ),
                              const SizedBox(height: 16),
                              _label('Contraseña'),
                              const SizedBox(height: 8),
                              TextFormField(
                                controller: _passwordController,
                                obscureText: _obscure,
                                style: const TextStyle(
                                    color: AppColors.textPrimary, fontSize: 15),
                                decoration: _fieldDecoration(
                                  hint: 'Mínimo 6 caracteres',
                                  icon: Icons.lock_outline_rounded,
                                  suffix: IconButton(
                                    onPressed: () =>
                                        setState(() => _obscure = !_obscure),
                                    icon: Icon(
                                      _obscure
                                          ? Icons.visibility_outlined
                                          : Icons.visibility_off_outlined,
                                      color: AppColors.textSecondary,
                                      size: 20,
                                    ),
                                  ),
                                ),
                                validator: (v) {
                                  if (v == null || v.isEmpty) {
                                    return 'Ingresa tu contraseña';
                                  }
                                  if (v.length < 6) return 'Mínimo 6 caracteres';
                                  return null;
                                },
                              ),
                              if (_error != null) ...[
                                const SizedBox(height: 14),
                                _ErrorText(_error!),
                              ],
                              const SizedBox(height: 20),
                              SizedBox(
                                height: 54,
                                child: ElevatedButton(
                                  onPressed: _loading ? null : _register,
                                  style: ElevatedButton.styleFrom(
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(14),
                                    ),
                                  ),
                                  child: _loading
                                      ? const SizedBox(
                                          width: 22,
                                          height: 22,
                                          child: CircularProgressIndicator(
                                            strokeWidth: 2.4,
                                            valueColor:
                                                AlwaysStoppedAnimation<Color>(
                                                    Colors.white),
                                          ),
                                        )
                                      : const Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            Text(
                                              'Registrarme',
                                              style: TextStyle(
                                                fontSize: 16,
                                                fontWeight: FontWeight.w700,
                                              ),
                                            ),
                                            SizedBox(width: 8),
                                            Icon(Icons.arrow_forward_rounded,
                                                size: 20),
                                          ],
                                        ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 22),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text(
                            '¿Ya tienes una cuenta?',
                            style: TextStyle(
                              color: AppColors.textSecondary,
                              fontSize: 14,
                            ),
                          ),
                          TextButton(
                            onPressed: () => context.go(AppRoutes.login),
                            style: TextButton.styleFrom(
                              foregroundColor: AppColors.primary,
                              padding: const EdgeInsets.symmetric(horizontal: 6),
                              minimumSize: Size.zero,
                              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                            ),
                            child: const Text(
                              'Inicia sesión',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),
                      const Text(
                        'EMPATÍA  •  CONFIANZA  •  SALUD',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 11,
                          letterSpacing: 1.0,
                        ),
                      ),
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

class _ErrorText extends StatelessWidget {
  const _ErrorText(this.message);

  final String message;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: AppColors.surfaceSoft,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          const Icon(Icons.error_outline_rounded,
              size: 18, color: AppColors.primary),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              message,
              style: const TextStyle(
                color: AppColors.primaryDark,
                fontSize: 12.5,
                fontWeight: FontWeight.w600,
                height: 1.3,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
