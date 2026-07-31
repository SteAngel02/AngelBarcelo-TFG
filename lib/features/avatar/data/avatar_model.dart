import 'package:cloud_firestore/cloud_firestore.dart';
import '../domain/avatar_entity.dart';
import '../domain/atributo_entity.dart';

/// Modelo de Atributo para convertir hacia y desde Firestore (Map).
class AtributoModel extends AtributoEntity {
  AtributoModel({
    required super.id,
    required super.name,
    required super.description,
    super.level,
    super.exp,
  });

  factory AtributoModel.fromMap(Map<String, dynamic> map) {
    return AtributoModel(
      id: map['id'] ?? '',
      name: map['name'] ?? '',
      description: map['description'] ?? '',
      level: map['level'] ?? 1,
      exp: (map['exp'] ?? 0.0).toDouble(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'level': level,
      'exp': exp,
    };
  }
}

/// Implementación del modelo de Avatar para la capa de Datos con Firebase.
class AvatarModel extends AvatarEntity {
  AvatarModel({
    required super.id,
    required super.name,
    required super.image,
    super.isAlive,
    super.health,
    super.coins,
    super.gems,
    super.level,
    super.exp,
    super.titulos,
    super.activeTitle,
    super.completedRetos,
    super.challengePoints,
    super.atributos,
  });

  /// Crea una instancia a partir de un documento de Firestore.
  factory AvatarModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>?;

    // Parseamos la lista de atributos (si existe)
    List<AtributoModel> parsedAtributos = [];
    if (data?['atributos'] != null) {
      parsedAtributos = (data!['atributos'] as List)
          .map((item) => AtributoModel.fromMap(item as Map<String, dynamic>))
          .toList();
    }

    return AvatarModel(
      id: doc.id,
      name: data?['name'] ?? '',
      image: data?['image'] ?? '',
      isAlive: data?['isAlive'] ?? true,
      health: data?['health'] ?? 100,
      coins: data?['coins'] ?? 0,
      gems: data?['gems'] ?? 0,
      level: data?['level'] ?? 1,
      exp: data?['exp'] ?? 0,
      titulos: List<String>.from(data?['titulos'] ?? []),
      activeTitle: data?['activeTitle'] as String?,
      completedRetos: List<String>.from(data?['completedRetos'] ?? []),
      challengePoints: data?['challengePoints'] ?? 0,
      atributos: parsedAtributos,
    );
  }

  /// Convierte el modelo en un mapa para guardar en Firestore.
  Map<String, dynamic> toFirestore() {
    return {
      'name': name,
      'image': image,
      'isAlive': isAlive,
      'health': health,
      'coins': coins,
      'gems': gems,
      'level': level,
      'exp': exp,
      'titulos': titulos,
      'activeTitle': activeTitle,
      'completedRetos': completedRetos,
      'challengePoints': challengePoints,
      // Convertimos cada AtributoEntity a su versión Map
      'atributos': atributos.map((a) {
        return {
          'id': a.id,
          'name': a.name,
          'description': a.description,
          'level': a.level,
          'exp': a.exp,
        };
      }).toList(),
    };
  }
}
