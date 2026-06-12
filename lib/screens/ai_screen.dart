import 'dart:async';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../models/chat_message.dart';
import '../router/app_router.dart';
import '../services/ai_chat_service.dart';
import '../services/premium_service.dart';
import '../theme.dart';
import '../widgets/vihtal_app_bar.dart';

/// Pantalla del chat con la IA (el "corazón" de la app).
///
/// MVP / placeholder: usa [AiChatService] con respuestas simuladas localmente.
/// Cuando se conecte la Cloud Function, solo cambia el servicio; esta UI queda
/// igual (sigue consumiendo un `Stream<String>` de chunks).
class AiScreen extends StatefulWidget {
  const AiScreen({super.key, this.service, this.premiumService});

  final AiChatService? service;
  final PremiumService? premiumService;

  @override
  State<AiScreen> createState() => _AiScreenState();
}

class _AiScreenState extends State<AiScreen> {
  late final AiChatService _service = widget.service ?? AiChatService();
  late final PremiumService _premiumService =
      widget.premiumService ?? PremiumService();

  final List<ChatMessage> _messages = <ChatMessage>[];
  final TextEditingController _inputController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  StreamSubscription<String>? _replySub;
  StreamSubscription<bool>? _premiumSub;
  bool _isResponding = false;
  bool _isPremium = false;
  int _messagesSentToday = 0;

  static const List<String> _suggestions = <String>[
    '¿Qué es la PrEP?',
    '¿Cómo me hago la prueba?',
    'Dudas sobre mi tratamiento',
  ];

  // Premium = chat ilimitado; gratis = límite diario.
  bool get _limitReached =>
      !_isPremium && _messagesSentToday >= AiChatService.freeDailyLimit;

  @override
  void initState() {
    super.initState();
    _premiumSub = _premiumService.watchIsPremium().listen((value) {
      if (mounted) setState(() => _isPremium = value);
    });
  }

  @override
  void dispose() {
    _replySub?.cancel();
    _premiumSub?.cancel();
    _inputController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _handleSend([String? prefilled]) {
    final text = (prefilled ?? _inputController.text).trim();
    if (text.isEmpty || _isResponding || _limitReached) return;

    setState(() {
      _messages.add(ChatMessage(
        role: ChatRole.user,
        content: text,
        createdAt: DateTime.now(),
      ));
      // Burbuja vacía de la IA que se irá rellenando con el streaming.
      _messages.add(ChatMessage(
        role: ChatRole.assistant,
        content: '',
        createdAt: DateTime.now(),
      ));
      _isResponding = true;
      _messagesSentToday++;
    });
    _inputController.clear();
    _scrollToBottom();

    final history = _messages.sublist(0, _messages.length - 2);
    final buffer = StringBuffer();

    _replySub = _service.sendMessage(text, history: history).listen(
      (chunk) {
        buffer.write(chunk);
        setState(() {
          _messages[_messages.length - 1] =
              _messages.last.copyWith(content: buffer.toString());
        });
        _scrollToBottom();
      },
      onDone: () {
        setState(() => _isResponding = false);
      },
      onError: (Object _) {
        setState(() {
          _messages[_messages.length - 1] = _messages.last.copyWith(
            content: 'Lo siento, ocurrió un error. Intenta de nuevo.',
          );
          _isResponding = false;
        });
      },
    );
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_scrollController.hasClients) return;
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeOut,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: const VihtalAppBar(),
      body: Column(
        children: [
          const _DisclaimerBanner(),
          Expanded(
            child: _messages.isEmpty
                ? _EmptyState(
                    suggestions: _suggestions,
                    onSelect: _handleSend,
                  )
                : ListView.builder(
                    controller: _scrollController,
                    padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
                    itemCount: _messages.length,
                    itemBuilder: (context, index) {
                      final msg = _messages[index];
                      final isLast = index == _messages.length - 1;
                      final showTyping =
                          isLast && _isResponding && msg.content.isEmpty;
                      return _MessageBubble(
                        message: msg,
                        showTyping: showTyping,
                      );
                    },
                  ),
          ),
          if (_limitReached)
            const _LimitBanner()
          else
            _InputBar(
              controller: _inputController,
              enabled: !_isResponding,
              onSend: () => _handleSend(),
            ),
        ],
      ),
    );
  }
}

