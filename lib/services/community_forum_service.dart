import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

class ForumPost {
  const ForumPost({
    required this.id,
    required this.categoryKey,
    required this.categoryLabel,
    required this.title,
    required this.excerpt,
    required this.createdAt,
    required this.repliesCount,
    required this.likesCount,
  });

  final String id;
  final String categoryKey;
  final String categoryLabel;
  final String title;
  final String excerpt;
  final DateTime createdAt;
  final int repliesCount;
  final int likesCount;

  factory ForumPost.fromDoc(QueryDocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data();
    final ts = data['createdAt'];
    final createdAt = ts is Timestamp ? ts.toDate() : DateTime.now();

    return ForumPost(
      id: doc.id,
      categoryKey: (data['categoryKey'] as String?) ?? 'general',
      categoryLabel: (data['categoryLabel'] as String?) ?? 'General',
      title: (data['title'] as String?) ?? '',
      excerpt: (data['excerpt'] as String?) ?? '',
      createdAt: createdAt,
      repliesCount: (data['repliesCount'] as num?)?.toInt() ?? 0,
      likesCount: (data['likesCount'] as num?)?.toInt() ?? 0,
    );
  }

  String get timeAgo {
    final diff = DateTime.now().difference(createdAt);
    if (diff.inMinutes < 60) return 'Hace ${diff.inMinutes.clamp(1, 59)} min';
    if (diff.inHours < 24) return 'Hace ${diff.inHours} h';
    return 'Hace ${diff.inDays} d';
  }
}

class CommunityForumService {
  CommunityForumService({FirebaseFirestore? firestore})
      : _firestore = firestore ?? _tryGetFirestoreInstance();

  final FirebaseFirestore? _firestore;
  final FirebaseAuth? _auth = _tryGetAuthInstance();

  static FirebaseFirestore? _tryGetFirestoreInstance() {
    try {
      return FirebaseFirestore.instance;
    } catch (_) {
      return null;
    }
  }

  static FirebaseAuth? _tryGetAuthInstance() {
    try {
      return FirebaseAuth.instance;
    } catch (_) {
      return null;
    }
  }

  CollectionReference<Map<String, dynamic>>? get _postsCollection =>
      _firestore?.collection('forum_posts');

  Stream<List<ForumPost>> watchPosts() {
    final posts = _postsCollection;
    if (posts == null) {
      return Stream<List<ForumPost>>.value(const []);
    }

    return posts.orderBy('createdAt', descending: true).snapshots().map(
          (snapshot) => snapshot.docs.map(ForumPost.fromDoc).toList(),
        );
  }

  Future<void> createPost({
    required String categoryKey,
    required String categoryLabel,
    required String title,
    required String excerpt,
    required bool anonymous,
    String? imageUrl,
    String? linkUrl,
  }) async {
    final posts = _postsCollection;
    if (posts == null) {
      throw StateError('FirebaseFirestore no está disponible.');
    }

    final user = _auth?.currentUser;
    final doc = posts.doc();

    await doc.set(<String, dynamic>{
      'categoryKey': categoryKey,
      'categoryLabel': categoryLabel,
      'title': title.trim(),
      'excerpt': excerpt.trim(),
      'createdAt': FieldValue.serverTimestamp(),
      'repliesCount': 0,
      'likesCount': 0,
      'isAnonymous': anonymous,
      'authorId': anonymous ? null : user?.uid,
      'authorName': anonymous ? 'Anónimo' : (user?.displayName ?? 'Usuario'),
      'authorPhotoUrl': anonymous ? null : user?.photoURL,
      'imageUrl': imageUrl,
      'linkUrl': linkUrl,
    });
  }

  Future<void> ensureSeedData() async {
    final posts = _postsCollection;
    if (posts == null) return;

    final existing = await posts.limit(1).get();
    if (existing.docs.isNotEmpty) return;

    final now = DateTime.now();
    final seeds = <Map<String, dynamic>>[
      {
        'id': 'recia-diagnosticos',
        'categoryKey': 'recien_diagnosticados',
        'categoryLabel': 'Recién diagnosticados',
        'title': '¿Cómo fue su primera semana después del resultado?',
        'excerpt': 'Me siento un poco perdido y me gustaría saber cómo manejaron la noticia al principio...',
        'createdAt': Timestamp.fromDate(now.subtract(const Duration(hours: 2))),
        'repliesCount': 24,
        'likesCount': 15,
      },
      {
        'id': 'apoyo-emocional',
        'categoryKey': 'apoyo_emocional',
        'categoryLabel': 'Apoyo emocional',
        'title': 'Consejos para hablar con la pareja',
        'excerpt': 'Llevo 6 meses saliendo con alguien y creo que ya es momento de ser honesto, pero tengo miedo...',
        'createdAt': Timestamp.fromDate(now.subtract(const Duration(hours: 5))),
        'repliesCount': 42,
        'likesCount': 89,
      },
      {
        'id': 'tratamientos',
        'categoryKey': 'tratamientos',
        'categoryLabel': 'Tratamientos',
        'title': 'Efectos secundarios en los primeros meses',
        'excerpt': '¿Alguien más sintió mucho cansancio al empezar el tratamiento? El doctor dice que es normal...',
        'createdAt': Timestamp.fromDate(now.subtract(const Duration(days: 1))),
        'repliesCount': 12,
        'likesCount': 8,
      },
    ];

    final batch = _firestore!.batch();
    for (final seed in seeds) {
      final id = seed['id'] as String;
      final data = Map<String, dynamic>.from(seed)..remove('id');
      batch.set(posts.doc(id), data);
    }

    try {
      await batch.commit();
    } catch (e) {
      debugPrint('[CommunityForum] no se pudo sembrar la colección forum_posts: $e');
    }
  }
}

