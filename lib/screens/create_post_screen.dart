import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../router/app_router.dart';
import '../services/community_forum_service.dart';
import '../theme.dart';
import '../widgets/brand_logo.dart';

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
    _CategoryOption(key: 'apoyo_emocional', label: 'Apoyo Emocional'),
    _CategoryOption(key: 'estilo_vida', label: 'Estilo de Vida'),
    _CategoryOption(key: 'historias_reales', label: 'Historias Reales'),
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

  InputDecoration _fieldDecoration({
    required String hint,
  }) {
    return InputDecoration(
      hintText: hint,
      filled: true,
      fillColor: const Color(0xFFFBEDEF),
      hintStyle: const TextStyle(
        color: Color(0xFFC3AEB3),
        fontSize: 18,
        height: 1.35,
        fontWeight: FontWeight.w500,
      ),
      contentPadding: const EdgeInsets.all(18),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(28),
        borderSide: const BorderSide(color: Color(0xFFF3D9DD)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(28),
        borderSide: const BorderSide(color: AppColors.primary, width: 1.4),
      ),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(28),
        borderSide: const BorderSide(color: Color(0xFFF3D9DD)),
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
        color: selected ? Colors.white : AppColors.textPrimary,
        fontSize: 15,
        fontWeight: FontWeight.w700,
      ),
      selectedColor: const Color(0xFFEA5B4B),
      backgroundColor: const Color(0xFFF7DADB),
      side: BorderSide.none,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(999)),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
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
        linkUrl: _linkController.text.trim().isEmpty ? null : _linkController.text.trim(),
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

  Widget _header() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 6, 16, 0),
      child: Row(
        children: [
          IconButton(
            onPressed: () {
              if (context.canPop()) {
                context.pop();
              } else {
                context.go(AppRoutes.community);
              }
            },
            icon: const Icon(Icons.arrow_back_rounded, color: AppColors.primary),
          ),
          const SizedBox(width: 2),
          const Text(
            'Serene',
            style: TextStyle(
              color: AppColors.primary,
              fontSize: 28,
              fontWeight: FontWeight.w800,
            ),
          ),
          const Spacer(),
          TextButton(
            onPressed: _loading ? null : () => context.pop(),
            child: const Text(
              'Cancelar',
              style: TextStyle(
                color: AppColors.textPrimary,
                fontSize: 18,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _bottomNavigation() {
    return Container(
      margin: const EdgeInsets.fromLTRB(12, 0, 12, 10),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(26),
        border: Border.all(color: AppColors.subtle),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 14,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: NavigationBar(
        height: 74,
        elevation: 0,
        backgroundColor: Colors.transparent,
        indicatorColor: const Color(0xFFF5C7CB),
        selectedIndex: 2,
        labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
        onDestinationSelected: (index) {
          switch (index) {
            case 0:
              context.go(AppRoutes.home);
              break;
            case 1:
              context.go(AppRoutes.community);
              break;
            case 2:
              break;
            case 3:
              context.go(AppRoutes.profile);
              break;
          }
        },
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home_rounded),
            label: 'Inicio',
          ),
          NavigationDestination(
            icon: Icon(Icons.location_on_outlined),
            selectedIcon: Icon(Icons.location_on_rounded),
            label: 'Centros',
          ),
          NavigationDestination(
            icon: Icon(Icons.edit_note_outlined),
            selectedIcon: Icon(Icons.edit_note_rounded),
            label: 'Post',
          ),
          NavigationDestination(
            icon: Icon(Icons.person_outline_rounded),
            selectedIcon: Icon(Icons.person_rounded),
            label: 'Perfil',
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final media = MediaQuery.of(context);

    return Scaffold(
      backgroundColor: const Color(0xFFF9EEF0),
      body: SafeArea(
        child: Stack(
          children: [
            Positioned(
              top: -10,
              right: -18,
              child: IgnorePointer(
                child: BrandMark(size: 150, opacity: 0.09),
              ),
            ),
            SingleChildScrollView(
              padding: EdgeInsets.fromLTRB(16, 4, 16, 24 + media.viewInsets.bottom),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _header(),
                    const SizedBox(height: 10),
                    const Text(
                      'Nuevo Post',
                      style: TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 34,
                        fontWeight: FontWeight.w800,
                        letterSpacing: -0.5,
                      ),
                    ),
                    const SizedBox(height: 10),
                    const Text(
                      'Comparte tus vivencias, preguntas o\nconsejos con la comunidad.',
                      style: TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 18,
                        height: 1.45,
                      ),
                    ),
                    const SizedBox(height: 24),
                    const Text(
                      'SELECCIONA UNA CATEGORÍA',
                      style: TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 13,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 1.4,
                      ),
                    ),
                    const SizedBox(height: 14),
                    Wrap(
                      spacing: 12,
                      runSpacing: 12,
                      children: _categories.map(_categoryChip).toList(),
                    ),
                    const SizedBox(height: 22),
                    Container(
                      padding: const EdgeInsets.all(18),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFBEDEF),
                        borderRadius: BorderRadius.circular(30),
                        border: Border.all(color: const Color(0xFFF2D7DA)),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          TextFormField(
                            controller: _titleController,
                            maxLines: 1,
                            style: const TextStyle(
                              color: AppColors.textPrimary,
                              fontSize: 24,
                              fontWeight: FontWeight.w700,
                            ),
                            decoration: _fieldDecoration(
                              hint: 'Título de tu post...',
                            ),
                            validator: (value) {
                              if (value == null || value.trim().isEmpty) {
                                return 'Escribe un título';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 14),
                          TextFormField(
                            controller: _bodyController,
                            maxLines: 10,
                            minLines: 8,
                            style: const TextStyle(
                              color: AppColors.textPrimary,
                              fontSize: 18,
                              height: 1.45,
                            ),
                            decoration: _fieldDecoration(
                              hint:
                                  'Escribe lo que sientes, lo que has aprendido o lo que necesitas saber. Este es un espacio seguro para ti...',
                            ),
                            validator: (value) {
                              if (value == null || value.trim().isEmpty) {
                                return 'Escribe el contenido del post';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 18),
                          const Divider(color: Color(0xFFF0D7DA)),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              TextButton.icon(
                                onPressed: () {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(content: Text('Añadir imagen pendiente de implementar.')),
                                  );
                                },
                                icon: const Icon(Icons.image_outlined, color: AppColors.primary),
                                label: const Text(
                                  'Añadir imagen',
                                  style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.w700),
                                ),
                              ),
                              const SizedBox(width: 10),
                              TextButton.icon(
                                onPressed: () {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(content: Text('Agregar enlace pendiente de implementar.')),
                                  );
                                },
                                icon: const Icon(Icons.link_rounded, color: AppColors.primary),
                                label: const Text(
                                  'Enlace',
                                  style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.w700),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 18),
                    Container(
                      padding: const EdgeInsets.all(18),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFBEDEF),
                        borderRadius: BorderRadius.circular(30),
                        border: Border.all(color: const Color(0xFFF2D7DA)),
                      ),
                      child: Row(
                        children: [
                          Switch.adaptive(
                            value: _anonymous,
                            onChanged: (value) => setState(() => _anonymous = value),
                            activeThumbColor: AppColors.primary,
                          ),
                          const SizedBox(width: 12),
                          const Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Publicar de forma anónima',
                                  style: TextStyle(
                                    color: AppColors.textPrimary,
                                    fontSize: 18,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                                SizedBox(height: 4),
                                Text(
                                  'Tu identidad será protegida en la comunidad.',
                                  style: TextStyle(
                                    color: AppColors.textSecondary,
                                    fontSize: 14,
                                    height: 1.35,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 14),
                    SizedBox(
                      width: double.infinity,
                      height: 62,
                      child: ElevatedButton(
                        onPressed: _loading ? null : _publishPost,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(999)),
                        ),
                        child: _loading
                            ? const SizedBox(
                                width: 22,
                                height: 22,
                                child: CircularProgressIndicator(strokeWidth: 2.4, color: Colors.white),
                              )
                            : const Text(
                                'Publicar  >',
                                style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800),
                              ),
                      ),
                    ),
                    const SizedBox(height: 18),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.fromLTRB(18, 18, 18, 18),
                      decoration: BoxDecoration(
                        color: const Color(0xFFE2E9F2),
                        borderRadius: BorderRadius.circular(30),
                      ),
                      child: const Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          CircleAvatar(
                            radius: 20,
                            backgroundColor: Color(0xFFB8D0E9),
                            child: Icon(Icons.shield_rounded, color: Color(0xFF0D5C98), size: 20),
                          ),
                          SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Tu seguridad es\nnuestra prioridad',
                                  style: TextStyle(
                                    color: AppColors.textPrimary,
                                    fontSize: 20,
                                    fontWeight: FontWeight.w800,
                                    height: 1.2,
                                  ),
                                ),
                                SizedBox(height: 8),
                                Text(
                                  'Recuerda que VIHTAL es un espacio de apoyo mutuo.\nTodos los posts son revisados para asegurar un ambiente libre de estigma y discriminación. Si te sientes vulnerable, el botón de publicación anónima está siempre disponible para ti.',
                                  style: TextStyle(
                                    color: AppColors.textSecondary,
                                    fontSize: 14,
                                    height: 1.5,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 18),
                    Container(
                      height: 170,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(30),
                        gradient: const LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [Color(0xFFF0C7C4), Color(0xFFDDA8A1)],
                        ),
                      ),
                      child: Stack(
                        children: [
                          Positioned(
                            right: 14,
                            top: 16,
                            child: Opacity(
                              opacity: 0.22,
                              child: BrandMark(size: 84, opacity: 0.9),
                            ),
                          ),
                          Positioned(
                            left: 16,
                            bottom: 10,
                            child: Opacity(
                              opacity: 0.10,
                              child: Container(
                                width: 120,
                                height: 70,
                                decoration: const BoxDecoration(
                                  gradient: LinearGradient(
                                    colors: [Color(0xFFF9E7E2), Color(0x00FFFFFF)],
                                  ),
                                  borderRadius: BorderRadius.only(
                                    topLeft: Radius.circular(80),
                                    topRight: Radius.circular(80),
                                    bottomLeft: Radius.circular(40),
                                    bottomRight: Radius.circular(40),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: _bottomNavigation(),
    );
  }
}

class _CategoryOption {
  const _CategoryOption({required this.key, required this.label});

  final String key;
  final String label;
}

