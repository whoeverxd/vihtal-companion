# Directorio médico + Laboratorios cercanos — Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Agregar en el inicio un slider con "Directorio médico" y "Laboratorios cercanos", más sus pantallas (médicos agrupados por especialidad; labs ordenados por distancia con sus exámenes) y detalle por pantalla propia, con contacto por WhatsApp.

**Architecture:** Pila plana idiomática del repo: `lib/{models,services,screens,widgets}`, Firestore denormalizado (sin tablas join), estado con `StatefulWidget`/`setState` (sin Riverpod), tema `AppColors`, iconos Material, geolocalización reusando el `LocationService` existente. Las funciones puras (parseo `fromMap`, agrupación, formato, URI de WhatsApp) se aíslan para ser testeables.

**Tech Stack:** Flutter, `cloud_firestore`, `firebase_core`, `geolocator` (vía `LocationService`), `url_launcher`, `go_router`, tema `lib/theme.dart`.

**Spec:** `docs/superpowers/specs/2026-06-21-directorio-medico-labs-firebase-design.md`

---

## Convenciones del repo (recordatorio para quien implementa)

- **Imports en lib:** relativos (`import '../theme.dart';`, `import '../models/lab.dart';`). NO `package:vihtal_companion/...` dentro de `lib/`.
- **Imports en tests:** `package:vihtal_companion/...`.
- **Tema:** solo `AppColors.*` de `lib/theme.dart`. Iconos `Icons.*` (Material). NO heroicons, NO `ck_tokens`, NO Riverpod, NO Supabase.
- **Logging:** `debugPrint` (no existe `AppLogger`).
- **Servicios Firestore:** patrón de `lib/services/community_forum_service.dart` (instancia defensiva, `fromDoc`, `ensureSeedData`, IDs `String`).
- **Geolocalización:** `lib/services/location_service.dart` ya tiene `getCurrentLocation()` y `distanceKm(LatLng, LatLng)`.
- **App bar:** `VihtalAppBar(showDonateAction: false, leading: BackButton(...))` para pantallas internas.
- **Commits frecuentes**, uno por tarea. Mensaje al final con:
  `Co-Authored-By: Claude Opus 4.8 (1M context) <noreply@anthropic.com>`

## Esquema Firestore (lo siembra `ensureSeedData`; también poblable a mano)

```
doctors/{autoId}: { name, photoUrl?, bio?, whatsappPhone?, specialties: [string] }
labs/{autoId}:    { name, whatsappPhone?, address?, city?, lat?, lng?, exams: [ {name, priceCents?} ] }
```

## File Structure

**Crear:**
- `lib/models/doctor.dart` — `Doctor` + `fromMap`/`fromDoc`; `SpecialtyGroup` + `groupDoctorsBySpecialty`.
- `lib/models/lab.dart` — `LabExam`, `Lab` (+ `fromMap`/`fromDoc`/`copyWithDistance`); helpers puros `formatDistanceKm`, `formatPrice`.
- `lib/services/contact.dart` — `buildWhatsappUri`, `openWhatsapp`.
- `lib/services/directory_service.dart` — Firestore directo: `fetchDoctors()`, `fetchLabs()`, `ensureSeedData()`.
- `lib/widgets/home_directory_slider.dart` — `DirectorySlide` + `HomeDirectorySlider` (presentacional).
- `lib/screens/doctor_detail_screen.dart`
- `lib/screens/medical_directory_screen.dart`
- `lib/screens/lab_detail_screen.dart`
- `lib/screens/nearby_labs_screen.dart`
- Tests: `test/doctor_test.dart`, `test/lab_test.dart`, `test/contact_test.dart`.

**Modificar:**
- `lib/router/app_router.dart` — 4 rutas + imports.
- `lib/screens/home_screen.dart` — insertar el slider.

---

## Task 1: Modelo Doctor + fromMap

**Files:**
- Create: `lib/models/doctor.dart`
- Test: `test/doctor_test.dart`

- [ ] **Step 1: Write the failing test**

```dart
// test/doctor_test.dart
import 'package:flutter_test/flutter_test.dart';

import 'package:vihtal_companion/models/doctor.dart';

void main() {
  group('Doctor.fromMap', () {
    test('parsea campos y especialidades', () {
      final d = Doctor.fromMap({
        'name': 'Dra. Ana',
        'photoUrl': 'https://x/a.jpg',
        'bio': 'Pediatra',
        'whatsappPhone': '584120000001',
        'specialties': ['Pediatría', 'Nutrición'],
      }, 'doc1');
      expect(d.id, 'doc1');
      expect(d.name, 'Dra. Ana');
      expect(d.photoUrl, 'https://x/a.jpg');
      expect(d.whatsappPhone, '584120000001');
      expect(d.specialties, ['Pediatría', 'Nutrición']);
    });

    test('tolera ausencia de campos opcionales', () {
      final d = Doctor.fromMap({'name': 'Dr. Z'}, 'doc2');
      expect(d.name, 'Dr. Z');
      expect(d.photoUrl, isNull);
      expect(d.bio, isNull);
      expect(d.whatsappPhone, isNull);
      expect(d.specialties, isEmpty);
    });

    test('castea items de specialties a String', () {
      final d = Doctor.fromMap({
        'name': 'Dr. Y',
        'specialties': ['Cardiología', 123],
      }, 'doc3');
      expect(d.specialties, ['Cardiología', '123']);
    });
  });
}
```

- [ ] **Step 2: Run test to verify it fails**

Run: `flutter test test/doctor_test.dart`
Expected: FAIL — `Doctor` no existe (error de compilación).

- [ ] **Step 3: Write minimal implementation**

```dart
// lib/models/doctor.dart
import 'package:cloud_firestore/cloud_firestore.dart';

/// Médico del directorio. Colección `doctors`.
class Doctor {
  const Doctor({
    required this.id,
    required this.name,
    this.photoUrl,
    this.bio,
    this.whatsappPhone,
    this.specialties = const [],
  });

  final String id;
  final String name;
  final String? photoUrl;
  final String? bio;
  final String? whatsappPhone;
  final List<String> specialties;

  factory Doctor.fromMap(Map<String, dynamic> data, String id) {
    final raw = (data['specialties'] as List?) ?? const [];
    return Doctor(
      id: id,
      name: (data['name'] as String?) ?? '',
      photoUrl: data['photoUrl'] as String?,
      bio: data['bio'] as String?,
      whatsappPhone: data['whatsappPhone'] as String?,
      specialties: raw.map((e) => e.toString()).toList(),
    );
  }

  factory Doctor.fromDoc(DocumentSnapshot<Map<String, dynamic>> doc) =>
      Doctor.fromMap(doc.data() ?? const <String, dynamic>{}, doc.id);
}
```

