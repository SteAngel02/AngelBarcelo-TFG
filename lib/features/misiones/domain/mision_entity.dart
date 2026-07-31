/// Enum que representa los posibles atributos que se ven afectados por las misiones.
enum StatType {
  fuerza,
  inteligencia,
  constitucion,
  destreza,
  sabiduria,
}

/// Clase base abstracta para todas las misiones.
abstract class MisionEntity {
  final String id;
  final String name;
  final String description;
  final bool isCompleted;
  final StatType stat;
  final bool visible;
  final String difficulty;
  final int coinReward;
  final DateTime? lastCompletedAt;

  MisionEntity({
    required this.id,
    required this.name,
    required this.description,
    this.isCompleted = false,
    required this.stat,
    this.visible = true,
    required this.difficulty,
    required this.coinReward,
    this.lastCompletedAt,
  });

  /// Marca la misión como completada.
  MisionEntity complete([DateTime? completionDate]);

  /// Evaluación Lazy para reiniciar estado según paso del tiempo (Rich Domain Model)
  MisionEntity evaluateLazyReset([DateTime? now]);

  /// Comprueba si la misión venció sin haber sido completada.
  bool isMissed([DateTime? now]) => false;

  /// Define si la misión debe ser eliminada de la base de datos al completarse.
  bool get shouldDeleteOnComplete => false;

  /// Edita los campos comunes de la misión.
  MisionEntity edit({
    String? name,
    String? description,
    StatType? stat,
    bool? visible,
    String? difficulty,
    int? coinReward,
  });
}

/// Misión de frecuencia diaria.
class DiariaEntity extends MisionEntity {
  DiariaEntity({
    required super.id,
    required super.name,
    required super.description,
    super.isCompleted,
    required super.stat,
    super.visible,
    required super.difficulty,
    required super.coinReward,
    super.lastCompletedAt,
  });

  @override
  DiariaEntity complete([DateTime? completionDate]) {
    return _copyWith(
      isCompleted: true,
      visible: false,
      lastCompletedAt: completionDate ?? DateTime.now(),
    );
  }

  @override
  bool isMissed([DateTime? now]) {
    if (isCompleted || !visible) return false;
    if (lastCompletedAt == null) return false;
    final currentDate = now ?? DateTime.now();

    final lastDateOnly = DateTime(
      lastCompletedAt!.year,
      lastCompletedAt!.month,
      lastCompletedAt!.day,
    );
    final currentDateOnly = DateTime(
      currentDate.year,
      currentDate.month,
      currentDate.day,
    );

    return currentDateOnly.isAfter(lastDateOnly);
  }

  @override
  DiariaEntity evaluateLazyReset([DateTime? now]) {
    final currentDate = now ?? DateTime.now();
    if (lastCompletedAt == null) {
      return _copyWith(lastCompletedAt: currentDate);
    }

    final lastDateOnly = DateTime(
      lastCompletedAt!.year,
      lastCompletedAt!.month,
      lastCompletedAt!.day,
    );
    final currentDateOnly = DateTime(
      currentDate.year,
      currentDate.month,
      currentDate.day,
    );

    // Si hoy es un día calendarizado posterior al de la última vez completada
    if (currentDateOnly.isAfter(lastDateOnly)) {
      return _copyWith(
        isCompleted: false,
        visible: true,
        lastCompletedAt: currentDate,
      );
    }
    return this;
  }

  @override
  DiariaEntity edit({
    String? name,
    String? description,
    StatType? stat,
    bool? visible,
    String? difficulty,
    int? coinReward,
  }) {
    return _copyWith(
      name: name,
      description: description,
      stat: stat,
      visible: visible,
      difficulty: difficulty,
      coinReward: coinReward,
    );
  }

