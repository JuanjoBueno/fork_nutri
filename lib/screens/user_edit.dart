import 'package:NutriMate/theme/app_theme.dart';
import 'package:flutter/material.dart';
import '../models/usuario.dart';

void showUserEditDialog(
    BuildContext context, Usuario usuario, Function(Usuario) onSave) {
  final TextEditingController nameController =
      TextEditingController(text: usuario.name);
  final TextEditingController lastNameController =
      TextEditingController(text: usuario.lastName);

  showDialog(
    context: context,
    builder: (context) {
      return Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15.0),
        ),
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Título del popup
              Text(
                "Editar Usuario",
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: AppTheme.primary,
                    ),
              ),
              const SizedBox(height: 20.0),

              // Campos de entrada
              _buildTextField(
                controller: nameController,
                label: "Nombre",
              ),
              const SizedBox(height: 10.0),
              _buildTextField(
                controller: lastNameController,
                label: "Apellidos",
              ),
              const SizedBox(height: 10.0),

              // Botones de acción
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ElevatedButton.icon(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.cancel),
                    label: const Text("Cancelar"),
                    style: ElevatedButton.styleFrom(
                      foregroundColor: Colors.black,
                      backgroundColor: Colors.grey[300],
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10.0),
                      ),
                    ),
                  ),
                  ElevatedButton.icon(
                    onPressed: () {
                      Usuario updatedUser = Usuario(
                        email: usuario.email,
                        name: nameController.text,
                        lastName: lastNameController.text,
                        weight: usuario.weight,
                      );
                      onSave(updatedUser);
                      Navigator.pop(context);
                    },
                    icon: const Icon(Icons.save),
                    label: const Text("Guardar"),
                    style: ElevatedButton.styleFrom(
                      foregroundColor: Colors.black,
                      backgroundColor: Colors.grey[300],
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10.0),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      );
    },
  );
}

// Función auxiliar para los campos de texto
Widget _buildTextField({
  required TextEditingController controller,
  required String label,
  TextInputType keyboardType = TextInputType.text,
}) {
  return TextFormField(
    controller: controller,
    decoration: InputDecoration(
      labelText: label,
      labelStyle: TextStyle(color: Colors.blueAccent),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10.0),
        borderSide: const BorderSide(color: Colors.blueAccent, width: 1.5),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10.0),
        borderSide: const BorderSide(color: Colors.blueAccent, width: 2.0),
      ),
    ),
    keyboardType: keyboardType,
  );
}
