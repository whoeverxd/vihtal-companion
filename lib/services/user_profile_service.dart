import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';

// Import condicional para web (Blob)
import 'user_profile_service_web_stub.dart'
    if (dart.library.html) 'user_profile_service_web.dart';

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
    FirebaseStorage? storage,
  })  : _auth = auth ?? FirebaseAuth.instance,
        _firestore = firestore ?? FirebaseFirestore.instance,
        _storage = storage ?? FirebaseStorage.instance;

  final FirebaseAuth _auth;
  final FirebaseFirestore _firestore;
  final FirebaseStorage _storage;

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

  Future<String> uploadProfilePhoto({
    required Uint8List bytes,
    required String contentType,
  }) async {
    final user = _auth.currentUser;
    if (user == null) {
      throw StateError('No hay usuario autenticado');
    }

    final ref = _storage.ref().child('users/${user.uid}/profile.jpg');

    debugPrint('[Storage] bucket=${_storage.app.options.storageBucket} path=${ref.fullPath} uid=${user.uid}');

    final metadata = SettableMetadata(
      contentType: contentType,
      cacheControl: 'public,max-age=3600',
    );

    UploadTask task;
    if (kIsWeb) {
      final blob = bytesToBlob(bytes, contentType);
      task = ref.putBlob(blob, metadata);
    } else {
      task = ref.putData(bytes, metadata);
    }

    // Si el upload se queda en 0% mucho tiempo suele ser por reglas/permiso/CORS.
    // Esperamos el primer snapshot para detectar errores temprano.
    final firstSnapshot = task.snapshotEvents.first.timeout(const Duration(seconds: 8),
        onTimeout: () {
      throw TimeoutException(
        'No llegó ningún evento de subida. Revisa reglas de Storage, auth y red (localhost).',
      );
    });

    await firstSnapshot;

    task.snapshotEvents.listen(
      (s) {
        final total = s.totalBytes;
        final transferred = s.bytesTransferred;
        final pct = total == 0 ? 0 : ((transferred / total) * 100).round();
        debugPrint('[Storage] profile upload state=${s.state} $transferred/$total (${pct}%)');
      },
      onError: (e) {
        debugPrint('[Storage] profile upload snapshotEvents error: $e');
      },
    );

    await task;
    final url = await ref.getDownloadURL();

    // Persistimos la URL sin tocar nombre/apellido.
    await _userDoc(user.uid).set(
      <String, dynamic>{
        'photoUrl': url,
        'updatedAt': FieldValue.serverTimestamp(),
      },
      SetOptions(merge: true),
    );

    await user.updatePhotoURL(url);
    await user.reload();

    return url;
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

    final updateData = <String, dynamic>{
      'updatedAt': FieldValue.serverTimestamp(),
    };
    if (firstName.isNotEmpty) updateData['firstName'] = f;
    if (lastName.isNotEmpty) updateData['lastName'] = l;
    if (photoUrl != null) updateData['photoUrl'] = photoUrl;

    // 1) Guardar extra data en Firestore
    await _userDoc(user.uid).set(
      updateData,
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
