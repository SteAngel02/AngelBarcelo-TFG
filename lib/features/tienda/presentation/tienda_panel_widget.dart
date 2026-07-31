import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'tienda_provider.dart';
import '../../avatar/presentation/avatar_provider.dart';
import 'widgets/recompensa_card_widget.dart';

class TiendaPanelWidget extends StatefulWidget {
  final VoidCallback? onClose;

  const TiendaPanelWidget({super.key, this.onClose});

  @override
  State<TiendaPanelWidget> createState() => _TiendaPanelWidgetState();
}

class _TiendaPanelWidgetState extends State<TiendaPanelWidget> {
  bool _showCoins = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final avatarProvider = context.read<AvatarProvider>();
      if (avatarProvider.currentAvatar != null) {
        context.read<TiendaProvider>().loadRecompensas(
          avatarProvider.currentAvatar!.id,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final tiendaProvider = context.watch<TiendaProvider>();
    final recompensasFiltradas = tiendaProvider.recompensas
        .where((r) => r.coinType.name == (_showCoins ? 'coins' : 'gems'))
        .toList();

    return Column(
      children: [
        // Header de la tienda
        GestureDetector(
          onVerticalDragUpdate: (details) {
            if (details.primaryDelta! > 5) {
              widget.onClose?.call();
            }
          },
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Tienda',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                ToggleButtons(
                  constraints: const BoxConstraints(
                    minWidth: 44.0,
                    minHeight: 36.0,
                  ),
                  isSelected: [_showCoins, !_showCoins],
                  onPressed: (index) {
                    setState(() {
                      _showCoins = !_showCoins;
                    });
                  },
                  color: Colors.white54,
                  selectedColor: _showCoins ? Colors.amber : Colors.cyanAccent,
                  fillColor: Colors.transparent,
                  borderColor: Colors.white30,
                  selectedBorderColor: _showCoins
                      ? Colors.amber
                      : Colors.cyanAccent,
                  borderRadius: BorderRadius.circular(20),
                  children: const [
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 12.0),
                      child: Icon(Icons.monetization_on, size: 20),
                    ),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 12.0),
                      child: Icon(Icons.diamond, size: 20),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
        // Lista de la tienda
        Expanded(
          child: tiendaProvider.isLoading
              ? const Center(child: CircularProgressIndicator())
              : recompensasFiltradas.isEmpty
              ? Center(
                  child: Text(
                    _showCoins
                        ? "No hay recompensas de monedas."
                        : "No hay recompensas de gemas.",
                    style: const TextStyle(color: Colors.white70),
                  ),
                )
              : ListView.builder(
                  itemCount: recompensasFiltradas.length,
                  itemBuilder: (itemContext, index) {
                    final recompensa = recompensasFiltradas[index];
                    return RecompensaCardWidget(
                      recompensa: recompensa,
                      onBuy: () async {
                        try {
                          await context.read<TiendaProvider>().buyRecompensa(
                            recompensa,
                            context.read<AvatarProvider>(),
                          );
                          if (context.mounted) {
                            showDialog(
                              context: context,
                              builder: (dialogContext) => AlertDialog(
                                backgroundColor: const Color(0xFF1E2A38),
                                title: const Text(
                                  'Recompensa canjeada',
                                  style: TextStyle(color: Colors.white),
                                ),
                                content: const Text(
                                  '¡Disfrútala!',
                                  style: TextStyle(color: Colors.white70),
                                ),
                                actions: [
                                  TextButton(
                                    onPressed: () =>
                                        Navigator.pop(dialogContext),
                                    child: const Text(
                                      'Cerrar',
                                      style: TextStyle(color: Colors.green),
                                    ),
                                  ),
                                ],
                              ),
                            );
                          }
                        } catch (e) {
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(e.toString()),
                                backgroundColor: Colors.red,
                              ),
                            );
                          }
                        }
                      },
                    );
                  },
                ),
        ),
      ],
    );
  }
}
