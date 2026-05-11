import 'dart:typed_data';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';

import '../services/user_profile_service.dart';
import '../theme.dart';

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

    setState(() => _uploadingPhoto = true);
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.image,
        allowMultiple: false,
        withData: true,
      );

      if (result == null || result.files.isEmpty) {
        return;
      }

      final file = result.files.single;
      final bytes = file.bytes;
      if (bytes == null) {
        throw StateError('No se pudo leer el archivo seleccionado');
      }

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

      final url = await _profileService.uploadProfilePhoto(
        bytes: bytes,
        contentType: contentType,
      );

      if (!mounted) return;
      setState(() {
        _photoUrl = url;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Foto de perfil actualizada')),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('No se pudo actualizar la foto: $e')),
      );
    } finally {
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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: AppColors.textPrimary,
            fontSize: 14,
            fontWeight: FontWeight.w800,
            letterSpacing: 1.2,
          ),
        ),
        const SizedBox(height: 10),
        TextField(
          controller: controller,
          enabled: enabled,
          style: TextStyle(
            color: enabled ? AppColors.textPrimary : AppColors.textSecondary,
            fontSize: 18,
            fontWeight: FontWeight.w500,
          ),
          decoration: InputDecoration(
            filled: true,
            fillColor: enabled
                ? AppColors.surfaceSoft.withValues(alpha: 0.55)
                : AppColors.surfaceSoft.withValues(alpha: 0.40),
            hintStyle: const TextStyle(color: AppColors.textSecondary),
            contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 18),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(999),
              borderSide: BorderSide.none,
            ),
            suffixIcon: suffixIcon,
          ),
        ),
        if (helperText != null) ...[
          const SizedBox(height: 8),
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
      body: SafeArea(
        child: _loading
            ? const Center(child: CircularProgressIndicator())
            : SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(16, 10, 16, 22),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        IconButton(
                          onPressed: () => Navigator.of(context).maybePop(),
                          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: AppColors.primary),
                          tooltip: 'Volver',
                        ),
                        const SizedBox(width: 6),
                        const Expanded(
                          child: Text(
                            'Editar Perfil',
                            style: TextStyle(
                              color: AppColors.textPrimary,
                              fontSize: 28,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ),
                        Container(
                          width: 44,
                          height: 44,
                          decoration: const BoxDecoration(
                            color: Color(0xFFF3D9DC),
                            shape: BoxShape.circle,
                          ),
                          child: IconButton(
                            onPressed: () {},
                            icon: const Icon(Icons.favorite_border_rounded, color: AppColors.primary),
                            tooltip: 'Favoritos',
                          ),
                        ),
                      ],
                    ),
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
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    gradient: RadialGradient(
                                      colors: [
                                        const Color(0xFFF1C7C2),
                                        const Color(0xFFE9B0A8).withValues(alpha: 0.75),
                                      ],
                                    ),
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
                                              errorBuilder: (_, __, ___) {
                                                return const ColoredBox(
                                                  color: Color(0xFFEAB7AE),
                                                  child: Center(
                                                    child: Icon(
                                                      Icons.person_rounded,
                                                      size: 64,
                                                      color: AppColors.accent,
                                                    ),
                                                  ),
                                                );
                                              },
                                            )
                                          else
                                            const ColoredBox(
                                              color: Color(0xFFEAB7AE),
                                              child: Center(
                                                child: Icon(
                                                  Icons.person_rounded,
                                                  size: 64,
                                                  color: AppColors.accent,
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
                              fontSize: 18,
                              fontWeight: FontWeight.w500,
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
                      height: 62,
                      child: ElevatedButton(
                        onPressed: _saving ? null : _save,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          foregroundColor: Colors.white,
                          elevation: 8,
                          shadowColor: Colors.black.withValues(alpha: 0.20),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(999)),
                        ),
                        child: _saving
                            ? const SizedBox(
                                width: 22,
                                height: 22,
                                child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                              )
                            : const Text(
                                'Guardar Cambios',
                                style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800),
                              ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.fromLTRB(18, 20, 18, 20),
                      decoration: BoxDecoration(
                        color: AppColors.surfaceSoft.withValues(alpha: 0.65),
                        borderRadius: BorderRadius.circular(28),
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  '¿Necesitas ayuda?',
                                  style: TextStyle(
                                    color: AppColors.textPrimary,
                                    fontSize: 20,
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                                SizedBox(height: 8),
                                Text(
                                  'Si tienes problemas para actualizar\ntus datos, contacta a nuestro\nequipo de soporte.',
                                  style: TextStyle(
                                    color: AppColors.textSecondary,
                                    fontSize: 14,
                                    height: 1.35,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 10),
                          Icon(Icons.support_agent_rounded, color: AppColors.subtle, size: 54),
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
