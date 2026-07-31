import '../../avatar/domain/avatar_entity.dart';

/// Enum que representa la moneda con la que se compra una recompensa
enum CoinType {
  coins,
  gems,
}

/// Entidad que representa una recompensa en la tienda
class RecompensaEntity {
  final String id;
  final String nombre;
  final String descripcion;
  final CoinType coinType;
  final int price;
  final int stock;

  RecompensaEntity({
    required this.id,
    required this.nombre,
    required this.descripcion,
    required this.coinType,
    required this.price,
    this.stock = 1,
  });

  /// Ejecuta la lógica de negocio de canjear/comprar una recompensa.
  /// Valida el stock y los fondos del avatar.
  /// Retorna un objeto con las copias inmutables actualizadas de ambas entidades.
  BuyResult buy(AvatarEntity avatar) {
    if (stock == 0) {
      throw Exception('No hay stock disponible para esta recompensa.');
    }

    AvatarEntity updatedAvatar;
    if (coinType == CoinType.coins) {
      if (avatar.coins < price) {
        throw Exception('Monedas insuficientes.');
      }
      updatedAvatar = avatar.modifyCoins(-price);
    } else {
      if (avatar.gems < price) {
        throw Exception('Gemas insuficientes.');
      }
      updatedAvatar = avatar.modifyGems(-price);
    }

    // Descontar el stock (si es ilimitado -1, se mantiene en -1)
    final newStock = stock < 0 ? stock : stock - 1;
    final updatedRecompensa = copyWith(stock: newStock);

    return BuyResult(
      avatar: updatedAvatar, 
      recompensa: updatedRecompensa,
    );
  }

  /// Método de conveniencia para marcar intenciones de borrado
  /// (sólo se borra si el stock llega exactamente a 0, -1 significa ilimitado)
  bool get shouldDelete => stock == 0;

  RecompensaEntity copyWith({
    String? id,
    String? nombre,
    String? descripcion,
    CoinType? coinType,
    int? price,
    int? stock,
  }) {
    return RecompensaEntity(
      id: id ?? this.id,
      nombre: nombre ?? this.nombre,
      descripcion: descripcion ?? this.descripcion,
      coinType: coinType ?? this.coinType,
      price: price ?? this.price,
      stock: stock ?? this.stock,
    );
  }
}

/// Objeto de resultado que agrupa las entidades actualizadas tras la compra
class BuyResult {
  final AvatarEntity avatar;
  final RecompensaEntity recompensa;

  BuyResult({required this.avatar, required this.recompensa});
}
