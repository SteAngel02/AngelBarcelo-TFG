import 'dart:io';
import 'package:flutter/material.dart';

/// Widget visual para pintar la imagen del avatar de forma segura.
/// Soporta tanto URLs de red (presets) como rutas de archivos locales del móvil.
class AvatarImage extends StatelessWidget {
  final String imagePath;
  final double radius;
  final BoxBorder? border;
  final List<BoxShadow>? boxShadow;

  const AvatarImage({
    super.key,
    required this.imagePath,
    this.radius = 40,
    this.border,
    this.boxShadow,
  });

  bool _isNetworkUrl(String path) {
    return path.startsWith('http://') || path.startsWith('https://');
  }

  @override
  Widget build(BuildContext context) {
    ImageProvider? imageProvider;

    if (imagePath.isNotEmpty) {
      if (_isNetworkUrl(imagePath)) {
        imageProvider = NetworkImage(imagePath);
      } else {
        final file = File(imagePath);
        if (file.existsSync()) {
          imageProvider = FileImage(file);
        }
      }
    }

    return Container(
      width: radius * 2,
      height: radius * 2,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: border,
        boxShadow: boxShadow,
        color: Colors.grey[200],
      ),
      child: ClipOval(
        child: imageProvider != null
            ? Image(
                image: imageProvider,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Icon(
                    Icons.person,
                    size: radius,
                    color: Colors.grey,
                  );
                },
              )
            : Icon(
                Icons.person,
                size: radius,
                color: Colors.grey,
              ),
      ),
    );
  }
}
