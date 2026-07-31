import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../domain/mision_entity.dart';
import '../domain/mision_repository.dart';
import 'mision_model.dart';

class MisionRepositoryImpl implements MisionRepository {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  String get _currentUserId {
    final user = _auth.currentUser;
    if (user == null) throw Exception("Usuario no autenticado");
    return user.uid;
  }

  @override
  Stream<List<MisionEntity>> getMisionesByAvatar(String avatarId) {
    return _db
        .collection('users')
        .doc(_currentUserId)
        .collection('avatars')
        .doc(avatarId)
        .collection('misiones')
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => MisionModel.fromFirestore(doc))
          .toList();
    });
  }

  @override
  Future<void> saveMision(String avatarId, MisionEntity mision) async {
    // Si el ID de la misión está vacío, Firestore generará uno.
    // Usualmente generamos IDs para que la Entidad ya lo tenga,
    // o dejamos que Firestore lo cree usando doc().
    DocumentReference docRef;
    final collectionRef = _db
        .collection('users')
        .doc(_currentUserId)
        .collection('avatars')
        .doc(avatarId)
        .collection('misiones');

    if (mision.id.isEmpty) {
      docRef = collectionRef.doc();
    } else {
      docRef = collectionRef.doc(mision.id);
    }
    await docRef.set(MisionModel.toFirestore(mision, avatarId));
  }

  @override
  Future<void> updateMision(String avatarId, MisionEntity mision) async {
    await _db
        .collection('users')
        .doc(_currentUserId)
        .collection('avatars')
        .doc(avatarId)
        .collection('misiones')
        .doc(mision.id)
        .update(MisionModel.toFirestore(mision, avatarId));
  }

  @override
  Future<void> deleteMision(String avatarId, String misionId) async {
    await _db
        .collection('users')
        .doc(_currentUserId)
        .collection('avatars')
        .doc(avatarId)
        .collection('misiones')
        .doc(misionId)
        .delete();
  }
}
