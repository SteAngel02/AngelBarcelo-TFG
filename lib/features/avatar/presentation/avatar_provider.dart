import 'dart:async';
import 'package:flutter/material.dart';
import '../domain/avatar_repository.dart';
import '../domain/avatar_entity.dart';
import '../../misiones/domain/mision_entity.dart';

enum BorderEffectType { damage, reward }

/// Gestor de estado para el Avatar.
/// Sigue el patrón de Presentation Layer comunicando la UI con Data (a través de Domain).
class AvatarProvider extends ChangeNotifier {
  final AvatarRepository _repository;

  AvatarEntity? _currentAvatar;
  bool _isLoading = false;
  String? _errorMessage;

  final StreamController<BorderEffectType> _borderEffectController =
      StreamController<BorderEffectType>.broadcast();

  Stream<BorderEffectType> get onBorderEffect => _borderEffectController.stream;
  Stream<void> get onDamageTaken =>
      _borderEffectController.stream.where((e) => e == BorderEffectType.damage);
  Stream<void> get onRewardEarned =>
      _borderEffectController.stream.where((e) => e == BorderEffectType.reward);

  void triggerDamageEffect() {
    if (!_borderEffectController.isClosed) {
      _borderEffectController.add(BorderEffectType.damage);
    }
  }

  void triggerRewardEffect() {
    if (!_borderEffectController.isClosed) {
      _borderEffectController.add(BorderEffectType.reward);
    }
  }

  @override
  void dispose() {
    _borderEffectController.close();
    super.dispose();
  }

  /// Constructor con Inyección de Dependencias del repositorio.
  AvatarProvider(this._repository);

  // Getters para la UI
  AvatarEntity? get currentAvatar => _currentAvatar;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get hasAvatar => _currentAvatar != null;

  /// Carga el avatar activo desde la base de datos
  Future<void> loadAvatar(String avatarId) async {
    _setLoading(true);
    _clearError();
    try {
      _currentAvatar = await _repository.getAvatarById(avatarId);
    } catch (e) {
      _errorMessage = "Error al cargar el avatar: ${e.toString()}";
    } finally {
      _setLoading(false);
    }
  }

  /// Crea un avatar nuevo y lo guarda en base de datos
  Future<void> createAvatar(String userId, AvatarEntity newAvatar) async {
    _setLoading(true);
    _clearError();
    try {
      await _repository.saveAvatar(userId, newAvatar);
      _currentAvatar = newAvatar;
    } catch (e) {
      _errorMessage = "Error al crear el avatar: ${e.toString()}";
    } finally {
      _setLoading(false);
    }
  }

  /// Obtiene la lista de avatares muertos (Cementerio) sin afectar al estado actual
  Future<List<AvatarEntity>> fetchDeadAvatars() async {
    try {
      return await _repository.getDeadAvatars();
    } catch (e) {
      _errorMessage = "Error al cargar el cementerio: ${e.toString()}";
      notifyListeners();
      return [];
    }
  }

  /// Sube de nivel el avatar
  Future<void> levelUp() async {
    if (_currentAvatar == null) return;
    
    // 1. Modificamos el estado usando la regla de negocio (clon inmutable)
    _currentAvatar = _currentAvatar!.levelUp();
    notifyListeners(); // La UI reacciona inmediatamente (optimistic update)

    // 2. Persistencia
    try {
      await _repository.updateAvatar(_currentAvatar!);
    } catch (e) {
      _errorMessage = "Error al subir de nivel: ${e.toString()}";
      notifyListeners();
    }
  }

  /// Establece un nuevo título principal
  Future<void> setActiveTitle(String title) async {
    if (_currentAvatar == null) return;
    
    _currentAvatar = _currentAvatar!.setActiveTitle(title);
    notifyListeners();

    try {
      await _repository.updateAvatar(_currentAvatar!);
    } catch (e) {
      _errorMessage = "Error al actualizar el título: ${e.toString()}";
      notifyListeners();
    }
  }

  /// Añade un título al inventario de títulos adquiridos
  Future<void> addTitle(String title) async {
    if (_currentAvatar == null) return;
    
    _currentAvatar = _currentAvatar!.addTitle(title);
    notifyListeners();

    try {
      await _repository.updateAvatar(_currentAvatar!);
    } catch (e) {
      _errorMessage = "Error al guardar el título: ${e.toString()}";
      notifyListeners();
    }
  }

  /// Completa un reto y guarda la lista actualizada
  Future<void> completeReto(String retoId) async {
    if (_currentAvatar == null) return;
    
    _currentAvatar = _currentAvatar!.completeReto(retoId);
    notifyListeners();

    try {
      await _repository.updateAvatar(_currentAvatar!);
    } catch (e) {
      _errorMessage = "Error al completar el reto: ${e.toString()}";
      notifyListeners();
    }
  }

