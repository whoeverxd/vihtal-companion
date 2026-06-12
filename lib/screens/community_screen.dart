import 'package:flutter/material.dart';

import 'package:go_router/go_router.dart';

import '../router/app_router.dart';
import '../services/community_forum_service.dart';
import '../theme.dart';

class CommunityScreen extends StatefulWidget {
  const CommunityScreen({super.key});

  @override
  State<CommunityScreen> createState() => _CommunityScreenState();
}

class _CommunityScreenState extends State<CommunityScreen> {
  final _forumService = CommunityForumService();
  String _selectedCategory = 'todos';

  static const _categories = <_CommunityCategory>[
    _CommunityCategory(key: 'todos', label: 'Todos'),
    _CommunityCategory(key: 'recien_diagnosticados', label: 'Recién Diagnosticados'),
    _CommunityCategory(key: 'apoyo_emocional', label: 'Apoyo Emocional'),
    _CommunityCategory(key: 'tratamientos', label: 'Tratamientos'),
  ];

  @override
  void initState() {
    super.initState();
    Future.microtask(_forumService.ensureSeedData);
  }

  Widget _topActions(BuildContext context) {
    return Row(
      children: [
        IconButton(
          onPressed: () => context.push(AppRoutes.donate),
          icon: const Icon(Icons.favorite_border_rounded, color: AppColors.primary),
          tooltip: 'Donar',
        ),
        const Spacer(),
        Stack(
          clipBehavior: Clip.none,
          children: [
            IconButton(
              onPressed: () {},
              icon: const Icon(
                Icons.notifications_none_rounded,
                color: AppColors.textSecondary,
              ),
              tooltip: 'Notificaciones',
            ),
            Positioned(
              right: 6,
              top: 6,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: BorderRadius.circular(999),
                ),
                child: const Text(
                  '0',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  List<ForumPost> _applyFilter(List<ForumPost> posts) {
    if (_selectedCategory == 'todos') return posts;
    return posts.where((post) => post.categoryKey == _selectedCategory).toList();
  }

  Widget _categoryChip(_CommunityCategory category, bool selected) {
    return ChoiceChip(
      label: Text(category.label),
      selected: selected,
      onSelected: (_) => setState(() => _selectedCategory = category.key),
      labelStyle: TextStyle(
        color: selected ? Colors.white : AppColors.textPrimary,
        fontWeight: FontWeight.w700,
      ),
      selectedColor: AppColors.primary,
      backgroundColor: const Color(0xFFF5DDE0),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(999)),
      side: BorderSide.none,
    );
  }

  Widget _forumCard(ForumPost post) {
    return Container(
      margin: const EdgeInsets.only(bottom: 18),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: const Color(0xFFF9E7EA),
        borderRadius: BorderRadius.circular(28),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: const Color(0xFFF1CDD1),
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(
                  post.categoryLabel.toUpperCase(),
                  style: const TextStyle(
                    color: AppColors.primary,
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0.8,
                  ),
                ),
              ),
              const Spacer(),
              Text(
                post.timeAgo,
                style: const TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 14,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Text(
            post.title,
            style: const TextStyle(
              color: AppColors.textPrimary,
              fontSize: 22,
              height: 1.12,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            post.excerpt,
            style: const TextStyle(
              color: AppColors.textSecondary,
              fontSize: 15,
              height: 1.45,
            ),
          ),
          const SizedBox(height: 18),
          Row(
            children: [
              const Icon(Icons.mode_comment_outlined, size: 19, color: AppColors.textPrimary),
              const SizedBox(width: 6),
              Text(
                '${post.repliesCount} respuestas',
                style: const TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(width: 22),
              const Icon(Icons.favorite_border_rounded, size: 19, color: AppColors.textPrimary),
              const SizedBox(width: 6),
              Text(
                '${post.likesCount}',
                style: const TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _newPostSheet(BuildContext context) {
    context.push(AppRoutes.createPost);
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 8, 12, 8),
      child: Column(
        children: [
          _topActions(context),
          const SizedBox(height: 10),
          Expanded(
            child: Stack(
              children: [
                StreamBuilder<List<ForumPost>>(
                  stream: _forumService.watchPosts(),
                  builder: (context, snapshot) {
                    final posts = _applyFilter(snapshot.data ?? const []);

                    return RefreshIndicator(
                      onRefresh: _forumService.ensureSeedData,
                      child: ListView(
                        physics: const AlwaysScrollableScrollPhysics(),
                        padding: const EdgeInsets.only(bottom: 110),
                        children: [
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(18),
                            decoration: BoxDecoration(
                              color: AppColors.primary,
                              borderRadius: BorderRadius.circular(34),
                            ),
                            child: Stack(
                              children: [
                                Positioned(
                                  right: 0,
                                  top: 0,
                                  child: Icon(
                                    Icons.shield_rounded,
                                    size: 120,
                                    color: Colors.white.withValues(alpha: 0.08),
                                  ),
                                ),
                                const Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Icon(Icons.lock_outline_rounded, color: Colors.white, size: 24),
                                        SizedBox(width: 10),
                                        Text(
                                          'Espacio 100% Anónimo',
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontSize: 24,
                                            fontWeight: FontWeight.w800,
                                          ),
                                        ),
                                      ],
                                    ),
                                    SizedBox(height: 14),
                                    Text(
                                      'Tu identidad está protegida. Participa en la\ncomunidad con total libertad y seguridad.',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 16,
                                        height: 1.45,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 24),
                          const Text(
                            'Explorar Categorías',
                            style: TextStyle(
                              color: AppColors.textPrimary,
                              fontSize: 22,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          const SizedBox(height: 14),
                          SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            child: Row(
                              children: _categories
                                  .map(
                                    (category) => Padding(
                                      padding: const EdgeInsets.only(right: 12),
                                      child: _categoryChip(
                                        category,
                                        _selectedCategory == category.key,
                                      ),
                                    ),
                                  )
                                  .toList(),
                            ),
                          ),
                          const SizedBox(height: 24),
                          Row(
                            children: [
                              const Expanded(
                                child: Text(
                                  'Discusiones Recientes',
                                  style: TextStyle(
                                    color: AppColors.textPrimary,
                                    fontSize: 24,
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                              ),
                              TextButton(
                                onPressed: () {},
                                style: TextButton.styleFrom(
                                  foregroundColor: AppColors.primary,
                                ),
                                child: const Text(
                                  'Ver más →',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          if (snapshot.connectionState == ConnectionState.waiting && posts.isEmpty)
                            const Padding(
                              padding: EdgeInsets.all(24),
                              child: Center(child: CircularProgressIndicator()),
                            )
                          else if (posts.isEmpty)
                            const Padding(
                              padding: EdgeInsets.symmetric(vertical: 32),
                              child: Center(
                                child: Text(
                                  'Aún no hay publicaciones.',
                                  style: TextStyle(color: AppColors.textSecondary),
                                ),
                              ),
                            )
                          else
                            ...posts.map(_forumCard),
                        ],
                      ),
                    );
                  },
                ),
                Positioned(
                  right: 8,
                  bottom: 18,
                  child: FloatingActionButton(
                    onPressed: () => _newPostSheet(context),
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    child: const Icon(Icons.add_comment_rounded),
                  ),
                ),
              ],
            ),
          ),
        ],

      ),
    );
  }
}


class _CommunityCategory {
  const _CommunityCategory({required this.key, required this.label});

  final String key;
  final String label;
}