- [ ] **Step 4: Run test to verify it passes**

Run: `flutter test test/doctor_test.dart`
Expected: PASS (3 tests).

- [ ] **Step 5: Commit**

```bash
git add lib/models/doctor.dart test/doctor_test.dart
git commit -m "feat(directory): modelo Doctor con fromMap/fromDoc"
```

---

## Task 2: Agrupación por especialidad

**Files:**
- Modify: `lib/models/doctor.dart`
- Test: `test/doctor_test.dart`

- [ ] **Step 1: Write the failing test**

Añadir DENTRO de `void main()` en `test/doctor_test.dart`, después del grupo existente, un nuevo grupo (y agregar el import si hace falta — ya está):

```dart
  group('groupDoctorsBySpecialty', () {
    Doctor doc(String id, String name, List<String> specs) =>
        Doctor(id: id, name: name, specialties: specs);

    test('multi-especialidad aparece en cada grupo, orden alfabético', () {
      final ana = doc('1', 'Ana', ['Cardiología', 'Pediatría']);
      final beto = doc('2', 'Beto', ['Cardiología']);

      final groups = groupDoctorsBySpecialty([ana, beto]);

      expect(groups.map((g) => g.specialty), ['Cardiología', 'Pediatría']);
      expect(groups[0].doctors.map((d) => d.name), ['Ana', 'Beto']);
      expect(groups[1].doctors.map((d) => d.name), ['Ana']);
    });

    test('doctor sin especialidad cae en "Otros" al final', () {
      final zoe = doc('3', 'Zoe', const []);
      final groups = groupDoctorsBySpecialty([zoe]);
      expect(groups.last.specialty, 'Otros');
      expect(groups.last.doctors.single.name, 'Zoe');
    });
  });
```

- [ ] **Step 2: Run test to verify it fails**

Run: `flutter test test/doctor_test.dart`
Expected: FAIL — `groupDoctorsBySpecialty` / `SpecialtyGroup` no existen.

- [ ] **Step 3: Write minimal implementation**

Añadir al FINAL de `lib/models/doctor.dart`:

```dart
/// Una especialidad con los doctores que la ejercen.
class SpecialtyGroup {
  const SpecialtyGroup({required this.specialty, required this.doctors});

  final String specialty;
  final List<Doctor> doctors;
}

const String _otros = 'Otros';

/// Agrupa doctores por especialidad (alfabético). Un doctor con N especialidades
/// aparece en los N grupos. Los doctores sin especialidad caen en "Otros" al
/// final. Dentro de cada grupo, doctores ordenados por nombre.
List<SpecialtyGroup> groupDoctorsBySpecialty(List<Doctor> doctors) {
  final buckets = <String, List<Doctor>>{};

  for (final doc in doctors) {
    if (doc.specialties.isEmpty) {
      (buckets[_otros] ??= []).add(doc);
      continue;
    }
    for (final spec in doc.specialties) {
      (buckets[spec] ??= []).add(doc);
    }
  }

  final groups = buckets.entries.map((e) {
    final docs = [...e.value]..sort((a, b) => a.name.compareTo(b.name));
    return SpecialtyGroup(specialty: e.key, doctors: docs);
  }).toList();

  groups.sort((a, b) {
    if (a.specialty == _otros) return 1;
    if (b.specialty == _otros) return -1;
    return a.specialty.compareTo(b.specialty);
  });

  return groups;
}
```

- [ ] **Step 4: Run test to verify it passes**

Run: `flutter test test/doctor_test.dart`
Expected: PASS (5 tests).

- [ ] **Step 5: Commit**

```bash
git add lib/models/doctor.dart test/doctor_test.dart
git commit -m "feat(directory): groupDoctorsBySpecialty"
```

---

## Task 3: Modelo Lab + LabExam + formatos

**Files:**
- Create: `lib/models/lab.dart`
- Test: `test/lab_test.dart`

- [ ] **Step 1: Write the failing test**

```dart
// test/lab_test.dart
import 'package:flutter_test/flutter_test.dart';

import 'package:vihtal_companion/models/lab.dart';

void main() {
  group('Lab.fromMap', () {
    test('parsea campos, coords y exámenes', () {
      final lab = Lab.fromMap({
        'name': 'Lab Central',
        'whatsappPhone': '584120000010',
        'address': 'Av. Urdaneta',
        'city': 'Caracas',
        'lat': 10.5061,
        'lng': -66.9146,
        'exams': [
          {'name': 'Hemograma', 'priceCents': 150000},
          {'name': 'Glucemia'},
        ],
      }, 'lab1');

      expect(lab.id, 'lab1');
      expect(lab.name, 'Lab Central');
      expect(lab.lat, 10.5061);
      expect(lab.lng, -66.9146);
      expect(lab.distanceKm, isNull);
      expect(lab.exams.length, 2);
      expect(lab.exams[0].name, 'Hemograma');
      expect(lab.exams[0].priceCents, 150000);
      expect(lab.exams[1].priceCents, isNull);
    });

    test('tolera ausencia de coords y exámenes', () {
      final lab = Lab.fromMap({'name': 'Lab Z'}, 'lab2');
      expect(lab.lat, isNull);
      expect(lab.lng, isNull);
      expect(lab.exams, isEmpty);
    });
  });

  group('copyWithDistance', () {
    test('asigna la distancia sin perder el resto', () {
      final lab = Lab.fromMap({'name': 'Lab'}, 'l').copyWithDistance(2.5);
      expect(lab.distanceKm, 2.5);
      expect(lab.name, 'Lab');
    });
  });

  group('formatDistanceKm', () {
    test('null -> vacío', () => expect(formatDistanceKm(null), ''));
    test('< 1 km -> metros', () => expect(formatDistanceKm(0.85), '850 m'));
    test('>= 1 km -> un decimal', () => expect(formatDistanceKm(1.234), '1.2 km'));
    test('redondea', () => expect(formatDistanceKm(1.98), '2.0 km'));
  });

  group('formatPrice', () {
    test('null -> vacío', () => expect(formatPrice(null), ''));
    test('entero -> sin decimales ni símbolo', () => expect(formatPrice(150000), '1500'));
    test('con centavos -> dos decimales', () => expect(formatPrice(150050), '1500.50'));
  });
}
```

- [ ] **Step 2: Run test to verify it fails**

