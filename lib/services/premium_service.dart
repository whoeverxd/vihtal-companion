import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

/// Estado de suscripción premium del usuario.
///
/// MVP: el flag `isPremium` vive en `users/{uid}` en Firestore. Por ahora se
/// puede activar/desactivar manualmente (modo prueba). Cuando se integre una
/// pasarela de pago real (Google Play / Stripe), la compra confirmada será quien
/// llame a [setPremium]; el resto de la app (gating) no necesita cambiar.
class PremiumService {
  PremiumService({FirebaseAuth? auth, FirebaseFirestore? firestore})
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

  /// Observa si el usuario actual es premium (false si no hay sesión/datos).
  Stream<bool> watchIsPremium() {
    final firestore = _firestore;
    final uid = _auth?.currentUser?.uid;
    if (firestore == null || uid == null) return Stream<bool>.value(false);
    return firestore
        .collection('users')
        .doc(uid)
        .snapshots()
        .map((doc) => (doc.data()?['isPremium'] as bool?) ?? false);
  }

  /// Activa o desactiva el premium del usuario actual.
  Future<void> setPremium(bool value) async {
    final firestore = _firestore;
    final uid = _auth?.currentUser?.uid;
    if (firestore == null || uid == null) {
      throw StateError('No hay usuario autenticado.');
    }
    await firestore.collection('users').doc(uid).set(
      <String, dynamic>{
        'isPremium': value,
        'updatedAt': FieldValue.serverTimestamp(),
      },
      SetOptions(merge: true),
    );
  }
}
