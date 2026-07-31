import 'dart:io';
import 'package:flutter/material.dart';
import '../../domain/sendas_entity.dart';
import '../screens/senda_detail_screen.dart';
import '../screens/update_senda_screen.dart';
import 'package:provider/provider.dart';
import '../../../avatar/presentation/avatar_provider.dart';

class SendaCardWidget extends StatefulWidget {
  final SendaEntity senda;

  const SendaCardWidget({
    super.key,
    required this.senda,
  });

  @override
  State<SendaCardWidget> createState() => _SendaCardWidgetState();
}

class _SendaCardWidgetState extends State<SendaCardWidget> {
  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    return Card(
      color: const Color(0xFF1E2A38),
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      clipBehavior: Clip.antiAlias, // Necesario para bordes redondeados con la imagen
      child: InkWell(
        onTap: widget.senda.isCompleted
            ? () {
                if (widget.senda.tituloReward != null && widget.senda.tituloReward!.isNotEmpty) {
                  showDialog(
                    context: context,
                    builder: (context) => AlertDialog(
                      backgroundColor: const Color(0xFF1E2A38),
                      title: const Text('Título Honorífico', style: TextStyle(color: Colors.white)),
                      content: Text(
                        '¿Quieres hacer de "${widget.senda.tituloReward}" tu título principal?',
                        style: const TextStyle(color: Colors.white70),
                      ),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(context),
                          child: const Text('No', style: TextStyle(color: Colors.white54)),
                        ),
                        TextButton(
                          onPressed: () {
                            context.read<AvatarProvider>().setActiveTitle(widget.senda.tituloReward!);
                            Navigator.pop(context);
                          },
                          child: const Text('Sí', style: TextStyle(color: Colors.purpleAccent, fontWeight: FontWeight.bold)),
                        ),
                      ],
                    ),
                  );
                }
              }
            : () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => SendaDetailScreen(sendaId: widget.senda.id),
                  ),
                );
              },
        child: widget.senda.isCompleted
            ? _buildCompletedLayout()
            : Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Mitad superior: Portada
                  SizedBox(
                    height: 140, // Altura fija para mantener proporciones
                    width: double.infinity,
                    child: widget.senda.imageUrl != null && widget.senda.imageUrl!.isNotEmpty
                        ? (widget.senda.imageUrl!.startsWith('http')
                            ? Image.network(
                                widget.senda.imageUrl!,
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) => _buildPlaceholder(),
                              )
                            : Image.file(
                                File(widget.senda.imageUrl!),
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) => _buildPlaceholder(),
                              ))
                        : _buildPlaceholder(),
                  ),
                  
                  // Mitad inferior: Información
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Text(
                                widget.senda.name,
                                style: TextStyle(
                                  color: widget.senda.isCompleted ? Colors.grey : Colors.white,
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  decoration: widget.senda.isCompleted
                                      ? TextDecoration.lineThrough
                                      : null,
                                ),
                              ),
                            ),
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                if (widget.senda.isCompleted) ...[
                                  const Icon(Icons.check_circle, color: Colors.green),
                                  const SizedBox(width: 4),
                                ],
                                IconButton(
                                  padding: EdgeInsets.zero,
                                  constraints: const BoxConstraints(),
                                  icon: const Icon(Icons.border_color, color: Colors.white54, size: 16),
                                  onPressed: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => UpdateSendaScreen(senda: widget.senda),
                                      ),
                                    );
                                  },
                                ),
                              ],
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        
                        // Recompensas
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (widget.senda.tituloReward != null && widget.senda.tituloReward!.isNotEmpty) ...[
                              Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Icon(Icons.military_tech, size: 18, color: Colors.purpleAccent),
                                  const SizedBox(width: 4),
                                  Text(
                                    widget.senda.tituloReward!,
                                    style: const TextStyle(
                                      color: Colors.purpleAccent,
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold,
                                      fontStyle: FontStyle.italic,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 6),
                            ],
                            if (widget.senda.gemsReward > 0)
                              Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Icon(Icons.diamond, size: 18, color: Colors.cyanAccent),
                                  const SizedBox(width: 4),
                                  Text(
                                    '${widget.senda.gemsReward}',
                                    style: const TextStyle(
                                      color: Colors.cyanAccent,
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                          ],
                        ),
                        const SizedBox(height: 8),

                        // Descripción desplegable
                        if (widget.senda.description.isNotEmpty) ...[
                          if (_isExpanded)
                            Text(
                              widget.senda.description,
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
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
      ),
    );
  }

  Widget _buildCompletedLayout() {
    final hasTitle = widget.senda.tituloReward != null && widget.senda.tituloReward!.isNotEmpty;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (hasTitle) ...[
            const Icon(Icons.military_tech, size: 18, color: Colors.purpleAccent),
            const SizedBox(width: 4),
            Text(
              widget.senda.tituloReward!,
              style: const TextStyle(
                color: Colors.purpleAccent,
                fontSize: 14,
                fontWeight: FontWeight.bold,
                fontStyle: FontStyle.italic,
              ),
            ),
          ] else ...[
            const Icon(Icons.check_circle, color: Colors.green, size: 20),
            const SizedBox(width: 8),
            Text(
              widget.senda.name,
              style: const TextStyle(
                color: Colors.grey,
                fontSize: 16,
                fontWeight: FontWeight.bold,
                decoration: TextDecoration.lineThrough,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildPlaceholder() {
    return Container(
      color: Colors.blueGrey.withValues(alpha: 0.3),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.map, size: 48, color: Colors.white.withValues(alpha: 0.5)),
            const SizedBox(height: 8),
            Text(
              'Senda de Aprendizaje',
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.5), 
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
