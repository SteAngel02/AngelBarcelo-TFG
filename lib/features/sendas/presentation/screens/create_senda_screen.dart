import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;
import '../sendas_provider.dart';
import '../../domain/sendas_entity.dart';
import '../../../login/presentation/auth_provider.dart';

class CreateSendaScreen extends StatefulWidget {
  final String? parentId;

  const CreateSendaScreen({super.key, this.parentId});

  @override
  State<CreateSendaScreen> createState() => _CreateSendaScreenState();
}

class _CreateSendaScreenState extends State<CreateSendaScreen> {
  final _nameController = TextEditingController();
  final _descController = TextEditingController();
  final _gemsController = TextEditingController();
  final _titleRewardController = TextEditingController();
  
  final ImagePicker _picker = ImagePicker();
  File? _localImageFile;
  bool _isSaving = false;

  @override
  void dispose() {
    _nameController.dispose();
    _descController.dispose();
    _gemsController.dispose();
    _titleRewardController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    try {
      final pickedFile = await _picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 800,
        maxHeight: 600,
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
          SnackBar(content: Text('Error al seleccionar imagen: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  Future<void> _crearSenda() async {
    final name = _nameController.text.trim();
    if (name.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('El título de la senda es obligatorio.'), backgroundColor: Colors.red),
      );
      return;
    }

    final gemsText = _gemsController.text.trim();
    if (gemsText.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('La recompensa de gemas es obligatoria.'), backgroundColor: Colors.red),
      );
      return;
    }

    final gemsReward = int.tryParse(gemsText);
    if (gemsReward == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('La recompensa de gemas debe ser un número válido.'), backgroundColor: Colors.red),
      );
      return;
    }

    final titleReward = _titleRewardController.text.trim();
    if (titleReward.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('La recompensa de título es obligatoria.'), backgroundColor: Colors.red),
      );
      return;
    }

    final authProvider = context.read<AuthProvider>();
    final sendaProvider = context.read<SendaProvider>();
    final user = authProvider.user;

    if (user == null || user.activeAvatarId == null) return;

    setState(() {
      _isSaving = true;
    });

    String finalImageUrl = '';

    if (_localImageFile != null) {
      try {
        final appDir = await getApplicationDocumentsDirectory();
        final sendasDir = Directory(p.join(appDir.path, 'sendas'));
        if (!await sendasDir.exists()) {
          await sendasDir.create(recursive: true);
        }

        final extension = p.extension(_localImageFile!.path);
        final fileName = 'senda_${DateTime.now().millisecondsSinceEpoch}$extension';
        final savedImagePath = p.join(sendasDir.path, fileName);

        await _localImageFile!.copy(savedImagePath);
        finalImageUrl = savedImagePath;
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error al guardar la imagen: $e'), backgroundColor: Colors.red),
          );
        }
        setState(() { _isSaving = false; });
        return;
      }
    }

    final newSenda = SendaEntity(
      id: '', // Firestore asignará un ID válido al crear el documento
      name: name,
      description: _descController.text.trim(),
      gemsReward: gemsReward,
      tituloReward: titleReward,
      imageUrl: finalImageUrl.isNotEmpty ? finalImageUrl : null,
      parentId: widget.parentId,
      subSendas: const [],
      tasks: const [],
    );

    await sendaProvider.addSenda(user.activeAvatarId!, newSenda);

    if (mounted) {
      setState(() { _isSaving = false; });
      if (sendaProvider.errorMessage == null) {
        Navigator.pop(context); // Volver a la pantalla anterior si hay éxito
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(sendaProvider.errorMessage!), backgroundColor: Colors.red),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF121A22),
      appBar: AppBar(
        title: const Text('Crear Senda'),
        backgroundColor: const Color(0xFF1E2A38),
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Selección de portada
            GestureDetector(
              onTap: _pickImage,
              child: Container(
                height: 150,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: const Color(0xFF1E2A38),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.amber, width: 2),
                  image: _localImageFile != null
                      ? DecorationImage(
                          image: FileImage(_localImageFile!),
                          fit: BoxFit.cover,
                        )
                      : null,
                ),
                child: _localImageFile == null
                    ? Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.add_photo_alternate, size: 50, color: Colors.white54),
                          const SizedBox(height: 8),
                          Text(
                            'Añadir portada de la senda', 
                            style: TextStyle(color: Colors.white.withValues(alpha: 0.5)),
                          ),
                        ],
                      )
                    : null,
              ),
            ),
            const SizedBox(height: 24),
            
            // Campos de texto
            TextField(
              controller: _nameController,
              style: const TextStyle(color: Colors.white),
              decoration: _buildInputDecoration('Título de la Senda', Icons.title),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _descController,
              style: const TextStyle(color: Colors.white),
              maxLines: 3,
              decoration: _buildInputDecoration('Descripción', Icons.description),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _gemsController,
              style: const TextStyle(color: Colors.white),
              keyboardType: TextInputType.number,
              decoration: _buildInputDecoration('Recompensa (Gemas)', Icons.diamond),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _titleRewardController,
              style: const TextStyle(color: Colors.white),
              decoration: _buildInputDecoration('Recompensa (Título Honorífico)', Icons.military_tech),
            ),
            const SizedBox(height: 32),
            
            // Botón de guardado
            _isSaving
                ? const CircularProgressIndicator(color: Colors.amber)
                : SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: _crearSenda,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.amber,
                        foregroundColor: Colors.black,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                        textStyle: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      child: const Text('Crear Senda'),
                    ),
                  ),
          ],
        ),
      ),
    );
  }

  InputDecoration _buildInputDecoration(String label, IconData icon) {
    return InputDecoration(
      labelText: label,
      labelStyle: const TextStyle(color: Colors.white54),
      prefixIcon: Icon(icon, color: Colors.white54),
      filled: true,
      fillColor: const Color(0xFF1E2A38),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide.none),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: Colors.amber, width: 2),
      ),
    );
  }
}
