import 'package:NutriMate/screens/formulario_screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/usuario.dart';

class NuevaScreen extends StatelessWidget {
  final Usuario usuario;

  const NuevaScreen({Key? key, required this.usuario}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Usamos un StreamBuilder para escuchar las mediciones del usuario
    return Scaffold(
      appBar: AppBar(
        title: const Text("Perfil de Usuario"),
        backgroundColor: Colors.teal,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Información del usuario
            _informacionUsuario(),
            const SizedBox(height: 20),
            // Botón para ir al formulario de medición
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => FormularioMedicion(usuario: usuario),
                  ),
                );
              },
              child: const Text('Agregar Medición'),
              style: ElevatedButton.styleFrom(backgroundColor: Colors.teal),
            ),
            const SizedBox(height: 20),
            // StreamBuilder para mostrar las mediciones
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance
                    .collection('mediciones')
                    .where('userId', isEqualTo: usuario.email)
                    .orderBy('fecha', descending: true)
                    .snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (snapshot.hasError) {
                    return Center(child: Text('Error: ${snapshot.error}'));
                  }

                  if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                    return const Center(child: Text('No hay mediciones aún.'));
                  }

                  // Listado de mediciones
                  final mediciones = snapshot.data!.docs;
                  return ListView.builder(
                    itemCount: mediciones.length,
                    itemBuilder: (context, index) {
                      final medicion = mediciones[index];
                      final fecha = DateTime.parse(medicion['fecha']);
                      final formattedDate =
                          DateFormat('dd/MM/yyyy').format(fecha);
                      final grasaCorporal = medicion['grasaCorporal'];

                      return Card(
                        margin: const EdgeInsets.symmetric(vertical: 8.0),
                        child: ListTile(
                          title: Text('$grasaCorporal% de grasa corporal'),
                          subtitle: Text('Fecha: $formattedDate'),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon: const Icon(Icons.delete),
                                onPressed: () async {
                                  // Eliminar medición
                                  await FirebaseFirestore.instance
                                      .collection('mediciones')
                                      .doc(medicion.id)
                                      .delete();
                                },
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Widget que muestra los datos del usuario
  Widget _informacionUsuario() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text("Email: ${usuario.email}", style: const TextStyle(fontSize: 18)),
        Text("Nombre: ${usuario.name}", style: const TextStyle(fontSize: 18)),
        Text("Apellidos: ${usuario.lastName}",
            style: const TextStyle(fontSize: 18)),
        Text("Peso: ${usuario.weight} kg",
            style: const TextStyle(fontSize: 18)),
      ],
    );
  }
}
