import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../domain/mision_entity.dart';
import '../mision_provider.dart';
import '../../../avatar/presentation/avatar_provider.dart';
import '../../../login/presentation/auth_provider.dart';
import 'mision_card_widget.dart';
import 'levelUp_dialog_widget.dart';
import 'crear_mision_rapido_widget.dart';

class ListaPeriodicasWidget extends StatefulWidget {
  final List<PeriodicaEntity> misiones;
  final String avatarId;

  const ListaPeriodicasWidget({
    super.key,
    required this.misiones,
    required this.avatarId,
  });

  @override
  State<ListaPeriodicasWidget> createState() => _ListaPeriodicasWidgetState();
}

class _ListaPeriodicasWidgetState extends State<ListaPeriodicasWidget> {
  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {


    final visibleMisiones = widget.misiones.where((m) => m.visible).toList();
    final nonVisibleMisiones = widget.misiones
        .where((m) => !m.visible)
        .toList();
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
                'Periódicas',
                style: TextStyle(
                  color: Colors.blueAccent,
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
                  border: Border.all(color: Colors.blueAccent, width: 1.5),
                ),
                child: IconButton(
                  padding: EdgeInsets.zero,
                  iconSize: 14,
                  icon: const Icon(Icons.add, color: Colors.blueAccent),
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (context) => const CrearMisionRapidoWidget(tipoMision: 'Periodica'),
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
              "No hay misiones periódicas activas.",
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
        if (nonVisibleMisiones.isNotEmpty) ...[
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: TextButton.icon(
              onPressed: () {
                setState(() {
                  _isExpanded = !_isExpanded;
                });
              },
              icon: Icon(
                _isExpanded ? Icons.expand_less : Icons.expand_more,
                color: Colors.purple,
              ),
              label: Text(
                _isExpanded
                    ? 'Ocultar no visibles'
                    : 'Ver no visibles (${nonVisibleMisiones.length})',
                style: const TextStyle(color: Colors.purple),
              ),
            ),
          ),
          if (_isExpanded)
            ...nonVisibleMisiones.map(
              (mision) => MisionCardWidget(mision: mision, onComplete: () {}),
            ),
        ],
      ],
    );
  }
}
