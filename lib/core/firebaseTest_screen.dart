import 'package:flutter/material.dart';
//import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key, required this.title});
  final String title;

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _counter = 0;
  String _lastEntry = 'Ninguna entrada leída aún.';

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  void _incrementCounter() {
    setState(() {
      _counter++;
    });
  }

  Future<void> _addEntryToFirestore() async {
    try {
      await _firestore.collection('log_entries').add({
        'timestamp': FieldValue.serverTimestamp(),
        'counter_value': _counter,
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Entrada guardada en Firestore.')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al guardar: $e')),
      );
      print('Error adding entry to Firestore: $e');
    }
  }

  Future<void> _readLastEntryFromFirestore() async {
    try {
      final querySnapshot = await _firestore
          .collection('log_entries')
          .orderBy('timestamp', descending: true)
          .limit(1)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        final data = querySnapshot.docs.first.data();
        final timestamp = (data['timestamp'] as Timestamp?)?.toDate();
        final counterValue = data['counter_value'];
        setState(() {
          _lastEntry = 'Última entrada: ${timestamp?.toLocal()} (Contador: $counterValue)';
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Última entrada leída.')),
        );
      } else {
        setState(() {
          _lastEntry = 'No hay entradas en Firestore.';
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('No hay entradas en Firestore.')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al leer: $e')),
      );
      print('Error reading last entry from Firestore: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const Text('Valor actual del contador:'),
            Text(
              '$_counter',
              style: Theme.of(context).textTheme.displayLarge,
            ),
            const SizedBox(height: 20),
            Text(
              _lastEntry,
              style: Theme.of(context).textTheme.bodyLarge,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
      floatingActionButton: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          FloatingActionButton(
            onPressed: _readLastEntryFromFirestore,
            heroTag: "btnLeer",
            tooltip: 'Leer última entrada',
            child: const Icon(Icons.download),
          ),
          const SizedBox(height: 12),
          FloatingActionButton(
            onPressed: _addEntryToFirestore,
            heroTag: "btnGuardar",
            tooltip: 'Guardar en Firestore',
            child: const Icon(Icons.save),
          ),
          const SizedBox(height: 12),
          FloatingActionButton(
            onPressed: _incrementCounter,
            heroTag: "btnSumar",
            tooltip: 'Incrementar',
            child: const Icon(Icons.add),
          ),
        ],
      ),
    );
  }
}