class _DisclaimerBanner extends StatelessWidget {
  const _DisclaimerBanner();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      color: AppColors.surfaceSoft,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: const [
          Icon(Icons.info_outline_rounded, size: 16, color: AppColors.accent),
          SizedBox(width: 8),
          Expanded(
            child: Text(
              'Información general. No sustituye atención médica profesional.',
              style: TextStyle(
                fontSize: 12,
                color: AppColors.accent,
                height: 1.25,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState({required this.suggestions, required this.onSelect});

  final List<String> suggestions;
  final ValueChanged<String> onSelect;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 72,
              height: 72,
              decoration: const BoxDecoration(
                color: AppColors.surfaceSoft,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.forum_rounded,
                size: 34,
                color: AppColors.primary,
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'Pregúntame con confianza',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            const Text(
              'Estoy aquí para orientarte sobre VIH, salud sexual, prevención y '
              'bienestar, de forma confidencial y sin juicios.',
              textAlign: TextAlign.center,
              style: TextStyle(color: AppColors.textSecondary, height: 1.4),
            ),
            const SizedBox(height: 24),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              alignment: WrapAlignment.center,
              children: [
                for (final s in suggestions)
                  ActionChip(
                    label: Text(s),
                    backgroundColor: AppColors.surface,
                    side: const BorderSide(color: AppColors.subtle),
                    labelStyle: const TextStyle(
                      color: AppColors.textPrimary,
                      fontWeight: FontWeight.w600,
                      fontSize: 13,
                    ),
                    onPressed: () => onSelect(s),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _MessageBubble extends StatelessWidget {
  const _MessageBubble({required this.message, required this.showTyping});

  final ChatMessage message;
  final bool showTyping;

  @override
  Widget build(BuildContext context) {
    final isUser = message.isUser;
    final bg = isUser ? AppColors.primary : AppColors.surface;
    final fg = isUser ? AppColors.whiteText : AppColors.textPrimary;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        mainAxisAlignment:
            isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (!isUser) ...[
            const _AssistantAvatar(),
            const SizedBox(width: 8),
          ],
          Flexible(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: bg,
                borderRadius: BorderRadius.only(
                  topLeft: const Radius.circular(16),
                  topRight: const Radius.circular(16),
                  bottomLeft: Radius.circular(isUser ? 16 : 4),
                  bottomRight: Radius.circular(isUser ? 4 : 16),
                ),
                border: isUser
                    ? null
                    : Border.all(color: AppColors.subtle),
              ),
              child: showTyping
                  ? const _TypingDots()
                  : Text(
                      message.content,
                      style: TextStyle(color: fg, fontSize: 15, height: 1.35),
                    ),
            ),
          ),
        ],
      ),
    );
  }
}

class _AssistantAvatar extends StatelessWidget {
  const _AssistantAvatar();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 30,
      height: 30,
      decoration: const BoxDecoration(
        color: AppColors.surfaceSoft,
        shape: BoxShape.circle,
      ),
      child: const Icon(Icons.favorite_rounded, size: 16, color: AppColors.primary),
    );
  }
}

class _TypingDots extends StatefulWidget {
  const _TypingDots();

  @override
  State<_TypingDots> createState() => _TypingDotsState();
}

class _TypingDotsState extends State<_TypingDots>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1200),
  )..repeat();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 36,
      height: 16,
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, _) {
          return Row(
            mainAxisSize: MainAxisSize.min,
            children: List.generate(3, (i) {
              final t = (_controller.value + i * 0.2) % 1.0;
              final opacity = 0.3 + 0.7 * (1 - (t - 0.5).abs() * 2).clamp(0.0, 1.0);
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 2),
                child: Opacity(
                  opacity: opacity,
                  child: const CircleAvatar(
                    radius: 3.5,
                    backgroundColor: AppColors.textSecondary,
                  ),
                ),
              );
            }),
          );
        },
      ),
    );
  }
}

class _InputBar extends StatelessWidget {
  const _InputBar({
    required this.controller,
    required this.enabled,
    required this.onSend,
  });

  final TextEditingController controller;
  final bool enabled;
  final VoidCallback onSend;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(12, 8, 12, 12),
      decoration: const BoxDecoration(
        color: AppColors.background,
        border: Border(top: BorderSide(color: AppColors.subtle)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Expanded(
            child: TextField(
              controller: controller,
              enabled: enabled,
              minLines: 1,
              maxLines: 4,
              textInputAction: TextInputAction.send,
              onSubmitted: (_) => onSend(),
              decoration: InputDecoration(
                hintText: 'Escribe tu pregunta…',
                filled: true,
                fillColor: AppColors.surface,
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(24),
                  borderSide: const BorderSide(color: AppColors.subtle),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(24),
                  borderSide: const BorderSide(color: AppColors.subtle),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(24),
                  borderSide: const BorderSide(color: AppColors.primary),
                ),
              ),
            ),
          ),
          const SizedBox(width: 8),
          Material(
            color: enabled ? AppColors.primary : AppColors.subtle,
            shape: const CircleBorder(),
            child: InkWell(
              customBorder: const CircleBorder(),
              onTap: enabled ? onSend : null,
              child: const Padding(
                padding: EdgeInsets.all(12),
                child: Icon(Icons.send_rounded, color: Colors.white, size: 20),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _LimitBanner extends StatelessWidget {
  const _LimitBanner();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 18),
      decoration: const BoxDecoration(
        color: AppColors.surface,
        border: Border(top: BorderSide(color: AppColors.subtle)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.lock_clock_rounded, color: AppColors.primary),
          const SizedBox(height: 8),
          Text(
            'Alcanzaste tu límite diario gratuito',
            style: Theme.of(context).textTheme.titleMedium,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 4),
          const Text(
            'Vuelve mañana o hazte Premium para chat ilimitado.',
            textAlign: TextAlign.center,
            style: TextStyle(color: AppColors.textSecondary, fontSize: 13),
          ),
          const SizedBox(height: 12),
          ElevatedButton.icon(
            onPressed: () => context.push(AppRoutes.premium),
            icon: const Icon(Icons.workspace_premium_rounded, size: 18),
            label: const Text('Hazte Premium'),
            style: ElevatedButton.styleFrom(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
