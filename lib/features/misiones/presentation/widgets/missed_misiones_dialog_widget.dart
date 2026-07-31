import 'package:flutter/material.dart';

/// Diálogo que alerta al usuario cuando no completó sus misiones del día anterior
Future<void> showMissedMisionesDialog(
    BuildContext context, int heartsLost) async {
  if (heartsLost <= 0 || !context.mounted) return;

  await showDialog(
    context: context,
    builder: (context) => AlertDialog(
      backgroundColor: const Color(0xFF1E2A38),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: Colors.redAccent.withValues(alpha: 0.6),
          width: 1.5,
        ),
      ),
      title: const Text(
        'Ayer no completaste todas tus misiones',
        style: TextStyle(
          color: Colors.redAccent,
          fontWeight: FontWeight.bold,
          fontSize: 18,
        ),
        textAlign: TextAlign.center,
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                '-$heartsLost ',
                style: const TextStyle(
                  color: Colors.redAccent,
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Icon(
                Icons.favorite,
                color: Colors.redAccent,
                size: 32,
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            'Has perdido $heartsLost ${heartsLost == 1 ? "corazón" : "corazones"} por no haber completado tus misiones asignadas.',
            style: const TextStyle(color: Colors.white70, fontSize: 14),
            textAlign: TextAlign.center,
          ),
        ],
      ),
      actions: [
        Center(
          child: TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              'Entendido',
              style: TextStyle(
                color: Colors.amber,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
          ),
        ),
      ],
    ),
  );
}
