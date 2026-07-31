/// Entidad que representa uno de los 5 atributos del Avatar.
class AtributoEntity {
  final String id;
  final String name;
  final String description;
  final int level;
  final double exp;

  AtributoEntity({
    required this.id,
    required this.name,
    required this.description,
    this.level = 1,
    this.exp = 0.0,
  });

  /// Aumenta el nivel del atributo en 1 y reinicia la experiencia.
  AtributoEntity levelUp() {
    return copyWith(
      level: level + 1,
      exp: 0.0, // Reiniciamos la experiencia al subir de nivel
    );
  }

  /// Añade experiencia al atributo.
  AtributoEntity addExp(double amount) {
    double newExp = exp + amount;
    int levelsGained = 0;
    while (newExp >= 10.0) {
      levelsGained += 1;
      newExp -= 10.0;
    }
    
    if (levelsGained > 0) {
      return copyWith(
        level: level + levelsGained,
        exp: newExp,
      );
    }
    
    return copyWith(
      exp: newExp,
    );
  }

  /// Método para clonar la entidad modificando campos específicos.
  AtributoEntity copyWith({
    String? id,
    String? name,
    String? description,
    int? level,
    double? exp,
  }) {
    return AtributoEntity(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      level: level ?? this.level,
      exp: exp ?? this.exp,
    );
  }
}