Run: `flutter test test/lab_test.dart`
Expected: FAIL — `Lab` / `formatDistanceKm` / `formatPrice` no existen.

- [ ] **Step 3: Write minimal implementation**

```dart
// lib/models/lab.dart
import 'package:cloud_firestore/cloud_firestore.dart';

/// Examen ofrecido por un lab. Vive en el array `exams` del doc del lab.
class LabExam {
  const LabExam({required this.name, this.priceCents});

  final String name;

  /// Precio en centavos. Null si no se publica.
  final int? priceCents;

  factory LabExam.fromMap(Map<String, dynamic> map) {
    final price = map['priceCents'];
    return LabExam(
      name: (map['name'] as String?) ?? '',
      priceCents: price == null ? null : (price as num).toInt(),
    );
  }
}

/// Laboratorio. Colección `labs`.
class Lab {
  const Lab({
    required this.id,
    required this.name,
    this.whatsappPhone,
    this.address,
    this.city,
    this.lat,
    this.lng,
    this.exams = const [],
    this.distanceKm,
  });

  final String id;
  final String name;
  final String? whatsappPhone;
  final String? address;
  final String? city;
  final double? lat;
  final double? lng;
  final List<LabExam> exams;

  /// Distancia al usuario en km. La calcula la pantalla en runtime; no viene de
  /// Firestore.
  final double? distanceKm;

  Lab copyWithDistance(double? km) => Lab(
        id: id,
        name: name,
        whatsappPhone: whatsappPhone,
        address: address,
        city: city,
        lat: lat,
        lng: lng,
        exams: exams,
        distanceKm: km,
      );

  factory Lab.fromMap(Map<String, dynamic> data, String id) {
    final rawExams = (data['exams'] as List?) ?? const [];
    return Lab(
      id: id,
      name: (data['name'] as String?) ?? '',
      whatsappPhone: data['whatsappPhone'] as String?,
      address: data['address'] as String?,
      city: data['city'] as String?,
      lat: (data['lat'] as num?)?.toDouble(),
      lng: (data['lng'] as num?)?.toDouble(),
      exams: rawExams
          .whereType<Map>()
          .map((e) => LabExam.fromMap(Map<String, dynamic>.from(e)))
          .toList(),
    );
  }

  factory Lab.fromDoc(DocumentSnapshot<Map<String, dynamic>> doc) =>
      Lab.fromMap(doc.data() ?? const <String, dynamic>{}, doc.id);
}

/// Formatea distancia en km a texto legible: "850 m" o "1.2 km". Null -> ''.
String formatDistanceKm(double? km) {
  if (km == null) return '';
  if (km < 1) return '${(km * 1000).round()} m';
  return '${km.toStringAsFixed(1)} km';
}

/// Formatea un precio en centavos a número SIN símbolo de moneda.
/// Entero -> sin decimales ("1500"); con centavos -> dos decimales ("1500.50").
/// Null -> ''.
String formatPrice(int? priceCents) {
  if (priceCents == null) return '';
  final value = priceCents / 100;
  return value == value.roundToDouble()
      ? value.toStringAsFixed(0)
      : value.toStringAsFixed(2);
}
```

- [ ] **Step 4: Run test to verify it passes**

Run: `flutter test test/lab_test.dart`
Expected: PASS (8 tests).

- [ ] **Step 5: Commit**

```bash
git add lib/models/lab.dart test/lab_test.dart
git commit -m "feat(directory): modelo Lab + LabExam + formatos"
```

---

## Task 4: Contacto por WhatsApp

**Files:**
- Create: `lib/services/contact.dart`
- Test: `test/contact_test.dart`

- [ ] **Step 1: Write the failing test**

```dart
// test/contact_test.dart
import 'package:flutter_test/flutter_test.dart';

import 'package:vihtal_companion/services/contact.dart';

void main() {
  group('buildWhatsappUri', () {
    test('limpia el teléfono (sin +, espacios ni guiones)', () {
      final uri = buildWhatsappUri('+58 412-000', text: 'Hola');
      expect(uri.host, 'wa.me');
      expect(uri.path, '/58412000');
      expect(uri.queryParameters['text'], 'Hola');
    });

    test('sin texto -> sin query', () {
      final uri = buildWhatsappUri('58412');
      expect(uri.toString(), 'https://wa.me/58412');
    });
  });
}
```

- [ ] **Step 2: Run test to verify it fails**

Run: `flutter test test/contact_test.dart`
Expected: FAIL — `buildWhatsappUri` no existe.

- [ ] **Step 3: Write minimal implementation**

```dart
// lib/services/contact.dart
import 'package:flutter/foundation.dart';
import 'package:url_launcher/url_launcher.dart';

/// Construye `https://wa.me/<phone>?text=...` dejando solo dígitos en el teléfono.
/// El [text] es opcional.
Uri buildWhatsappUri(String phone, {String? text}) {
  final digits = phone.replaceAll(RegExp(r'[^0-9]'), '');
  return Uri.https(
    'wa.me',
    '/$digits',
    (text != null && text.isNotEmpty) ? {'text': text} : null,
  );
}

/// Abre WhatsApp para [phone]. No-op si el teléfono queda vacío.
Future<void> openWhatsapp(String? phone, {String? text}) async {
  if (phone == null || phone.replaceAll(RegExp(r'[^0-9]'), '').isEmpty) return;
  final uri = buildWhatsappUri(phone, text: text);
  try {
    await launchUrl(uri, mode: LaunchMode.externalApplication);
  } catch (e) {
    debugPrint('[contact] no se pudo abrir WhatsApp: $e');
  }
}
```

- [ ] **Step 4: Run test to verify it passes**

Run: `flutter test test/contact_test.dart`
Expected: PASS (2 tests).

- [ ] **Step 5: Commit**

```bash
git add lib/services/contact.dart test/contact_test.dart
git commit -m "feat(directory): helper de contacto por WhatsApp"
```

---

## Task 5: DirectoryService (Firestore + seed)

Sin test unitario (toca Firestore). Se verifica con `flutter analyze`.

**Files:**
- Create: `lib/services/directory_service.dart`

- [ ] **Step 1: Implementar el service**

```dart
// lib/services/directory_service.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

import '../models/doctor.dart';
import '../models/lab.dart';

/// Lee médicos y laboratorios desde Firestore. Patrón defensivo de
/// `community_forum_service.dart`: si Firestore no está, degrada a listas vacías.
class DirectoryService {
  DirectoryService({FirebaseFirestore? firestore})
      : _firestore = firestore ?? _tryGetFirestoreInstance();

