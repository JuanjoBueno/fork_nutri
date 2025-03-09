import 'package:NutriMate/screens/nueva_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:NutriMate/screens/screens.dart';

class SessionManager {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  //Comprueba si el usuario está autenticado.
  bool isLoggedIn() {
    return _auth.currentUser != null;
  }

  //Verifica si el usuario está autenticado y lo redirige a la pantalla que corresponda.
  void checkAuthAndRedirect(BuildContext context) {
    //Si el usuario está autenticado y es la cuenta de administrador lo lleva al apartado de administracion.
    if (isLoggedIn() && _auth.currentUser!.email == "admin@nutrimate.com") {
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (context) => ClientesScreen()),
        (route) => false,
      );
    } else if (isLoggedIn()) {
      // Si el usuario está autenticado, lo lleva a la pantalla principal TabScreen
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => NuevaScreen()),
      );
    } else {
      // Si el usuario no está autenticado, lo envía a la pantalla de inicio de sesión LoginScreen
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const LoginScreenDefensa()),
      );
    }
  }
}
