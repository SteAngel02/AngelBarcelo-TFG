import 'package:flutter/material.dart';
import '../../domain/sendas_entity.dart';
import '../screens/update_task_screen.dart';

class SendaTaskCardWidget extends StatefulWidget {
  final SendaEntity senda;
  final SendaTaskEntity task;
  final VoidCallback onComplete;

  const SendaTaskCardWidget({
    super.key,
    required this.senda,
    required this.task,
    required this.onComplete,
  });

  @override
  State<SendaTaskCardWidget> createState() => _SendaTaskCardWidgetState();
}

class _SendaTaskCardWidgetState extends State<SendaTaskCardWidget> {
  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    return Card(
      color: const Color(0xFF2A3645), // Ligeramente más claro que la card principal
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      clipBehavior: Clip.hardEdge,
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => UpdateTaskScreen(senda: widget.senda, task: widget.task),
            ),
          );
        },
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Textos (Título y descripción)
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.task.title,
                    style: TextStyle(
                      color: widget.task.isCompleted ? Colors.grey : Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      decoration: widget.task.isCompleted
                          ? TextDecoration.lineThrough
                          : null,
                    ),
                  ),
                  if (widget.task.description.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    if (_isExpanded)
                      Text(
                        widget.task.description,
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 14,
                        ),
                      )
                    else
                      GestureDetector(
                        onTap: () {
                          setState(() {
                            _isExpanded = true;
                          });
                        },
                        child: const Text(
                          '...más',
                          style: TextStyle(
                            color: Colors.white38,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                  ],
                ],
              ),
            ),
            const SizedBox(width: 16),
            
            // Botón de completar a la derecha
            ElevatedButton(
              onPressed: widget.onComplete,
              style: ElevatedButton.styleFrom(
                backgroundColor: widget.task.isCompleted ? Colors.grey : Colors.blueAccent,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                minimumSize: const Size(48, 48), // Tamaño accesible
              ),
              child: Icon(
                widget.task.isCompleted ? Icons.replay : Icons.check, 
                size: 20
              ),
            ),
          ],
        ),
      ),
      ),
    );
  }
}