  final FirebaseFirestore? _firestore;

  static FirebaseFirestore? _tryGetFirestoreInstance() {
    try {
      return FirebaseFirestore.instance;
    } catch (_) {
      return null;
    }
  }

  CollectionReference<Map<String, dynamic>>? get _doctors =>
      _firestore?.collection('doctors');

  CollectionReference<Map<String, dynamic>>? get _labs =>
      _firestore?.collection('labs');

  Future<List<Doctor>> fetchDoctors() async {
    final col = _doctors;
    if (col == null) return const [];
    try {
      final snap = await col.orderBy('name').get();
      return snap.docs.map(Doctor.fromDoc).toList();
    } catch (e) {
      debugPrint('[directory] fetchDoctors falló: $e');
      return const [];
    }
  }

  Future<List<Lab>> fetchLabs() async {
    final col = _labs;
    if (col == null) return const [];
    try {
      final snap = await col.orderBy('name').get();
      return snap.docs.map(Lab.fromDoc).toList();
    } catch (e) {
      debugPrint('[directory] fetchLabs falló: $e');
      return const [];
    }
  }

  /// Siembra datos demo si las colecciones están vacías. No son datos reales.
  Future<void> ensureSeedData() async {
    await _seedDoctors();
    await _seedLabs();
  }

  Future<void> _seedDoctors() async {
    final col = _doctors;
    final db = _firestore;
    if (col == null || db == null) return;
    try {
      final existing = await col.limit(1).get();
      if (existing.docs.isNotEmpty) return;

      final seeds = <Map<String, dynamic>>[
        {
          'name': 'Dra. Ana Martínez',
          'bio': 'Pediatra con 12 años de experiencia.',
          'whatsappPhone': '584120000001',
          'specialties': ['Pediatría'],
        },
        {
          'name': 'Dr. Luis Pérez',
          'bio': 'Cardiólogo clínico.',
          'whatsappPhone': '584120000002',
          'specialties': ['Cardiología'],
        },
        {
          'name': 'Dra. Carla Gómez',
          'bio': 'Cardiología y medicina interna.',
          'whatsappPhone': '584120000003',
          'specialties': ['Cardiología', 'Medicina Interna'],
        },
        {
          'name': 'Dr. José Rodríguez',
          'bio': 'Ginecólogo.',
          'whatsappPhone': '584120000004',
          'specialties': ['Ginecología'],
        },
      ];

      final batch = db.batch();
      for (final seed in seeds) {
        batch.set(col.doc(), seed);
      }
      await batch.commit();
    } catch (e) {
      debugPrint('[directory] no se pudo sembrar doctors: $e');
    }
  }

  Future<void> _seedLabs() async {
    final col = _labs;
    final db = _firestore;
    if (col == null || db == null) return;
    try {
      final existing = await col.limit(1).get();
      if (existing.docs.isNotEmpty) return;

      final seeds = <Map<String, dynamic>>[
        {
          'name': 'Laboratorio Central',
          'whatsappPhone': '584120000010',
          'address': 'Av. Urdaneta',
          'city': 'Caracas',
          'lat': 10.5061,
          'lng': -66.9146,
          'exams': [
            {'name': 'Hemograma', 'priceCents': 150000},
            {'name': 'Glucemia', 'priceCents': 90000},
          ],
        },
        {
          'name': 'Lab Salud Sexual',
          'whatsappPhone': '584120000011',
          'address': 'Av. Francisco de Miranda, Chacao',
          'city': 'Caracas',
          'lat': 10.4920,
          'lng': -66.8530,
          'exams': [
            {'name': 'Carga viral VIH', 'priceCents': 800000},
            {'name': 'Prueba VIH rápida', 'priceCents': 200000},
          ],
        },
        {
          'name': 'Diagnóstica Caracas',
          'whatsappPhone': '584120000012',
          'address': 'Los Palos Grandes',
          'city': 'Caracas',
          'lat': 10.4980,
          'lng': -66.8430,
          'exams': [
            {'name': 'Hemograma', 'priceCents': 140000},
            {'name': 'Perfil lipídico', 'priceCents': 250000},
          ],
        },
      ];

      final batch = db.batch();
      for (final seed in seeds) {
        batch.set(col.doc(), seed);
      }
      await batch.commit();
    } catch (e) {
      debugPrint('[directory] no se pudo sembrar labs: $e');
    }
  }
}
```

- [ ] **Step 2: Verificar compilación**

Run: `flutter analyze lib/services/directory_service.dart`
Expected: "No issues found!"

- [ ] **Step 3: Commit**

```bash
git add lib/services/directory_service.dart
git commit -m "feat(directory): DirectoryService Firestore + seed demo"
```

---

## Task 6: Slider del inicio (widget presentacional)

**Files:**
- Create: `lib/widgets/home_directory_slider.dart`

- [ ] **Step 1: Implementar el slider**

```dart
// lib/widgets/home_directory_slider.dart
import 'package:flutter/material.dart';

import '../theme.dart';

/// Una diapositiva del slider del inicio.
class DirectorySlide {
  const DirectorySlide({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.accent,
    required this.onTap,
  });

  final String title;
  final String subtitle;
  final IconData icon;
  final Color accent;
  final VoidCallback onTap;
}

/// Carrusel horizontal de tarjetas grandes para el inicio. Presentacional.
class HomeDirectorySlider extends StatefulWidget {
  const HomeDirectorySlider({super.key, required this.slides});

  final List<DirectorySlide> slides;

  @override
  State<HomeDirectorySlider> createState() => _HomeDirectorySliderState();
}

class _HomeDirectorySliderState extends State<HomeDirectorySlider> {
  final PageController _controller = PageController(viewportFraction: 0.9);
  int _page = 0;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(
          height: 132,
          child: PageView.builder(
            controller: _controller,
            itemCount: widget.slides.length,
            onPageChanged: (i) => setState(() => _page = i),
            itemBuilder: (_, i) => Padding(
              padding: const EdgeInsets.symmetric(horizontal: 6),
              child: _SlideCard(slide: widget.slides[i]),
            ),
          ),
        ),
        const SizedBox(height: 10),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(widget.slides.length, (i) {
            final active = i == _page;
            return AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              margin: const EdgeInsets.symmetric(horizontal: 3),
              width: active ? 18 : 6,
              height: 6,
              decoration: BoxDecoration(
                color: active ? AppColors.primary : AppColors.border,
                borderRadius: BorderRadius.circular(3),
              ),
            );
          }),
        ),
      ],
    );
  }
}

class _SlideCard extends StatelessWidget {
  const _SlideCard({required this.slide});

