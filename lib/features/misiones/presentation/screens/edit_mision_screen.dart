import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../mision_provider.dart';
import '../../domain/mision_entity.dart';
import '../../../avatar/presentation/avatar_provider.dart';

class EditMisionScreen extends StatefulWidget {
  final MisionEntity mision;

  const EditMisionScreen({super.key, required this.mision});

  @override
  State<EditMisionScreen> createState() => _EditMisionScreenState();
}

class _EditMisionScreenState extends State<EditMisionScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _rewardController;

  late String _name;
  late String _description;
  late StatType _selectedStat;

  late TextEditingController _periodicityController;
  late TextEditingController _goalController;
  late bool _isForever;

  @override
  void initState() {
    super.initState();
    _name = widget.mision.name;
    _description = widget.mision.description;
    _selectedStat = widget.mision.stat;
    _rewardController = TextEditingController(text: widget.mision.coinReward.toString());

    if (widget.mision is PeriodicaEntity) {
      final pMision = widget.mision as PeriodicaEntity;
      _periodicityController = TextEditingController(text: pMision.periodicity.toString());
      _goalController = TextEditingController(text: pMision.goal.toString());
      _isForever = pMision.isForever;
    } else {
      _periodicityController = TextEditingController(text: '1');
      _goalController = TextEditingController(text: '10');
      _isForever = true;
    }
  }

  @override
  void dispose() {
    _rewardController.dispose();
    _periodicityController.dispose();
    _goalController.dispose();
    super.dispose();
  }

  void _saveMision() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();

      final avatarProvider = context.read<AvatarProvider>();
      final misionProvider = context.read<MisionProvider>();

      if (avatarProvider.currentAvatar == null) return;

      int currentReward = int.tryParse(_rewardController.text) ?? 0;

      MisionEntity updatedMision;
      
      if (widget.mision is PeriodicaEntity) {
        int periodicityDays = int.tryParse(_periodicityController.text) ?? 1;
        int goalTimes = int.tryParse(_goalController.text) ?? 10;
        
        updatedMision = (widget.mision as PeriodicaEntity).edit(
          name: _name,
          description: _description,
          stat: _selectedStat,
          coinReward: currentReward,
          periodicity: periodicityDays,
          isForever: _isForever,
          goal: goalTimes,
        );
      } else {
        updatedMision = widget.mision.edit(
          name: _name,
          description: _description,
          stat: _selectedStat,
          coinReward: currentReward,
        );
      }

      // Guardamos cambios
      misionProvider.updateMision(
        avatarProvider.currentAvatar!.id,
        updatedMision,
      );

      if (mounted) {
        Navigator.pop(context);
      }
    }
  }

  void _deleteMision() {
    final avatarProvider = context.read<AvatarProvider>();
    final misionProvider = context.read<MisionProvider>();
    
    if (avatarProvider.currentAvatar == null) return;

    misionProvider.deleteMision(
      avatarProvider.currentAvatar!.id,
      widget.mision.id,
    );
    
    if (mounted) {
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF121A22),
      appBar: AppBar(
        title: const Text('Editar Misión'),
        backgroundColor: const Color(0xFF1E2A38),
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.delete, color: Colors.redAccent),
            onPressed: () {
              // Cuadro de diálogo de confirmación antes de borrar
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  backgroundColor: const Color(0xFF1E2A38),
                  title: const Text('Borrar misión', style: TextStyle(color: Colors.white)),
                  content: const Text('¿Estás seguro de que deseas borrar esta misión?', style: TextStyle(color: Colors.white70)),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Cancelar', style: TextStyle(color: Colors.grey)),
                    ),
                    TextButton(
                      onPressed: () {
                        Navigator.pop(context);
                        _deleteMision();
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
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                initialValue: _name,
                decoration: const InputDecoration(
                  labelText: 'Nombre de la misión',
                  labelStyle: TextStyle(color: Colors.white70),
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.white30),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.green),
                  ),
                ),
                style: const TextStyle(color: Colors.white),
                validator: (value) => value == null || value.isEmpty
                    ? 'Introduce un nombre'
                    : null,
                onSaved: (value) => _name = value!,
              ),
              const SizedBox(height: 16),
              TextFormField(
                initialValue: _description,
                decoration: const InputDecoration(
                  labelText: 'Descripción (Opcional)',
                  labelStyle: TextStyle(color: Colors.white70),
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.white30),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.green),
                  ),
                ),
                style: const TextStyle(color: Colors.white),
                onSaved: (value) => _description = value ?? '',
              ),
              if (widget.mision is! CastigoEntity) ...[
                const SizedBox(height: 16),
                DropdownButtonFormField<StatType>(
                  initialValue: _selectedStat,
                  dropdownColor: const Color(0xFF1E2A38),
                  decoration: const InputDecoration(
                    labelText: 'Atributo que mejora',
                    labelStyle: TextStyle(color: Colors.white70),
                    enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.white30),
                    ),
                  ),
                  style: const TextStyle(color: Colors.white),
                  items: StatType.values.map((stat) {
                    return DropdownMenuItem(
                      value: stat,
                      child: Text(stat.name.toUpperCase()),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      _selectedStat = value!;
                    });
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _rewardController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: 'Recompensa (Monedas)',
                    labelStyle: TextStyle(color: Colors.white70),
                    enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.white30),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.green),
                    ),
                  ),
                  style: const TextStyle(color: Colors.white),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Introduce una recompensa';
                    }
                    if (int.tryParse(value) == null) {
                      return 'Debe ser un número válido';
                    }
                    return null;
                  },
                ),
              ],
              if (widget.mision is PeriodicaEntity) ...[
                const SizedBox(height: 16),
                TextFormField(
                  controller: _periodicityController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: 'Se repite cada (días)',
                    labelStyle: TextStyle(color: Colors.white70),
                    enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.white30),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.green),
                    ),
                  ),
                  style: const TextStyle(color: Colors.white),
                  validator: (value) {
                    if (value == null || value.isEmpty) return 'Introduce los días';
                    if (int.tryParse(value) == null) return 'Debe ser un número válido';
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                SwitchListTile(
                  title: const Text('¿Es para siempre?', style: TextStyle(color: Colors.white)),
                  activeColor: Colors.green,
                  value: _isForever,
                  onChanged: (bool value) {
                    setState(() {
                      _isForever = value;
                    });
                  },
                ),
                if (!_isForever) ...[
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _goalController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: 'Meta (veces a completar)',
                      labelStyle: TextStyle(color: Colors.white70),
                      enabledBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.white30),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.green),
                      ),
                    ),
                    style: const TextStyle(color: Colors.white),
                    validator: (value) {
                      if (value == null || value.isEmpty) return 'Introduce la meta';
                      if (int.tryParse(value) == null) return 'Debe ser un número válido';
                      return null;
                    },
                  ),
                ],
              ],

              const SizedBox(height: 32),
              ElevatedButton(
                onPressed: _saveMision,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  foregroundColor: Colors.white,
                  minimumSize: const Size(double.infinity, 50),
                ),
                child: const Text(
                  'Actualizar Misión',
                  style: TextStyle(fontSize: 18),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
