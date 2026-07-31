import 'package:flutter/material.dart';
import '../domain/recompensa_entity.dart';
import '../domain/recompensa_repository.dart';

/// Gestor de estado para la Tienda.
/// Sigue el patrón de Presentation Layer comunicando la UI con Data (a través de Domain).
class TiendaProvider extends ChangeNotifier {
  final RecompensaRepository _repository;

  List<RecompensaEntity> _recompensas = [];
  bool _isLoading = false;
  String? _errorMessage;

  TiendaProvider(this._repository);

  // Getters para la UI
  List<RecompensaEntity> get recompensas => _recompensas;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  /// Carga todas las recompensas desde la base de datos para un avatar
  Future<void> loadRecompensas(String avatarId) async {
    _setLoading(true);
    _clearError();
    try {
      _recompensas = await _repository.getRecompensasByAvatar(avatarId);
    } catch (e) {
      _errorMessage = "Error al cargar las recompensas: ${e.toString()}";
    } finally {
      _setLoading(false);
    }
  }

  /// Añade una nueva recompensa a la tienda de un avatar
  Future<void> addRecompensa(String avatarId, RecompensaEntity recompensa) async {
    _clearError();
    try {
      await _repository.saveRecompensa(avatarId, recompensa);
      await loadRecompensas(avatarId); // Recargamos para actualizar la UI
    } catch (e) {
      _errorMessage = "Error al crear la recompensa: ${e.toString()}";
      notifyListeners();
    }
  }

  /// Actualiza una recompensa existente
  Future<void> updateRecompensa(String avatarId, RecompensaEntity recompensa) async {
    _clearError();
    try {
      await _repository.updateRecompensa(avatarId, recompensa);
      await loadRecompensas(avatarId); // Recargamos para actualizar la UI
    } catch (e) {
      _errorMessage = "Error al actualizar la recompensa: ${e.toString()}";
      notifyListeners();
    }
  }

  /// Elimina una recompensa
  Future<void> deleteRecompensa(String avatarId, String id) async {
    _clearError();
    try {
      await _repository.deleteRecompensa(avatarId, id);
      await loadRecompensas(avatarId);
    } catch (e) {
      _errorMessage = "Error al eliminar la recompensa: ${e.toString()}";
      notifyListeners();
    }
  }

  /// Realiza la compra de una recompensa por parte de un avatar
  Future<void> buyRecompensa(RecompensaEntity recompensa, dynamic avatarProvider) async {
    _clearError();
    try {
      if (avatarProvider.currentAvatar == null) throw Exception("No hay avatar activo");
      
      final avatarId = avatarProvider.currentAvatar!.id;
      
      // Aplicar lógica de dominio rica
      final result = recompensa.buy(avatarProvider.currentAvatar!);
      
      // Persistir avatar actualizado
      await avatarProvider.setUpdatedAvatar(result.avatar);
      
      // Persistir recompensa o eliminarla si el stock llegó a 0 y that's how we handle it
      // Según nuestro modelo, recompensa actualiza stock, y si shouldDelete es true podemos borrarla
      if (result.recompensa.shouldDelete) {
        await _repository.deleteRecompensa(avatarId, result.recompensa.id);
      } else {
        await _repository.updateRecompensa(avatarId, result.recompensa);
      }
      
      await loadRecompensas(avatarId);
    } catch (e) {
      _errorMessage = e.toString().replaceAll('Exception: ', '');
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
