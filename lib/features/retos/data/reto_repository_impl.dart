import 'package:cloud_firestore/cloud_firestore.dart';
import '../domain/reto_entity.dart';
import '../domain/reto_repository.dart';
import 'reto_model.dart';

class RetoRepositoryImpl implements RetoRepository {
  final FirebaseFirestore _firestore;

  RetoRepositoryImpl({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  @override
  Future<List<RetoEntity>> getRetos() async {
    // Solo obtenemos los retos que están activos
    final snapshot = await _firestore
        .collection('Retos')
        .where('activo', isEqualTo: true)
        .get();

    final list = snapshot.docs.map((doc) => RetoModel.fromFirestore(doc)).toList();
    // Ordenamos en memoria para no requerir un índice compuesto en Firestore (activo + idUI)
    list.sort((a, b) => a.idUI.compareTo(b.idUI));
    
    return list;
  }

  @override
  Stream<List<RetoEntity>> streamRetos() {
    // Solo escuchamos los retos que están activos
    return _firestore
        .collection('Retos')
        .where('activo', isEqualTo: true)
        .snapshots()
        .map((snapshot) {
      final list = snapshot.docs.map((doc) => RetoModel.fromFirestore(doc)).toList();
      // Ordenamos en memoria
      list.sort((a, b) => a.idUI.compareTo(b.idUI));
      return list;
    });
  }
}
