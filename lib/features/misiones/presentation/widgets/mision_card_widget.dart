import 'package:flutter/material.dart';
import '../../domain/mision_entity.dart';
import '../screens/edit_mision_screen.dart';

class MisionCardWidget extends StatefulWidget {
  final MisionEntity mision;
  final VoidCallback onComplete;

  const MisionCardWidget({
    super.key,
    required this.mision,
    required this.onComplete,
  });

  @override
  State<MisionCardWidget> createState() => _MisionCardWidgetState();
}

class _MisionCardWidgetState extends State<MisionCardWidget> {
  bool _isExpanded = false;

  String _getStatAbbreviation(StatType stat) {
    switch (stat) {
      case StatType.fuerza:
        return 'FUE';
      case StatType.inteligencia:
        return 'INT';
      case StatType.constitucion:
        return 'CON';
      case StatType.destreza:
        return 'DES';
      case StatType.sabiduria:
        return 'SAB';
    }
  }

  IconData _getStatIcon(StatType stat) {
    switch (stat) {
      case StatType.fuerza:
        return Icons.fitness_center;
      case StatType.inteligencia:
        return Icons.menu_book;
      case StatType.constitucion:
        return Icons.favorite;
      case StatType.destreza:
        return Icons.directions_run;
      case StatType.sabiduria:
        return Icons.psychology;
    }
  }

  Color _getMisionColor() {
    if (widget.mision is DiariaEntity) return Colors.green;
    if (widget.mision is CastigoEntity) return Colors.red;
    if (widget.mision is PeriodicaEntity) return Colors.purple;
    return Colors.grey; // TodoEntity o por defecto
  }

  String _getMisionTypeInitials() {
    if (widget.mision is DiariaEntity) return 'D';
    if (widget.mision is CastigoEntity) return 'C';
    if (widget.mision is PeriodicaEntity) return 'P';
    return 'T'; // TodoEntity
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      color: const Color(0xFF1E2A38),
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      clipBehavior: Clip.hardEdge,
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => EditMisionScreen(mision: widget.mision),
            ),
          );
        },
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Círculo con el tipo de misión y color
              CircleAvatar(
                backgroundColor: _getMisionColor().withOpacity(0.2),
                child: Text(
                  _getMisionTypeInitials(),
                  style: TextStyle(
                    color: _getMisionColor(),
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(width: 16),
              
              // Textos (Nombre de la misión y stat)
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.mision.name,
                      style: TextStyle(
                        color: widget.mision.isCompleted ? Colors.grey : Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        decoration: widget.mision.isCompleted
                            ? TextDecoration.lineThrough
                            : null,
                      ),
                    ),
                    if (widget.mision is! CastigoEntity) ...[
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Icon(_getStatIcon(widget.mision.stat), size: 14, color: Colors.amber),
                          const SizedBox(width: 4),
                          Text(
                            _getStatAbbreviation(widget.mision.stat),
                            style: const TextStyle(
                              color: Colors.amber,
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(width: 12),
                          const Icon(Icons.monetization_on, size: 14, color: Colors.yellow),
                          const SizedBox(width: 4),
                          Text(
                            '+${widget.mision.coinReward}',
                            style: const TextStyle(
                              color: Colors.yellow,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ],
                    if (widget.mision is PeriodicaEntity) ...[
                      const SizedBox(height: 4),
                      Wrap(
                        spacing: 12,
                        runSpacing: 4,
                        children: [
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.update, size: 14, color: Colors.purpleAccent.withOpacity(0.8)),
                              const SizedBox(width: 4),
                              Text(
                                () {
                                  final daysLeft = (widget.mision as PeriodicaEntity).remainingDays();
                                  if (daysLeft <= 0) return 'Hoy';
                                  return daysLeft == 1 ? 'Vuelve en 1 día' : 'Vuelve en $daysLeft días';
                                }(),
                                style: TextStyle(
                                  color: Colors.purpleAccent.withValues(alpha: 0.8),
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                          if (!(widget.mision as PeriodicaEntity).isForever)
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(Icons.flag, size: 14, color: Colors.purpleAccent.withOpacity(0.8)),
                                const SizedBox(width: 4),
                                Text(
                                  'Faltan ${(widget.mision as PeriodicaEntity).goal} veces',
                                  style: TextStyle(
                                    color: Colors.purpleAccent.withOpacity(0.8),
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                        ],
                      ),
                    ],
                    if (widget.mision.description.isNotEmpty) ...[
                      const SizedBox(height: 4),
                      if (_isExpanded)
                        Text(
                          widget.mision.description,
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
              
              // Botón de completar a la derecha
              ElevatedButton(
                onPressed: widget.mision.isCompleted ? null : widget.onComplete,
                style: ElevatedButton.styleFrom(
                  backgroundColor: _getMisionColor(),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                ),
                child: const Icon(Icons.check, size: 20),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
