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
        title: const Text("Mediciones de Grasa Corporal",
            style: TextStyle(color: Colors.white)),
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

                  // Lista de mediciones
                  final mediciones = snapshot.data!.docs;
                  return ListView.builder(
                    itemCount: mediciones.length,
                    itemBuilder: (context, index) {
                      final medicion = mediciones[index];
                      final fecha = DateTime.parse(medicion['fecha']);
                      final formattedDate =
                          DateFormat('dd/MM/yyyy').format(fecha);
                      final grasaCorporal = medicion['grasaCorporal'];

                      // Card con la información de la medición
                      return Card(
                        elevation: 2, // Sombra sutil para un efecto elevado
                        shape: RoundedRectangleBorder(
                          borderRadius:
                              BorderRadius.circular(12), // Bordes redondeados
                        ),
                        color: Colors.blueGrey[50], // Color de fondo más suave
                        margin: const EdgeInsets.symmetric(
                            vertical: 8.0, horizontal: 12.0),
                        child: ListTile(
                          contentPadding: const EdgeInsets.symmetric(
                              vertical: 8.0, horizontal: 16.0),
                          leading: CircleAvatar(
                            backgroundColor: Colors.blueGrey[200],
                            child:
                                Icon(Icons.fitness_center, color: Colors.white),
                          ),
                          title: Text(
                            '$grasaCorporal% de grasa corporal',
                            style: const TextStyle(
                                fontSize: 16, fontWeight: FontWeight.bold),
                          ),
                          subtitle: Text(
                            'Fecha: $formattedDate',
                            style: const TextStyle(
                                fontSize: 14, color: Colors.black54),
                          ),
                          trailing: IconButton(
                            icon: const Icon(Icons.delete, color: Colors.red),
                            onPressed: () async {
                              await FirebaseFirestore.instance
                                  .collection('mediciones')
                                  .doc(medicion.id)
                                  .delete();
                            },
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

  // Datos del usuario
  Widget _informacionUsuario() {
    return Card(
      elevation: 3, // Sombra sutil
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12), // Bordes redondeados
      ),
      color: Colors.blueGrey[50], // Color de fondo suave
      margin: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 16.0),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 30,
                  backgroundColor: Colors.blueGrey[200],
                  child: Icon(Icons.person, color: Colors.white, size: 30),
                ),
                const SizedBox(width: 12),
                Text(
                  usuario.name + " " + usuario.lastName,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
              ],
            ),
            const Divider(height: 20, thickness: 1, color: Colors.grey),
            _infoRow(Icons.email, "Email", usuario.email),
            _infoRow(Icons.fitness_center, "Peso", "${usuario.weight} kg"),
          ],
        ),
      ),
    );
  }

  Widget _infoRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        children: [
          Icon(icon, color: Colors.blueGrey),
          const SizedBox(width: 10),
          Text(
            "$label: ",
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          Text(
            value,
            style: const TextStyle(fontSize: 16, color: Colors.black54),
          ),
        ],
      ),
    );
  }
}
