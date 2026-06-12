import 'package:flutter/material.dart';

import '../services/community_forum_service.dart';
import '../theme.dart';
import '../widgets/vihtal_app_bar.dart';

/// Detalle de un post del foro: contenido completo, like y respuestas.
class PostDetailScreen extends StatefulWidget {
  const PostDetailScreen({super.key, required this.post, this.service});

  /// Post inicial (para pintar de inmediato); los contadores se actualizan en
  /// vivo desde Firestore vía [CommunityForumService.watchPost].
  final ForumPost post;
  final CommunityForumService? service;

  @override
  State<PostDetailScreen> createState() => _PostDetailScreenState();
}

class _PostDetailScreenState extends State<PostDetailScreen> {
  late final CommunityForumService _service =
      widget.service ?? CommunityForumService();
  final TextEditingController _replyController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  bool _anonymous = true;
  bool _sending = false;

  @override
  void dispose() {
    _replyController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _sendReply() async {
    final text = _replyController.text.trim();
    if (text.isEmpty || _sending) return;

    setState(() => _sending = true);
    try {
      await _service.addReply(
        postId: widget.post.id,
        content: text,
        anonymous: _anonymous,
      );
      _replyController.clear();
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (_scrollController.hasClients) {
          _scrollController.animateTo(
            _scrollController.position.maxScrollExtent,
            duration: const Duration(milliseconds: 250),
            curve: Curves.easeOut,
          );
        }
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('No se pudo enviar: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _sending = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: VihtalAppBar(
        showDonateAction: false,
        leading: BackButton(
          color: AppColors.primary,
          onPressed: () => Navigator.of(context).maybePop(),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView(
              controller: _scrollController,
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
              children: [
                StreamBuilder<ForumPost?>(
                  stream: _service.watchPost(widget.post.id),
                  builder: (context, snapshot) {
                    final post = snapshot.data ?? widget.post;
                    return _PostHeader(post: post, service: _service);
                  },
                ),
                const SizedBox(height: 20),
                const Text(
                  'Respuestas',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 12),
                StreamBuilder<List<ForumReply>>(
                  stream: _service.watchReplies(widget.post.id),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Padding(
                        padding: EdgeInsets.all(20),
                        child: Center(child: CircularProgressIndicator()),
                      );
                    }
                    final replies = snapshot.data ?? const <ForumReply>[];
                    if (replies.isEmpty) {
                      return const Padding(
                        padding: EdgeInsets.symmetric(vertical: 28),
                        child: Center(
                          child: Text(
                            'Sé el primero en responder con respeto y empatía.',
                            textAlign: TextAlign.center,
                            style: TextStyle(color: AppColors.textSecondary),
                          ),
                        ),
                      );
                    }
                    return Column(
                      children: [
                        for (final r in replies) _ReplyCard(reply: r),
                      ],
                    );
                  },
                ),
              ],
            ),
          ),
          _ReplyInput(
            controller: _replyController,
            anonymous: _anonymous,
            sending: _sending,
            onToggleAnonymous: (v) => setState(() => _anonymous = v),
            onSend: _sendReply,
          ),
        ],
      ),
    );
  }
}

class _PostHeader extends StatelessWidget {
  const _PostHeader({required this.post, required this.service});

