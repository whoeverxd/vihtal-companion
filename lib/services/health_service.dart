import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../models/health_models.dart';

/// Persistencia de Salud / Adherencia en Firestore, bajo `users/{uid}`:
/// `medications`, `intakes` (tomas), `appointments` y `symptoms`.
class HealthService {
  HealthService({FirebaseAuth? auth, FirebaseFirestore? firestore})
      : _auth = auth ?? _tryGetAuth(),
        _firestore = firestore ?? _tryGetFirestore();

  final FirebaseAuth? _auth;
  final FirebaseFirestore? _firestore;

  static FirebaseAuth? _tryGetAuth() {
    try {
      return FirebaseAuth.instance;
    } catch (_) {
      return null;
    }
  }

  static FirebaseFirestore? _tryGetFirestore() {
    try {
      return FirebaseFirestore.instance;
    } catch (_) {
      return null;
    }
  }

  String? get _uid => _auth?.currentUser?.uid;

  CollectionReference<Map<String, dynamic>>? _col(String name) {
    final firestore = _firestore;
    final uid = _uid;
    if (firestore == null || uid == null) return null;
    return firestore.collection('users').doc(uid).collection(name);
  }

  static String dayKeyOf(DateTime date) {
    final y = date.year.toString().padLeft(4, '0');
    final m = date.month.toString().padLeft(2, '0');
    final d = date.day.toString().padLeft(2, '0');
    return '$y$m$d';
  }

  /// Las claves de día de los últimos [days] días (incluyendo hoy), de más
  /// antiguo a más reciente.
  static List<String> lastDayKeys(DateTime now, int days) {
    final today = DateTime(now.year, now.month, now.day);
    return List.generate(
      days,
      (i) => dayKeyOf(today.subtract(Duration(days: days - 1 - i))),
    );
  }

  // --- Medicación -----------------------------------------------------------

  Stream<List<Medication>> watchMedications() {
    final col = _col('medications');
    if (col == null) return Stream.value(const []);
    // Orden por hora en cliente (evita un índice compuesto en Firestore).
    return col.snapshots().map((snap) {
      final list = snap.docs.map(Medication.fromDoc).toList();
      list.sort((a, b) =>
          (a.hour * 60 + a.minute).compareTo(b.hour * 60 + b.minute));
      return list;
    });
  }

  Future<void> addMedication({
    required String name,
    required String dose,
    required int hour,
    required int minute,
  }) async {
    final col = _col('medications');
    if (col == null) throw StateError('No hay sesión.');
    await col.add(<String, dynamic>{
      'name': name.trim(),
      'dose': dose.trim(),
      'hour': hour,
      'minute': minute,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> removeMedication(String id) async {
    final col = _col('medications');
    if (col == null) return;
    await col.doc(id).delete();
  }

  // --- Tomas ----------------------------------------------------------------

  /// Marca (idempotente) la toma de [medId] para el día de [when].
  Future<void> markTaken(String medId, {DateTime? when}) async {
    final col = _col('intakes');
    if (col == null) throw StateError('No hay sesión.');
    final now = when ?? DateTime.now();
    final key = dayKeyOf(now);
    await col.doc('${key}_$medId').set(<String, dynamic>{
      'medId': medId,
      'dayKey': key,
      'takenAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> undoTaken(String medId, {DateTime? when}) async {
    final col = _col('intakes');
    if (col == null) return;
    final key = dayKeyOf(when ?? DateTime.now());
    await col.doc('${key}_$medId').delete();
  }

  /// Tomas registradas en los días indicados (máximo 10 por la restricción de
  /// `whereIn`). Útil para hoy ([dayKeys] con una sola clave) y para adherencia.
  Stream<List<Intake>> watchIntakes(List<String> dayKeys) {
    final col = _col('intakes');
    if (col == null || dayKeys.isEmpty) return Stream.value(const []);
    return col.where('dayKey', whereIn: dayKeys).snapshots().map(
          (snap) => snap.docs.map(Intake.fromDoc).toList(),
        );
  }

  // --- Citas ----------------------------------------------------------------

  Stream<List<Appointment>> watchAppointments() {
    final col = _col('appointments');
    if (col == null) return Stream.value(const []);
    return col.orderBy('dateTime').snapshots().map(
          (snap) => snap.docs.map(Appointment.fromDoc).toList(),
        );
  }

  Future<void> addAppointment({
    required String title,
    required String location,
    required DateTime dateTime,
  }) async {
    final col = _col('appointments');
    if (col == null) throw StateError('No hay sesión.');
    await col.add(<String, dynamic>{
      'title': title.trim(),
      'location': location.trim(),
      'dateTime': Timestamp.fromDate(dateTime),
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> removeAppointment(String id) async {
    final col = _col('appointments');
    if (col == null) return;
    await col.doc(id).delete();
  }

  // --- Síntomas / ánimo -----------------------------------------------------

  Stream<List<SymptomEntry>> watchSymptoms({int limit = 10}) {
    final col = _col('symptoms');
    if (col == null) return Stream.value(const []);
    return col
        .orderBy('createdAt', descending: true)
        .limit(limit)
        .snapshots()
        .map((snap) => snap.docs.map(SymptomEntry.fromDoc).toList());
  }

  Future<void> addSymptom({required int mood, required String note}) async {
    final col = _col('symptoms');
    if (col == null) throw StateError('No hay sesión.');
    await col.add(<String, dynamic>{
      'mood': mood,
      'note': note.trim(),
      'createdAt': FieldValue.serverTimestamp(),
    });
  }
}
