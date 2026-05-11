import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class UserProfileData {
  const UserProfileData({
    required this.uid,
    required this.email,
    required this.firstName,
    required this.lastName,
    required this.displayName,
    required this.photoUrl,
  });

  final String uid;
  final String email;
  final String firstName;
  final String lastName;
  final String displayName;
  final String? photoUrl;

  String get fullName {
    final full = ('${firstName.trim()} ${lastName.trim()}').trim();
    return full.isEmpty ? displayName : full;
  }
}

class UserProfileService {
  UserProfileService({
    FirebaseAuth? auth,
    FirebaseFirestore? firestore,
  })  : _auth = auth ?? FirebaseAuth.instance,
        _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseAuth _auth;
  final FirebaseFirestore _firestore;

  DocumentReference<Map<String, dynamic>> _userDoc(String uid) =>
      _firestore.collection('users').doc(uid);

  Future<UserProfileData> getCurrentUserProfile() async {
    final user = _auth.currentUser;
    if (user == null) {
      throw StateError('No hay usuario autenticado');
    }

    final snap = await _userDoc(user.uid).get();
    final data = snap.data();

    final firstName = (data?['firstName'] as String?) ?? '';
    final lastName = (data?['lastName'] as String?) ?? '';

    return UserProfileData(
      uid: user.uid,
      email: user.email ?? '',
      firstName: firstName,
      lastName: lastName,
      displayName: user.displayName ?? '',
      photoUrl: user.photoURL,
    );
  }

  Future<void> updateProfile({
    required String firstName,
    required String lastName,
    String? photoUrl,
  }) async {
    final user = _auth.currentUser;
    if (user == null) {
      throw StateError('No hay usuario autenticado');
    }

    final f = firstName.trim();
    final l = lastName.trim();
    final displayName = ('${f.isEmpty ? '' : f} ${l.isEmpty ? '' : l}').trim();

    // 1) Guardar extra data en Firestore
    await _userDoc(user.uid).set(
      <String, dynamic>{
        'firstName': f,
        'lastName': l,
        'updatedAt': FieldValue.serverTimestamp(),
      },
      SetOptions(merge: true),
    );

    // 2) Reflejar cambios básicos en FirebaseAuth
    if (displayName.isNotEmpty) {
      await user.updateDisplayName(displayName);
    }
    if (photoUrl != null) {
      await user.updatePhotoURL(photoUrl);
    }

    await user.reload();
  }
}

