import 'package:cloud_firestore/cloud_firestore.dart';
import '../domain/sendas_entity.dart';

/// Helper para convertir Sendas entre Entity y Firestore.
class SendaModel {
  /// Convierte de Firestore a SendaEntity (con subSendas vacías inicialmente).
  static SendaEntity fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;

    final id = doc.id;
    final name = data['name'] ?? '';
    final description = data['description'] ?? '';
    final isCompleted = data['isCompleted'] ?? false;
    final gemsReward = data['gemsReward'] ?? 0;
    final tituloReward = data['tituloReward'] as String?;
    final imageUrl = data['imageUrl'] as String?;
    final parentId = data['parentId'] as String?;

    // Parsear tareas ToDo
    final tasksData = data['tasks'] as List<dynamic>? ?? [];
    final List<SendaTaskEntity> tasks = tasksData.map((t) {
      final taskMap = t as Map<String, dynamic>;
      return SendaTaskEntity(
        id: taskMap['id'] ?? '',
        title: taskMap['title'] ?? '',
        description: taskMap['description'] ?? '',
        isCompleted: taskMap['isCompleted'] ?? false,
      );
    }).toList();

    return SendaEntity(
      id: id,
      name: name,
      description: description,
      isCompleted: isCompleted,
      gemsReward: gemsReward,
      tituloReward: tituloReward,
      imageUrl: imageUrl,
      parentId: parentId,
      subSendas: const [],
      tasks: tasks,
    );
  }

  /// Convierte de SendaEntity a un mapa para Firestore.
  /// Nota: Las subsendas no se anidan en el mismo documento de Firestore,
  /// ya que se gestionan como documentos propios con una referencia `parentId`.
  static Map<String, dynamic> toFirestore(SendaEntity senda, String avatarId) {
    final tasksData = senda.tasks.map((t) {
      return {
        'id': t.id,
        'title': t.title,
        'description': t.description,
        'isCompleted': t.isCompleted,
      };
    }).toList();

    return <String, dynamic>{
      'avatarId': avatarId,
      'name': senda.name,
      'description': senda.description,
      'isCompleted': senda.isCompleted,
      'gemsReward': senda.gemsReward,
      'tituloReward': senda.tituloReward,
      'imageUrl': senda.imageUrl,
      'parentId': senda.parentId,
      'tasks': tasksData,
    };
  }
}