  final ForumPost post;
  final CommunityForumService service;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
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
                    color: AppColors.textSecondary, fontSize: 13),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Text(
            post.title,
            style: const TextStyle(
              color: AppColors.textPrimary,
              fontSize: 20,
              height: 1.2,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            post.excerpt,
            style: const TextStyle(
              color: AppColors.textPrimary,
              fontSize: 15,
              height: 1.5,
            ),
          ),
          if (post.imageUrl != null) ...[
            const SizedBox(height: 14),
            ClipRRect(
              borderRadius: BorderRadius.circular(14),
              child: Image.network(post.imageUrl!, fit: BoxFit.cover),
            ),
          ],
          const SizedBox(height: 16),
          Row(
            children: [
              _Avatar(name: post.authorName, photoUrl: post.authorPhotoUrl),
              const SizedBox(width: 8),
              Text(
                post.authorName,
                style: const TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const Spacer(),
              _LikeButton(post: post, service: service),
              const SizedBox(width: 14),
              const Icon(Icons.mode_comment_outlined,
                  size: 18, color: AppColors.textSecondary),
              const SizedBox(width: 5),
              Text(
                '${post.repliesCount}',
                style: const TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _LikeButton extends StatelessWidget {
  const _LikeButton({required this.post, required this.service});

  final ForumPost post;
  final CommunityForumService service;

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<bool>(
      stream: service.watchLikeState(post.id),
      builder: (context, snapshot) {
        final liked = snapshot.data ?? false;
        return InkWell(
          borderRadius: BorderRadius.circular(999),
          onTap: () => service.toggleLike(post.id),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
            child: Row(
              children: [
                Icon(
                  liked ? Icons.favorite_rounded : Icons.favorite_border_rounded,
                  size: 19,
                  color: liked ? AppColors.primary : AppColors.textSecondary,
                ),
                const SizedBox(width: 5),
                Text(
                  '${post.likesCount}',
                  style: TextStyle(
                    color: liked ? AppColors.primary : AppColors.textSecondary,
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _ReplyCard extends StatelessWidget {
  const _ReplyCard({required this.reply});

  final ForumReply reply;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              _Avatar(name: reply.authorName, photoUrl: reply.authorPhotoUrl),
              const SizedBox(width: 8),
              Text(
                reply.authorName,
                style: const TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: 13,
                  color: AppColors.textPrimary,
                ),
              ),
              const Spacer(),
              Text(
                reply.timeAgo,
                style: const TextStyle(
                    color: AppColors.textSecondary, fontSize: 12),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            reply.content,
            style: const TextStyle(
              color: AppColors.textPrimary,
              fontSize: 14,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }
}

class _Avatar extends StatelessWidget {
  const _Avatar({required this.name, required this.photoUrl});

  final String name;
  final String? photoUrl;

  @override
  Widget build(BuildContext context) {
    if (photoUrl != null) {
      return CircleAvatar(radius: 13, backgroundImage: NetworkImage(photoUrl!));
    }
    final initial = name.trim().isEmpty ? '?' : name.trim()[0].toUpperCase();
    return CircleAvatar(
      radius: 13,
      backgroundColor: AppColors.surfaceSoft,
      child: Text(
        initial,
        style: const TextStyle(
          color: AppColors.primary,
          fontSize: 12,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

class _ReplyInput extends StatelessWidget {
  const _ReplyInput({
    required this.controller,
    required this.anonymous,
    required this.sending,
    required this.onToggleAnonymous,
    required this.onSend,
  });

  final TextEditingController controller;
  final bool anonymous;
  final bool sending;
  final ValueChanged<bool> onToggleAnonymous;
  final VoidCallback onSend;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Container(
        padding: const EdgeInsets.fromLTRB(12, 8, 12, 8),
        decoration: const BoxDecoration(
          color: AppColors.background,
          border: Border(top: BorderSide(color: AppColors.border)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            InkWell(
              borderRadius: BorderRadius.circular(8),
              onTap: () => onToggleAnonymous(!anonymous),
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 4),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      anonymous
                          ? Icons.check_box_rounded
                          : Icons.check_box_outline_blank_rounded,
                      size: 18,
                      color: anonymous
                          ? AppColors.primary
                          : AppColors.textSecondary,
                    ),
                    const SizedBox(width: 6),
                    const Text(
                      'Responder de forma anónima',
                      style: TextStyle(
                        fontSize: 12.5,
                        color: AppColors.textSecondary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const Spacer(),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 4),
            Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Expanded(
                  child: TextField(
                    controller: controller,
                    minLines: 1,
                    maxLines: 4,
                    textInputAction: TextInputAction.send,
                    onSubmitted: (_) => onSend(),
                    decoration: InputDecoration(
                      hintText: 'Escribe una respuesta…',
                      filled: true,
                      fillColor: AppColors.surface,
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 12),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(22),
                        borderSide: const BorderSide(color: AppColors.border),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(22),
                        borderSide: const BorderSide(color: AppColors.border),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(22),
                        borderSide:
                            const BorderSide(color: AppColors.primary),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Material(
                  color: AppColors.primary,
                  shape: const CircleBorder(),
                  child: InkWell(
                    customBorder: const CircleBorder(),
                    onTap: sending ? null : onSend,
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: sending
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2.2,
                                valueColor:
                                    AlwaysStoppedAnimation<Color>(Colors.white),
                              ),
                            )
                          : const Icon(Icons.send_rounded,
                              color: Colors.white, size: 20),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
