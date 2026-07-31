import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../reto_provider.dart';
import '../../../avatar/presentation/avatar_provider.dart';
import '../widgets/reto_card_widget.dart';
import 'reto_flow_screen.dart';

class ListaRetosScreen extends StatefulWidget {
  const ListaRetosScreen({super.key});

  @override
  State<ListaRetosScreen> createState() => _ListaRetosScreenState();
}

class _ListaRetosScreenState extends State<ListaRetosScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<RetoProvider>().listenToRetos();
    });
  }

  @override
  Widget build(BuildContext context) {
    final retoProvider = context.watch<RetoProvider>();
    final avatarProvider = context.watch<AvatarProvider>();

    // Ya no usamos dynamic porque AvatarEntity ya tiene completedRetos explícito
    final currentAvatar = avatarProvider.currentAvatar;
    final completedRetos = currentAvatar?.completedRetos ?? [];
    final currentPoints = currentAvatar?.challengePoints ?? 0;

    return Scaffold(
      backgroundColor: const Color(0xFF121A22), // Fondo oscuro RPG
      appBar: AppBar(
        title: const Text('Retos'),
        backgroundColor: const Color(0xFF1E2A38),
        foregroundColor: Colors.white,
      ),
      body: retoProvider.isLoading
          ? const Center(child: CircularProgressIndicator())
          : retoProvider.error != null
          ? Center(
              child: Text(
                retoProvider.error!,
                style: const TextStyle(color: Colors.red),
              ),
            )
          : retoProvider.retos.isEmpty
          ? const Center(
              child: Text(
                'No hay retos disponibles aún.',
                style: TextStyle(color: Colors.white70),
              ),
            )
          : Column(
              children: [
                const SizedBox(height: 24),
                Center(
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 12,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFF1E2A38),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      '$currentPoints Intentos',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: GridView.builder(
                    padding: const EdgeInsets.only(
                      top: 24.0,
                      bottom: 24.0,
                      left: 32.0,
                      right: 32.0,
                    ),
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 3, // 3 retos por fila
                          crossAxisSpacing: 12.0,
                          mainAxisSpacing: 12.0,
                          childAspectRatio: 1.6, // Rectángulo aún más achatado
                        ),
                    itemCount: retoProvider.retos.length,
                    itemBuilder: (context, index) {
                      final reto = retoProvider.retos[index];
                      final isCompleted = completedRetos.contains(reto.id);

                      // Obtenemos el nivel actual (por defecto 1 si no hay avatar)
                      final currentLevel = currentAvatar?.level ?? 1;
                      final isLocked = currentLevel < reto.nivelRequerido;

                      return RetoCardWidget(
                        reto: reto,
                        isCompleted: isCompleted,
                        isLocked: isLocked,
                        onTap: () {
                          if (isLocked) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  'Nivel insuficiente. Necesitas nivel ${reto.nivelRequerido}.',
                                ),
                                backgroundColor: Colors.orange.shade800,
                              ),
                            );
                            return;
                          }

                          if (!isCompleted && currentPoints <= 0) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: const Text(
                                  'No tienes Puntos de Reto (Challenge Points). ¡Sube de nivel para conseguir más!',
                                ),
                                backgroundColor: Colors.redAccent.shade700,
                              ),
                            );
                            return;
                          }

                          // Navegamos a la pantalla del flujo del reto
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => RetoFlowScreen(
                                reto: reto,
                                isCompleted: isCompleted,
                              ),
                            ),
                          );
                        },
                      );
                    },
                  ),
                ),
              ],
            ),
      // TODO: ELIMINAR ESTE BOTÓN DE DEBUG EN PRODUCCIÓN
      /*floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          if (currentAvatar != null) {
            final debugAvatar = currentAvatar.copyWith(
              challengePoints: currentAvatar.challengePoints + 2,
              completedRetos: [],
            );
            avatarProvider.setUpdatedAvatar(debugAvatar);

            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text(
                  'DEBUG: +2 Pts, Lista de retos completados reseteada.',
                ),
                backgroundColor: Colors.purple,
              ),
            );
          }
        },
        backgroundColor: Colors.purple,
        icon: const Icon(Icons.bug_report, color: Colors.white),
        label: const Text('Debug Retos', style: TextStyle(color: Colors.white)),
      ),*/
    );
  }
}
