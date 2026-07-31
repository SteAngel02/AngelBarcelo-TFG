import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../domain/mision_entity.dart';
import '../mision_provider.dart';
import '../../../avatar/presentation/avatar_provider.dart';
import '../../../login/presentation/auth_provider.dart';
import 'mision_card_widget.dart';
import 'crear_mision_rapido_widget.dart';
import 'levelUp_dialog_widget.dart';

class ListaTodoWidget extends StatelessWidget {
  final List<TodoEntity> misiones;
  final String avatarId;

  const ListaTodoWidget({
    super.key,
    required this.misiones,
    required this.avatarId,
  });

  @override
  Widget build(BuildContext context) {
    final visibleMisiones = misiones.where((m) => m.visible).toList();
    final misionProvider = context.read<MisionProvider>();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              const Text(
                'To-Do',
                style: TextStyle(
                  color: Colors.grey,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(width: 8),
              Container(
                width: 20,
                height: 20,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.grey, width: 1.5),
                ),
                child: IconButton(
                  padding: EdgeInsets.zero,
                  iconSize: 14,
                  icon: const Icon(Icons.add, color: Colors.grey),
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (context) => const CrearMisionRapidoWidget(tipoMision: 'Todo'),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
        if (visibleMisiones.isEmpty)
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.0),
            child: Text(
              "No hay misiones To-Do activas.",
              style: TextStyle(color: Colors.white70),
            ),
          )
        else
          ...visibleMisiones.map(
            (mision) => MisionCardWidget(
              mision: mision,
              onComplete: () async {
                final avatarProvider = context.read<AvatarProvider>();
                final authProvider = context.read<AuthProvider>();
                final result = await misionProvider.completeMision(
                  avatarProvider,
                  authProvider,
                  mision,
                );
                if (!context.mounted) return;
                await showLevelUpDialogs(context, result);
              },
            ),
          ),
      ],
    );
  }
}
