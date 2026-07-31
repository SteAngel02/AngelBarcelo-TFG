import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../mision_provider.dart';
import '../../domain/mision_entity.dart';
import '../../../avatar/presentation/avatar_provider.dart';

class CreateMisionScreen extends StatefulWidget {
  const CreateMisionScreen({super.key});

  @override
  State<CreateMisionScreen> createState() => _CreateMisionScreenState();
}

class _CreateMisionScreenState extends State<CreateMisionScreen> {
  final _formKey = GlobalKey<FormState>();
  final _rewardController = TextEditingController(text: '5');
  final _periodicityController = TextEditingController(text: '1');
  final _goalController = TextEditingController(text: '10');

  String _name = '';
  String _description = '';
  StatType _selectedStat = StatType.fuerza;
  String _selectedType = 'Todo';
  bool _isForever = true;

  final List<String> _misionTypes = ['Diaria', 'Periodica', 'Todo', 'Castigo'];

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

      MisionEntity newMision;

      int currentReward = int.tryParse(_rewardController.text) ?? 5;
      int periodicityDays = int.tryParse(_periodicityController.text) ?? 1;
      int goalTimes = int.tryParse(_goalController.text) ?? 10;

      // Creamos la instancia según el tipo seleccionado
      switch (_selectedType) {
        case 'Diaria':
          newMision = DiariaEntity(
            id: '',
            name: _name,
            description: _description,
            stat: _selectedStat,
            difficulty: 'Normal',
            coinReward: currentReward,
          );
          break;
        case 'Castigo':
          newMision = CastigoEntity(
            id: '',
            name: _name,
            description: _description,
            stat: _selectedStat,
            difficulty: 'Normal',
            coinReward: 0,
            penaltyCoins: 5,
            penaltyHealth: 10,
          );
          break;
        case 'Periodica':
          newMision = PeriodicaEntity(
            id: '',
            name: _name,
            description: _description,
            stat: _selectedStat,
            difficulty: 'Normal',
            coinReward: currentReward,
            periodicity: periodicityDays,
            isForever: _isForever,
            goal: goalTimes,
          );
          break;
        case 'Todo':
        default:
          newMision = TodoEntity(
            id: '',
            name: _name,
            description: _description,
            stat: _selectedStat,
            difficulty: 'Normal',
            coinReward: currentReward,
          );
          break;
      }

      // No hacemos 'await' para que Firebase guarde en segundo plano 
      // y la pantalla vuelva inmediatamente sin esperar la respuesta del servidor.
      misionProvider.addMision(
        avatarProvider.currentAvatar!.id,
        newMision,
      );

      if (mounted) {
        Navigator.pop(context); // Volvemos a InicioScreen
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF121A22),
      appBar: AppBar(
        title: const Text('Añadir Misión'),
        backgroundColor: const Color(0xFF1E2A38),
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
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
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                initialValue: _selectedType,
                dropdownColor: const Color(0xFF1E2A38),
                decoration: const InputDecoration(
                  labelText: 'Tipo de Misión',
                  labelStyle: TextStyle(color: Colors.white70),
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.white30),
                  ),
                ),
                style: const TextStyle(color: Colors.white),
                items: _misionTypes.map((type) {
                  return DropdownMenuItem(value: type, child: Text(type));
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedType = value!;
                    if (_selectedType == 'Diaria') {
                      _rewardController.text = '10';
                    } else if (_selectedType == 'Periodica') {
                      _rewardController.text = '20';
                    } else if (_selectedType == 'Todo') {
                      _rewardController.text = '5';
                    }
                  });
                },
              ),
              if (_selectedType != 'Castigo') ...[
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
              if (_selectedType == 'Periodica') ...[
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
                  'Crear Misión',
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
