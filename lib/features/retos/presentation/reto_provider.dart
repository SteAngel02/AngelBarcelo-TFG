import 'dart:async';
import 'package:flutter/foundation.dart';
import '../domain/reto_entity.dart';
import '../domain/reto_repository.dart';
import '../../avatar/presentation/avatar_provider.dart';

class RetoProvider with ChangeNotifier {
  final RetoRepository _repository;
  StreamSubscription? _retosSubscription;

  List<RetoEntity> _retos = [];
  bool _isLoading = false;
  String? _error;

  List<RetoEntity> get retos => _retos;
  bool get isLoading => _isLoading;
  String? get error => _error;

  RetoProvider({required RetoRepository repository}) : _repository = repository;

  /// Inicia la escucha de la colección de retos en tiempo real.
  void listenToRetos() {
    if (_isLoading && _retosSubscription != null) return;
    
    _isLoading = true;
    _error = null;
    notifyListeners();

    _retosSubscription?.cancel();
    _retosSubscription = _repository.streamRetos().listen(
      (retosData) {
        _retos = retosData;
        _isLoading = false;
        notifyListeners();
      },
      onError: (err) {
        _error = err.toString();
        _isLoading = false;
        notifyListeners();
      },
    );
  }

  /// Carga puntual por si se prefiere evitar el stream.
  Future<void> loadRetos() async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      _retos = await _repository.getRetos();
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Orquestador para resolver un reto.
  /// Llama a la lógica pura de negocio en RetoEntity. Si acierta, delega 
  /// la persistencia del estado (reto completado) al AvatarProvider.
  /// Devuelve true si la respuesta era la correcta.
  Future<bool> resolverReto({
    required RetoEntity reto,
    required int selectedIndex,
    required AvatarProvider avatarProvider,
  }) async {
    final isCorrect = reto.checkAnswer(selectedIndex);
    
    if (isCorrect) {
      // Como el Reto es global, el progreso pertenece al Avatar.
      // Asegúrate de implementar 'completeReto' en tu AvatarProvider/AvatarEntity
      // await avatarProvider.completeReto(reto.id);
    }
    
    return isCorrect;
  }

  @override
  void dispose() {
    _retosSubscription?.cancel();
    super.dispose();
  }
}
