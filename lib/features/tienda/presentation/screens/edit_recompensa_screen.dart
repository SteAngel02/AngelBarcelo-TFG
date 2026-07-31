import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../tienda_provider.dart';
import '../../domain/recompensa_entity.dart';
import '../../../avatar/presentation/avatar_provider.dart';

class EditRecompensaScreen extends StatefulWidget {
  final RecompensaEntity recompensa;

  const EditRecompensaScreen({super.key, required this.recompensa});

  @override
  State<EditRecompensaScreen> createState() => _EditRecompensaScreenState();
}

class _EditRecompensaScreenState extends State<EditRecompensaScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _costController;
  late TextEditingController _stockController;

  late String _name;
  late String _description;
  late CoinType _selectedCoinType;
  late bool _isUnlimited;

  @override
  void initState() {
    super.initState();
    _name = widget.recompensa.nombre;
    _description = widget.recompensa.descripcion;
    _selectedCoinType = widget.recompensa.coinType;
    _isUnlimited = widget.recompensa.stock < 0; // -1 significa ilimitado
    
    _costController = TextEditingController(text: widget.recompensa.price.toString());
    _stockController = TextEditingController(
      text: _isUnlimited ? '1' : widget.recompensa.stock.toString(),
    );
  }

  @override
  void dispose() {
    _costController.dispose();
    _stockController.dispose();
    super.dispose();
  }

  void _updateRecompensa() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();

      final avatarProvider = context.read<AvatarProvider>();
      final avatarId = avatarProvider.currentAvatar?.id;
      if (avatarId == null) return;

      final tiendaProvider = context.read<TiendaProvider>();

      int price = int.tryParse(_costController.text) ?? 10;
      int stock = _isUnlimited ? -1 : (int.tryParse(_stockController.text) ?? 1);

      final updatedRecompensa = widget.recompensa.copyWith(
        nombre: _name,
        descripcion: _description,
        coinType: _selectedCoinType,
        price: price,
        stock: stock,
      );

      // Guardamos en segundo plano
      tiendaProvider.updateRecompensa(avatarId, updatedRecompensa);

      if (mounted) {
        Navigator.pop(context); // Volvemos a la tienda
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF121A22),
      appBar: AppBar(
        title: const Text('Editar Recompensa'),
        backgroundColor: const Color(0xFF1E2A38),
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              children: [
                TextFormField(
                  initialValue: _name,
                  decoration: const InputDecoration(
                    labelText: 'Nombre de la recompensa',
                    labelStyle: TextStyle(color: Colors.white70),
                    enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.white30),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.green),
                    ),
                  ),
                  style: const TextStyle(color: Colors.white),
                  validator: (value) => value == null || value.isEmpty ? 'Introduce un nombre' : null,
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
                const SizedBox(height: 16),
                DropdownButtonFormField<CoinType>(
                  value: _selectedCoinType,
                  dropdownColor: const Color(0xFF1E2A38),
                  decoration: const InputDecoration(
                    labelText: 'Moneda de pago',
                    labelStyle: TextStyle(color: Colors.white70),
                    enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.white30),
                    ),
                  ),
                  style: const TextStyle(color: Colors.white),
                  items: const [
                    DropdownMenuItem(value: CoinType.coins, child: Text('Monedas')),
                    DropdownMenuItem(value: CoinType.gems, child: Text('Gemas')),
                  ],
                  onChanged: (value) {
                    setState(() {
                      if (value != null) _selectedCoinType = value;
                    });
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _costController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: 'Coste',
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
                    if (value == null || value.isEmpty) return 'Introduce un coste';
                    if (int.tryParse(value) == null) return 'Debe ser un número válido';
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                SwitchListTile(
                  title: const Text('Stock Ilimitado', style: TextStyle(color: Colors.white)),
                  activeColor: Colors.green,
                  value: _isUnlimited,
                  onChanged: (bool value) {
                    setState(() {
                      _isUnlimited = value;
                    });
                  },
                ),
                if (!_isUnlimited) ...[
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _stockController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: 'Cantidad en Stock',
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
                      if (value == null || value.isEmpty) return 'Introduce el stock';
                      if (int.tryParse(value) == null) return 'Debe ser un número válido';
                      return null;
                    },
                  ),
                ],
                const SizedBox(height: 32),
                ElevatedButton(
                  onPressed: _updateRecompensa,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.amber, // Color distinto para indicar edición
                    foregroundColor: Colors.black,
                    minimumSize: const Size(double.infinity, 50),
                  ),
                  child: const Text(
                    'Actualizar Recompensa',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
