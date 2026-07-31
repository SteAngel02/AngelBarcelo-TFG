import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import '../../domain/avatar_entity.dart';
import '../avatar_provider.dart';
import '../../../login/presentation/auth_provider.dart';
import 'avatar_image.dart';
import 'chart_widget.dart';
import '../screens/cementerio_screen.dart';

class AvatarInicioWidget extends StatefulWidget {
  final AvatarEntity avatar;
  final String userName;

  const AvatarInicioWidget({
    super.key,
    required this.avatar,
    required this.userName,
  });

  @override
  State<AvatarInicioWidget> createState() => _AvatarInicioWidgetState();
}

class _AvatarInicioWidgetState extends State<AvatarInicioWidget> {
  bool _isChartOpen = false;

  void _showAvatarMenu(BuildContext context, Offset position) async {
    final RenderBox overlay =
        Overlay.of(context).context.findRenderObject() as RenderBox;

    final result = await showMenu<String>(
      context: context,
      color: const Color(0xFF2A3B4C), // Azul oscuro acorde al tema
      elevation: 8,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Colors.white.withOpacity(0.2), width: 1),
      ),
      position: RelativeRect.fromRect(
        position & const Size(40, 40),
        Offset.zero & overlay.size,
      ),
      items: [
        const PopupMenuItem<String>(
          value: 'change_image',
          child: Text(
            'Cambiar imagen del avatar',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ),
        ),
        const PopupMenuDivider(height: 1),
        const PopupMenuItem<String>(
          value: 'logout',
          child: Text(
            'Cerrar sesión',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ),
        ),
      ],
    );

    if (result == 'change_image') {
      if (!context.mounted) return;
      _pickImage(context);
    } else if (result == 'logout') {
      if (!context.mounted) return;
      context.read<AuthProvider>().logout();
    }
  }

  Future<void> _pickImage(BuildContext context) async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);
    if (image != null && context.mounted) {
      context.read<AvatarProvider>().updateAvatarImage(image.path);
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onVerticalDragUpdate: (details) {
        if (details.primaryDelta! > 5) {
          setState(() {
            _isChartOpen = true;
          });
        } else if (details.primaryDelta! < -5) {
          setState(() {
            _isChartOpen = false;
          });
        }
      },
      child: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          color: const Color(0xFF1E2A38), // Azul oscuro RPG
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.3),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.only(
                left: 24.0,
                right: 24.0,
                top: 20.0,
                bottom: 20.0,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Nombre y usuario a la izquierda en la parte superior
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Expanded(
                        child: GestureDetector(
                          onTapDown: (details) =>
                              _showAvatarMenu(context, details.globalPosition),
                          child: Text.rich(
                            TextSpan(
                              children: [
                                TextSpan(
                                  text: widget.avatar.name,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 24,
                                    letterSpacing: 1.2,
                                  ),
                                ),
                                if (widget.userName.isNotEmpty)
                                  TextSpan(
                                    text: '  (@${widget.userName})',
                                    style: TextStyle(
                                      color: Colors.white.withOpacity(0.55),
                                      fontWeight: FontWeight.normal,
                                      fontSize: 16,
                                      letterSpacing: 1.0,
                                    ),
                                  ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      IconButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const CementerioScreen(),
                            ),
                          );
                        },
                        icon: const Icon(Icons.account_balance, color: Colors.grey),
                        tooltip: 'Cementerio de Avatares',
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      // Izquierda: Imagen del avatar
                      GestureDetector(
                        onTapDown: (details) =>
                            _showAvatarMenu(context, details.globalPosition),
                        child: AvatarImage(
                          imagePath: widget.avatar.image,
                          radius: 40,
                          border: Border.all(color: Colors.grey, width: 2.5),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.5),
                              blurRadius: 8,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 24),
                      // Derecha: Nivel, Título, Corazones y Recursos
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Nivel
                            Text(
                              'Nivel ${widget.avatar.level}',
                              style: const TextStyle(
                                color: Colors.amber,
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 1.2,
                              ),
                            ),
                            const SizedBox(height: 2),
                            if (widget.avatar.activeTitle != null && widget.avatar.activeTitle!.isNotEmpty)
                              Row(
                                children: [
                                  const Icon(Icons.military_tech, size: 16, color: Colors.purpleAccent),
                                  const SizedBox(width: 4),
                                  Expanded(
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
                              Text(
                                'Sin título',
                                style: TextStyle(
                                  color: Colors.white.withOpacity(0.6),
                                  fontSize: 14,
                                  fontStyle: FontStyle.italic,
                                ),
                              ),
                            const SizedBox(height: 12),
                            // Corazones de vida (máximo 10) que se auto-escalan para caber en una sola línea
                            FittedBox(
                              fit: BoxFit.scaleDown,
                              alignment: Alignment.centerLeft,
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: List.generate(10, (index) {
                                  return Padding(
                                    padding: const EdgeInsets.only(right: 3.0),
                                    child: Icon(
                                      index < widget.avatar.health
                                          ? Icons.favorite
                                          : Icons.favorite_border,
                                      color: Colors.redAccent,
                                      size: 22,
                                    ),
                                  );
                                }),
                              ),
                            ),
                            const SizedBox(height: 12),
                            // Monedas y Gemas
                            Wrap(
                              spacing: 20,
                              runSpacing: 8,
                              children: [
                                _buildResourceIndicator(
                                  Icons.monetization_on,
                                  Colors.amber,
                                  widget.avatar.coins,
                                ),
                                _buildResourceIndicator(
                                  Icons.diamond,
                                  Colors.cyanAccent,
                                  widget.avatar.gems,
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // Sección del Gráfico Animado con AnimatedCrossFade
            AnimatedCrossFade(
              duration: const Duration(milliseconds: 350),
              sizeCurve: Curves.fastOutSlowIn,
              firstCurve: Curves.easeIn,
              secondCurve: Curves.easeOut,
              crossFadeState: _isChartOpen
                  ? CrossFadeState.showSecond
                  : CrossFadeState.showFirst,
              firstChild: const SizedBox(width: double.infinity, height: 0),
              secondChild: SizedBox(
                height: 320,
                width: double.infinity,
                child: ChartWidget(avatar: widget.avatar),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildResourceIndicator(IconData icon, Color color, int amount) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, color: color, size: 24),
        const SizedBox(width: 6),
        Text(
          '$amount',
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
      ],
    );
  }
}
