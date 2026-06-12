import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../router/app_router.dart';
import '../services/community_forum_service.dart';
import '../theme.dart';

class CreatePostScreen extends StatefulWidget {
  const CreatePostScreen({super.key});

  @override
  State<CreatePostScreen> createState() => _CreatePostScreenState();
}

class _CreatePostScreenState extends State<CreatePostScreen> {
  final _forumService = CommunityForumService();
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _bodyController = TextEditingController();
  final _linkController = TextEditingController();

  bool _anonymous = true;
  bool _loading = false;
  String _selectedCategoryKey = 'tratamientos';

  static const _categories = <_CategoryOption>[
    _CategoryOption(key: 'tratamientos', label: 'Tratamientos'),
    _CategoryOption(key: 'apoyo_emocional', label: 'Apoyo emocional'),
    _CategoryOption(key: 'estilo_vida', label: 'Estilo de vida'),
    _CategoryOption(key: 'historias_reales', label: 'Historias reales'),
  ];

  @override
  void dispose() {
    _titleController.dispose();
    _bodyController.dispose();
    _linkController.dispose();
    super.dispose();
  }

  _CategoryOption get _selectedCategory =>
      _categories.firstWhere((c) => c.key == _selectedCategoryKey);

  InputDecoration _fieldDecoration({required String hint}) {
    final border = OutlineInputBorder(
      borderRadius: BorderRadius.circular(14),
      borderSide: const BorderSide(color: AppColors.border),
    );
    return InputDecoration(
      hintText: hint,
      filled: true,
      fillColor: AppColors.background,
      hintStyle: const TextStyle(
        color: AppColors.textSecondary,
        fontSize: 15,
        height: 1.35,
      ),
      contentPadding: const EdgeInsets.all(14),
      enabledBorder: border,
      border: border,
      focusedBorder: border.copyWith(
        borderSide: const BorderSide(color: AppColors.primary, width: 1.4),
      ),
    );
  }