  final DirectorySlide slide;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: slide.accent,
      borderRadius: BorderRadius.circular(20),
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: slide.onTap,
        child: Padding(
          padding: const EdgeInsets.all(18),
          child: Row(
            children: [
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Icon(slide.icon, color: Colors.white, size: 26),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      slide.title,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 17,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      slide.subtitle,
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.85),
                        fontSize: 13,
                        height: 1.25,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.arrow_forward_rounded, color: Colors.white, size: 20),
            ],
          ),
        ),
      ),
    );
  }
}
```

- [ ] **Step 2: Verificar compilación**

Run: `flutter analyze lib/widgets/home_directory_slider.dart`
Expected: "No issues found!"

- [ ] **Step 3: Commit**

```bash
git add lib/widgets/home_directory_slider.dart
git commit -m "feat(directory): slider del inicio (presentacional)"
```

---

## Task 7: Rutas (constantes)

**Files:**
- Modify: `lib/router/app_router.dart`

- [ ] **Step 1: Agregar las constantes de ruta**

En `lib/router/app_router.dart`, en la clase `AppRoutes` (después de `settings`, ~línea 53), agregar:

```dart
  static const String directory = '/directorio';
  static const String doctorDetail = '/directorio/medico';
  static const String labs = '/laboratorios';
  static const String labDetail = '/laboratorios/lab';
```

> Nota: las entradas `GoRoute` se agregan en la Task 12 (cuando las pantallas ya existen). Aquí solo se agregan las constantes para que las pantallas puedan referenciarlas.

- [ ] **Step 2: Verificar compilación**

Run: `flutter analyze lib/router/app_router.dart`
Expected: "No issues found!" (constantes sin usar todavía no son error).

- [ ] **Step 3: Commit**

```bash
git add lib/router/app_router.dart
git commit -m "feat(directory): constantes de ruta de directorio y labs"
```

---

## Task 8: Pantalla de detalle de médico

**Files:**
- Create: `lib/screens/doctor_detail_screen.dart`

- [ ] **Step 1: Implementar la pantalla**

```dart
// lib/screens/doctor_detail_screen.dart
import 'package:flutter/material.dart';

import '../models/doctor.dart';
import '../services/contact.dart';
import '../theme.dart';
import '../widgets/vihtal_app_bar.dart';

/// Detalle de un médico. Recibe el [Doctor] por `extra` en la ruta.
class DoctorDetailScreen extends StatelessWidget {
  const DoctorDetailScreen({super.key, required this.doctor});

  final Doctor doctor;

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
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
        children: [
          Row(
            children: [
              _Avatar(doctor: doctor),
              const SizedBox(width: 14),
              Expanded(
                child: Text(
                  doctor.name,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          if (doctor.specialties.isNotEmpty)
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                for (final s in doctor.specialties) _SpecialtyChip(label: s),
              ],
            ),
          if (doctor.bio != null && doctor.bio!.isNotEmpty) ...[
            const SizedBox(height: 16),
            Text(
              doctor.bio!,
              style: const TextStyle(
                fontSize: 14,
                height: 1.4,
                color: AppColors.textSecondary,
              ),
            ),
          ],
          if (doctor.whatsappPhone != null) ...[
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () => openWhatsapp(
                doctor.whatsappPhone,
                text: 'Hola ${doctor.name}, te contacto desde VIHTAL.',
              ),
              icon: const Icon(Icons.chat_rounded, size: 18),
              label: const Text('Contactar por WhatsApp'),
            ),
          ],
        ],
      ),
    );
  }
}

class _Avatar extends StatelessWidget {
  const _Avatar({required this.doctor});

  final Doctor doctor;

  @override
  Widget build(BuildContext context) {
    final initial = doctor.name.isEmpty ? '?' : doctor.name.characters.first;
    final hasPhoto = doctor.photoUrl != null && doctor.photoUrl!.isNotEmpty;
    return Container(
      width: 56,
      height: 56,
      clipBehavior: Clip.antiAlias,
      decoration: const BoxDecoration(
        color: AppColors.surfaceSoft,
        shape: BoxShape.circle,
      ),
      child: hasPhoto
          ? Image.network(
              doctor.photoUrl!,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => _Initial(initial: initial),
            )
          : _Initial(initial: initial),
    );
  }
}

class _Initial extends StatelessWidget {
  const _Initial({required this.initial});

  final String initial;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(
        initial.toUpperCase(),
        style: const TextStyle(
          fontSize: 22,
          fontWeight: FontWeight.w800,
          color: AppColors.primary,
        ),
      ),
    );
  }
}

class _SpecialtyChip extends StatelessWidget {
  const _SpecialtyChip({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.surfaceSoft,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        label,
        style: const TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w700,
          color: AppColors.accent,
        ),
      ),
    );
  }
}
```

- [ ] **Step 2: Verificar compilación**

Run: `flutter analyze lib/screens/doctor_detail_screen.dart`
Expected: "No issues found!"

- [ ] **Step 3: Commit**

```bash
git add lib/screens/doctor_detail_screen.dart
git commit -m "feat(directory): pantalla de detalle de médico"
```

---

## Task 9: Pantalla de directorio médico

**Files:**
- Create: `lib/screens/medical_directory_screen.dart`

- [ ] **Step 1: Implementar la pantalla**

```dart
// lib/screens/medical_directory_screen.dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../models/doctor.dart';
import '../router/app_router.dart';
import '../services/directory_service.dart';
import '../theme.dart';
import '../widgets/vihtal_app_bar.dart';

/// Directorio médico: médicos agrupados por especialidad, con buscador.
class MedicalDirectoryScreen extends StatefulWidget {
  const MedicalDirectoryScreen({super.key, this.service});

  final DirectoryService? service;

  @override
  State<MedicalDirectoryScreen> createState() => _MedicalDirectoryScreenState();
}

class _MedicalDirectoryScreenState extends State<MedicalDirectoryScreen> {
  late final DirectoryService _service = widget.service ?? DirectoryService();

