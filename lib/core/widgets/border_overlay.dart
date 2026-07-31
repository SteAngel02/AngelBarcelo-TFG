import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../features/avatar/presentation/avatar_provider.dart';

/// Widget de superposición que ilumina los bordes de la pantalla:
/// - En ROJO si se pierden vidas o se completa un castigo.
/// - En AMARILLO/DORADO (color monedas) si se completa cualquier otra misión o reto.
class BorderOverlay extends StatefulWidget {
  final Widget child;

  const BorderOverlay({super.key, required this.child});

  @override
  State<BorderOverlay> createState() => _BorderOverlayState();
}

class _BorderOverlayState extends State<BorderOverlay>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _opacityAnimation;
  StreamSubscription<BorderEffectType>? _subscription;

  BorderEffectType _activeEffectType = BorderEffectType.damage;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );

    _opacityAnimation = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween<double>(begin: 0.0, end: 1.0)
            .chain(CurveTween(curve: Curves.easeOutCubic)),
        weight: 30,
      ),
      TweenSequenceItem(
        tween: Tween<double>(begin: 1.0, end: 0.0)
            .chain(CurveTween(curve: Curves.easeInCubic)),
        weight: 70,
      ),
    ]).animate(_controller);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _subscription?.cancel();
    final avatarProvider = Provider.of<AvatarProvider>(context, listen: false);
    _subscription = avatarProvider.onBorderEffect.listen((effectType) {
      if (mounted) {
        setState(() {
          _activeEffectType = effectType;
        });
        _controller.forward(from: 0.0);
      }
    });
  }

  @override
  void dispose() {
    _subscription?.cancel();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        widget.child,
        AnimatedBuilder(
          animation: _opacityAnimation,
          builder: (context, child) {
            final opacity = _opacityAnimation.value;
            if (opacity <= 0.001) return const SizedBox.shrink();

            return Positioned.fill(
              child: IgnorePointer(
                child: CustomPaint(
                  painter: _BorderPainter(
                    opacity: opacity,
                    effectType: _activeEffectType,
                  ),
                ),
              ),
            );
          },
        ),
      ],
    );
  }
}

class _BorderPainter extends CustomPainter {
  final double opacity;
  final BorderEffectType effectType;

  _BorderPainter({
    required this.opacity,
    required this.effectType,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (opacity <= 0) return;

    final rect = Offset.zero & size;

    // Determinamos la paleta de colores según el tipo de evento
    final Color deepColor;
    final Color accentColor;
    final Color strokeColor;

    if (effectType == BorderEffectType.damage) {
      // Castigo / Daño -> Rojo
      deepColor = Colors.red.shade900;
      accentColor = Colors.redAccent;
      strokeColor = Colors.redAccent;
    } else {
      // Recompensa / Misión completada -> Amarillo / Dorado Monedas
      deepColor = Colors.orange.shade900;
      accentColor = Colors.amber;
      strokeColor = Colors.amberAccent;
    }

    // 1. Gradientes en los 4 bordes (Efecto Vignette)
    final double vignetteSize = size.shortestSide * 0.15; // 15% del lado más corto

    // Top
    final topPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          deepColor.withValues(alpha: 0.85 * opacity),
          accentColor.withValues(alpha: 0.4 * opacity),
          Colors.transparent,
        ],
      ).createShader(Rect.fromLTWH(0, 0, size.width, vignetteSize));
    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, vignetteSize), topPaint);

    // Bottom
    final bottomPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.bottomCenter,
        end: Alignment.topCenter,
        colors: [
          deepColor.withValues(alpha: 0.85 * opacity),
          accentColor.withValues(alpha: 0.4 * opacity),
          Colors.transparent,
        ],
      ).createShader(
        Rect.fromLTWH(0, size.height - vignetteSize, size.width, vignetteSize),
      );
    canvas.drawRect(
      Rect.fromLTWH(0, size.height - vignetteSize, size.width, vignetteSize),
      bottomPaint,
    );

    // Left
    final leftPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.centerLeft,
        end: Alignment.centerRight,
        colors: [
          deepColor.withValues(alpha: 0.85 * opacity),
          accentColor.withValues(alpha: 0.4 * opacity),
          Colors.transparent,
        ],
      ).createShader(Rect.fromLTWH(0, 0, vignetteSize, size.height));
    canvas.drawRect(Rect.fromLTWH(0, 0, vignetteSize, size.height), leftPaint);

    // Right
    final rightPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.centerRight,
        end: Alignment.centerLeft,
        colors: [
          deepColor.withValues(alpha: 0.85 * opacity),
          accentColor.withValues(alpha: 0.4 * opacity),
          Colors.transparent,
        ],
      ).createShader(
        Rect.fromLTWH(size.width - vignetteSize, 0, vignetteSize, size.height),
      );
    canvas.drawRect(
      Rect.fromLTWH(size.width - vignetteSize, 0, vignetteSize, size.height),
      rightPaint,
    );

    // 2. Trazo de borde radiante resplandeciente
    final borderPaint = Paint()
      ..color = strokeColor.withValues(alpha: 0.9 * opacity)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 6.0
      ..maskFilter = const MaskFilter.blur(BlurStyle.solid, 4);

    canvas.drawRect(rect, borderPaint);
  }

  @override
  bool shouldRepaint(covariant _BorderPainter oldDelegate) {
    return oldDelegate.opacity != opacity || oldDelegate.effectType != effectType;
  }
}
