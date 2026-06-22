# Diseño: Directorio médico + Laboratorios cercanos (Firebase)

**Fecha:** 2026-06-21
**Stack:** Flutter + Firebase/Firestore (NO Supabase). Esta es la reescritura del diseño
previo (`2026-06-21-directorio-medico-labs-design.md`), que estaba escrito para otro
proyecto (`connek_frontend`, Supabase/Riverpod) y es inaplicable aquí.
**Alcance:** solo lado cliente. CRUD de admin fuera de alcance.

## Objetivo

Agregar en el inicio (`home_screen`) un slider con dos tarjetas:

1. **"Directorio médico"** → listado de médicos agrupados por especialidad (un médico
   puede tener una o más especialidades).
2. **"Laboratorios cercanos"** → listado de laboratorios ordenados por distancia real,
   donde el cliente consulta qué exámenes hace cada uno.

Acciones del cliente: ver/consultar, buscar y filtrar, contactar por **WhatsApp**.
Sin agendar/reservar.

## Decisiones de producto (confirmadas)

- **Datos:** Firestore real (colecciones nuevas), poblado a mano en la consola de Firebase.
  Compatible con plan Spark (gratis); no requiere Blaze ni Cloud Functions.
- **Laboratorios = feature separada** de los "centros de salud" existentes
  (`centers_screen`/`health_center`), porque los labs tienen exámenes y precios que los
  centros no modelan.
- **Labs como lista** ordenada por distancia (sin mapa; el mapa queda exclusivo de
  `centers_screen`).
- **Detalle por pantalla propia** (ruta + `extra`), igual que `article_screen`/
  `post_detail_screen`. No bottom sheets (el repo no tiene helper de sheets).
- **Precio sin símbolo de moneda:** se muestra el número formateado (`priceCents / 100`).
- **Reuso:** `LocationService` (ya existe) para ubicación y distancia; `url_launcher`
  (ya en deps) para WhatsApp y "Cómo llegar".

## Convenciones del repo que aplican

- Estructura **plana**: `lib/{models,services,screens,widgets}`. NO `lib/features/...`.
- Estado con `StatefulWidget` + `setState`. NO Riverpod (no está en deps).
- Tema: `lib/theme.dart` → `AppColors.*`. Iconos Material (`Icons.*`). NO heroicons,
  NO `ck_tokens`.
- Servicios Firestore: instancia defensiva (`_tryGetFirestoreInstance()`), factory
  `fromDoc`, IDs `String` (id del doc), `ensureSeedData()` para sembrar. Patrón de
  `community_forum_service.dart`.
- Logging: `debugPrint` (no existe `AppLogger`).
- Rutas: `go_router` en `lib/router/app_router.dart`, clase `AppRoutes` con constantes;
  detalle navega con `context.push(path, extra: obj)`.

## Esquema Firestore (denormalizado)

No hay tablas join (Firestore se denormaliza). Dos colecciones planas:

```
doctors/{autoId}
  name          : string
  photoUrl      : string?     (URL; Firebase Storage o externa)
  bio           : string?
  whatsappPhone : string?     (E.164 sin '+', ej. "584120000000")
  specialties   : array<string>   ej. ["Cardiología", "Pediatría"]

labs/{autoId}
  name          : string
  whatsappPhone : string?
  address       : string?
  city          : string?
  lat           : number?
  lng           : number?
  exams         : array<map>   ej. [ { "name": "Hemograma", "priceCents": 150000 } ]
```

- `specialties` es un array de strings en el propio doc del médico.
- `exams` es un array de mapas `{name, priceCents?}` en el propio doc del lab.
- La agrupación por especialidad y el orden por distancia se calculan **en el cliente**
  (listas chicas). `distanceKm` no se persiste: lo calcula la pantalla en runtime.

## Modelos de dominio (`lib/models/`)

### `doctor.dart`

```
class Doctor {
  final String id;
  final String name;
  final String? photoUrl;
  final String? bio;
  final String? whatsappPhone;
  final List<String> specialties;
}
```

- `Doctor.fromMap(Map<String,dynamic> data, String id)` — parseo puro y testeable.
  `specialties` tolera ausencia/null → `[]`; castea cada item a String.
