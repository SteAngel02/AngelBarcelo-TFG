import 'atributo_entity.dart';
import '../../misiones/domain/mision_entity.dart';

/// Entidad que representa un avatar en el juego.
class AvatarEntity {
  final String id;
  final String name;
  final String image;
  final bool isAlive;
  final int health;
  final int coins;
  final int gems;
  final int level;
  final List<String> titulos;
  final String? activeTitle;
  final List<String> completedRetos;
  final int challengePoints;
  final int exp;

  /// Van a ser 5 atributos.
  final List<AtributoEntity> atributos;

  AvatarEntity({
    required this.id,
    required this.name,
    required this.image,
    this.isAlive = true,
    this.health = 10, // Vida máxima inicial por defecto
    this.coins = 0,
    this.gems = 0,
    this.level = 1,
    this.exp = 0,
    this.titulos = const [],
    this.activeTitle,
    this.completedRetos = const [],
    this.challengePoints = 0,
    this.atributos = const [],
  });

  /// El avatar muere, perdiendo toda su vida.
  AvatarEntity die() {
    return copyWith(isAlive: false, health: 0);
  }

  /// Sube el nivel general del avatar y cura toda su salud.
  AvatarEntity levelUp() {
    return copyWith(
      level: level + 1, 
      challengePoints: challengePoints + 1,
      exp: exp % 100, // Mantenemos el resto si ha superado 100
      health: 10, // Curación completa al subir de nivel
    );
  }

  /// Establece el título principal del avatar.
  AvatarEntity setActiveTitle(String title) {
    return copyWith(activeTitle: title);
  }

  /// Añade un título nuevo a la lista si no lo tiene.
  AvatarEntity addTitle(String title) {
    if (titulos.contains(title)) return this;
    return copyWith(
      titulos: [...titulos, title],
    );
  }

  /// Completa un reto guardando su ID.
  AvatarEntity completeReto(String retoId) {
    if (completedRetos.contains(retoId)) return this;
    return copyWith(
      completedRetos: [...completedRetos, retoId],
    );
  }

  /// Acepta un reto, consumiendo un challengePoint si es posible.
  AvatarEntity acceptReto() {
    if (challengePoints > 0) {
      return copyWith(challengePoints: challengePoints - 1);
    }
    return this; 
  }

  /// Añade o resta monedas.
  AvatarEntity modifyCoins(int amount) {
    final newCoins = (coins + amount < 0) ? 0 : coins + amount;
    return copyWith(coins: newCoins);
  }

  /// Añade o resta gemas.
  AvatarEntity modifyGems(int amount) {
    final newGems = (gems + amount < 0) ? 0 : gems + amount;
    return copyWith(gems: newGems);
  }

  /// Añade o resta vida. Si la vida llega a 0, el avatar muere.
  AvatarEntity modifyHealth(int amount) {
    final newHealth = (health + amount < 0) ? 0 : health + amount;
    if (newHealth == 0) return die();
    return copyWith(health: newHealth);
  }

  /// Añade experiencia a un atributo específico, creándolo si no existe, y añade exp global.
  AvatarEntity addExpToAttribute(String statName, double expAmount) {
    final List<AtributoEntity> newAtributos = List.from(atributos);
    final index = newAtributos.indexWhere(
      (a) => a.name.toLowerCase() == statName.toLowerCase(),
    );

    if (index >= 0) {
      newAtributos[index] = newAtributos[index].addExp(expAmount);
    } else {
      newAtributos.add(
        AtributoEntity(
          id: statName,
          name: statName,
          description: 'Atributo $statName',
          exp: expAmount,
        ),
      );
    }

    // Añadir exp global al avatar (5 por cada vez que se sube exp a un atributo)
    int newGlobalExp = exp + 5;
    AvatarEntity updated = copyWith(atributos: newAtributos, exp: newGlobalExp);

    // Subir de nivel si llega a 100
    while (updated.exp >= 100) {
      updated = updated.levelUp();
    }

    return updated;
  }

  /// Consume una misión y aplica las recompensas al avatar (Rich Domain Model)
  AvatarEntity applyMisionRewards(MisionEntity mision) {
    if (mision is CastigoEntity) {
      // Un castigo siempre resta -1 de vida y 0 monedas
      return modifyHealth(-1);
    } else {
      // Para cualquier otra misión, sumamos monedas y experiencia
      AvatarEntity updated = modifyCoins(mision.coinReward);
      return updated.addExpToAttribute(mision.stat.name, 1.0);
    }
  }

  /// Aplica la recompensa tras completar un Reto:
  /// Incrementa 1 nivel al atributo seleccionado y otorga 50 de exp global.
  AvatarEntity applyRetoReward(String statName) {
    final List<AtributoEntity> newAtributos = List.from(atributos);
    final index = newAtributos.indexWhere(
      (a) => a.name.toLowerCase() == statName.toLowerCase(),
    );

    if (index >= 0) {
      newAtributos[index] = newAtributos[index].copyWith(
        level: newAtributos[index].level + 1,
      );
    } else {
      newAtributos.add(
        AtributoEntity(
          id: statName.toLowerCase(), // Usar lowercase o como se defina
          name: statName,
          description: 'Atributo $statName',
          level: 2, // Si acaba de crearse, sube directamente de 1 a 2
          exp: 0.0,
        ),
      );
    }

    // Añadir exp global al avatar (Medio nivel = 50 exp)
    int newGlobalExp = exp + 50;
    AvatarEntity updated = copyWith(atributos: newAtributos, exp: newGlobalExp);

    // Subir de nivel si llega a 100
    while (updated.exp >= 100) {
      updated = updated.levelUp();
    }

    return updated;
  }

  /// Método para clonar la entidad modificando campos específicos.
  AvatarEntity copyWith({
    String? id,
    String? name,
    String? image,
    bool? isAlive,
    int? health,
    int? coins,
    int? gems,
    int? level,
    int? exp,
    List<String>? titulos,
    String? activeTitle,
    List<String>? completedRetos,
    int? challengePoints,
    List<AtributoEntity>? atributos,
  }) {
    return AvatarEntity(
      id: id ?? this.id,
      name: name ?? this.name,
      image: image ?? this.image,
      isAlive: isAlive ?? this.isAlive,
      health: health ?? this.health,
      coins: coins ?? this.coins,
      gems: gems ?? this.gems,
      level: level ?? this.level,
      exp: exp ?? this.exp,
      titulos: titulos ?? this.titulos,
      activeTitle: activeTitle ?? this.activeTitle,
      completedRetos: completedRetos ?? this.completedRetos,
      challengePoints: challengePoints ?? this.challengePoints,
      atributos: atributos ?? this.atributos,
    );
  }
}
