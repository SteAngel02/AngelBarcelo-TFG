import 'mision_entity.dart';

/// Interfaz que define los métodos de acceso a datos para Misiones.
abstract class MisionRepository {
  /// Obtiene un flujo de misiones asociadas a un avatar específico.
  Stream<List<MisionEntity>> getMisionesByAvatar(String avatarId);

  /// Guarda una nueva misión en la base de datos asociada a un avatar.
  Future<void> saveMision(String avatarId, MisionEntity mision);

  /// Actualiza una misión existente.
  Future<void> updateMision(String avatarId, MisionEntity mision);

  /// Elimina una misión por su ID.
  Future<void> deleteMision(String avatarId, String misionId);
}