- `Doctor.fromDoc(DocumentSnapshot)` — envuelve `fromMap(doc.data() ?? {}, doc.id)`.

Función pura de agrupación (en el mismo archivo o `doctor.dart`):

```
class SpecialtyGroup { final String specialty; final List<Doctor> doctors; }

List<SpecialtyGroup> groupDoctorsBySpecialty(List<Doctor> doctors)
```

Reglas: alfabético por nombre de especialidad; un médico con N especialidades aparece
en los N grupos; médicos sin especialidad caen en un grupo `"Otros"` al final; dentro de
cada grupo, médicos ordenados por nombre.

### `lab.dart`

```
class LabExam { final String name; final int? priceCents; }

class Lab {
  final String id;
  final String name;
  final String? whatsappPhone;
  final String? address;
  final String? city;
  final double? lat;
  final double? lng;
  final List<LabExam> exams;
  final double? distanceKm;   // calculado en runtime; no viene de Firestore
}
```

- `LabExam.fromMap(Map)` — `priceCents` null si ausente.
- `Lab.fromMap(Map, id)` / `Lab.fromDoc(doc)` — `lat`/`lng` toleran num o null;
  `exams` tolera ausencia → `[]`.
- `Lab copyWithDistance(double? km)` — para asignar la distancia tras calcularla.

## Servicios (`lib/services/`)

### `directory_service.dart`

Patrón espejo de `community_forum_service.dart`:

```
class DirectoryService {
  DirectoryService({FirebaseFirestore? firestore});
  Future<List<Doctor>> fetchDoctors();   // collection('doctors').orderBy('name')
  Future<List<Lab>>    fetchLabs();       // collection('labs').orderBy('name')
  Future<void> ensureSeedData();          // siembra demo si las colecciones están vacías
}
```

- Instancia defensiva (`_tryGetFirestoreInstance()`); si Firestore no está, los fetch
  devuelven `[]`.
- try/catch en cada fetch → log con `debugPrint` y `[]` (degradación, no crash).
- `ensureSeedData()`: si `doctors`/`labs` vacías, escribe un batch con datos demo
  (médicos con especialidades, labs con exámenes y coords de Caracas).

### `contact.dart`

```
Uri  buildWhatsappUri(String phone, {String? text});   // pura, testeable
Future<void> openWhatsapp(String? phone, {String? text});
```

- `buildWhatsappUri`: limpia el teléfono a solo dígitos, arma
  `https://wa.me/<digits>?text=<text>` (sin query si no hay texto).
- `openWhatsapp`: no-op si el teléfono queda vacío; `launchUrl(..., externalApplication)`;
  en error, `debugPrint` (sin romper).

## Pantallas (`lib/screens/`)

### `medical_directory_screen.dart`

`StatefulWidget`. En `initState` dispara `ensureSeedData()` + `fetchDoctors()`.
Estados: loading (spinner) → error (mensaje + reintentar) → empty (`DsEmptyState`
no existe → mensaje propio simple) → data.

- Buscador por nombre (`TextField`, filtra en memoria, `setState`).
- Agrupa con `groupDoctorsBySpecialty`; por grupo, encabezado (nombre de especialidad)
  + tarjetas de médico.
- Tap en médico → `context.push(AppRoutes.doctorDetail, extra: doctor)`.

### `doctor_detail_screen.dart`

Recibe `Doctor` por `state.extra`. Foto (o placeholder), nombre, chips de especialidades,
bio, botón **WhatsApp** (solo si `whatsappPhone != null`). `VihtalAppBar` con back.

### `nearby_labs_screen.dart`

`StatefulWidget`. Reusa el patrón de `centers_screen`:

- `LocationService.getCurrentLocation()` en `_locate()`; al obtener ubicación, calcula
  `distanceKm` por lab (con coords) vía `LocationService.distanceKm` y **ordena ascendente**;
  labs sin coords van al final sin distancia.
- Si el permiso se niega / no hay GPS: muestra los labs **sin ordenar** + aviso no
  bloqueante (widget tipo `_LocationStatus`). Nunca rompe.
- Filtro por examen: chips horizontales ("Todos" + un chip por examen único). Al elegir,
  filtra los labs que ofrecen ese examen.
