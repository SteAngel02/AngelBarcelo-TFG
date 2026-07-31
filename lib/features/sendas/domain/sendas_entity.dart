/// Clase que representa una tarea simple tipo ToDo dentro de una senda.
class SendaTaskEntity {
  final String id;
  final String title;
  final String description;
  final bool isCompleted;

  SendaTaskEntity({
    required this.id,
    required this.title,
    required this.description,
    this.isCompleted = false,
  });

  /// Crea una copia de la tarea con los campos modificados.
  SendaTaskEntity copyWith({
    String? id,
    String? title,
    String? description,
    bool? isCompleted,
  }) {
    return SendaTaskEntity(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      isCompleted: isCompleted ?? this.isCompleted,
    );
  }
}

/// Clase que representa una Senda de aprendizaje/progreso.
class SendaEntity {
  final String id;
  final String name;
  final String description;
  final bool isCompleted;
  final int gemsReward;
  final String? tituloReward;
  final String? imageUrl;
  final String? parentId;
  final List<SendaEntity> subSendas;
  final List<SendaTaskEntity> tasks;

  SendaEntity({
    required this.id,
    required this.name,
    required this.description,
    this.isCompleted = false,
    required this.gemsReward,
    this.tituloReward,
    this.imageUrl,
    this.parentId,
    this.subSendas = const [],
    this.tasks = const [],
  });

  /// Verifica si se cumplen las condiciones para completar la senda.
  /// Para completar una senda, todas sus subsendas y tareas asociadas deben estar completadas.
  bool get canBeCompleted {
    return tasks.every((t) => t.isCompleted) && subSendas.every((s) => s.isCompleted);
  }

  /// Marca la senda como completada si se cumplen los requisitos.
  SendaEntity complete() {
    if (!canBeCompleted) {
      throw StateError('No se puede completar la senda: hay tareas o subsendas pendientes.');
    }
    return copyWith(isCompleted: true);
  }

  /// Edita los campos de la senda.
  SendaEntity edit({
    String? name,
    String? description,
    int? gemsReward,
    String? tituloReward,
    String? imageUrl,
    String? parentId,
    List<SendaEntity>? subSendas,
    List<SendaTaskEntity>? tasks,
  }) {
    return copyWith(
      name: name,
      description: description,
      gemsReward: gemsReward,
      tituloReward: tituloReward,
      imageUrl: imageUrl,
      parentId: parentId,
      subSendas: subSendas,
      tasks: tasks,
    );
  }

  /// Crea una copia de la senda con los campos modificados.
  SendaEntity copyWith({
    String? id,
    String? name,
    String? description,
    bool? isCompleted,
    int? gemsReward,
    String? tituloReward,
    String? imageUrl,
    String? parentId,
    List<SendaEntity>? subSendas,
    List<SendaTaskEntity>? tasks,
  }) {
    return SendaEntity(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      isCompleted: isCompleted ?? this.isCompleted,
      gemsReward: gemsReward ?? this.gemsReward,
      tituloReward: tituloReward ?? this.tituloReward,
      imageUrl: imageUrl ?? this.imageUrl,
      parentId: parentId ?? this.parentId,
      subSendas: subSendas ?? this.subSendas,
      tasks: tasks ?? this.tasks,
    );
  }
}
