import 'reto_entity.dart';

abstract class RetoRepository {
  /// Obtiene todos los retos disponibles desde la base de datos (solo lectura)
  Future<List<RetoEntity>> getRetos();

  /// Opcional: Para escuchar cambios en tiempo real si el admin añade nuevos retos
  Stream<List<RetoEntity>> streamRetos();
}
