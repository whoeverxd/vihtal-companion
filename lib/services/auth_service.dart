import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';

class AuthService {
  AuthService({FirebaseAuth? firebaseAuth}) : _auth = firebaseAuth ?? _tryGetAuthInstance();

  final FirebaseAuth? _auth;

  static FirebaseAuth? _tryGetAuthInstance() {
    try {
      return FirebaseAuth.instance;
    } catch (_) {
      // Firebase no inicializado (común en tests o antes de flutterfire configure)
      return null;
    }
  }

  Stream<User?> authStateChanges() {
    final auth = _auth;
    if (auth == null) {
      return Stream<User?>.value(null);
    }
    return auth.authStateChanges();
  }

  User? get currentUser => _auth?.currentUser;

  Future<UserCredential> signInWithEmailPassword({
    required String email,
    required String password,
  }) {
    final auth = _auth;
    if (auth == null) {
      return Future.error(StateError('FirebaseAuth no está disponible. Configura Firebase (flutterfire configure) e inicializa Firebase.'));
    }
    return auth.signInWithEmailAndPassword(email: email, password: password);
  }

  Future<UserCredential> registerWithEmailPassword({
    required String email,
    required String password,
  }) {
    final auth = _auth;
    if (auth == null) {
      return Future.error(StateError('FirebaseAuth no está disponible. Configura Firebase (flutterfire configure) e inicializa Firebase.'));
    }
    return auth.createUserWithEmailAndPassword(email: email, password: password);
  }

  Future<void> sendPasswordResetEmail({required String email}) {
    final auth = _auth;
    if (auth == null) {
      return Future.error(StateError('FirebaseAuth no está disponible. Configura Firebase (flutterfire configure) e inicializa Firebase.'));
    }
    return auth.sendPasswordResetEmail(email: email);
  }

  Future<void> signOut() {
    final auth = _auth;
    if (auth == null) {
      return Future.value();
    }
    return auth.signOut();
  }

  /// Elimina la cuenta del usuario actual. Puede lanzar
  /// `requires-recent-login` si la sesión es antigua (hay que volver a entrar).
  Future<void> deleteAccount() async {
    final user = _auth?.currentUser;
    if (user == null) return;
    await user.delete();
  }
}