  DiariaEntity _copyWith({
    String? name,
    String? description,
    bool? isCompleted,
    StatType? stat,
    bool? visible,
    String? difficulty,
    int? coinReward,
    DateTime? lastCompletedAt,
  }) {
    return DiariaEntity(
      id: id,
      name: name ?? this.name,
      description: description ?? this.description,
      isCompleted: isCompleted ?? this.isCompleted,
      stat: stat ?? this.stat,
      visible: visible ?? this.visible,
      difficulty: difficulty ?? this.difficulty,
      coinReward: coinReward ?? this.coinReward,
      lastCompletedAt: lastCompletedAt ?? this.lastCompletedAt,
    );
  }
}

/// Misión con periodicidad específica.
class PeriodicaEntity extends MisionEntity {
  /// El número de días para que esa misión se repita.
  final int periodicity;

  /// El booleano que determina si esa misión se completará un número indefinido de veces o n veces igual a goal.
  final bool isForever;

  /// El número de veces que se tiene que completar esa misión hasta que se termine por eliminar.
  final int goal;

  PeriodicaEntity({
    required super.id,
    required super.name,
    required super.description,
    super.isCompleted,
    required super.stat,
    super.visible,
    required super.difficulty,
    required super.coinReward,
    required this.periodicity,
    required this.isForever,
    required this.goal,
    super.lastCompletedAt,
  });

  /// Calcula los días restantes para volver a estar disponible
  int remainingDays([DateTime? now]) {
    if (lastCompletedAt == null || !isCompleted || visible) return 0;
    final currentDate = now ?? DateTime.now();

    final lastDateOnly = DateTime(
      lastCompletedAt!.year,
      lastCompletedAt!.month,
      lastCompletedAt!.day,
    );
    final currentDateOnly = DateTime(
      currentDate.year,
      currentDate.month,
      currentDate.day,
    );

    final daysPassed = currentDateOnly.difference(lastDateOnly).inDays;
    final daysLeft = periodicity - daysPassed;
    return daysLeft > 0 ? daysLeft : 0;
  }

  @override
  PeriodicaEntity complete([DateTime? completionDate]) {
    int newGoal = goal;
    if (!isForever && newGoal > 0) {
      newGoal--;
    }
    return _copyWith(
      isCompleted: true,
      visible: false,
      goal: newGoal,
      lastCompletedAt: completionDate ?? DateTime.now(),
    );
  }

  @override
  PeriodicaEntity evaluateLazyReset([DateTime? now]) {
    if (lastCompletedAt == null) return this;
    if (shouldDeleteOnComplete) return this;

    if (remainingDays(now) <= 0) {
      return _copyWith(
        isCompleted: false,
        visible: true,
      );
    }
    return this;
  }

  @override
  bool get shouldDeleteOnComplete => !isForever && goal <= 1;

  @override
  PeriodicaEntity edit({
    String? name,
    String? description,
    StatType? stat,
    bool? visible,
    String? difficulty,
    int? coinReward,
    int? periodicity,
    bool? isForever,
    int? goal,
  }) {
    return _copyWith(
      name: name,
      description: description,
      stat: stat,
      visible: visible,
      difficulty: difficulty,
      coinReward: coinReward,
      periodicity: periodicity,
      isForever: isForever,
      goal: goal,
    );
  }

  PeriodicaEntity _copyWith({
    String? name,
    String? description,
    bool? isCompleted,
    StatType? stat,
    bool? visible,
    String? difficulty,
    int? coinReward,
    int? periodicity,
    bool? isForever,
    int? goal,
    DateTime? lastCompletedAt,
  }) {
    return PeriodicaEntity(
      id: id,
      name: name ?? this.name,
      description: description ?? this.description,
      isCompleted: isCompleted ?? this.isCompleted,
      stat: stat ?? this.stat,
      visible: visible ?? this.visible,
      difficulty: difficulty ?? this.difficulty,
      coinReward: coinReward ?? this.coinReward,
      periodicity: periodicity ?? this.periodicity,
      isForever: isForever ?? this.isForever,
      goal: goal ?? this.goal,
      lastCompletedAt: lastCompletedAt ?? this.lastCompletedAt,
    );
  }
}