  /// Consume un punto de reto para aceptar uno
  Future<bool> acceptReto() async {
    if (_currentAvatar == null) return false;
    
    if (_currentAvatar!.challengePoints > 0) {
      _currentAvatar = _currentAvatar!.acceptReto();
      notifyListeners();

      try {
        await _repository.updateAvatar(_currentAvatar!);
        return true;
      } catch (e) {
        _errorMessage = "Error al aceptar el reto: ${e.toString()}";
        notifyListeners();
        return false;
      }
    }
    return false;
  }

  /// Mata al avatar
  Future<void> die() async {
    if (_currentAvatar == null) return;

    _currentAvatar = _currentAvatar!.die();
    notifyListeners();

    try {
      await _repository.updateAvatar(_currentAvatar!);
    } catch (e) {
      _errorMessage = "Error al actualizar estado (muerte): ${e.toString()}";
      notifyListeners();
    }
  }

  /// Modifica las monedas
  Future<void> modifyCoins(int amount) async {
    if (_currentAvatar == null) return;

    _currentAvatar = _currentAvatar!.modifyCoins(amount);
    notifyListeners();

    try {
      await _repository.updateAvatar(_currentAvatar!);
    } catch (e) {
      _errorMessage = "Error al modificar monedas: ${e.toString()}";
      notifyListeners();
    }
  }

  /// Modifica la vida
  Future<void> modifyHealth(int amount) async {
    if (_currentAvatar == null) return;

    final oldHealth = _currentAvatar!.health;
    _currentAvatar = _currentAvatar!.modifyHealth(amount);
    notifyListeners();

    try {
      await _repository.updateAvatar(_currentAvatar!);
    } catch (e) {
      _errorMessage = "Error al modificar vida: ${e.toString()}";
      notifyListeners();
    }

    if (_currentAvatar!.health < oldHealth || amount < 0) {
      triggerDamageEffect();
    }
  }

  /// Añade experiencia a un atributo
  Future<void> addExpToAttribute(String statName, double expAmount) async {
    if (_currentAvatar == null) return;

    _currentAvatar = _currentAvatar!.addExpToAttribute(statName, expAmount);
    notifyListeners();

    try {
      await _repository.updateAvatar(_currentAvatar!);
    } catch (e) {
      _errorMessage = "Error al añadir experiencia al atributo: ${e.toString()}";
      notifyListeners();
    }
  }

  /// Modifica las gemas
  Future<void> modifyGems(int amount) async {
    if (_currentAvatar == null) return;

    _currentAvatar = _currentAvatar!.modifyGems(amount);
    notifyListeners();

    try {
      await _repository.updateAvatar(_currentAvatar!);
    } catch (e) {
      _errorMessage = "Error al modificar gemas: ${e.toString()}";
      notifyListeners();
    }
  }

  /// Aplica las recompensas de una misión completada delegando en la entidad
  Future<void> applyMisionRewards(MisionEntity mision) async {
    if (_currentAvatar == null) return;

    final oldHealth = _currentAvatar!.health;
    _currentAvatar = _currentAvatar!.applyMisionRewards(mision);
    notifyListeners();

    try {
      await _repository.updateAvatar(_currentAvatar!);
    } catch (e) {
      _errorMessage = "Error al aplicar recompensas de misión: ${e.toString()}";
      notifyListeners();
    }

    if (_currentAvatar!.health < oldHealth || mision is CastigoEntity) {
      triggerDamageEffect();
    } else {
      triggerRewardEffect();
    }
  }

  /// Aplica las recompensas de un reto completado (atributo y exp global)
  Future<void> claimRetoReward(String statName) async {
    if (_currentAvatar == null) return;

    _currentAvatar = _currentAvatar!.applyRetoReward(statName);
    triggerRewardEffect();
    notifyListeners();

    try {
      await _repository.updateAvatar(_currentAvatar!);
    } catch (e) {
      _errorMessage = "Error al reclamar recompensa de reto: ${e.toString()}";
      notifyListeners();
    }
  }

  /// Actualiza la imagen del avatar
  Future<void> updateAvatarImage(String newImagePath) async {
    if (_currentAvatar == null) return;

    _currentAvatar = _currentAvatar!.copyWith(image: newImagePath);
    notifyListeners();

    try {
      await _repository.updateAvatar(_currentAvatar!);
    } catch (e) {
      _errorMessage = "Error al actualizar la imagen: ${e.toString()}";
      notifyListeners();
    }
  }

  /// Permite sobrescribir el avatar completamente (útil para lógica cruzada como en TiendaProvider)
  Future<void> setUpdatedAvatar(AvatarEntity updatedAvatar) async {
    _currentAvatar = updatedAvatar;
    notifyListeners();

    try {
      await _repository.updateAvatar(_currentAvatar!);
    } catch (e) {
      _errorMessage = "Error al sincronizar avatar: ${e.toString()}";
      notifyListeners();
      rethrow;
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
