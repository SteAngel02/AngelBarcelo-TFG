import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../domain/recompensa_entity.dart';
import '../domain/recompensa_repository.dart';
import 'recompensa_model.dart';

/// Implementación concreta del repositorio de recompensas usando Firebase Firestore.
class RecompensaRepositoryImpl implements RecompensaRepository {
  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  RecompensaRepositoryImpl(this._firestore);

  String get _currentUserId {
    final user = _auth.currentUser;
    if (user == null) throw Exception("Usuario no autenticado");
    return user.uid;
  }

  CollectionReference _getRecompensasRef(String avatarId) {
    return _firestore
        .collection('users')
        .doc(_currentUserId)
        .collection('avatars')
        .doc(avatarId)
        .collection('recompensas');
  }

  @override
  Future<List<RecompensaEntity>> getRecompensasByAvatar(String avatarId) async {
    final snapshot = await _getRecompensasRef(avatarId).get();
    return snapshot.docs.map((doc) => RecompensaModel.fromFirestore(doc)).toList();
  }

  @override
  Future<void> saveRecompensa(String avatarId, RecompensaEntity recompensa) async {
    final model = RecompensaModel(
      id: recompensa.id,
      nombre: recompensa.nombre,
      descripcion: recompensa.descripcion,
      coinType: recompensa.coinType,
      price: recompensa.price,
      stock: recompensa.stock,
    );

    if (model.id.isEmpty) {
      // Si no tiene ID, dejamos que Firestore genere uno automáticamente
      await _getRecompensasRef(avatarId).add(model.toFirestore());
    } else {
      // Si tiene ID, lo guardamos con ese ID
      await _getRecompensasRef(avatarId).doc(model.id).set(model.toFirestore());
    }
  }

  @override
  Future<void> updateRecompensa(String avatarId, RecompensaEntity recompensa) async {
    final model = RecompensaModel(
      id: recompensa.id,
      nombre: recompensa.nombre,
      descripcion: recompensa.descripcion,
      coinType: recompensa.coinType,
      price: recompensa.price,
      stock: recompensa.stock,
    );

    await _getRecompensasRef(avatarId).doc(model.id).update(model.toFirestore());
  }

  @override
  Future<void> deleteRecompensa(String avatarId, String id) async {
    await _getRecompensasRef(avatarId).doc(id).delete();
  }
}
