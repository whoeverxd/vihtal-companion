# Diseño: Chat con IA (Sub-proyecto A) — VIHTAL Companion

- **Fecha:** 2026-06-11
- **Estado:** Diseño aprobado. UI/placeholder implementado; backend pendiente del plan Blaze.
- **Módulo:** Chat con IA — el "corazón" de la app.

## 1. Contexto y objetivo

VIHTAL Companion es una app Flutter de salud sobre VIH que integra IA, comunidad y
acompañamiento. El stack actual es **Firebase** (Auth + Cloud Firestore + Storage);
no usa Supabase. Ya están construidos: autenticación, perfil, comunidad/foro,
home, donar, soporte y splash.

Este módulo añade un **chat conversacional confidencial** que orienta sobre VIH,
salud sexual, prevención, PrEP, pruebas, tratamiento y bienestar emocional, con
información validada y garantías de seguridad médica.

### Decisiones tomadas
- **Enfoque:** producto / MVP usable.
- **Backend de IA:** Firebase Cloud Functions como proxy (NO FastAPI), para
  mantenerse en el stack actual y asegurar la API key.
- **Modelo:** Anthropic / Claude (fuerte en seguridad y rechazos; buen español;
  Haiku es económico para chat de alto volumen).
- **Alcance MVP:** historial + rate limit + guardarraíles de seguridad + streaming.

### Restricción actual
El usuario **no puede pagar el plan Blaze** de Firebase todavía, requisito para
Cloud Functions con llamadas externas. Por eso la fase 1 implementa solo la
**UI con un servicio simulado local**, diseñado para que la Cloud Function real
se enchufe después sin cambiar la UI.

## 2. Arquitectura y flujo de datos (objetivo)

```
Flutter (AiScreen)  --1. mensaje + token-->  Cloud Function chatWithAI
                    <--4. respuesta (stream)-- (callable, streaming)
       |                                              |
       | 5. lee historial                             | 2. valida auth + rate limit
       v                                              | 3. llama a Claude (key en
   Firestore  <----- la función persiste -----        |    Secret Manager), streaming
```

**Principio clave:** la app **nunca** ve la API key ni habla directo con Anthropic.
La Cloud Function valida identidad, aplica el rate limit, arma el system prompt de
seguridad, llama a Claude en streaming, reenvía chunks y persiste el historial.

## 3. Modelo de datos (Firestore)

```
users/{uid}/conversations/{conversationId}
  ├─ title: string         (auto: primeras palabras del primer mensaje)
  ├─ createdAt, updatedAt: Timestamp
  └─ messages/{messageId}
       ├─ role: 'user' | 'assistant'
       ├─ content: string
       └─ createdAt: Timestamp

usage/{uid}
  ├─ date: 'YYYY-MM-DD'
  └─ count: int            (mensajes hoy; reinicia diario)
```

**Reglas de seguridad:** cada usuario solo lee/escribe sus propias
`conversations`. El documento `usage/{uid}` es de **solo lectura** para la app;
únicamente la Cloud Function lo incrementa (la app no puede falsificar el contador).

## 4. Cloud Function `chatWithAI`

- **Tipo:** callable con streaming (`onCall` + `response.sendChunk`).
- **Runtime:** TypeScript/Node con el SDK oficial de Anthropic.
- **Secreto:** API key de Anthropic en Firebase Secret Manager.
- **Pasos:**
  1. Verifica `request.auth`; si no hay, rechaza (`unauthenticated`).
  2. Lee `usage/{uid}`; si `count >= freeDailyLimit` (10), devuelve
     `resource-exhausted` → la app muestra el estado "límite alcanzado".
  3. Carga los últimos N mensajes de la conversación para dar contexto.
  4. Llama a Claude con el system prompt de seguridad (§6) + historial + mensaje,
     en streaming.
  5. Reenvía cada chunk; al terminar, persiste el mensaje del usuario y la
     respuesta completa, e incrementa `usage`.

## 5. Capa Flutter

Sigue el patrón de servicios existente (instancias nullable con `_tryGet...`,
modelos con factory `fromDoc`).

- `lib/models/chat_message.dart` — `ChatMessage` (role, content, createdAt).
  [Implementado]
- `lib/services/ai_chat_service.dart` — `AiChatService`. [Implementado como
  placeholder] Expone `Stream<String> sendMessage(text, {history})`. Hoy genera
  respuestas locales simuladas con streaming simulado; mañana invoca la callable.
  Constante `freeDailyLimit = 10`.
- `lib/screens/ai_screen.dart` — pantalla de chat. [Implementada] Burbujas,
  indicador "escribiendo…", banner de disclaimer fijo, estado vacío con chips de
  sugerencia, manejo del estado "límite alcanzado".

### Pendiente al conectar backend
- `Conversation` model + `fromDoc`.
- `watchConversations()` y `watchMessages(conversationId)` (streams Firestore).
- Persistencia real; rate limit server-side; lista/historial de conversaciones.

## 6. Guardarraíles de seguridad médica

Núcleo de la seguridad. El system prompt (en la función) instruye a Claude a:
- **Siempre** dejar claro que **no sustituye atención médica profesional**.
- **Nunca diagnosticar** ni afirmar que alguien tiene/no tiene VIH.
- Detectar **síntomas graves o crisis** (ideación suicida, síntomas agudos) →
  responder con empatía y **derivar a urgencias / línea de ayuda**.
- Tono empático, español neutro, sin estigma.
- Ceñirse a VIH / salud sexual / PrEP / salud mental; fuera de alcance → redirigir.

Además, **disclaimer visible fijo** en la pantalla (no solo en el prompt).
[Implementado en la UI]

El placeholder ya simula esto: detecta palabras de urgencia → deriva a atención
inmediata, y añade un disclaimer a cada respuesta. NO es asesoría real; solo da
textura a la demo hasta que exista el system prompt en la función.

## 7. Rate limiting y streaming

- **Rate limit:** contador diario en `usage/{uid}`, server-side. Configurable.
  Base del futuro freemium (premium = ilimitado). Hoy simulado en memoria.
- **Streaming:** callable con streaming → respuesta progresiva. Fallback a
  request/respuesta simple si alguna plataforma da problemas, sin cambiar la UI.

## 8. Pruebas

- Tests de modelos (`fromDoc`) y de `AiChatService` con Firebase mockeado
  (patrón nullable existente).
- Test de la lógica de la función (rate limit, armado de prompt) en Node.

## 9. Fuera de alcance (para después)

- Gating premium real / pasarela de pago (sub-proyecto E).
- Text-to-speech / speech-to-text.
- RAG con documentos médicos propios (mejora del system prompt).
- Geolocalización de centros (sub-proyecto C).

## 10. Plan de migración del placeholder → producción

Cuando el usuario active Blaze:
1. Crear la Cloud Function `chatWithAI` (TS/Node) con el SDK de Anthropic.
2. Guardar la API key en Secret Manager; escribir el system prompt de §6.
3. Definir reglas de Firestore para `conversations` y `usage`.
4. Reemplazar el cuerpo de `AiChatService.sendMessage` por la invocación a la
   callable (la firma `Stream<String>` y la UI no cambian).
5. Añadir el `Conversation` model y los streams de historial.
6. Mover el rate limit a la función.
