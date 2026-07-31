import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../domain/avatar_repository.dart';
import '../domain/avatar_entity.dart';
import 'avatar_model.dart';

class AvatarRepositoryImpl implements AvatarRepository {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  /// Helper para asegurar que siempre trabajamos bajo el usuario logueado
  String get _currentUserId {
    final user = _auth.currentUser;
    if (user == null) throw Exception("Usuario no autenticado");
    return user.uid;
  }

  @override
  Future<AvatarEntity?> getAvatarById(String avatarId) async {
    try {
      // Los avatares se guardan como subcolección del usuario
      final doc = await _db
          .collection('users')
          .doc(_currentUserId)
          .collection('avatars')
          .doc(avatarId)
          .get();

      if (doc.exists) {
        return AvatarModel.fromFirestore(doc);
      }
      return null;
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<void> saveAvatar(String userId, AvatarEntity avatar) async {
    try {
      final uid = userId.isNotEmpty ? userId : _currentUserId;

      final avatarModel = AvatarModel(
        id: avatar.id,
        name: avatar.name,
        image: avatar.image,
        isAlive: avatar.isAlive,
        health: avatar.health,
        coins: avatar.coins,
        gems: avatar.gems,
        level: avatar.level,
        exp: avatar.exp,
        titulos: avatar.titulos,
        activeTitle: avatar.activeTitle,
        completedRetos: avatar.completedRetos,
        challengePoints: avatar.challengePoints,
        atributos: avatar.atributos,
      );

      await _db
          .collection('users')
          .doc(uid)
          .collection('avatars')
          .doc(avatarModel.id)
          .set(avatarModel.toFirestore());
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<void> updateAvatar(AvatarEntity avatar) async {
    try {
      final avatarModel = AvatarModel(
        id: avatar.id,
        name: avatar.name,
        image: avatar.image,
        isAlive: avatar.isAlive,
        health: avatar.health,
        coins: avatar.coins,
        gems: avatar.gems,
        level: avatar.level,
        exp: avatar.exp,
        titulos: avatar.titulos,
        activeTitle: avatar.activeTitle,
        completedRetos: avatar.completedRetos,
        challengePoints: avatar.challengePoints,
        atributos: avatar.atributos,
      );

      await _db
          .collection('users')
          .doc(_currentUserId)
          .collection('avatars')
          .doc(avatarModel.id)
          .update(avatarModel.toFirestore());
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<void> deleteAvatar(String avatarId) async {
    try {
      await _db
          .collection('users')
          .doc(_currentUserId)
          .collection('avatars')
          .doc(avatarId)
          .delete();
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<List<AvatarEntity>> getDeadAvatars() async {
    try {
      final query = await _db
          .collection('users')
          .doc(_currentUserId)
          .collection('avatars')
          .where('isAlive', isEqualTo: false)
          .get();

      return query.docs.map((doc) => AvatarModel.fromFirestore(doc)).toList();
    } catch (e) {
      rethrow;
    }
  }
}
