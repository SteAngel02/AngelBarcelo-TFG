import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../domain/sendas_entity.dart';
import '../sendas_provider.dart';
import '../../../login/presentation/auth_provider.dart';
import '../widgets/senda_task_card_widget.dart';
import '../widgets/senda_card_widget.dart';
import 'create_senda_screen.dart';
import '../../../avatar/presentation/avatar_provider.dart';


class SendaDetailScreen extends StatefulWidget {
  final String sendaId;

  const SendaDetailScreen({super.key, required this.sendaId});

  @override
  State<SendaDetailScreen> createState() => _SendaDetailScreenState();
}

class _SendaDetailScreenState extends State<SendaDetailScreen> {
  final _taskTitleController = TextEditingController();
  final _taskDescController = TextEditingController();
  final _descFocusNode = FocusNode();
  bool _showDescriptionField = false;
  bool _isExpanded = false;

  @override
  void dispose() {
    _taskTitleController.dispose();
    _taskDescController.dispose();
    _descFocusNode.dispose();
    super.dispose();
  }

  void _createTask(SendaEntity senda, String avatarId) {
    final title = _taskTitleController.text.trim();
    if (title.isEmpty) return;

    final desc = _taskDescController.text.trim();

    final newTask = SendaTaskEntity(
      id: DateTime.now().millisecondsSinceEpoch.toString(), // ID simple generado en cliente
      title: title,
      description: desc,
      isCompleted: false,
    );

    // Añadimos la tarea a la lista inmutable y actualizamos la senda
    final updatedTasks = List<SendaTaskEntity>.from(senda.tasks)..add(newTask);
    final updatedSenda = senda.copyWith(tasks: updatedTasks);

    context.read<SendaProvider>().updateSenda(avatarId, updatedSenda);

    // Reseteamos el input
    _taskTitleController.clear();
    _taskDescController.clear();
    setState(() {
      _showDescriptionField = false;
    });

    // Cerramos el teclado
    FocusScope.of(context).unfocus();
  }

