import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../domain/sendas_entity.dart';
import '../domain/sendas_repository.dart';
import 'sendas_model.dart';

/// Implementación de la interfaz SendaRepository utilizando Cloud Firestore.
class SendaRepositoryImpl implements SendaRepository {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  String get _currentUserId {
    final user = _auth.currentUser;
    if (user == null) throw Exception("Usuario no autenticado");
    return user.uid;
  }

  @override
  Stream<List<SendaEntity>> getSendasByAvatar(String avatarId) {
    return _db
        .collection('users')
        .doc(_currentUserId)
        .collection('avatars')
        .doc(avatarId)
        .collection('sendas')
        .snapshots()
        .map((snapshot) {
      // 1. Obtener todas las sendas de Firestore
      final allSendas = snapshot.docs
          .map((doc) => SendaModel.fromFirestore(doc))
          .toList();

      // 2. Reconstruir el árbol jerárquico padre-hijo en memoria
      return _buildSendaTree(allSendas);
    });
  }

  @override
  Future<void> saveSenda(String avatarId, SendaEntity senda) async {
    DocumentReference docRef;
    final collectionRef = _db
        .collection('users')
        .doc(_currentUserId)
        .collection('avatars')
        .doc(avatarId)
        .collection('sendas');

    if (senda.id.isEmpty) {
      docRef = collectionRef.doc();
    } else {
      docRef = collectionRef.doc(senda.id);
    }

    // Al guardar, no anidamos físicamente las subsendas en el documento.
    // Solo guardamos los campos propios del nodo actual.
    await docRef.set(SendaModel.toFirestore(senda, avatarId));
  }

  @override
  Future<void> updateSenda(String avatarId, SendaEntity senda) async {
    await _db
        .collection('users')
        .doc(_currentUserId)
        .collection('avatars')
        .doc(avatarId)
        .collection('sendas')
        .doc(senda.id)
        .update(SendaModel.toFirestore(senda, avatarId));
  }

  @override
  Future<void> deleteSenda(String avatarId, String sendaId) async {
    final collectionRef = _db
        .collection('users')
        .doc(_currentUserId)
        .collection('avatars')
        .doc(avatarId)
        .collection('sendas');

    // 1. Obtener todas las sendas actuales para encontrar dependientes
    final snapshot = await collectionRef.get();
    final allSendas = snapshot.docs
        .map((doc) => SendaModel.fromFirestore(doc))
        .toList();

    // 2. Buscar IDs de subsendas descendientes recursivamente para eliminarlos todos
    final List<String> idsToDelete = [sendaId];
    _findDescendantIds(sendaId, allSendas, idsToDelete);

    // 3. Ejecutar la eliminación en un WriteBatch
    final batch = _db.batch();
    for (final id in idsToDelete) {
      batch.delete(collectionRef.doc(id));
    }
    await batch.commit();
  }

  /// Construye recursivamente el árbol de sendas.
  List<SendaEntity> _buildSendaTree(List<SendaEntity> all) {
    final Map<String, SendaEntity> lookup = {for (var s in all) s.id: s};
    final Map<String, List<SendaEntity>> childrenOf = {};
    final List<SendaEntity> roots = [];

    for (var s in all) {
      final parentId = s.parentId;
      if (parentId == null || parentId.isEmpty || !lookup.containsKey(parentId)) {
        roots.add(s);
      } else {
        childrenOf.putIfAbsent(parentId, () => []).add(s);
      }
    }

    SendaEntity buildNode(SendaEntity node) {
      final children = childrenOf[node.id] ?? [];
      final resolvedChildren = children.map((c) => buildNode(c)).toList();
      return node.copyWith(subSendas: resolvedChildren);
    }

    return roots.map((r) => buildNode(r)).toList();
  }

  /// Busca de forma recursiva todos los descendientes directos e indirectos de una senda.
  void _findDescendantIds(String parentId, List<SendaEntity> all, List<String> result) {
    for (final s in all) {
      if (s.parentId == parentId) {
        result.add(s.id);
        _findDescendantIds(s.id, all, result);
      }
    }
  }
}
