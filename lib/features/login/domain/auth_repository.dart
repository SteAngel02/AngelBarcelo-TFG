import 'user_entity.dart';

/// Interfaz del Repositorio de Autenticación.
/// Define las reglas de negocio para el acceso al sistema.
abstract class AuthRepository {
  /// Inicia sesión y devuelve la entidad del usuario.
  Future<UserEntity?> signIn(String email, String password);

  /// Registra un nuevo usuario y crea su perfil inicial.
  Future<UserEntity?> signUp({
    required String email, 
    required String password, 
    required String userName,
  });

  /// Cierra la sesión del usuario.
  Future<void> signOut();

  /// Actualiza los datos del usuario en la base de datos (por ejemplo, al vincular un avatar).
  Future<void> updateUser(UserEntity user);

  /// Proporciona un stream para escuchar los cambios en el estado de autenticación del usuario.
  /// Emite un UserEntity? cada vez que el estado de autenticación cambia (ej. login, logout).
  Stream<UserEntity?> get onAuthStateChanged;

}