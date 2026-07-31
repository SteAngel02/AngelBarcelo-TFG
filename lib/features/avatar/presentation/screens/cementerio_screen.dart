import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../avatar_provider.dart';
import '../../domain/avatar_entity.dart';
import '../widgets/avatar_muerto_widget.dart';

class CementerioScreen extends StatelessWidget {
  const CementerioScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F172A), // Fondo muy oscuro
      appBar: AppBar(
        title: const Text('Cementerio de Avatares', style: TextStyle(color: Colors.white)),
        backgroundColor: const Color(0xFF1E2A38),
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: FutureBuilder<List<AvatarEntity>>(
        future: context.read<AvatarProvider>().fetchDeadAvatars(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator(color: Colors.purpleAccent));
          }

          if (snapshot.hasError) {
            return Center(
              child: Text(
                'Error al cargar el cementerio:\n${snapshot.error}',
                style: const TextStyle(color: Colors.redAccent),
                textAlign: TextAlign.center,
              ),
            );
          }

          final deadAvatars = snapshot.data ?? [];

          if (deadAvatars.isEmpty) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.spa, size: 64, color: Colors.grey),
                  SizedBox(height: 16),
                  Text(
                    'No hay avatares caídos.',
                    style: TextStyle(color: Colors.white70, fontSize: 18),
                  ),
                ],
              ),
            );
          }

          // Ordenamos para que los de mayor nivel salgan primero
          deadAvatars.sort((a, b) => b.level.compareTo(a.level));

          return ListView.builder(
            padding: const EdgeInsets.all(16.0),
            itemCount: deadAvatars.length,
            itemBuilder: (context, index) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 16.0),
                child: AvatarMuertoWidget(avatar: deadAvatars[index]),
              );
            },
          );
        },
      ),
    );
  }
}
