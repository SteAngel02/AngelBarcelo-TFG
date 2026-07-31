import 'package:flutter/material.dart';
import '../domain/auth_repository.dart';
import '../domain/user_entity.dart';

/// Gestor de estado para la autenticación. Se inyecta 
/// Sigue el patrón de Presentation Layer comunicando la UI con Data.
class AuthProvider extends ChangeNotifier {
  final AuthRepository _repository;

  UserEntity? _user;
  bool _isLoading = false;
  String? _errorMessage;

  /// Constructor con Inyección de Dependencias del repositorio.
  AuthProvider(this._repository) {
    _listenToAuthChanges();
  }

  // Getters para la UI
  UserEntity? get user => _user;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get isAuthenticated => _user != null;

  /// Escucha cambios en tiempo real 
  void _listenToAuthChanges() {
    _repository.onAuthStateChanged.listen((user) {
      _user = user;
      notifyListeners();
    });
  }

  /// Procesa el inicio de sesión.
  Future<bool> login(String email, String password) async {
    _setLoading(true);
    _clearError();
    
    try {
      _user = await _repository.signIn(email, password);
      return _user != null;
    } catch (e) {
      _errorMessage = "Error al iniciar sesión: ${e.toString()}";
      return false;
    } finally {
      _setLoading(false);
    }
  }

  /// Procesa el registro de un nuevo usuario.
  Future<bool> register(String email, String password, String userName) async {
    _setLoading(true);
    _clearError();

    try {
      _user = await _repository.signUp(
        email: email, 
        password: password, 
        userName: userName
      );
      return _user != null;
    } catch (e) {
      _errorMessage = "Error al registrarse: ${e.toString()}";
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<void> logout() async {
    await _repository.signOut();
    _user = null;
    notifyListeners();
  }

  /// Vincula un avatar creado al usuario actual
  Future<void> setActiveAvatar(String avatarId) async {
    if (_user == null) return;
    
    _setLoading(true);
    _clearError();
    try {
      // Usamos el método rico de la entidad
      final updatedUser = _user!.setActiveAvatar(avatarId);
      
      // Guardamos en Firebase
      await _repository.updateUser(updatedUser);
      
      // Actualizamos en memoria y notificamos a la UI
      _user = updatedUser;
      notifyListeners();
    } catch (e) {
      _errorMessage = "Error al vincular el avatar: ${e.toString()}";
      notifyListeners();
    } finally {
      _setLoading(false);
    }
  }

  /// Entierra el avatar activo actual
  Future<void> buryActiveAvatar() async {
    if (_user == null || _user!.activeAvatarId == null) return;

    _setLoading(true);
    _clearError();
    try {
      final updatedUser = _user!.buryActiveAvatar();
      await _repository.updateUser(updatedUser);

      _user = updatedUser;
      notifyListeners();
    } catch (e) {
      _errorMessage = "Error al enterrar el avatar: ${e.toString()}";
      notifyListeners();
    } finally {
      _setLoading(false);
    }
  }

  // Métodos auxiliares de estado
  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  void _clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}