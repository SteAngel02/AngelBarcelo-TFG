import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../mision_provider.dart';
import '../../domain/mision_entity.dart';
import '../../../avatar/presentation/avatar_provider.dart';

class CrearMisionRapidoWidget extends StatefulWidget {
  final String tipoMision;

  const CrearMisionRapidoWidget({Key? key, required this.tipoMision}) : super(key: key);

  @override
  State<CrearMisionRapidoWidget> createState() => _CrearMisionRapidoWidgetState();
}

class _CrearMisionRapidoWidgetState extends State<CrearMisionRapidoWidget> {
  final _formKey = GlobalKey<FormState>();
  String _name = '';

  void _save() {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      final misionProvider = context.read<MisionProvider>();
      final avatarProvider = context.read<AvatarProvider>();
      
      MisionEntity newMision;
      
      switch (widget.tipoMision) {
        case 'Diaria':
          newMision = DiariaEntity(
            id: '',
            name: _name,
            description: '',
            stat: StatType.fuerza,
            difficulty: 'Normal',
            coinReward: 5,
          );
          break;
        case 'Castigo':
          newMision = CastigoEntity(
            id: '',
            name: _name,
            description: '',
            stat: StatType.fuerza,
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
            description: '',
            stat: StatType.fuerza,
            difficulty: 'Normal',
            coinReward: 5,
            periodicity: 2,
            isForever: true,
            goal: 1,
          );
          break;
        case 'Todo':
        default:
          newMision = TodoEntity(
            id: '',
            name: _name,
            description: '',
            stat: StatType.fuerza,
            difficulty: 'Normal',
            coinReward: 5,
          );
          break;
      }
      
      misionProvider.addMision(
        avatarProvider.currentAvatar!.id,
        newMision,
      );
      
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: const Color(0xFF1E2A38),
      title: Text('Nueva ${widget.tipoMision} Rápida', style: const TextStyle(color: Colors.white)),
      content: Form(
        key: _formKey,
        child: TextFormField(
          autofocus: true,
          style: const TextStyle(color: Colors.white),
          decoration: const InputDecoration(
            hintText: 'Nombre de la misión',
            hintStyle: TextStyle(color: Colors.white54),
            enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.white30)),
            focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.amber)),
          ),
          validator: (value) => value == null || value.isEmpty ? 'Escribe algo' : null,
          onSaved: (value) => _name = value!,
          onFieldSubmitted: (_) => _save(),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancelar', style: TextStyle(color: Colors.white54)),
        ),
        ElevatedButton(
          style: ElevatedButton.styleFrom(backgroundColor: Colors.amber, foregroundColor: Colors.black),
          onPressed: _save,
          child: const Text('Crear'),
        ),
      ],
    );
  }
}
