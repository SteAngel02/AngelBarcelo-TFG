import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../domain/sendas_entity.dart';
import '../sendas_provider.dart';
import '../../../login/presentation/auth_provider.dart';

class UpdateTaskScreen extends StatefulWidget {
  final SendaEntity senda;
  final SendaTaskEntity task;

  const UpdateTaskScreen({super.key, required this.senda, required this.task});

  @override
  State<UpdateTaskScreen> createState() => _UpdateTaskScreenState();
}

class _UpdateTaskScreenState extends State<UpdateTaskScreen> {
  late TextEditingController _titleController;
  late TextEditingController _descController;
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.task.title);
    _descController = TextEditingController(text: widget.task.description);
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descController.dispose();
    super.dispose();
  }

  void _deleteTask() {
    final user = context.read<AuthProvider>().user;
    if (user == null || !user.hasActiveAvatar) return;

    final updatedTasks = widget.senda.tasks.where((t) => t.id != widget.task.id).toList();

    context.read<SendaProvider>().updateSenda(
      user.activeAvatarId!,
      widget.senda.copyWith(tasks: updatedTasks),
    );

    if (mounted) {
      Navigator.pop(context);
    }
  }

  void _saveTask() {
    if (!_formKey.currentState!.validate()) return;

    final user = context.read<AuthProvider>().user;
    if (user == null || !user.hasActiveAvatar) return;

    final updatedTask = widget.task.copyWith(
      title: _titleController.text.trim(),
      description: _descController.text.trim(),
    );

    final updatedTasks = widget.senda.tasks.map((t) {
      if (t.id == widget.task.id) return updatedTask;
      return t;
    }).toList();

    context.read<SendaProvider>().updateSenda(
      user.activeAvatarId!,
      widget.senda.copyWith(tasks: updatedTasks),
    );

    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF121A22),
      appBar: AppBar(
        title: const Text('Editar Tarea'),
        backgroundColor: const Color(0xFF1E2A38),
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.delete, color: Colors.redAccent),
            onPressed: () {
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  backgroundColor: const Color(0xFF1E2A38),
                  title: const Text('Borrar tarea', style: TextStyle(color: Colors.white)),
                  content: const Text('¿Estás seguro de que deseas borrar esta tarea?', style: TextStyle(color: Colors.white70)),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Cancelar', style: TextStyle(color: Colors.grey)),
                    ),
                    TextButton(
                      onPressed: () {
                        Navigator.pop(context);
                        _deleteTask();
                      },
                      child: const Text('Borrar', style: TextStyle(color: Colors.redAccent)),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextFormField(
                controller: _titleController,
                style: const TextStyle(color: Colors.white),
                decoration: const InputDecoration(
                  labelText: 'Título',
                  labelStyle: TextStyle(color: Colors.white70),
                  border: OutlineInputBorder(),
                  enabledBorder: OutlineInputBorder(borderSide: BorderSide(color: Colors.white38)),
                ),
                validator: (val) => (val == null || val.trim().isEmpty) ? 'Este campo es obligatorio' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _descController,
                style: const TextStyle(color: Colors.white),
                maxLines: 5,
                minLines: 3,
                decoration: const InputDecoration(
                  labelText: 'Descripción (Opcional)',
                  labelStyle: TextStyle(color: Colors.white70),
                  border: OutlineInputBorder(),
                  enabledBorder: OutlineInputBorder(borderSide: BorderSide(color: Colors.white38)),
                ),
              ),
              const SizedBox(height: 32),
              ElevatedButton.icon(
                onPressed: _saveTask,
                icon: const Icon(Icons.save),
                label: const Text('Guardar Cambios'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blueAccent,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