  List<Doctor> _doctors = const [];
  bool _loading = true;
  String? _error;
  String _query = '';

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      await _service.ensureSeedData();
      final doctors = await _service.fetchDoctors();
      if (!mounted) return;
      setState(() => _doctors = doctors);
    } catch (e) {
      if (!mounted) return;
      setState(() => _error = 'No se pudo cargar el directorio.');
    } finally {
      if (mounted) setState(() => _loading = false);
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
      body: Padding(
        padding: const EdgeInsets.fromLTRB(16, 4, 16, 0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text('Directorio médico',
                style: Theme.of(context).textTheme.headlineMedium),
            const SizedBox(height: 12),
            TextField(
              onChanged: (v) => setState(() => _query = v.trim().toLowerCase()),
              decoration: InputDecoration(
                hintText: 'Buscar médico…',
                prefixIcon: const Icon(Icons.search_rounded),
                filled: true,
                fillColor: AppColors.surface,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: const BorderSide(color: AppColors.border),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: const BorderSide(color: AppColors.border),
                ),
              ),
            ),
            const SizedBox(height: 12),
            Expanded(child: _buildBody()),
          ],
        ),
      ),
    );
  }

  Widget _buildBody() {
    if (_loading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_error != null) {
      return _ErrorState(message: _error!, onRetry: _load);
    }

    final filtered = _query.isEmpty
        ? _doctors
        : _doctors.where((d) => d.name.toLowerCase().contains(_query)).toList();

    if (filtered.isEmpty) {
      return const Center(
        child: Text('No se encontraron médicos',
            style: TextStyle(color: AppColors.textSecondary)),
      );
    }

    final groups = groupDoctorsBySpecialty(filtered);
    return ListView(
      padding: const EdgeInsets.only(bottom: 24),
      children: [
        for (final g in groups) ...[
          Padding(
            padding: const EdgeInsets.fromLTRB(2, 8, 2, 10),
            child: Text(g.specialty,
                style: Theme.of(context).textTheme.titleMedium),
          ),
          for (final d in g.doctors) ...[
            _DoctorCard(
              doctor: d,
              onTap: () => context.push(AppRoutes.doctorDetail, extra: d),
            ),
            const SizedBox(height: 10),
          ],
        ],
      ],
    );
  }
}

class _DoctorCard extends StatelessWidget {
  const _DoctorCard({required this.doctor, required this.onTap});

  final Doctor doctor;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final specs = doctor.specialties.join(' · ');
    return Material(
      color: AppColors.surface,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.border),
          ),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      doctor.name,
                      style: const TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 15,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      specs.isEmpty ? 'Sin especialidad' : specs,
                      style: const TextStyle(
                        fontSize: 13,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right_rounded,
                  color: AppColors.textSecondary),
            ],
          ),
        ),
      ),
    );
  }
}

class _ErrorState extends StatelessWidget {
  const _ErrorState({required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(message,
              style: const TextStyle(color: AppColors.textSecondary)),
          const SizedBox(height: 12),
          TextButton(onPressed: onRetry, child: const Text('Reintentar')),
        ],
      ),
    );
  }
}
```

- [ ] **Step 2: Verificar compilación**

Run: `flutter analyze lib/screens/medical_directory_screen.dart`
Expected: "No issues found!"

- [ ] **Step 3: Commit**

```bash
git add lib/screens/medical_directory_screen.dart
git commit -m "feat(directory): pantalla directorio médico agrupado por especialidad"
```

---

## Task 10: Pantalla de detalle de laboratorio

**Files:**
- Create: `lib/screens/lab_detail_screen.dart`

- [ ] **Step 1: Implementar la pantalla**

```dart
// lib/screens/lab_detail_screen.dart
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../models/lab.dart';
import '../services/contact.dart';
import '../theme.dart';
import '../widgets/vihtal_app_bar.dart';

/// Detalle de un laboratorio. Recibe el [Lab] por `extra` en la ruta.
class LabDetailScreen extends StatelessWidget {
  const LabDetailScreen({super.key, required this.lab});

  final Lab lab;

  @override
  Widget build(BuildContext context) {
    final location = [lab.address, lab.city]
        .where((s) => s != null && s.isNotEmpty)
        .join(', ');

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: VihtalAppBar(
        showDonateAction: false,
        leading: BackButton(
          color: AppColors.primary,
          onPressed: () => Navigator.of(context).maybePop(),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
        children: [
          Text(lab.name,
              style: Theme.of(context).textTheme.headlineMedium),
          if (location.isNotEmpty) ...[
            const SizedBox(height: 6),
            Text(location,
                style: const TextStyle(
                    fontSize: 14, color: AppColors.textSecondary)),
          ],
          const SizedBox(height: 20),
          Text('Exámenes',
              style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 8),
          if (lab.exams.isEmpty)
            const Text('Este laboratorio no cargó exámenes todavía.',
                style: TextStyle(color: AppColors.textSecondary))
          else
            for (final e in lab.exams) _ExamRow(exam: e),
          const SizedBox(height: 24),
          if (lab.whatsappPhone != null)
            ElevatedButton.icon(
              onPressed: () => openWhatsapp(
                lab.whatsappPhone,
                text: 'Hola ${lab.name}, te contacto desde VIHTAL.',
              ),
              icon: const Icon(Icons.chat_rounded, size: 18),
              label: const Text('Contactar por WhatsApp'),
            ),
          if (lab.lat != null && lab.lng != null) ...[
            const SizedBox(height: 10),
            OutlinedButton.icon(
              onPressed: () => _openDirections(context, lab),
              icon: const Icon(Icons.directions_rounded, size: 18),
              label: const Text('Cómo llegar'),
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.primary,
                side: const BorderSide(color: AppColors.border),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(999),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _ExamRow extends StatelessWidget {
  const _ExamRow({required this.exam});

  final LabExam exam;

  @override
  Widget build(BuildContext context) {
    final price = formatPrice(exam.priceCents);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Text(exam.name,
                style: const TextStyle(
                    fontSize: 14, color: AppColors.textPrimary)),
          ),
          if (price.isNotEmpty)
            Text(price,
                style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textSecondary)),
        ],
      ),
    );
  }
}

Future<void> _openDirections(BuildContext context, Lab lab) async {
  final uri = Uri.parse(
    'https://www.google.com/maps/search/?api=1&query=${lab.lat},${lab.lng}',
  );
  if (!await launchUrl(uri, mode: LaunchMode.externalApplication) &&
      context.mounted) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('No se pudo abrir el mapa.')),
    );
  }
}
```

- [ ] **Step 2: Verificar compilación**

Run: `flutter analyze lib/screens/lab_detail_screen.dart`
Expected: "No issues found!"

- [ ] **Step 3: Commit**

```bash
git add lib/screens/lab_detail_screen.dart
git commit -m "feat(directory): pantalla de detalle de laboratorio"
```

---

## Task 11: Pantalla de laboratorios cercanos

**Files:**
- Create: `lib/screens/nearby_labs_screen.dart`

- [ ] **Step 1: Implementar la pantalla**

```dart
// lib/screens/nearby_labs_screen.dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:latlong2/latlong.dart';

