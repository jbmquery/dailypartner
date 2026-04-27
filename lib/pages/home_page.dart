//lib/pages/home_page.dart
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final CollectionReference testRef = FirebaseFirestore.instance.collection(
    'test',
  );

  // 🔥 Agregar dato de prueba
  Future<void> agregarDato() async {
    await testRef.add({
      'mensaje': 'Hola Firebase 🚀',
      'fecha': FieldValue.serverTimestamp(),
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Prueba Firebase'), centerTitle: true),
      body: Column(
        children: [
          // 🧾 LISTA DE DATOS
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: testRef.orderBy('fecha', descending: true).snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return const Center(child: Text('Sin datos aún'));
                }

                final docs = snapshot.data!.docs;

                return ListView.builder(
                  itemCount: docs.length,
                  itemBuilder: (context, index) {
                    final data = docs[index];

                    return ListTile(
                      leading: const Icon(Icons.cloud),
                      title: Text(data['mensaje'] ?? ''),
                      subtitle: Text(data['fecha']?.toString() ?? ''),
                    );
                  },
                );
              },
            ),
          ),

          // ➕ BOTÓN PARA AGREGAR
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: ElevatedButton.icon(
              onPressed: agregarDato,
              icon: const Icon(Icons.add),
              label: const Text('Agregar dato'),
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(double.infinity, 50),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
