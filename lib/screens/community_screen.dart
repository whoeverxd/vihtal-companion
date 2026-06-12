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
    _CommunityCategory(key: 'recien_diagnosticados', label: 'Recién diagnosticados'),
    _CommunityCategory(key: 'apoyo_emocional', label: 'Apoyo emocional'),
    _CommunityCategory(key: 'tratamientos', label: 'Tratamientos'),
  ];

  @override
  void initState() {
    super.initState();
    Future.microtask(_forumService.ensureSeedData);
  }

  List<ForumPost> _applyFilter(List<ForumPost> posts) {
    if (_selectedCategory == 'todos') return posts;
    return posts.where((post) => post.categoryKey == _selectedCategory).toList();
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
        IconButton(
          onPressed: () {},
          icon: const Icon(Icons.notifications_none_rounded,
              color: AppColors.textSecondary),
          tooltip: 'Notificaciones',
        ),
      ],
    );
  }

  Widget _categoryChip(_CommunityCategory category, bool selected) {
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: ChoiceChip(
        label: Text(category.label),
        selected: selected,
        onSelected: (_) => setState(() => _selectedCategory = category.key),
        labelStyle: TextStyle(
          color: selected ? Colors.white : AppColors.textSecondary,
          fontWeight: FontWeight.w600,
          fontSize: 13,
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
      ),
    );
  }

  Widget _forumCard(ForumPost post) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Material(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: () => context.push(AppRoutes.postDetail, extra: post),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: AppColors.border),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 5),
                      decoration: BoxDecoration(
                        color: AppColors.surfaceSoft,
                        borderRadius: BorderRadius.circular(999),
                      ),
                      child: Text(
                        post.categoryLabel.toUpperCase(),
                        style: const TextStyle(
                          color: AppColors.primary,
                          fontSize: 10.5,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 0.6,
                        ),
                      ),
                    ),
                    const Spacer(),
                    Text(
                      post.timeAgo,
                      style: const TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 12.5,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  post.title,
                  style: const TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 16,
                    height: 1.25,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  post.excerpt,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 13.5,
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 14),
                Row(
                  children: [
                    const Icon(Icons.mode_comment_outlined,
                        size: 16, color: AppColors.textSecondary),
                    const SizedBox(width: 6),
                    Text(
                      '${post.repliesCount}',
                      style: const TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(width: 18),
                    const Icon(Icons.favorite_border_rounded,
                        size: 16, color: AppColors.textSecondary),
                    const SizedBox(width: 6),
                    Text(
                      '${post.likesCount}',
                      style: const TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const Spacer(),
                    const Icon(Icons.chevron_right_rounded,
                        size: 20, color: AppColors.textSecondary),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 6, 16, 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _topActions(context),
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
                        padding: const EdgeInsets.only(bottom: 100),
                        children: [
                          Text(
                            'Comunidad',
                            style: Theme.of(context).textTheme.titleLarge,
                          ),
                          const SizedBox(height: 12),
                          const _AnonymityBanner(),
                          const SizedBox(height: 22),
                          // Filtros de categoría
                          SizedBox(
                            height: 38,
                            child: ListView(
                              scrollDirection: Axis.horizontal,
                              physics: const BouncingScrollPhysics(),
                              children: _categories
                                  .map((c) => _categoryChip(
                                      c, _selectedCategory == c.key))
                                  .toList(),
                            ),
                          ),
                          const SizedBox(height: 20),
                          Text(
                            'Discusiones recientes',
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                          const SizedBox(height: 12),
                          if (snapshot.connectionState ==
                                  ConnectionState.waiting &&
                              posts.isEmpty)
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
                                  style:
                                      TextStyle(color: AppColors.textSecondary),
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
                  right: 0,
                  bottom: 12,
                  child: FloatingActionButton(
                    onPressed: () => context.push(AppRoutes.createPost),
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    elevation: 2,
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

/// Franja discreta que recuerda que el espacio es anónimo y seguro.
class _AnonymityBanner extends StatelessWidget {
  const _AnonymityBanner();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.surfaceSoft,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          Container(
            width: 34,
            height: 34,
            decoration: const BoxDecoration(
              color: AppColors.surface,
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.lock_outline_rounded,
                color: AppColors.primary, size: 18),
          ),
          const SizedBox(width: 12),
          const Expanded(
            child: Text(
              'Espacio 100% anónimo. Tu identidad está protegida.',
              style: TextStyle(
                color: AppColors.accent,
                fontSize: 13,
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

class _CommunityCategory {
  const _CommunityCategory({required this.key, required this.label});

  final String key;
  final String label;
}
