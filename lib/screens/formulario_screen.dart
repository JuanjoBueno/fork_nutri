import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../models/usuario.dart';

class FormularioMedicion extends StatefulWidget {
  final Usuario usuario;

  const FormularioMedicion({Key? key, required this.usuario}) : super(key: key);

  @override
  State<FormularioMedicion> createState() => _FormularioMedicionState();
}

class _FormularioMedicionState extends State<FormularioMedicion> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _grasaController = TextEditingController();
  DateTime _fecha = DateTime.now();

  // Función para guardar la medición en Firestore
  Future<void> _guardarMedicion() async {
    if (_formKey.currentState!.validate()) {
      try {
        await FirebaseFirestore.instance.collection('mediciones').add({
          'userId': widget.usuario.email, // Asociamos la medición al usuario
          'grasaCorporal': double.parse(_grasaController.text),
          'fecha': _fecha.toIso8601String(),
        });

        // Volver a la pantalla anterior después de guardar
        Navigator.pop(context);
      } catch (e) {
        // Mostrar error si ocurre algún problema al guardar
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error al guardar la medición: $e')));
      }
    }
  }

  // Función para mostrar el selector de fecha
  Future<void> _seleccionarFecha(BuildContext context) async {
    final DateTime? selectedDate = await showDatePicker(
      context: context,
      initialDate: _fecha,
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
    );
    if (selectedDate != null && selectedDate != _fecha) {
      setState(() {
        _fecha = selectedDate;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Registrar Medición de Grasa Corporal"),
        backgroundColor: Colors.teal,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Campo de grasa corporal
              TextFormField(
                controller: _grasaController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: 'Grasa Corporal (%)',
                  border: OutlineInputBorder(),
                  hintText: 'Ingrese el porcentaje de grasa corporal',
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor ingrese la grasa corporal';
                  }
                  if (double.tryParse(value) == null ||
                      double.parse(value) < 0) {
                    return 'Ingrese un valor numérico válido';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              // Selector de fecha
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Fecha: ${_fecha.toLocal()}'.split(' ')[0]),
                  IconButton(
                    icon: const Icon(Icons.calendar_today),
                    onPressed: () => _seleccionarFecha(context),
                  ),
                ],
              ),
              const SizedBox(height: 32),
              // Botón para guardar
              Center(
                child: ElevatedButton(
                  onPressed: _guardarMedicion,
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.teal),
                  child: const Text('Guardar Medición'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
