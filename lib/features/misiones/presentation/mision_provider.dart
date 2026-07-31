import 'dart:async';
import 'package:flutter/material.dart';
import '../domain/mision_entity.dart';
import '../domain/mision_repository.dart';
import '../../avatar/presentation/avatar_provider.dart';
import '../../login/presentation/auth_provider.dart';
import '../../../core/notification_service.dart';

class LevelUpResult {
  final String? leveledUpStat;
  final bool avatarLeveledUp;

  LevelUpResult({this.leveledUpStat, this.avatarLeveledUp = false});
}

class MisionProvider extends ChangeNotifier {
  final MisionRepository _repository;
  StreamSubscription? _misionesSubscription;

  List<MisionEntity> _misiones = [];
  bool _isLoading = false;
  String? _errorMessage;
  int _pendingMissedHearts = 0;
  DateTime? _lastEvaluationDate;
  final Set<String> _evaluatedMissedIds = {};

  MisionProvider(this._repository);

  List<MisionEntity> get misiones => _misiones;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  int get pendingMissedHearts => _pendingMissedHearts;

  int consumePendingMissedHearts() {
    final count = _pendingMissedHearts;
    _pendingMissedHearts = 0;
    return count;
  }

  void loadMisiones(String avatarId) {
    _misiones = [];
    _setLoading(true);
    _clearError();

    _misionesSubscription?.cancel();
    _misionesSubscription = _repository
        .getMisionesByAvatar(avatarId)
        .listen(
          (misionesList) {
            final now = DateTime.now();
            final currentDateOnly = DateTime(now.year, now.month, now.day);
            if (_lastEvaluationDate == null ||
                currentDateOnly.isAfter(_lastEvaluationDate!)) {
              _lastEvaluationDate = currentDateOnly;
              _evaluatedMissedIds.clear();
            }

            final evaluatedList = <MisionEntity>[];
            int missedCount = 0;

            for (var mision in misionesList) {
              if (mision.isMissed(now) &&
                  !_evaluatedMissedIds.contains(mision.id)) {
                _evaluatedMissedIds.add(mision.id);
                missedCount++;
              }
              final evaluated = mision.evaluateLazyReset(now);
              if (evaluated.isCompleted != mision.isCompleted ||
                  evaluated.visible != mision.visible ||
                  evaluated.lastCompletedAt != mision.lastCompletedAt) {
                // Sincronización Lazy diferida en base de datos
                _repository.updateMision(avatarId, evaluated);
              }
              evaluatedList.add(evaluated);
            }

            if (missedCount > 0) {
              _pendingMissedHearts += missedCount;
            }

            _misiones = evaluatedList;
            _setLoading(false);

            final pendingCount =
                _misiones.where((m) => m.visible && !m.isCompleted).length;
            NotificationService().scheduleDailyNotifications(pendingCount);
          },
          onError: (error) {
            _errorMessage = "Error al cargar misiones: ${error.toString()}";
            _setLoading(false);
          },
        );
  }

  Future<void> addMision(String avatarId, MisionEntity mision) async {
    _clearError();
    try {
      await _repository.saveMision(avatarId, mision);
    } catch (e) {
      _errorMessage = "Error al guardar misión: ${e.toString()}";
      notifyListeners();
    }
  }

  Future<LevelUpResult> completeMision(
    AvatarProvider avatarProvider,
    AuthProvider authProvider,
    MisionEntity mision,
  ) async {
    _clearError();
    try {
      if (avatarProvider.currentAvatar == null) return LevelUpResult();

      final avatarId = avatarProvider.currentAvatar!.id;
      final updatedMision = mision.complete();

      // Guardamos el nivel del atributo actual antes de aplicar recompensas
      int oldLevel = 0;
      if (mision is! CastigoEntity) {
        final currentStat = avatarProvider.currentAvatar!.atributos
            .where(
              (a) => a.name.toLowerCase() == mision.stat.name.toLowerCase(),
            )
            .firstOrNull;
        if (currentStat != null) {
          oldLevel = currentStat.level;
        }
      }

      int oldAvatarLevel = avatarProvider.currentAvatar!.level;

      // 1. Actualizamos o borramos primero la misión en base de datos
      if (mision.shouldDeleteOnComplete) {
        await _repository.deleteMision(avatarId, mision.id);
      } else {
        // En los demás casos, actualizamos su estado (ej: pasar visible a false)
        await _repository.updateMision(avatarId, updatedMision);
      }

      // 2. Aplicamos las recompensas al avatar y disparamos efectos
      await avatarProvider.applyMisionRewards(mision);

      // Comprobamos si subió de nivel
      String? leveledUpStat;
      if (mision is! CastigoEntity) {
        final newStat = avatarProvider.currentAvatar!.atributos
            .where(
              (a) => a.name.toLowerCase() == mision.stat.name.toLowerCase(),
            )
            .firstOrNull;
        if (newStat != null) {
          if (newStat.level > oldLevel && oldLevel > 0) {
            leveledUpStat = newStat.name.toUpperCase();
          } else if (oldLevel == 0 && newStat.level > 1) {
            leveledUpStat = newStat.name.toUpperCase();
          }
        }
      }

      bool avatarLeveledUp =
          avatarProvider.currentAvatar!.level > oldAvatarLevel;

      // Check for death
      if (!avatarProvider.currentAvatar!.isAlive) {
        await authProvider.buryActiveAvatar();
      }

      return LevelUpResult(
        leveledUpStat: leveledUpStat,
        avatarLeveledUp: avatarLeveledUp,
      );
    } catch (e) {
      _errorMessage = "Error al completar misión: ${e.toString()}";
      notifyListeners();
      return LevelUpResult();
    }
  }

  Future<void> deleteMision(String avatarId, String misionId) async {
    _clearError();
    try {
      await _repository.deleteMision(avatarId, misionId);
    } catch (e) {
      _errorMessage = "Error al eliminar misión: ${e.toString()}";
      notifyListeners();
    }
  }

  Future<void> updateMision(String avatarId, MisionEntity mision) async {
    _clearError();
    try {
      await _repository.updateMision(avatarId, mision);
    } catch (e) {
      _errorMessage = "Error al actualizar misión: ${e.toString()}";
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
    _misionesSubscription?.cancel();
    super.dispose();
  }
}
