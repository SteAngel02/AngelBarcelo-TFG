import 'package:cloud_firestore/cloud_firestore.dart';
import '../domain/recompensa_entity.dart';

/// Implementación del modelo de Recompensa para la capa de Datos con Firebase.
class RecompensaModel extends RecompensaEntity {
  RecompensaModel({
    required super.id,
    required super.nombre,
    required super.descripcion,
    required super.coinType,
    required super.price,
    super.stock,
  });

  /// Crea una instancia a partir de un documento de Firestore.
  factory RecompensaModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>?;

    return RecompensaModel(
      id: doc.id,
      nombre: data?['nombre'] ?? '',
      descripcion: data?['descripcion'] ?? '',
      // Se asume que en Firebase se guarda como String: 'coins' o 'gems'
      coinType: (data?['coinType'] == 'gems') ? CoinType.gems : CoinType.coins,
      price: data?['price'] ?? 0,
      stock: data?['stock'] ?? 1,
    );
  }

  /// Convierte el modelo en un mapa para guardar en Firestore.
  Map<String, dynamic> toFirestore() {
    return {
      'nombre': nombre,
      'descripcion': descripcion,
      'coinType': coinType == CoinType.gems ? 'gems' : 'coins',
      'price': price,
      'stock': stock,
    };
  }
}
