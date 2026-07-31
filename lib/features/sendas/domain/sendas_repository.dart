import 'sendas_entity.dart';

/// Interfaz que define los métodos de acceso a datos para Sendas.
abstract class SendaRepository {
  /// Obtiene un flujo de sendas asociadas a un avatar específico.
  Stream<List<SendaEntity>> getSendasByAvatar(String avatarId);

  /// Guarda una nueva senda en la base de datos asociada a un avatar.
  Future<void> saveSenda(String avatarId, SendaEntity senda);

  /// Actualiza una senda existente.
  Future<void> updateSenda(String avatarId, SendaEntity senda);

  /// Elimina una senda por su ID.
  Future<void> deleteSenda(String avatarId, String sendaId);
}
