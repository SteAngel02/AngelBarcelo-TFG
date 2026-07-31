import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../tienda_provider.dart';
import '../../domain/recompensa_entity.dart';
import '../../../avatar/presentation/avatar_provider.dart';

class CreateRecompensaScreen extends StatefulWidget {
  const CreateRecompensaScreen({super.key});

  @override
  State<CreateRecompensaScreen> createState() => _CreateRecompensaScreenState();
}

class _CreateRecompensaScreenState extends State<CreateRecompensaScreen> {
  final _formKey = GlobalKey<FormState>();
  final _costController = TextEditingController(text: '10');
  final _stockController = TextEditingController(text: '1');

  String _name = '';
  String _description = '';
  CoinType _selectedCoinType = CoinType.coins;
  bool _isUnlimited = true;

  @override
  void dispose() {
    _costController.dispose();
    _stockController.dispose();
    super.dispose();
  }

  void _saveRecompensa() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();

      final avatarProvider = context.read<AvatarProvider>();
      final avatarId = avatarProvider.currentAvatar?.id;
      if (avatarId == null) return;

      final tiendaProvider = context.read<TiendaProvider>();

      int price = int.tryParse(_costController.text) ?? 10;
      int stock = _isUnlimited ? -1 : (int.tryParse(_stockController.text) ?? 1);

      final newRecompensa = RecompensaEntity(
        id: '', // Firestore generará el ID auto
        nombre: _name,
        descripcion: _description,
        coinType: _selectedCoinType,
        price: price,
        stock: stock,
      );

      // Guardamos en segundo plano
      tiendaProvider.addRecompensa(avatarId, newRecompensa);

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
        title: const Text('Añadir Recompensa'),
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
                  onPressed: _saveRecompensa,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    foregroundColor: Colors.white,
                    minimumSize: const Size(double.infinity, 50),
                  ),
                  child: const Text(
                    'Crear Recompensa',
                    style: TextStyle(fontSize: 18),
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
