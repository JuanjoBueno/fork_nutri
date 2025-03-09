import 'entities.dart';

class Usuario {
  final String email;
  final String name;
  final String lastName;
  final double weight;
  final MenuSemanal? menu; // Ahora es opcional

  Usuario({
    required this.email,
    required this.name,
    required this.lastName,
    required this.weight,
    this.menu, // Puede ser null
  });

  factory Usuario.fromMap(Map<String, dynamic> map) {
    return Usuario(
      email: map['email'] ?? '',
      name: map['nombre'] ?? '',
      lastName: map['apellidos'] ?? '',
      weight: (map['peso'] ?? 0.0).toDouble(),
      menu: map['menu'] != null ? MenuSemanal.fromMap(map['menu']) : null,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'email': email,
      'nombre': name,
      'apellidos': lastName,
      'peso': weight,
      'menu': menu?.toMap(), // Solo lo incluye si no es null
    };
  }

  Usuario copyWith({
    String? email,
    String? name,
    String? lastName,
    double? weight,
    MenuSemanal? menu,
  }) {
    return Usuario(
      email: email ?? this.email,
      name: name ?? this.name,
      lastName: lastName ?? this.lastName,
      weight: weight ?? this.weight,
      menu: menu ?? this.menu, // Permite actualizarlo o mantenerlo como está
    );
  }
}
