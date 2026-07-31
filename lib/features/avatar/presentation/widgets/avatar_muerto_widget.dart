import 'package:flutter/material.dart';
import '../../domain/avatar_entity.dart';
import 'avatar_image.dart';
import 'chart_widget.dart';

class AvatarMuertoWidget extends StatefulWidget {
  final AvatarEntity avatar;

  const AvatarMuertoWidget({super.key, required this.avatar});

  @override
  State<AvatarMuertoWidget> createState() => _AvatarMuertoWidgetState();
}

class _AvatarMuertoWidgetState extends State<AvatarMuertoWidget> {
  int _clickCount = 0;

  void _handleTap() {
    setState(() {
      _clickCount = (_clickCount + 1) % 3;
    });
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _handleTap,
      child: Card(
        color: const Color(0xFF1E2A38), // Fondo oscuro
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: SizedBox(
          height: 200,
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: _buildContent(),
          ),
        ),
      ),
    );
  }

  Widget _buildContent() {
    switch (_clickCount) {
      case 0:
        return _buildVistaGeneral();
      case 1:
        return _buildVistaGrafico();
      case 2:
        return _buildVistaTitulos();
      default:
        return _buildVistaGeneral();
    }
  }

  // Vista 0: Imagen con cruz roja en ByN, Nivel, Nombre y Título
  Widget _buildVistaGeneral() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Stack(
          alignment: Alignment.center,
          children: [
            // Imagen en ByN
            ColorFiltered(
              colorFilter: const ColorFilter.matrix(<double>[
                0.2126, 0.7152, 0.0722, 0, 0,
                0.2126, 0.7152, 0.0722, 0, 0,
                0.2126, 0.7152, 0.0722, 0, 0,
                0,      0,      0,      1, 0,
              ]),
              child: AvatarImage(
                imagePath: widget.avatar.image,
                radius: 40,
                border: Border.all(color: Colors.grey, width: 2),
              ),
            ),
            // Cruz blanca superpuesta
            const Icon(Icons.close, color: Colors.white, size: 60),
          ],
        ),
        const SizedBox(width: 20),
        Flexible(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                widget.avatar.name,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Nivel ${widget.avatar.level}',
                style: const TextStyle(
                  color: Colors.amber,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              if (widget.avatar.activeTitle != null && widget.avatar.activeTitle!.isNotEmpty)
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.military_tech, size: 16, color: Colors.purpleAccent),
                    const SizedBox(width: 4),
                    Flexible(
                      child: Text(
                        widget.avatar.activeTitle!,
                        style: const TextStyle(
                          color: Colors.purpleAccent,
                          fontSize: 14,
                          fontStyle: FontStyle.italic,
                          fontWeight: FontWeight.bold,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                )
              else
                const Text(
                  'Sin título',
                  style: TextStyle(
                    color: Colors.white54,
                    fontSize: 14,
                    fontStyle: FontStyle.italic,
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }

  // Vista 1: Gráfico de atributos
  Widget _buildVistaGrafico() {
    return Stack(
      children: [
        ChartWidget(avatar: widget.avatar),
        Positioned.fill(
          child: GestureDetector(
            onTap: _handleTap,
            behavior: HitTestBehavior.opaque,
            child: const SizedBox.shrink(),
          ),
        ),
      ],
    );
  }

  // Vista 2: Historial de títulos con scroll interno
  Widget _buildVistaTitulos() {
    if (widget.avatar.titulos.isEmpty) {
      return const Center(
        child: Text(
          'No adquirió ningún título.',
          style: TextStyle(
            color: Colors.white54,
            fontSize: 16,
            fontStyle: FontStyle.italic,
          ),
        ),
      );
    }

    return Center(
      child: Scrollbar(
        thumbVisibility: true,
        child: ListView.builder(
          shrinkWrap: true,
          itemCount: widget.avatar.titulos.length,
          itemBuilder: (context, index) {
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 6.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.military_tech, size: 18, color: Colors.purpleAccent),
                  const SizedBox(width: 6),
                  Flexible(
                    child: Text(
                      widget.avatar.titulos[index],
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: Colors.purpleAccent,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