  Widget _categoryChip(_CategoryOption option) {
    final selected = option.key == _selectedCategoryKey;
    return ChoiceChip(
      label: Text(option.label),
      selected: selected,
      onSelected: (_) => setState(() => _selectedCategoryKey = option.key),
      labelStyle: TextStyle(
        color: selected ? Colors.white : AppColors.textSecondary,
        fontSize: 13,
        fontWeight: FontWeight.w600,
      ),
      selectedColor: AppColors.primary,
      backgroundColor: AppColors.surface,
      showCheckmark: false,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(999),
        side: BorderSide(
          color: selected ? AppColors.primary : AppColors.border,
        ),
      ),
    );
  }

  Future<void> _publishPost() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _loading = true);

    try {
      await _forumService.createPost(
        categoryKey: _selectedCategory.key,
        categoryLabel: _selectedCategory.label,
        title: _titleController.text,
        excerpt: _bodyController.text,
        anonymous: _anonymous,
        linkUrl:
            _linkController.text.trim().isEmpty ? null : _linkController.text.trim(),
      );

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Tu post fue publicado en Comunidad')),
      );
      context.pop();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('No se pudo publicar el post: $e')),
      );
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  void _back() {
    if (context.canPop()) {
      context.pop();
    } else {
      context.go(AppRoutes.community);
    }
  }

  @override
  Widget build(BuildContext context) {
    final media = MediaQuery.of(context);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          onPressed: _back,
          icon: const Icon(Icons.arrow_back_rounded, color: AppColors.primary),
        ),
        actions: [
          TextButton(
            onPressed: _loading ? null : _back,
            style: TextButton.styleFrom(foregroundColor: AppColors.textSecondary),
            child: const Text(
              'Cancelar',
              style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
      body: SafeArea(
        top: false,
        child: SingleChildScrollView(
          padding: EdgeInsets.fromLTRB(16, 4, 16, 24 + media.viewInsets.bottom),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Nuevo post',
                    style: Theme.of(context).textTheme.headlineMedium),
                const SizedBox(height: 6),
                const Text(
                  'Comparte tus vivencias, preguntas o consejos con la comunidad.',
                  style: TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 15,
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 22),
                const Text(
                  'CATEGORÍA',
                  style: TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 1.2,
                  ),
                ),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: _categories.map(_categoryChip).toList(),
                ),
                const SizedBox(height: 20),
                _CardBox(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      TextFormField(
                        controller: _titleController,
                        maxLines: 1,
                        style: const TextStyle(
                          color: AppColors.textPrimary,
                          fontSize: 17,
                          fontWeight: FontWeight.w700,
                        ),
                        decoration: _fieldDecoration(hint: 'Título de tu post…'),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Escribe un título';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: _bodyController,
                        maxLines: 9,
                        minLines: 6,
                        style: const TextStyle(
                          color: AppColors.textPrimary,
                          fontSize: 15,
                          height: 1.45,
                        ),
                        decoration: _fieldDecoration(
                          hint:
                              'Escribe lo que sientes, lo que has aprendido o lo que necesitas saber. Este es un espacio seguro para ti…',
                        ),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Escribe el contenido del post';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 10),
                      const Divider(color: AppColors.border, height: 1),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          TextButton.icon(
                            onPressed: () {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                    content: Text(
                                        'Añadir imagen pendiente de implementar.')),
                              );
                            },
                            icon: const Icon(Icons.image_outlined,
                                color: AppColors.primary, size: 20),
                            label: const Text('Imagen',
                                style: TextStyle(
                                    color: AppColors.primary,
                                    fontWeight: FontWeight.w700)),
                          ),
                          TextButton.icon(
                            onPressed: () {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                    content: Text(
                                        'Agregar enlace pendiente de implementar.')),
                              );
                            },
                            icon: const Icon(Icons.link_rounded,
                                color: AppColors.primary, size: 20),
                            label: const Text('Enlace',
                                style: TextStyle(
                                    color: AppColors.primary,
                                    fontWeight: FontWeight.w700)),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 14),
                _CardBox(
                  child: Row(
                    children: [
                      Switch.adaptive(
                        value: _anonymous,
                        onChanged: (value) =>
                            setState(() => _anonymous = value),
                        activeThumbColor: AppColors.primary,
                      ),
                      const SizedBox(width: 8),
                      const Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Publicar de forma anónima',
                              style: TextStyle(
                                color: AppColors.textPrimary,
                                fontSize: 15,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            SizedBox(height: 2),
                            Text(
                              'Tu identidad será protegida en la comunidad.',
                              style: TextStyle(
                                color: AppColors.textSecondary,
                                fontSize: 13,
                                height: 1.35,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 18),
                SizedBox(
                  width: double.infinity,
                  height: 54,
                  child: ElevatedButton(
                    onPressed: _loading ? null : _publishPost,
                    style: ElevatedButton.styleFrom(
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14)),
                    ),
                    child: _loading
                        ? const SizedBox(
                            width: 22,
                            height: 22,
                            child: CircularProgressIndicator(
                                strokeWidth: 2.4, color: Colors.white),
                          )
                        : const Text(
                            'Publicar',
                            style: TextStyle(
                                fontSize: 16, fontWeight: FontWeight.w700),
                          ),
                  ),
                ),
                const SizedBox(height: 18),
                _CardBox(
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: 40,
                        height: 40,
                        decoration: const BoxDecoration(
                          color: AppColors.surfaceSoft,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.shield_rounded,
                            color: AppColors.primary, size: 20),
                      ),
                      const SizedBox(width: 12),
                      const Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Tu seguridad es nuestra prioridad',
                              style: TextStyle(
                                color: AppColors.textPrimary,
                                fontSize: 15,
                                fontWeight: FontWeight.w800,
                                height: 1.2,
                              ),
                            ),
                            SizedBox(height: 6),
                            Text(
                              'VIHTAL es un espacio de apoyo mutuo. Los posts se '
                              'revisan para asegurar un ambiente libre de estigma. '
                              'La publicación anónima está siempre disponible para ti.',
                              style: TextStyle(
                                color: AppColors.textSecondary,
                                fontSize: 13,
                                height: 1.45,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Tarjeta blanca con borde, reutilizada en esta pantalla.
class _CardBox extends StatelessWidget {
  const _CardBox({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.border),
      ),
      child: child,
    );
  }
}

class _CategoryOption {
  const _CategoryOption({required this.key, required this.label});

  final String key;
  final String label;
}
