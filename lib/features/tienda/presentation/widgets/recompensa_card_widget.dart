import 'package:flutter/material.dart';
import '../../domain/recompensa_entity.dart';
import '../screens/edit_recompensa_screen.dart';

class RecompensaCardWidget extends StatefulWidget {
  final RecompensaEntity recompensa;
  final VoidCallback onBuy;

  const RecompensaCardWidget({
    super.key,
    required this.recompensa,
    required this.onBuy,
  });

  @override
  State<RecompensaCardWidget> createState() => _RecompensaCardWidgetState();
}

class _RecompensaCardWidgetState extends State<RecompensaCardWidget> {
  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    // Definimos el color e icono dependiendo de la moneda
    final bool isGem = widget.recompensa.coinType == CoinType.gems;
    final Color coinColor = isGem ? Colors.cyanAccent : Colors.amber;
    final IconData coinIcon = isGem ? Icons.diamond : Icons.monetization_on;
    
    // Verificamos stock
    final bool hasStock = widget.recompensa.stock != 0;
    final bool isUnlimited = widget.recompensa.stock < 0;

    return Card(
      color: const Color(0xFF121A22),
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      clipBehavior: Clip.hardEdge,
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => EditRecompensaScreen(recompensa: widget.recompensa),
            ),
          );
        },
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Textos
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.recompensa.nombre,
                      style: TextStyle(
                        color: hasStock ? Colors.white : Colors.grey,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        decoration: hasStock ? null : TextDecoration.lineThrough,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        Icon(coinIcon, size: 16, color: coinColor),
                        const SizedBox(width: 4),
                        Text(
                          '${widget.recompensa.price}',
                          style: TextStyle(
                            color: coinColor,
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        if (!isUnlimited) ...[
                          const SizedBox(width: 12),
                          const Icon(Icons.inventory_2, size: 14, color: Colors.white54),
                          const SizedBox(width: 4),
                          Text(
                            'Stock: ${widget.recompensa.stock}',
                            style: const TextStyle(
                              color: Colors.white54,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ],
                    ),
                    if (widget.recompensa.descripcion.isNotEmpty) ...[
                      const SizedBox(height: 6),
                      if (_isExpanded)
                        Text(
                          widget.recompensa.descripcion,
                          style: const TextStyle(
                            color: Colors.white70,
                            fontSize: 14,
                          ),
                        )
                      else
                        GestureDetector(
                          onTap: () {
                            setState(() {
                              _isExpanded = true;
                            });
                          },
                          child: const Text(
                            '...más',
                            style: TextStyle(
                              color: Colors.white38,
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                    ],
                  ],
                ),
              ),
              const SizedBox(width: 12),
              // Botón de Comprar a la derecha
              ElevatedButton(
                onPressed: hasStock ? widget.onBuy : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: coinColor,
                  foregroundColor: Colors.black, // Contraste oscuro para el texto
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                ),
                child: const Text(
                  'Comprar',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
