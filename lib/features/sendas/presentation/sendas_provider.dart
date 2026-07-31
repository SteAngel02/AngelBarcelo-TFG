import 'dart:async';
import 'package:flutter/material.dart';
import '../domain/sendas_entity.dart';
import '../domain/sendas_repository.dart';
import '../../avatar/presentation/avatar_provider.dart';

/// Gestor de estado para la feature de Sendas.
class SendaProvider extends ChangeNotifier {
  final SendaRepository _repository;
  StreamSubscription? _sendasSubscription;

  List<SendaEntity> _sendas = [];
  bool _isLoading = false;
  String? _errorMessage;

  SendaProvider(this._repository);

  List<SendaEntity> get sendas => _sendas;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  /// Carga las sendas asociadas a un avatar de forma reactiva (Stream).
  void loadSendas(String avatarId) {
    _sendas = [];
    _setLoading(true);
    _clearError();

    _sendasSubscription?.cancel();
    _sendasSubscription = _repository
        .getSendasByAvatar(avatarId)
        .listen(
          (sendasList) {
            _sendas = sendasList;
            _setLoading(false);
          },
          onError: (error) {
            _errorMessage = "Error al cargar sendas: ${error.toString()}";
            _setLoading(false);
          },
        );
  }

  /// Añade una nueva senda o subsenda.
  Future<void> addSenda(String avatarId, SendaEntity senda) async {
    _clearError();
    try {
      await _repository.saveSenda(avatarId, senda);
    } catch (e) {
      _errorMessage = "Error al guardar senda: ${e.toString()}";
      notifyListeners();
    }
  }

  /// Actualiza una senda (por ejemplo, al modificar tareas ToDo internas).
  Future<void> updateSenda(String avatarId, SendaEntity senda) async {
    _clearError();
    try {
      await _repository.updateSenda(avatarId, senda);
    } catch (e) {
      _errorMessage = "Error al actualizar senda: ${e.toString()}";
      notifyListeners();
    }
  }

  /// Elimina recursivamente una senda y sus dependientes.
  Future<void> deleteSenda(String avatarId, String sendaId) async {
    _clearError();
    try {
      await _repository.deleteSenda(avatarId, sendaId);
    } catch (e) {
      _errorMessage = "Error al eliminar senda: ${e.toString()}";
      notifyListeners();
    }
  }

  /// Intenta completar una senda y aplica sus recompensas si es posible.
  Future<void> completeSenda(
    AvatarProvider avatarProvider,
    SendaEntity senda,
  ) async {
    _clearError();
    try {
      if (avatarProvider.currentAvatar == null) return;

      final avatarId = avatarProvider.currentAvatar!.id;
      
      // Intentamos completarla (lanzará StateError si quedan tareas o subsendas pendientes)
      final updatedSenda = senda.complete();

      // Aplicar recompensa de gemas
      if (senda.gemsReward > 0) {
        await avatarProvider.modifyGems(senda.gemsReward);
      }

      // Aplicar recompensa de título si la tiene
      if (senda.tituloReward != null && senda.tituloReward!.isNotEmpty) {
        await avatarProvider.addTitle(senda.tituloReward!);
      }

      // Guardar el nuevo estado de la senda
      await _repository.updateSenda(avatarId, updatedSenda);

    } catch (e) {
      _errorMessage = "Error al completar senda: ${e.toString()}";
      notifyListeners();
    }
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  void _clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  @override
  void dispose() {
    _sendasSubscription?.cancel();
    super.dispose();
  }
}
