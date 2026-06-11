/// Rol de quien emite un mensaje en el chat con la IA.
enum ChatRole { user, assistant }

/// Un mensaje individual dentro de una conversación con la IA.
///
/// Por ahora vive solo en memoria (placeholder). Cuando se conecte la Cloud
/// Function y Firestore, se añadirá un factory `fromDoc` siguiendo el patrón de
/// `ForumPost` en `community_forum_service.dart`.
class ChatMessage {
  const ChatMessage({
    required this.role,
    required this.content,
    required this.createdAt,
  });

  final ChatRole role;
  final String content;
  final DateTime createdAt;

  bool get isUser => role == ChatRole.user;

  ChatMessage copyWith({String? content}) => ChatMessage(
        role: role,
        content: content ?? this.content,
        createdAt: createdAt,
      );
}
