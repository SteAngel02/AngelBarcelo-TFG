import 'package:cloud_firestore/cloud_firestore.dart';
import '../domain/user_entity.dart';

/// Implementación del modelo de Usuario para la capa de Datos con Firebase.
/// Extiende para heredar la lógica.

class UserModel extends UserEntity {
  UserModel({
    required super.id,
    required super.userName,
    required super.email,
    super.activeAvatarId,
    super.graveyard,
  });

  /// Crea una instancia de a partir de un documento de Firestore.

  factory UserModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>?;

    return UserModel(
      id: doc.id,
      userName: data?['userName'] ?? '',
      email: data?['email'] ?? '',
      activeAvatarId: data?['activeAvatarId'],
      // Convertimos la lista dinámica de Firestore a una lista de Strings
      graveyard: List<String>.from(data?['graveyard'] ?? []),
    );
  }

  /// Convierte el modelo en un mapa de claves y valores para guardar en Firestore.
  /// Útil para el registro y actualización de perfiles.
  Map<String, dynamic> toFirestore() {
    return {
      'userName': userName,
      'email': email,
      'activeAvatarId': activeAvatarId,
      'graveyard': graveyard,
    };
  }
}