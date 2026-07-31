import 'package:cloud_firestore/cloud_firestore.dart';
import '../domain/mision_entity.dart';

/// Helper para convertir Misiones entre Entity y Firestore.
class MisionModel {
  static const String TYPE_DIARIA = 'diaria';
  static const String TYPE_PERIODICA = 'periodica';
  static const String TYPE_TODO = 'todo';
  static const String TYPE_CASTIGO = 'castigo';

  /// Convierte de Firestore a la subclase correcta de MisionEntity
  static MisionEntity fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    final type = data['type'] as String? ?? TYPE_TODO;

    final id = doc.id;
    final name = data['name'] ?? '';
    final description = data['description'] ?? '';
    final isCompleted = data['isCompleted'] ?? false;
    final stat = _parseStat(data['stat']);
    final visible = data['visible'] ?? true;
    final difficulty = data['difficulty'] ?? 'Normal';
    final coinReward = data['coinReward'] ?? 0;

    final Timestamp? lastCompletedTimestamp =
        data['lastCompletedAt'] as Timestamp?;
    final DateTime? lastCompletedAt = lastCompletedTimestamp?.toDate();

    switch (type) {
      case TYPE_DIARIA:
        return DiariaEntity(
          id: id,
          name: name,
          description: description,
          isCompleted: isCompleted,
          stat: stat,
          visible: visible,
          difficulty: difficulty,
          coinReward: coinReward,
          lastCompletedAt: lastCompletedAt,
        );
      case TYPE_PERIODICA:
        return PeriodicaEntity(
          id: id,
          name: name,
          description: description,
          isCompleted: isCompleted,
          stat: stat,
          visible: visible,
          difficulty: difficulty,
          coinReward: coinReward,
          periodicity: data['periodicity'] ?? 1,
          isForever: data['isForever'] ?? false,
          goal: data['goal'] ?? 1,
          lastCompletedAt: lastCompletedAt,
        );
      case TYPE_CASTIGO:
        return CastigoEntity(
          id: id,
          name: name,
          description: description,
          isCompleted: isCompleted,
          stat: stat,
          visible: visible,
          difficulty: difficulty,
          coinReward: coinReward,
          penaltyCoins: data['penaltyCoins'] ?? 0,
          penaltyHealth: data['penaltyHealth'] ?? 0,
          lastCompletedAt: lastCompletedAt,
        );
      case TYPE_TODO:
      default:
        return TodoEntity(
          id: id,
          name: name,
          description: description,
          isCompleted: isCompleted,
          stat: stat,
          visible: visible,
          difficulty: difficulty,
          coinReward: coinReward,
          lastCompletedAt: lastCompletedAt,
        );
    }
  }

  /// Convierte de MisionEntity a un mapa para Firestore
  static Map<String, dynamic> toFirestore(MisionEntity mision, String avatarId) {
    String type = TYPE_TODO;
    if (mision is DiariaEntity) type = TYPE_DIARIA;
    if (mision is PeriodicaEntity) type = TYPE_PERIODICA;
    if (mision is CastigoEntity) type = TYPE_CASTIGO;
    if (mision is TodoEntity) type = TYPE_TODO;

    final data = <String, dynamic>{
      'avatarId': avatarId,
      'type': type,
      'name': mision.name,
      'description': mision.description,
      'isCompleted': mision.isCompleted,
      'stat': mision.stat.name,
      'visible': mision.visible,
      'difficulty': mision.difficulty,
      'coinReward': mision.coinReward,
      'lastCompletedAt': mision.lastCompletedAt != null
          ? Timestamp.fromDate(mision.lastCompletedAt!)
          : null,
    };

    if (mision is PeriodicaEntity) {
      data['periodicity'] = mision.periodicity;
      data['isForever'] = mision.isForever;
      data['goal'] = mision.goal;
    } else if (mision is CastigoEntity) {
      data['penaltyCoins'] = mision.penaltyCoins;
      data['penaltyHealth'] = mision.penaltyHealth;
    }

    return data;
  }

  static StatType _parseStat(String? statString) {
    if (statString == null) return StatType.fuerza;
    return StatType.values.firstWhere(
      (e) => e.name == statString,
      orElse: () => StatType.fuerza,
    );
  }
}
