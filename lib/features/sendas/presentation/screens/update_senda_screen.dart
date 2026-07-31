import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;
import 'package:provider/provider.dart';
import '../../domain/sendas_entity.dart';
import '../sendas_provider.dart';
import '../../../login/presentation/auth_provider.dart';

class UpdateSendaScreen extends StatefulWidget {
  final SendaEntity senda;

  const UpdateSendaScreen({super.key, required this.senda});

  @override
  State<UpdateSendaScreen> createState() => _UpdateSendaScreenState();
}

class _UpdateSendaScreenState extends State<UpdateSendaScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _descController;
  late TextEditingController _gemsRewardController;
  late TextEditingController _titleRewardController;
  
  File? _imageFile;
  String? _existingImageUrl;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.senda.name);
    _descController = TextEditingController(text: widget.senda.description);
    _gemsRewardController = TextEditingController(text: widget.senda.gemsReward.toString());
    _titleRewardController = TextEditingController(text: widget.senda.tituloReward ?? '');
    _existingImageUrl = widget.senda.imageUrl;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descController.dispose();
    _gemsRewardController.dispose();
    _titleRewardController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() {
        _imageFile = File(pickedFile.path);
        _existingImageUrl = null; // Ocultamos la URL antigua visualmente al seleccionar nueva
      });
    }
  }

  Future<void> _deleteSenda() async {
    final user = context.read<AuthProvider>().user;
    if (user == null || !user.hasActiveAvatar) return;

    final sendaProvider = context.read<SendaProvider>();

    await sendaProvider.deleteSenda(user.activeAvatarId!, widget.senda.id);

    if (mounted) {
      // Hacemos pop de la pantalla de edición
      Navigator.pop(context);
    }
  }

  Future<void> _updateSenda() async {
    if (!_formKey.currentState!.validate()) return;

    final user = context.read<AuthProvider>().user;
    if (user == null || !user.hasActiveAvatar) return;
    
    final sendaProvider = context.read<SendaProvider>();

    String finalImageUrl = _existingImageUrl ?? '';

    // Guardado de imagen si se selecciona una nueva
    if (_imageFile != null) {
      final directory = await getApplicationDocumentsDirectory();
      final sendasDir = Directory('${directory.path}/sendas');
      if (!await sendasDir.exists()) {
        await sendasDir.create(recursive: true);
      }

      final fileName = path.basename(_imageFile!.path);
      final savedImage = await _imageFile!.copy('${sendasDir.path}/${DateTime.now().millisecondsSinceEpoch}_$fileName');
      finalImageUrl = savedImage.path;
    }

    final gemsReward = int.tryParse(_gemsRewardController.text.trim()) ?? 0;

    final updatedSenda = widget.senda.copyWith(
      name: _nameController.text.trim(),
      description: _descController.text.trim(),
      gemsReward: gemsReward,
      tituloReward: _titleRewardController.text.trim(),
      imageUrl: finalImageUrl.isNotEmpty ? finalImageUrl : null,
    );

    await sendaProvider.updateSenda(user.activeAvatarId!, updatedSenda);

    if (mounted) {
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF121A22),
      appBar: AppBar(
        title: const Text('Editar Senda'),
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
                  title: const Text('Borrar senda', style: TextStyle(color: Colors.white)),
                  content: const Text('¿Estás seguro de que deseas borrar esta senda? Se eliminarán todas las subsendas y tareas dentro de ella de forma permanente.', style: TextStyle(color: Colors.white70)),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Cancelar', style: TextStyle(color: Colors.grey)),
                    ),
                    TextButton(
                      onPressed: () {
                        Navigator.pop(context);
                        _deleteSenda();
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
              // Selector de Imagen
              GestureDetector(
                onTap: _pickImage,
                child: Container(
                  height: 180,
                  decoration: BoxDecoration(
                    color: const Color(0xFF1E2A38),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.white38),
                    image: _imageFile != null
                        ? DecorationImage(
                            image: FileImage(_imageFile!),
                            fit: BoxFit.cover,
                          )
                        : (_existingImageUrl != null && _existingImageUrl!.isNotEmpty)
                            ? (_existingImageUrl!.startsWith('http')
                                ? DecorationImage(
                                    image: NetworkImage(_existingImageUrl!),
                                    fit: BoxFit.cover,
                                  )
                                : DecorationImage(
                                    image: FileImage(File(_existingImageUrl!)),
                                    fit: BoxFit.cover,
                                  ))
                            : null,
                  ),
                  child: (_imageFile == null && (_existingImageUrl == null || _existingImageUrl!.isEmpty))
                      ? Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: const [
                            Icon(Icons.add_photo_alternate, size: 48, color: Colors.white54),
                            SizedBox(height: 8),
                            Text('Añadir Portada', style: TextStyle(color: Colors.white54)),
                          ],
                        )
                      : const Align(
                          alignment: Alignment.bottomRight,
                          child: Padding(
                            padding: EdgeInsets.all(8.0),
                            child: CircleAvatar(
                              backgroundColor: Colors.black54,
                              child: Icon(Icons.edit, color: Colors.white, size: 20),
                            ),
                          ),
                        ),
                ),
              ),
              const SizedBox(height: 24),

              // Nombre
              TextFormField(
                controller: _nameController,
                style: const TextStyle(color: Colors.white),
                decoration: const InputDecoration(
                  labelText: 'Nombre de la Senda',
                  labelStyle: TextStyle(color: Colors.white70),
                  border: OutlineInputBorder(),
                  enabledBorder: OutlineInputBorder(borderSide: BorderSide(color: Colors.white38)),
                ),
                validator: (val) => (val == null || val.trim().isEmpty) ? 'Requerido' : null,
              ),
              const SizedBox(height: 16),

              // Descripción
              TextFormField(
                controller: _descController,
                style: const TextStyle(color: Colors.white),
                maxLines: 4,
                decoration: const InputDecoration(
                  labelText: 'Descripción',
                  labelStyle: TextStyle(color: Colors.white70),
                  border: OutlineInputBorder(),
                  enabledBorder: OutlineInputBorder(borderSide: BorderSide(color: Colors.white38)),
                ),
              ),
              const SizedBox(height: 24),

              // Recompensas
              const Text(
                'Recompensas por Completar',
                style: TextStyle(color: Colors.amber, fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _gemsRewardController,
                      style: const TextStyle(color: Colors.cyanAccent),
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: 'Gemas',
                        labelStyle: TextStyle(color: Colors.white70),
                        prefixIcon: Icon(Icons.diamond, color: Colors.cyanAccent),
                        border: OutlineInputBorder(),
                        enabledBorder: OutlineInputBorder(borderSide: BorderSide(color: Colors.white38)),
                      ),
                      validator: (val) {
                        if (val == null || val.trim().isEmpty) return 'Requerido';
                        if (int.tryParse(val) == null) return 'Debe ser un número';
                        return null;
                      },
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: TextFormField(
                      controller: _titleRewardController,
                      style: const TextStyle(color: Colors.amber),
                      decoration: const InputDecoration(
                        labelText: 'Título',
                        labelStyle: TextStyle(color: Colors.white70),
                        prefixIcon: Icon(Icons.military_tech, color: Colors.amber),
                        border: OutlineInputBorder(),
                        enabledBorder: OutlineInputBorder(borderSide: BorderSide(color: Colors.white38)),
                      ),
                      validator: (val) => (val == null || val.trim().isEmpty) ? 'Requerido' : null,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 32),

              // Guardar
              ElevatedButton.icon(
                onPressed: _updateSenda,
                icon: const Icon(Icons.save),
                label: const Text('Guardar Cambios'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
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