/// Misión de tipo lista de tareas pendientes.
class TodoEntity extends MisionEntity {
  TodoEntity({
    required super.id,
    required super.name,
    required super.description,
    super.isCompleted,
    required super.stat,
    super.visible,
    required super.difficulty,
    required super.coinReward,
    super.lastCompletedAt,
  });

  @override
  TodoEntity complete([DateTime? completionDate]) {
    return _copyWith(
      isCompleted: true,
      visible: false,
      lastCompletedAt: completionDate ?? DateTime.now(),
    );
  }

  @override
  TodoEntity evaluateLazyReset([DateTime? now]) {
    return this;
  }

  @override
  bool get shouldDeleteOnComplete => true;

  @override
  TodoEntity edit({
    String? name,
    String? description,
    StatType? stat,
    bool? visible,
    String? difficulty,
    int? coinReward,
  }) {
    return _copyWith(
      name: name,
      description: description,
      stat: stat,
      visible: visible,
      difficulty: difficulty,
      coinReward: coinReward,
    );
  }

  TodoEntity _copyWith({
    String? name,
    String? description,
    bool? isCompleted,
    StatType? stat,
    bool? visible,
    String? difficulty,
    int? coinReward,
    DateTime? lastCompletedAt,
  }) {
    return TodoEntity(
      id: id,
      name: name ?? this.name,
      description: description ?? this.description,
      isCompleted: isCompleted ?? this.isCompleted,
      stat: stat ?? this.stat,
      visible: visible ?? this.visible,
      difficulty: difficulty ?? this.difficulty,
      coinReward: coinReward ?? this.coinReward,
      lastCompletedAt: lastCompletedAt ?? this.lastCompletedAt,
    );
  }
}

/// Misión de tipo castigo, con penalizaciones.
class CastigoEntity extends MisionEntity {
  final int penaltyCoins;
  final int penaltyHealth;

  CastigoEntity({
    required super.id,
    required super.name,
    required super.description,
    super.isCompleted,
    required super.stat,
    super.visible,
    required super.difficulty,
    required super.coinReward,
    this.penaltyCoins = 0,
    this.penaltyHealth = 0,
    super.lastCompletedAt,
  });

  @override
  CastigoEntity complete([DateTime? completionDate]) {
    // Los castigos no cambian su estado al completarse
    return _copyWith(
      lastCompletedAt: completionDate ?? DateTime.now(),
    );
  }

  @override
  CastigoEntity evaluateLazyReset([DateTime? now]) {
    return this;
  }

  @override
  CastigoEntity edit({
    String? name,
    String? description,
    StatType? stat,
    bool? visible,
    String? difficulty,
    int? coinReward,
    int? penaltyCoins,
    int? penaltyHealth,
  }) {
    return _copyWith(
      name: name,
      description: description,
      stat: stat,
      visible: visible,
      difficulty: difficulty,
      coinReward: coinReward,
      penaltyCoins: penaltyCoins,
      penaltyHealth: penaltyHealth,
    );
  }

  CastigoEntity _copyWith({
    String? name,
    String? description,
    bool? isCompleted,
    StatType? stat,
    bool? visible,
    String? difficulty,
    int? coinReward,
    int? penaltyCoins,
    int? penaltyHealth,
    DateTime? lastCompletedAt,
  }) {
    return CastigoEntity(
      id: id,
      name: name ?? this.name,
      description: description ?? this.description,
      isCompleted: isCompleted ?? this.isCompleted,
      stat: stat ?? this.stat,
      visible: visible ?? this.visible,
      difficulty: difficulty ?? this.difficulty,
      coinReward: coinReward ?? this.coinReward,
      penaltyCoins: penaltyCoins ?? this.penaltyCoins,
      penaltyHealth: penaltyHealth ?? this.penaltyHealth,
      lastCompletedAt: lastCompletedAt ?? this.lastCompletedAt,
    );
  }
}
