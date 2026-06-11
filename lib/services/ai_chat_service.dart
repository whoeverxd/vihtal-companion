import 'dart:async';

import '../models/chat_message.dart';

/// Servicio del chat con IA.
///
/// **MVP / placeholder:** las respuestas se generan localmente y se emiten en
/// "chunks" para simular el streaming, sin backend ni costo (el usuario aún no
/// puede activar el plan Blaze de Firebase).
///
/// **Cuando haya Blaze:** reemplazar el cuerpo de [sendMessage] por una llamada
/// a la Cloud Function `chatWithAI` (callable con streaming que invoca a Claude).
/// La UI no debe cambiar: seguirá consumiendo un `Stream<String>` de chunks.
class AiChatService {
  AiChatService();

  /// Límite diario de mensajes para usuarios gratuitos (base del futuro
  /// freemium). En el placeholder se aplica solo en memoria; con backend se
  /// validará en la Cloud Function contra `usage/{uid}` en Firestore.
  static const int freeDailyLimit = 10;

  /// Envía [text] y devuelve la respuesta de la IA en fragmentos (streaming
  /// simulado). [history] queda disponible para cuando se arme el contexto real.
  Stream<String> sendMessage(
    String text, {
    List<ChatMessage> history = const <ChatMessage>[],
  }) async* {
    // Latencia inicial: simula a la IA "pensando".
    await Future<void>.delayed(const Duration(milliseconds: 650));

    final reply = _mockReply(text);
    final words = reply.split(' ');
    for (var i = 0; i < words.length; i++) {
      await Future<void>.delayed(const Duration(milliseconds: 40));
      yield i == 0 ? words[i] : ' ${words[i]}';
    }
  }

  // ---------------------------------------------------------------------------
  // Lógica simulada. NO es asesoría médica real: solo da textura a la demo.
  // El comportamiento real (información validada + guardarraíles) vivirá en el
  // system prompt de la Cloud Function.
  // ---------------------------------------------------------------------------

  static const String _disclaimer =
      'Recuerda: soy una orientación general y no sustituyo a un profesional de '
      'la salud. Ante cualquier duda o urgencia, acude a un centro médico.';

  String _mockReply(String text) {
    final t = text.toLowerCase();

    // Señal de urgencia / crisis → derivar a atención inmediata.
    const urgent = [
      'suicid',
      'matarme',
      'quitarme la vida',
      'sangrado',
      'desmay',
      'no puedo respirar',
      'emergencia',
    ];
    if (urgent.any(t.contains)) {
      return 'Siento mucho que estés pasando por esto y no estás solo/a. Lo que '
          'describes puede requerir atención inmediata: por favor acude a '
          'urgencias o contacta una línea de ayuda local ahora mismo. Si estás '
          'en peligro, llama a los servicios de emergencia. Estoy aquí para '
          'acompañarte mientras buscas ayuda profesional.';
    }

    if (t.contains('prep')) {
      return 'La PrEP (profilaxis pre-exposición) es un medicamento que, tomado '
          'correctamente, reduce mucho el riesgo de contraer VIH. Suele indicarse '
          'a personas con mayor exposición. Un profesional puede evaluar si es '
          'adecuada para ti y hacer el seguimiento necesario. $_disclaimer';
    }
    if (t.contains('prueba') || t.contains('test') || t.contains('examen')) {
      return 'Hacerte la prueba de VIH es sencillo, confidencial y muchas veces '
          'gratuito. Hay pruebas rápidas con resultado en minutos. Lo ideal es '
          'realizarla en un centro de salud o laboratorio confiable, donde '
          'también te orientarán según el resultado. $_disclaimer';
    }
    if (t.contains('tratamiento') || t.contains('antirretroviral') || t.contains('tar')) {
      return 'El tratamiento antirretroviral (TAR) permite que las personas con '
          'VIH vivan vidas largas y saludables, y al lograr carga viral '
          'indetectable no se transmite el virus (I=I). La constancia en la toma '
          'es clave. Tu equipo médico ajusta el esquema a tu caso. $_disclaimer';
    }
    if (t.contains('sintoma') || t.contains('síntoma')) {
      return 'Los síntomas pueden tener muchas causas y no permiten un '
          'diagnóstico por sí solos. No puedo decirte si tienes o no una '
          'condición. Lo más seguro es que un profesional te evalúe y, si '
          'corresponde, te indique pruebas. $_disclaimer';
    }

    return 'Gracias por confiarme tu pregunta. Puedo orientarte sobre VIH, salud '
        'sexual, prevención, PrEP, pruebas, tratamiento y bienestar emocional, '
        'siempre desde el respeto y sin juicios. ¿Me cuentas un poco más para '
        'ayudarte mejor? $_disclaimer';
  }
}
