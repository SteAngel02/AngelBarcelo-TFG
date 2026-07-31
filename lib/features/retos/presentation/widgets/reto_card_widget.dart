import 'package:flutter/material.dart';
import '../../domain/reto_entity.dart';

class RetoCardWidget extends StatelessWidget {
  final RetoEntity reto;
  final bool isCompleted;
  final bool isLocked;
  final VoidCallback onTap;

  const RetoCardWidget({
    super.key,
    required this.reto,
    this.isCompleted = false,
    this.isLocked = false,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    // Colores basados en el estilo de mision_card
    final backgroundColor = isLocked 
        ? Colors.grey.shade900.withOpacity(0.5) 
        : (isCompleted ? const Color(0xFF1A3326) : const Color(0xFF1E2A38));

    return Card(
      color: backgroundColor,
      elevation: 2,
      clipBehavior: Clip.hardEdge,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12.0),
        side: BorderSide(
          color: isLocked
              ? Colors.grey.shade800
              : (isCompleted ? Colors.green.shade700 : Colors.transparent),
          width: 1.5,
        ),
      ),
      child: InkWell(
        onTap: onTap,
        child: Stack(
          children: [
            Center(
              child: isLocked
                  ? Icon(
                      Icons.lock,
                      color: Colors.white.withOpacity(0.3),
                      size: 28,
                    )
                  : Text(
                      reto.idUI.toString(),
                      style: TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        color: isCompleted ? Colors.greenAccent : Colors.white,
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
