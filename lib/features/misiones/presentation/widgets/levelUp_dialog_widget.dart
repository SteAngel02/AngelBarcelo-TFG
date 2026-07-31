import 'package:flutter/material.dart';
import '../mision_provider.dart';

Future<void> showLevelUpDialogs(BuildContext context, LevelUpResult result) async {
  if (result.leveledUpStat != null && context.mounted) {
    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1E2A38),
        title: const Text('¡Nivel Arriba!', style: TextStyle(color: Colors.amber, fontWeight: FontWeight.bold)),
        content: Text('¡Tu atributo ${result.leveledUpStat} ha subido de nivel!', style: const TextStyle(color: Colors.white)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('¡Genial!', style: TextStyle(color: Colors.green)),
          ),
        ],
      ),
    );
  }
  
  if (result.avatarLeveledUp && context.mounted) {
    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1E2A38),
        title: const Text('¡Nivel de Avatar!', style: TextStyle(color: Colors.amber, fontWeight: FontWeight.bold)),
        content: const Text('¡Tu avatar ha subido de nivel por completar misiones!', style: TextStyle(color: Colors.white)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('¡Increíble!', style: TextStyle(color: Colors.green)),
          ),
        ],
      ),
    );
  }
}