import '../models/lab.dart';
import '../router/app_router.dart';
import '../services/directory_service.dart';
import '../services/location_service.dart';
import '../theme.dart';
import '../widgets/vihtal_app_bar.dart';

/// Laboratorios ordenados por distancia, con filtro por examen.
class NearbyLabsScreen extends StatefulWidget {
  const NearbyLabsScreen({super.key, this.service, this.locationService});

  final DirectoryService? service;
  final LocationService? locationService;

  @override
  State<NearbyLabsScreen> createState() => _NearbyLabsScreenState();
}

class _NearbyLabsScreenState extends State<NearbyLabsScreen> {
  late final DirectoryService _service = widget.service ?? DirectoryService();
  late final LocationService _location =
      widget.locationService ?? LocationService();

  List<Lab> _labs = const [];
  bool _loading = true;
  String? _error;
  bool _located = false;
  String? _examFilter;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      await _service.ensureSeedData();
      var labs = await _service.fetchLabs();
      labs = await _sortByDistance(labs);
      if (!mounted) return;
      setState(() => _labs = labs);
    } catch (e) {
      if (!mounted) return;
      setState(() => _error = 'No se pudo cargar los laboratorios.');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  /// Asigna distancia y ordena ascendente si hay ubicación. Si el permiso se
  /// niega o no hay GPS, devuelve la lista sin ordenar (no es error fatal).
  Future<List<Lab>> _sortByDistance(List<Lab> labs) async {
    try {
      final user = await _location.getCurrentLocation();
      final withDist = labs.map((lab) {
        if (lab.lat == null || lab.lng == null) return lab.copyWithDistance(null);
        final km = _location.distanceKm(user, LatLng(lab.lat!, lab.lng!));
        return lab.copyWithDistance(km);
      }).toList();
      withDist.sort((a, b) {
        final da = a.distanceKm;
        final db = b.distanceKm;
        if (da == null && db == null) return 0;
        if (da == null) return 1;
        if (db == null) return -1;
        return da.compareTo(db);
      });
      _located = true;
      return withDist;
    } catch (_) {
      _located = false;
      return labs;
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
      body: Padding(
        padding: const EdgeInsets.fromLTRB(16, 4, 16, 0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text('Laboratorios cercanos',
                style: Theme.of(context).textTheme.headlineMedium),
            const SizedBox(height: 12),
            Expanded(child: _buildBody()),
          ],
        ),
      ),
    );
  }

  Widget _buildBody() {
    if (_loading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_error != null) {
      return _ErrorState(message: _error!, onRetry: _load);
    }

    final examNames = <String>{
      for (final l in _labs) ...l.exams.map((e) => e.name),
    }.toList()
      ..sort();

    final visible = _examFilter == null
        ? _labs
        : _labs.where((l) => l.exams.any((e) => e.name == _examFilter)).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (!_located)
          const Padding(
            padding: EdgeInsets.only(bottom: 10),
            child: Text(
              'Activá la ubicación para ver los más cercanos.',
              style: TextStyle(fontSize: 12.5, color: AppColors.textSecondary),
            ),
          ),
        if (examNames.isNotEmpty)
          _ExamFilterRow(
            exams: examNames,
            selected: _examFilter,
            onSelect: (name) => setState(() => _examFilter = name),
          ),
        const SizedBox(height: 12),
        Expanded(
          child: visible.isEmpty
              ? const Center(
                  child: Text('No hay laboratorios para mostrar',
                      style: TextStyle(color: AppColors.textSecondary)),
                )
              : ListView.separated(
                  padding: const EdgeInsets.only(bottom: 24),
                  itemCount: visible.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 10),
                  itemBuilder: (_, i) => _LabCard(
                    lab: visible[i],
                    onTap: () =>
                        context.push(AppRoutes.labDetail, extra: visible[i]),
                  ),
                ),
        ),
      ],
    );
  }
}

class _LabCard extends StatelessWidget {
  const _LabCard({required this.lab, required this.onTap});

  final Lab lab;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final subtitle = [lab.city, lab.address]
        .where((s) => s != null && s.isNotEmpty)
        .join(' · ');
    final dist = formatDistanceKm(lab.distanceKm);
    return Material(
      color: AppColors.surface,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.border),
          ),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      lab.name,
                      style: const TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 15,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle.isEmpty ? 'Laboratorio' : subtitle,
                      style: const TextStyle(
                          fontSize: 13, color: AppColors.textSecondary),
                    ),
                    if (dist.isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Text('A $dist',
                          style: const TextStyle(
                              fontSize: 12.5,
                              fontWeight: FontWeight.w600,
                              color: AppColors.primary)),
                    ],
                  ],
                ),
              ),
              const Icon(Icons.chevron_right_rounded,
                  color: AppColors.textSecondary),
            ],
          ),
        ),
      ),
    );
  }
}

class _ExamFilterRow extends StatelessWidget {
  const _ExamFilterRow({
    required this.exams,
    required this.selected,
    required this.onSelect,
  });

  final List<String> exams;
  final String? selected;
  final void Function(String?) onSelect;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 36,
      child: ListView(
        scrollDirection: Axis.horizontal,
        children: [
          _Chip(label: 'Todos', active: selected == null, onTap: () => onSelect(null)),
          for (final name in exams)
            _Chip(
              label: name,
              active: selected == name,
              onTap: () => onSelect(name),
            ),
        ],
      ),
    );
  }
}

class _Chip extends StatelessWidget {
  const _Chip({required this.label, required this.active, required this.onTap});

