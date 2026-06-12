import 'dart:typed_data';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../router/app_router.dart';
import '../services/user_profile_service.dart';
import '../theme.dart';
import '../widgets/vihtal_app_bar.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _profileService = UserProfileService();

  late final TextEditingController _nameController;
  late final TextEditingController _lastNameController;
  late final TextEditingController _emailController;

  bool _loading = true;
  bool _saving = false;
  bool _uploadingPhoto = false;

  String? _photoUrl;
  Uint8List? _localPhotoBytes;

  @override
  void initState() {
    super.initState();

    _nameController = TextEditingController();
    _lastNameController = TextEditingController();
    _emailController = TextEditingController();

    _load();
  }

  Future<void> _load() async {
    try {
      final profile = await _profileService.getCurrentUserProfile();
      if (!mounted) return;

      _photoUrl = profile.photoUrl;

      // Si en Firestore no hay first/last, intenta derivarlo del displayName.
      final derived = profile.displayName.trim().split(RegExp(r'\s+'));
      final derivedFirst = derived.isNotEmpty ? derived.first : '';
      final derivedLast = derived.length > 1 ? derived.sublist(1).join(' ') : '';

      _nameController.text = profile.firstName.isNotEmpty ? profile.firstName : derivedFirst;
      _lastNameController.text = profile.lastName.isNotEmpty ? profile.lastName : derivedLast;
      _emailController.text = profile.email;
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('No se pudieron cargar tus datos: $e')),
      );
    } finally {
      if (!mounted) return;
      setState(() => _loading = false);
    }
  }

  Future<void> _pickAndUploadPhoto() async {
    if (_uploadingPhoto) return;

    final started = DateTime.now();
    debugPrint('[EditProfile] pick photo: start');

    setState(() => _uploadingPhoto = true);
    try {
      debugPrint('[EditProfile] pick photo: opening file picker');
      final result = await FilePicker.platform.pickFiles(
        type: FileType.image,
        allowMultiple: false,
        withData: true,
      );

      if (result == null || result.files.isEmpty) {
        debugPrint('[EditProfile] pick photo: cancelled/empty result');
        return;
      }

      final file = result.files.single;
      debugPrint(
        '[EditProfile] pick photo: selected name=${file.name} ext=${file.extension} size=${file.size}',
      );

      final bytes = file.bytes;
      if (bytes == null) {
        debugPrint('[EditProfile] pick photo: bytes == null');
        throw StateError('No se pudo leer el archivo seleccionado');
      }
      debugPrint('[EditProfile] pick photo: bytes length=${bytes.length}');

      // Preview inmediato
      setState(() {
        _localPhotoBytes = bytes;
      });

      final extension = (file.extension ?? '').toLowerCase();
      final contentType = switch (extension) {
        'png' => 'image/png',
        'jpg' || 'jpeg' => 'image/jpeg',
        'webp' => 'image/webp',
        'gif' => 'image/gif',
        _ => 'application/octet-stream',
      };
      debugPrint('[EditProfile] pick photo: contentType=$contentType');

      debugPrint('[EditProfile] upload: start');
      final url = await _profileService
          .uploadProfilePhoto(
            bytes: bytes,
            contentType: contentType,
          )
          .timeout(const Duration(seconds: 60));

      debugPrint('[EditProfile] upload: done url=$url');

      if (!mounted) return;
      setState(() {
        _photoUrl = url;
        // Ya podemos liberar preview local (opcional)
        // _localPhotoBytes = null;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Foto de perfil actualizada')),
      );
    } catch (e, st) {
      debugPrint('[EditProfile] upload error: $e');
      debugPrintStack(stackTrace: st);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('No se pudo actualizar la foto: $e')),
      );
    } finally {
      final elapsed = DateTime.now().difference(started);
      debugPrint('[EditProfile] pick/upload: finally after ${elapsed.inMilliseconds}ms');
      if (!mounted) return;
      setState(() => _uploadingPhoto = false);
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _lastNameController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    FocusScope.of(context).unfocus();

    if (_saving) return;
    setState(() => _saving = true);

    try {
      await _profileService.updateProfile(
        firstName: _nameController.text,
        lastName: _lastNameController.text,
      );

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Cambios guardados')),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('No se pudieron guardar los cambios: $e')),
      );
    } finally {
      if (!mounted) return;
      setState(() => _saving = false);
    }
  }

  Widget _pillField({
    required String label,
    required TextEditingController controller,
    bool enabled = true,
    Widget? suffixIcon,
    String? helperText,
  }) {
    final border = OutlineInputBorder(
      borderRadius: BorderRadius.circular(14),
      borderSide: const BorderSide(color: AppColors.border),
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: AppColors.textPrimary,
            fontSize: 14,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          enabled: enabled,
          style: TextStyle(
            color: enabled ? AppColors.textPrimary : AppColors.textSecondary,
            fontSize: 15,
          ),
          decoration: InputDecoration(
            filled: true,
            fillColor: enabled ? AppColors.surface : AppColors.background,
            hintStyle: const TextStyle(color: AppColors.textSecondary),
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            enabledBorder: border,
            border: border,
            focusedBorder: border.copyWith(
              borderSide: const BorderSide(color: AppColors.primary, width: 1.4),
            ),
            disabledBorder: border,
            suffixIcon: suffixIcon,
          ),
        ),
        if (helperText != null) ...[
          const SizedBox(height: 6),
          Text(
            helperText,
            style: const TextStyle(
              color: AppColors.textSecondary,
              fontSize: 12,
            ),
          ),
        ],
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: VihtalAppBar(
        leading: IconButton(
          onPressed: () {
            if (context.canPop()) {
              context.pop();
            } else {
              context.go(AppRoutes.profile);
            }
          },
          icon: const Icon(
            Icons.arrow_back_ios_new_rounded,
            color: AppColors.primary,
          ),
          tooltip: 'Volver',
        ),
        showDonateAction: false,
      ),
      body: SafeArea(
        top: false,
        child: _loading
            ? const Center(child: CircularProgressIndicator())
            : SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(16, 10, 16, 22),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 18),
                    Center(
                      child: Column(
                        children: [
                          SizedBox(
                            width: 140,
                            height: 140,
                            child: Stack(
                              clipBehavior: Clip.none,
                              children: [
                                Container(
                                  decoration: const BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: AppColors.surfaceSoft,
                                  ),
                                  child: Padding(
                                    padding: const EdgeInsets.all(10),
                                    child: ClipOval(
                                      child: Stack(
                                        fit: StackFit.expand,
                                        children: [
                                          if (_localPhotoBytes != null)
                                            Image.memory(
                                              _localPhotoBytes!,
                                              fit: BoxFit.cover,
                                            )
                                          else if (_photoUrl != null && _photoUrl!.isNotEmpty)
                                            Image.network(
                                              _photoUrl!,
                                              fit: BoxFit.cover,
                                              errorBuilder: (_, _, _) {
                                                return const ColoredBox(
                                                  color: AppColors.surfaceSoft,
                                                  child: Center(
                                                    child: Icon(
                                                      Icons.person_rounded,
                                                      size: 64,
                                                      color: AppColors.primary,
                                                    ),
                                                  ),
                                                );
                                              },
                                            )
                                          else
                                            const ColoredBox(
                                              color: AppColors.surfaceSoft,
                                              child: Center(
                                                child: Icon(
                                                  Icons.person_rounded,
                                                  size: 64,
                                                  color: AppColors.primary,
                                                ),
                                              ),
                                            ),
                                          if (_uploadingPhoto)
                                            ColoredBox(
                                              color: Colors.black.withValues(alpha: 0.25),
                                              child: const Center(
                                                child: CircularProgressIndicator(color: Colors.white),
                                              ),
                                            ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                                Positioned(
                                  right: -2,
                                  bottom: -2,
                                  child: GestureDetector(
                                    onTap: _pickAndUploadPhoto,
                                    child: Container(
                                      width: 54,
                                      height: 54,
                                      decoration: BoxDecoration(
                                        color: AppColors.primary,
                                        shape: BoxShape.circle,
                                        boxShadow: [
                                          BoxShadow(
                                            color: Colors.black.withValues(alpha: 0.20),
                                            blurRadius: 10,
                                            offset: const Offset(0, 6),
                                          ),
                                        ],
                                      ),
                                      child: const Icon(Icons.photo_camera_outlined, color: Colors.white),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 14),
                          const Text(
                            'Cambiar foto de perfil',
                            style: TextStyle(
                              color: AppColors.primary,
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 28),
                    _pillField(label: 'NOMBRE', controller: _nameController),
                    const SizedBox(height: 22),
                    _pillField(label: 'APELLIDO', controller: _lastNameController),
                    const SizedBox(height: 22),
                    _pillField(
                      label: 'CORREO ELECTRÓNICO',
                      controller: _emailController,
                      enabled: false,
                      suffixIcon: const Icon(Icons.lock_outline_rounded, color: AppColors.textSecondary),
                      helperText: 'El correo no puede ser modificado por seguridad.',
                    ),
                    const SizedBox(height: 26),
                    SizedBox(
                      width: double.infinity,
                      height: 54,
                      child: ElevatedButton(
                        onPressed: _saving ? null : _save,
                        style: ElevatedButton.styleFrom(
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14)),
                        ),
                        child: _saving
                            ? const SizedBox(
                                width: 22,
                                height: 22,
                                child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                              )
                            : const Text(
                                'Guardar cambios',
                                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
                              ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppColors.surface,
                        borderRadius: BorderRadius.circular(18),
                        border: Border.all(color: AppColors.border),
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          const Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  '¿Necesitas ayuda?',
                                  style: TextStyle(
                                    color: AppColors.textPrimary,
                                    fontSize: 16,
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                                SizedBox(height: 6),
                                Text(
                                  'Si tienes problemas para actualizar tus datos, contacta a nuestro equipo de soporte.',
                                  style: TextStyle(
                                    color: AppColors.textSecondary,
                                    fontSize: 13,
                                    height: 1.4,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 12),
                          const Icon(Icons.support_agent_rounded,
                              color: AppColors.primary, size: 32),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
      ),
    );
  }
}
