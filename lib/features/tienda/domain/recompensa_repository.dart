import 'recompensa_entity.dart';

/// Interfaz abstracta del repositorio para las recompensas de la tienda.
abstract class RecompensaRepository {
  /// Obtiene la lista de recompensas disponibles para un avatar específico.
  Future<List<RecompensaEntity>> getRecompensasByAvatar(String avatarId);

  /// Guarda una nueva recompensa para un avatar.
  Future<void> saveRecompensa(String avatarId, RecompensaEntity recompensa);

  /// Actualiza una recompensa existente (útil para cuando baja el stock).
  Future<void> updateRecompensa(String avatarId, RecompensaEntity recompensa);

  /// Elimina una recompensa de la tienda por su ID.
  Future<void> deleteRecompensa(String avatarId, String id);
}