- `ensureSeedData()` + `fetchLabs()` en `initState`. Estados loading/error/empty/data.
- Cada tarjeta: nombre, ciudad/dirección, distancia formateada (ej. "1.2 km") si hay.
- Tap → `context.push(AppRoutes.labDetail, extra: lab)`.

### `lab_detail_screen.dart`

Recibe `Lab` por `state.extra`. Nombre, dirección/ciudad, lista de exámenes con precio
(número sin símbolo, `priceCents / 100`), botón **WhatsApp** (si hay teléfono) y
**"Cómo llegar"** (si hay lat/lng; reusa la URL de Google Maps de `centers_screen`).

## Widget (`lib/widgets/`)

### `home_directory_slider.dart`

Presentacional. `PageView` (viewportFraction ~0.9) con tarjetas grandes + indicador de
puntos animado. Recibe `List<DirectorySlide>` por params (título, subtítulo, `IconData`,
color de acento, `onTap`). Estilos solo de `AppColors`; iconos `Icons.*`.

`DirectorySlide { String title; String subtitle; IconData icon; Color accent; VoidCallback onTap; }`

Inserción en `home_screen.dart`: dentro del `ListView`, tras el texto de intro
("Información confiable…") y **antes** del `_CampaignBanner`. Dos slides:
- "Directorio médico" → `context.push(AppRoutes.directory)` (icono `Icons.groups_rounded`).
- "Laboratorios cercanos" → `context.push(AppRoutes.labs)` (icono `Icons.science_rounded`).

## Rutas (`app_router.dart`)

Agregar a `AppRoutes`:

```
static const String directory    = '/directorio';
static const String doctorDetail = '/directorio/medico';
static const String labs         = '/laboratorios';
static const String labDetail    = '/laboratorios/lab';
```

`directory` y `labs` van **fuera** del `ShellRoute` (pantallas full, como `centers`),
con back. Los detalles reciben el objeto por `extra` (cast a `Doctor`/`Lab`), igual que
`article`/`postDetail`.

## Estados de borde

- Listas vacías → mensaje propio simple (no hay `DsEmptyState` en el repo).
- Error de red/Firestore → mensaje + reintentar; los fetch ya degradan a `[]`.
- Permiso de ubicación denegado / sin GPS → labs sin ordenar + aviso (no fatal).
- Médico/lab sin teléfono → sin botón WhatsApp.
- Lab sin lat/lng → no participa del orden por distancia (va al final, sin distancia).

## Testing

Solo funciones puras (sin Firebase):
- `groupDoctorsBySpecialty` (multi-especialidad en cada grupo; "Otros" al final; orden).
- `Doctor.fromMap` / `Lab.fromMap` / `LabExam.fromMap` (parseo y tolerancia a nulls).
- `buildWhatsappUri` (limpieza de teléfono, query con/sin texto).
- Formato de distancia (`"850 m"` / `"1.2 km"`) y de precio (`priceCents/100`, sin símbolo).

`fromDoc` no se testea directo (requiere mock de Firestore); delega en `fromMap`, que sí
se testea.

## Fuera de alcance

- CRUD admin de médicos/labs/especialidades/exámenes.
- Mapa en la vista de labs.
- Agendar citas; contacto por llamada/email/chat (WhatsApp es la única acción de contacto,
  más "Cómo llegar" en labs).
- Migración a endpoints REST.

## Archivos

**Crear:**
- `lib/models/doctor.dart` (Doctor + SpecialtyGroup + groupDoctorsBySpecialty)
- `lib/models/lab.dart` (Lab + LabExam)
- `lib/services/directory_service.dart`
- `lib/services/contact.dart`
- `lib/widgets/home_directory_slider.dart`
- `lib/screens/medical_directory_screen.dart`
- `lib/screens/doctor_detail_screen.dart`
- `lib/screens/nearby_labs_screen.dart`
- `lib/screens/lab_detail_screen.dart`
- `test/` con tests de las funciones puras.

**Modificar:**
- `lib/screens/home_screen.dart` (insertar el slider)
- `lib/router/app_router.dart` (4 rutas + imports)
