import 'package:flutter/material.dart';

/// Un tema educativo con su artículo (contenido de lectura).
///
/// MVP / placeholder: contenido informativo general (ver [EduTopic.demoData]).
/// Debe revisarse/validarse con fuentes médicas antes de producción y, más
/// adelante, podría servirse desde Firestore o un CMS.
class EduTopic {
  const EduTopic({
    required this.id,
    required this.title,
    required this.summary,
    required this.icon,
    required this.readMinutes,
    required this.body,
  });

  final String id;
  final String title;
  final String summary;
  final IconData icon;
  final int readMinutes;

  /// Párrafos del artículo.
  final List<String> body;

  static const String disclaimer =
      'Esta información es general y educativa; no sustituye la consulta con un '
      'profesional de la salud. Ante dudas o síntomas, acude a un centro médico.';

  static const List<EduTopic> demoData = <EduTopic>[
    EduTopic(
      id: 'prep',
      title: '¿Qué es la PrEP?',
      summary: 'Un medicamento para prevenir el VIH antes de la exposición.',
      icon: Icons.shield_rounded,
      readMinutes: 3,
      body: [
        'La PrEP (profilaxis pre-exposición) es un medicamento que toman '
            'personas sin VIH para reducir mucho el riesgo de contraerlo.',
        'Tomada de forma constante y correcta, es altamente eficaz. No protege '
            'frente a otras infecciones de transmisión sexual, por lo que suele '
            'combinarse con otras medidas de prevención.',
        'Un profesional de la salud evalúa si la PrEP es adecuada para ti y hace '
            'el seguimiento (pruebas periódicas y control).',
      ],
    ),
    EduTopic(
      id: 'prueba',
      title: 'Cómo hacerte la prueba',
      summary: 'Es sencilla, confidencial y muchas veces gratuita.',
      icon: Icons.biotech_rounded,
      readMinutes: 2,
      body: [
        'La prueba de VIH es rápida, confidencial y en muchos lugares gratuita. '
            'Hay pruebas que dan resultado en pocos minutos.',
        'Hacértela de forma periódica te permite cuidar tu salud y, si fuera '
            'necesario, iniciar tratamiento a tiempo.',
        'Puedes realizarla en centros de salud, laboratorios u ONG. Revisa el '
            'directorio de centros cercanos dentro de la app.',
      ],
    ),
    EduTopic(
      id: 'tar',
      title: 'Tratamiento e I=I',
      summary: 'Indetectable = Intransmisible: la ciencia que da esperanza.',
      icon: Icons.medication_liquid_rounded,
      readMinutes: 4,
      body: [
        'El tratamiento antirretroviral (TAR) permite que las personas con VIH '
            'vivan vidas largas y saludables.',
        'Cuando el tratamiento logra una carga viral indetectable de forma '
            'sostenida, el virus no se transmite por vía sexual. A esto se le '
            'conoce como I=I (Indetectable = Intransmisible).',
        'La constancia en la toma es clave. Tu equipo médico ajusta el esquema '
            'a tu caso y resuelve los efectos secundarios.',
      ],
    ),
    EduTopic(
      id: 'salud-mental',
      title: 'Salud mental y VIH',
      summary: 'Cuidar tus emociones también es parte del tratamiento.',
      icon: Icons.self_improvement_rounded,
      readMinutes: 3,
      body: [
        'Recibir un diagnóstico o convivir con el VIH puede traer emociones '
            'difíciles. Pedir apoyo es un acto de fortaleza, no de debilidad.',
        'El acompañamiento psicológico, los grupos de apoyo y hablar con '
            'personas de confianza ayudan a sobrellevar el proceso.',
        'Si te sientes abrumado/a o tienes pensamientos de hacerte daño, busca '
            'ayuda profesional de inmediato. No estás solo/a.',
      ],
    ),
  ];
}

/// Una historia de éxito / testimonio inspirador.
class SuccessStory {
  const SuccessStory({
    required this.name,
    required this.tag,
    required this.quote,
  });

  final String name;
  final String tag;
  final String quote;

  static const List<SuccessStory> demoData = <SuccessStory>[
    SuccessStory(
      name: 'María, 29',
      tag: 'Vive con VIH hace 4 años',
      quote:
          'El día del diagnóstico pensé que mi vida terminaba. Hoy, con mi '
          'tratamiento, estoy indetectable y más sana que nunca.',
    ),
    SuccessStory(
      name: 'Carlos, 35',
      tag: 'Usa PrEP',
      quote:
          'Informarme me quitó el miedo. La prevención me dio tranquilidad para '
          'vivir mi sexualidad con responsabilidad.',
    ),
  ];
}

/// Una alerta de campaña local (pruebas, vacunación, charlas).
class Campaign {
  const Campaign({
    required this.title,
    required this.date,
    required this.location,
  });

  final String title;
  final String date;
  final String location;

  static const Campaign featured = Campaign(
    title: 'Jornada de pruebas gratuitas de VIH',
    date: 'Sábado 14 de junio · 9:00–15:00',
    location: 'Plaza Bolívar, Caracas',
  );
}
