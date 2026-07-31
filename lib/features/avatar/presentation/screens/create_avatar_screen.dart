import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;
import '../avatar_provider.dart';
import '../../domain/avatar_entity.dart';
import '../../../login/presentation/auth_provider.dart';
import '../../../misiones/presentation/mision_provider.dart';
import '../../../sendas/presentation/sendas_provider.dart';

class CreateAvatarScreen extends StatefulWidget {
  const CreateAvatarScreen({super.key});

  @override
  State<CreateAvatarScreen> createState() => _CreateAvatarScreenState();
}

class _CreateAvatarScreenState extends State<CreateAvatarScreen> {
  final _nameController = TextEditingController();
  final ImagePicker _picker = ImagePicker();
  File? _localImageFile;

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    try {
      final pickedFile = await _picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 512,
        maxHeight: 512,
        imageQuality: 85,
      );
      if (pickedFile != null) {
        setState(() {
          _localImageFile = File(pickedFile.path);
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al seleccionar la imagen: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _crearAvatar() async {
    final name = _nameController.text.trim();
    if (name.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Por favor, introduce un nombre para tu avatar.'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    if (_localImageFile == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Debes subir una imagen para tu avatar.'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final authProvider = context.read<AuthProvider>();
    final avatarProvider = context.read<AvatarProvider>();
    final user = authProvider.user;

    if (user == null) return;

    String finalImageUrl = '';

    try {
      // Obtener el directorio persistente de la aplicación en el dispositivo
      final appDir = await getApplicationDocumentsDirectory();

      // Crear subcarpeta 'avatars' si no existe
      final avatarsDir = Directory(p.join(appDir.path, 'avatars'));
      if (!await avatarsDir.exists()) {
        await avatarsDir.create(recursive: true);
      }

      // Generar un nombre único para el archivo usando timestamp y la extensión original
      final extension = p.extension(_localImageFile!.path);
      final fileName =
          'avatar_${DateTime.now().millisecondsSinceEpoch}$extension';
      final savedImagePath = p.join(avatarsDir.path, fileName);

      // Copiar el archivo temporal a la ruta persistente
      await _localImageFile!.copy(savedImagePath);

      finalImageUrl = savedImagePath;
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al guardar la imagen localmente: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
      return;
    }

    // Generamos un ID básico
    final newId = DateTime.now().millisecondsSinceEpoch.toString();

    final newAvatar = AvatarEntity(id: newId, name: name, image: finalImageUrl);

    await avatarProvider.createAvatar(user.id, newAvatar);

    // Actualizamos el usuario para vincularle este avatar
    if (avatarProvider.errorMessage == null && mounted) {
      await authProvider.setActiveAvatar(newAvatar.id);

      if (mounted) {
        context.read<MisionProvider>().loadMisiones(newAvatar.id);
        context.read<SendaProvider>().loadSendas(newAvatar.id);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthProvider>().user;
    final isFirstAvatar = user?.graveyard.isEmpty ?? true;
    final isLoading = context.watch<AvatarProvider>().isLoading;

    return Scaffold(
      backgroundColor: const Color(0xFF121A22), // Fondo oscuro RPG
      appBar: AppBar(
        title: const Text('Crea tu personaje'),
        centerTitle: true,
        backgroundColor: const Color(0xFF1E2A38),
        foregroundColor: Colors.white,
      ),
      body: Center(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Container(
              padding: const EdgeInsets.all(24.0),
              decoration: BoxDecoration(
                color: const Color(0xFF1E2A38),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.white24, width: 2),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  if (isFirstAvatar) ...[
                    const Text(
                      'Crea tu primer personaje',
                      style: TextStyle(
                        color: Colors.amber,
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ] else ...[
                    const Text(
                      '¡Oh! Se ha muerto tu avatar',
                      style: TextStyle(
                        color: Colors.redAccent,
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      '¡No te preocupes! crea otro e intenta superar al anterior',
                      style: TextStyle(color: Colors.white70, fontSize: 14),
                      textAlign: TextAlign.center,
                    ),
                  ],
                  const SizedBox(height: 24),

                  // Avatar seleccionado (Vista Previa Grande)
                  GestureDetector(
                    onTap: _pickImage,
                    child: Container(
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.amber, width: 4),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.amber.withValues(alpha: 0.3),
                            blurRadius: 15,
                            spreadRadius: 2,
                          ),
                        ],
                      ),
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          CircleAvatar(
                            radius: 70,
                            backgroundColor: const Color(0xFF121A22),
                            backgroundImage: _localImageFile != null
                                ? FileImage(_localImageFile!)
                                : null,
                            child: _localImageFile == null
                                ? const Icon(
                                    Icons.add_a_photo,
                                    size: 50,
                                    color: Colors.white54,
                                  )
                                : null,
                          ),
                          Positioned(
                            bottom: 0,
                            right: 0,
                            child: CircleAvatar(
                              backgroundColor: Colors.amber,
                              radius: 20,
                              child: const Icon(
                                Icons.edit,
                                color: Colors.black,
                                size: 18,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 32),

                  // Nombre del Avatar
                  TextField(
                    controller: _nameController,
                    style: const TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      labelText: 'Nombre del Personaje',
                      labelStyle: const TextStyle(color: Colors.white54),
                      prefixIcon: const Icon(
                        Icons.person,
                        color: Colors.white54,
                      ),
                      filled: true,
                      fillColor: const Color(0xFF121A22),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide.none,
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: const BorderSide(
                          color: Colors.amber,
                          width: 2,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 32),

                  // Mensaje de Error si lo hay
                  if (context.watch<AvatarProvider>().errorMessage != null) ...[
                    Text(
                      context.read<AvatarProvider>().errorMessage!,
                      style: const TextStyle(
                        color: Colors.red,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),
                  ],

                  // Botón de creación
                  if (isLoading)
                    const CircularProgressIndicator(color: Colors.amber)
                  else
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton(
                        onPressed: _crearAvatar,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.amber,
                          foregroundColor: Colors.black,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          textStyle: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        child: const Text('Comenzar Aventura'),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
