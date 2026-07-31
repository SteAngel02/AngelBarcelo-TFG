/// Entidad usuario que define los datos del objeto.
class UserEntity {
  // Atributos del usuario.
  final String id;
  final String userName;
  final String email;

  /// ID del avatar activo, puede ser null. Solo puede ser uno.
  final String? activeAvatarId;

  /// Lista de IDs de avatares que han muerto.
  final List<String> graveyard;

  UserEntity({
    required this.id,
    required this.userName,
    required this.email,
    this.activeAvatarId,
    this.graveyard = const [],
  });

  bool get hasActiveAvatar => activeAvatarId != null;

  /// Establece un avatar como activo
  UserEntity setActiveAvatar(String avatarId) {
    return copyWith(activeAvatarId: avatarId);
  }

  /// Entierra el avatar activo: lo quita de activo y lo añade al cementerio
  UserEntity buryActiveAvatar() {
    if (activeAvatarId == null) return this;
    
    return UserEntity(
      id: id,
      userName: userName,
      email: email,
      activeAvatarId: null,
      graveyard: [...graveyard, activeAvatarId!],
    );
  }

  /// Método para clonar la entidad modificando campos específicos.
  UserEntity copyWith({
    String? id,
    String? userName,
    String? email,
    String? activeAvatarId,
    List<String>? graveyard,
  }) {
    return UserEntity(
      id: id ?? this.id,
      userName: userName ?? this.userName,
      email: email ?? this.email,
      activeAvatarId: activeAvatarId ?? this.activeAvatarId,
      graveyard: graveyard ?? this.graveyard,
    );
  }
}