  final String label;
  final bool active;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: Material(
        color: active ? AppColors.primary : AppColors.surface,
        borderRadius: BorderRadius.circular(18),
        child: InkWell(
          borderRadius: BorderRadius.circular(18),
          onTap: onTap,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(18),
              border: Border.all(
                  color: active ? AppColors.primary : AppColors.border),
            ),
            child: Text(
              label,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: active ? Colors.white : AppColors.textSecondary,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _ErrorState extends StatelessWidget {
  const _ErrorState({required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(message,
              style: const TextStyle(color: AppColors.textSecondary)),
          const SizedBox(height: 12),
          TextButton(onPressed: onRetry, child: const Text('Reintentar')),
        ],
      ),
    );
  }
}
```

- [ ] **Step 2: Verificar compilación**

Run: `flutter analyze lib/screens/nearby_labs_screen.dart`
Expected: "No issues found!"

- [ ] **Step 3: Commit**

```bash
git add lib/screens/nearby_labs_screen.dart
git commit -m "feat(directory): pantalla laboratorios cercanos con orden y filtro"
```

---

## Task 12: Registrar las rutas (GoRoute)

**Files:**
- Modify: `lib/router/app_router.dart`

- [ ] **Step 1: Agregar imports**

En el bloque de imports de pantallas de `lib/router/app_router.dart` (junto a los demás `import '../screens/...';`), agregar:

```dart
import '../screens/medical_directory_screen.dart';
import '../screens/doctor_detail_screen.dart';
import '../screens/nearby_labs_screen.dart';
import '../screens/lab_detail_screen.dart';
```

Y junto a `import '../models/education_content.dart';` agregar:

```dart
import '../models/doctor.dart';
import '../models/lab.dart';
```

- [ ] **Step 2: Agregar las entradas GoRoute**

En la lista `routes:` de nivel superior (fuera del `ShellRoute`, junto a la ruta `centers`, ~línea 200-203), agregar:

```dart
      GoRoute(
        path: AppRoutes.directory,
        builder: (BuildContext context, GoRouterState state) =>
            const MedicalDirectoryScreen(),
      ),
      GoRoute(
        path: AppRoutes.doctorDetail,
        builder: (BuildContext context, GoRouterState state) =>
            DoctorDetailScreen(doctor: state.extra as Doctor),
      ),
      GoRoute(
        path: AppRoutes.labs,
        builder: (BuildContext context, GoRouterState state) =>
            const NearbyLabsScreen(),
      ),
      GoRoute(
        path: AppRoutes.labDetail,
        builder: (BuildContext context, GoRouterState state) =>
            LabDetailScreen(lab: state.extra as Lab),
      ),
```

- [ ] **Step 3: Verificar compilación**

Run: `flutter analyze lib/router/app_router.dart`
Expected: "No issues found!"

- [ ] **Step 4: Commit**

```bash
git add lib/router/app_router.dart
git commit -m "feat(directory): rutas /directorio y /laboratorios + detalles"
```

---

## Task 13: Insertar el slider en el inicio

**Files:**
- Modify: `lib/screens/home_screen.dart`

- [ ] **Step 1: Agregar imports**

En `lib/screens/home_screen.dart`, junto a los imports existentes, agregar:

```dart
import '../widgets/home_directory_slider.dart';
```

(`go_router`, `app_router.dart` y `theme.dart` ya están importados en este archivo.)

- [ ] **Step 2: Insertar el widget**

En el `ListView` de `HomeScreen.build` (`home_screen.dart:14-52`), entre el bloque del texto de intro y el `_CampaignBanner`. Reemplazar exactamente:

```dart
        const SizedBox(height: 18),
        const _CampaignBanner(campaign: Campaign.featured),
```

por:

```dart
        const SizedBox(height: 18),
        HomeDirectorySlider(
          slides: [
            DirectorySlide(
              title: 'Directorio médico',
              subtitle: 'Encontrá especialistas por especialidad',
              icon: Icons.groups_rounded,
              accent: AppColors.primary,
              onTap: () => context.push(AppRoutes.directory),
            ),
            DirectorySlide(
              title: 'Laboratorios cercanos',
              subtitle: 'Consultá qué exámenes hace cada uno',
              icon: Icons.science_rounded,
              accent: AppColors.accent,
              onTap: () => context.push(AppRoutes.labs),
            ),
          ],
        ),
        const SizedBox(height: 20),
        const _CampaignBanner(campaign: Campaign.featured),
```

- [ ] **Step 3: Verificar compilación**

Run: `flutter analyze lib/screens/home_screen.dart`
Expected: "No issues found!"

- [ ] **Step 4: Commit**

```bash
git add lib/screens/home_screen.dart
git commit -m "feat(home): slider directorio médico + laboratorios en el inicio"
```

---

## Task 14: Verificación final

- [ ] **Step 1: Analyze de todo el proyecto**

Run: `flutter analyze`
Expected: "No issues found!" (o sin issues nuevos respecto al baseline).

- [ ] **Step 2: Correr todos los tests**

Run: `flutter test`
Expected: PASS — incluye `doctor_test.dart` (5), `lab_test.dart` (8), `contact_test.dart` (2) y el `widget_test.dart` existente.

- [ ] **Step 3: Commit final (si hubo correcciones)**

```bash
git add -A
git commit -m "chore(directory): correcciones finales de analyze/tests"
```

---

## Self-Review (completado por el autor del plan)

- **Cobertura del spec:**
  - Esquema Firestore denormalizado → Task 1, 3, 5. ✓
  - Modelos Doctor/Lab/LabExam con fromMap/fromDoc → Task 1, 3. ✓
  - groupDoctorsBySpecialty (multi-especialidad, "Otros") → Task 2. ✓
  - DirectoryService Firestore + ensureSeedData demo → Task 5. ✓
  - Contacto WhatsApp (buildWhatsappUri/openWhatsapp) → Task 4, 8, 10. ✓
  - Slider en el inicio con 2 slides → Task 6, 13. ✓
  - Pantalla directorio médico + buscador + agrupación → Task 9. ✓
  - Detalle médico (foto/inicial, chips, bio, WhatsApp) → Task 8. ✓
  - Labs ordenados por distancia + permiso/fallback (reusa LocationService) → Task 11. ✓
  - Filtro por examen → Task 11. ✓
  - Detalle lab (exámenes con precio sin símbolo, WhatsApp, Cómo llegar) → Task 10. ✓
  - Rutas /directorio y /laboratorios + detalles por extra → Task 7, 12. ✓
  - Estados loading/error/empty → Task 9, 11. ✓
  - Tests de funciones puras → Task 1, 2, 3, 4. ✓
- **Placeholders:** ninguno; cada paso trae el código completo.
- **Consistencia de tipos:** `Doctor.fromMap(data, id)`, `Lab.fromMap(data, id)`, `LabExam.fromMap(map)`, `groupDoctorsBySpecialty`, `SpecialtyGroup{specialty,doctors}`, `copyWithDistance`, `formatDistanceKm`, `formatPrice`, `buildWhatsappUri`/`openWhatsapp`, `DirectoryService.{fetchDoctors,fetchLabs,ensureSeedData}`, `LocationService.{getCurrentLocation,distanceKm}` se usan con la misma firma en todas las tareas.
- **Riesgo residual:** los `flutter analyze` por-archivo pueden quejarse de imports aún no usados entre tareas intermedias; el orden (constantes → pantallas → rutas → home) minimiza eso y la Task 14 valida el conjunto.
```
