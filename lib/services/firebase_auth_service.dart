import 'package:NutriMate/theme/app_theme.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:quickalert/models/quickalert_type.dart';
import 'package:quickalert/widgets/quickalert_dialog.dart';
import '../screens/screens.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();

// Traduce los codigos de error de firebase a español
  String _getTranslatedErrorMessage(String code) {
    switch (code) {
      case 'email-already-in-use':
        return 'El correo electrónico ya está registrado en otra cuenta';
      case 'invalid-credential':
        return 'Usuario o contraseña incorrectos';
      default:
        return 'Se ha producido un error inesperado';
    }
  }

  //Funcion para registrar un usuario
  Future<String?> registerUser({
    required String nombre,
    required String apellidos,
    required String email,
    required String password,
    required BuildContext context,
  }) async {
    //Cierra el teclado una vez que se envian los datos
    FocusScope.of(context).unfocus();
    try {
      //Crea las credenciales de acceso del usuario con email y password
      UserCredential userCredential =
          await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      //Obtiene el UID del usuario
      String uid = userCredential.user!.uid;

      //Guarda los datos del usuario en la base de datos
      await _firestore.collection('usuarios').doc(uid).set({
        'nombre': nombre,
        'apellidos': apellidos,
        'email': email,
      });

      //Muestra una ventana si todo ha salido correctamente en el registro
      QuickAlert.show(
        context: context,
        type: QuickAlertType.success,
        title: "Usuario registrado correctamente",
        showConfirmBtn: false,
      );

      Future.delayed(Duration(seconds: 3), () {
        Navigator.of(context).pop();
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (context) => const LoginScreen(),
          ),
        );
      });

      return null;
    }
    //Si se da alguna excepcion a la hora de registrar el usuario se muestra una ventana con el error.
    on FirebaseAuthException catch (e) {
      String message = _getTranslatedErrorMessage(e.code);
      QuickAlert.show(
        context: context,
        type: QuickAlertType.error,
        title: "Error al registrar usuario",
        text: message,
        confirmBtnText: "OK",
        confirmBtnColor: AppTheme.primary,
        onConfirmBtnTap: () {
          Navigator.of(context).pop();
        },
      );
      return e.message;
    }
  }

  // Iniciar sesión con email y contraseña
  Future<void> logIn(
      String email, String password, BuildContext context) async {
    try {
      await _auth
          .signInWithEmailAndPassword(
            email: email.trim(),
            password: password.trim(),
          )
          .then((value) => {
                if (value.user != null && context.mounted)
                  {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (context) => TabScreen()),
                    )
                  }
              });
    } on FirebaseAuthException catch (e) {
      String message = _getTranslatedErrorMessage(e.code);
      QuickAlert.show(
        context: context,
        type: QuickAlertType.error,
        title: "Error al iniciar sesión",
        text: message,
        confirmBtnText: "OK",
        confirmBtnColor: AppTheme.primary,
        onConfirmBtnTap: () {
          Navigator.of(context).pop();
        },
      );
    }
  }

  //Iniciar sesión con Google
  Future<void> signInWithGoogle(BuildContext context) async {
    try {
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) {
        return;
      }

      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;
      final AuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      UserCredential userCredential =
          await _auth.signInWithCredential(credential);
      User? user = userCredential.user;

//Si el usuario no existe en la base de datos lo crea
      if (user != null) {
        DocumentSnapshot userDoc =
            await _firestore.collection('usuarios').doc(user.uid).get();
        if (!userDoc.exists) {
          await _firestore.collection('usuarios').doc(user.uid).set({
            'nombre': user.displayName ?? 'Usuario',
            'email': user.email,
            'photoURL': user.photoURL,
          });
        }

        if (context.mounted) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => TabScreen()),
          );
        }
      }
    } catch (e) {
      if (context.mounted) {
        QuickAlert.show(
          context: context,
          type: QuickAlertType.error,
          title: "Error al iniciar sesión con Google",
          confirmBtnText: "OK",
          confirmBtnColor: AppTheme.primary,
          onConfirmBtnTap: () {
            Navigator.of(context).pop();
          },
        );
      }
    }
  }

//Cerrar sesion
  Future<void> signOut() async {
    await _auth.signOut();
    await _googleSignIn.signOut();
  }
}
