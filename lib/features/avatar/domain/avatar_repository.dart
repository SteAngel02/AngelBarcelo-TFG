import 'avatar_entity.dart';

/// Interfaz del Repositorio de Avatar.

abstract class AvatarRepository {
  /// Obtiene los datos de un avatar específico por su ID.
  Future<AvatarEntity?> getAvatarById(String avatarId);

  /// Crea o guarda un avatar asociándolo a un usuario.
  Future<void> saveAvatar(String userId, AvatarEntity avatar);

  /// Actualiza los datos de un avatar existente (p. ej. tras recibir daño o subir de nivel).
  Future<void> updateAvatar(AvatarEntity avatar);

  /// Elimina el avatar de la base de datos o lo mueve al cementerio.
  Future<void> deleteAvatar(String avatarId);

  /// Obtiene todos los avatares muertos del usuario.
  Future<List<AvatarEntity>> getDeadAvatars();
}