  /// Busca de forma recursiva una senda o subsenda por su ID
  SendaEntity? _findSendaRecursively(List<SendaEntity> sendas, String id) {
    for (var s in sendas) {
      if (s.id == id) return s;
      final found = _findSendaRecursively(s.subSendas, id);
      if (found != null) return found;
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final sendaProvider = context.watch<SendaProvider>();
    final user = context.watch<AuthProvider>().user;

    // Localizar la senda actualizada en todo el árbol de sendas
    final senda = _findSendaRecursively(sendaProvider.sendas, widget.sendaId);

    if (senda == null) {
      return Scaffold(
        backgroundColor: const Color(0xFF121A22),
        appBar: AppBar(
          title: const Text('Senda no encontrada'),
          backgroundColor: const Color(0xFF1E2A38),
          foregroundColor: Colors.white,
        ),
        body: const Center(
          child: Text('La senda ya no existe.', style: TextStyle(color: Colors.white)),
        ),
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xFF121A22),
      appBar: AppBar(
        title: Text(senda.name),
        backgroundColor: const Color(0xFF1E2A38),
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          // Área principal (Lista de subsendas y tareas)
          Expanded(
            child: Stack(
              children: [
                SingleChildScrollView(
                  padding: const EdgeInsets.only(bottom: 24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                  // Portada
                  if (senda.imageUrl != null && senda.imageUrl!.isNotEmpty)
                    Image.network(
                      senda.imageUrl!,
                      height: 180,
                      width: double.infinity,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) => const SizedBox(),
                    ),
                  
                  // Descripción
                  if (senda.description.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Text(
                        senda.description,
                        style: const TextStyle(color: Colors.white70, fontSize: 16),
                      ),
                    ),

                  // Si hay subsendas, listarlas arriba
                  if (senda.subSendas.isNotEmpty) ...[
                    const Padding(
                      padding: EdgeInsets.all(16.0),
                      child: Text(
                        'Subsendas', 
                        style: TextStyle(color: Colors.cyanAccent, fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                    ),
                    for (var sub in senda.subSendas)
                      SendaCardWidget(senda: sub),
                  ],

                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                    child: Text(
                      'Tareas', 
                      style: TextStyle(color: Colors.amber, fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                  ),
                  
                  if (senda.tasks.isEmpty)
                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 16.0),
                      child: Text(
                        'No hay tareas. ¡Añade una abajo!', 
                        style: TextStyle(color: Colors.white54),
                      ),
                    ),

                  // Listado de tareas pendientes
                  for (var task in senda.tasks.where((t) => !t.isCompleted))
                    SendaTaskCardWidget(
                      senda: senda,
                      task: task,
                      onComplete: () {
                        final updatedTasks = senda.tasks.map((t) {
                          if (t.id == task.id) return t.copyWith(isCompleted: true);
                          return t;
                        }).toList();
                        context.read<SendaProvider>().updateSenda(
                          user!.activeAvatarId!, 
                          senda.copyWith(tasks: updatedTasks),
                        );
                      },
                    ),

                  // Listado de tareas completadas (acordeón)
                  if (senda.tasks.any((t) => t.isCompleted)) ...[
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
                          color: Colors.amber,
                        ),
                        label: Text(
                          _isExpanded
                              ? 'Ocultar completadas'
                              : 'Ver completadas (${senda.tasks.where((t) => t.isCompleted).length})',
                          style: const TextStyle(color: Colors.amber),
                        ),
                      ),
                    ),
                    if (_isExpanded)
                      for (var task in senda.tasks.where((t) => t.isCompleted))
                        SendaTaskCardWidget(
                          senda: senda,
                          task: task,
                          onComplete: () {
                            // Marcar como no completada
                            final updatedTasks = senda.tasks.map((t) {
                              if (t.id == task.id) return t.copyWith(isCompleted: false);
                              return t;
                            }).toList();
                            context.read<SendaProvider>().updateSenda(
                              user!.activeAvatarId!, 
                              senda.copyWith(tasks: updatedTasks),
                            );
                          },
                        ),
                  ],
                ],
              ),
            ),
            Positioned(
              left: 16,
              bottom: 16,
              child: FloatingActionButton(
                heroTag: 'fab_add_subsenda_${senda.id}',
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => CreateSendaScreen(parentId: senda.id),
                    ),
                  );
                },
                backgroundColor: Colors.green,
                child: const Icon(Icons.add, color: Colors.white),
              ),
            ),
          ],
        ),
      ),
      // Botón de completar senda
      if (senda.canBeCompleted && !senda.isCompleted)
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () async {
                final avatarProvider = context.read<AvatarProvider>();
                await sendaProvider.completeSenda(avatarProvider, senda);
                if (context.mounted) {
                  Navigator.pop(context);
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.purpleAccent,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              icon: const Icon(Icons.stars, color: Colors.white),
              label: const Text(
                'COMPLETAR SENDA',
                style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ),
      // Casilla mimetizada para crear tarea
          Container(
            padding: EdgeInsets.only(
              bottom: MediaQuery.of(context).padding.bottom,
            ),
            decoration: const BoxDecoration(
              color: Color(0xFF1E2A38),
              border: Border(top: BorderSide(color: Colors.white12)),
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _taskTitleController,
                          style: const TextStyle(color: Colors.white, fontSize: 16),
                          decoration: const InputDecoration(
                            hintText: 'Crea una tarea',
                            hintStyle: TextStyle(color: Colors.white54),
                            border: InputBorder.none,
                          ),
                          onSubmitted: (_) => _createTask(senda, user!.activeAvatarId!),
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.send, color: Colors.amber),
                        onPressed: () => _createTask(senda, user!.activeAvatarId!),
                      ),
                    ],
                  ),
                  if (_showDescriptionField)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 8.0, right: 48.0),
                      child: TextField(
                        controller: _taskDescController,
                        focusNode: _descFocusNode,
                        style: const TextStyle(color: Colors.white70, fontSize: 14),
                        minLines: 1,
                        maxLines: 5,
                        decoration: const InputDecoration(
                          hintText: 'Escribe la descripción aquí...',
                          hintStyle: TextStyle(color: Colors.white38),
                          border: InputBorder.none,
                        ),
                      ),
                    )
                  else
                    TextButton.icon(
                      onPressed: () {
                        setState(() {
                          _showDescriptionField = true;
                        });
                        WidgetsBinding.instance.addPostFrameCallback((_) {
                          _descFocusNode.requestFocus();
                        });
                      },
                      icon: const Icon(Icons.add, size: 16, color: Colors.white54),
                      label: const Text('Añadir descripción', style: TextStyle(color: Colors.white54)),
                      style: TextButton.styleFrom(
                        padding: EdgeInsets.zero,
                        minimumSize: Size.zero,
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
