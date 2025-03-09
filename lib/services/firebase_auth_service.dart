import 'package:NutriMate/main.dart';
import 'package:NutriMate/models/entities.dart';
import 'package:NutriMate/providers/user_provider.dart';
import 'package:NutriMate/theme/app_theme.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:provider/provider.dart';
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
      case 'network-request-failed':
        return 'Error de conexion';
      default:
        return 'Se ha producido un error inesperado';
    }
  }

  //Funcion para registrar un usuario
  Future<String?> registerUser({
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
      await _firestore
          .collection('nuevosusuarios')
          .doc(uid)
          .set({'uid': uid, 'password': password, 'email': email});

      //Muestra una ventana si todo ha salido correctamente en el registro
      QuickAlert.show(
          context: context,
          type: QuickAlertType.success,
          title: "Usuario registrado correctamente",
          confirmBtnText: "Iniciar sesion",
          confirmBtnColor: AppTheme.primary,
          onConfirmBtnTap: () {
            Navigator.of(context).pushAndRemoveUntil(
              MaterialPageRoute(builder: (context) => LoginScreenDefensa()),
              (route) => false,
            );
          });
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
    return null;
  }

  // Iniciar sesión con email y contraseña
  Future<void> logIn(
      String email, String password, BuildContext context) async {
    FocusScope.of(context).unfocus();
    try {
      await _auth
          .signInWithEmailAndPassword(
            email: email.trim(),
            password: password.trim(),
          )
          .then((value) => {
                if (value.user != null && context.mounted)
                  {
                    if (value.user?.email == "admin@nutrimate.com")
                      {
                        Provider.of<UserProvider>(context, listen: false)
                            .loadUser()
                            .then((_) {
                          Navigator.of(context).pushAndRemoveUntil(
                            MaterialPageRoute(
                                builder: (context) => ClientesScreen()),
                            (route) => false,
                          );
                        })
                      }
                    else
                      {
                        Provider.of<UserProvider>(context, listen: false)
                            .loadUser()
                            .then((_) {
                          Navigator.of(context).pushAndRemoveUntil(
                            MaterialPageRoute(
                                builder: (context) => TabScreen()),
                            (route) => false,
                          );
                        })
                      }
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
    final Map<String, dynamic> menuSemanal = menu.toMap();
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
            'nombre': user.displayName?.split(" ").first,
            'apellidos': user.displayName!.split(" ")[1] +
                ' ' +
                user.displayName!.split(" ")[2],
            'email': user.email,
            'photoURL': user.photoURL,
          });
        }

        if (context.mounted) {
          await Provider.of<UserProvider>(context, listen: false)
              .loadUser()
              .then((_) {
            Navigator.of(context).pushAndRemoveUntil(
              MaterialPageRoute(builder: (context) => TabScreen()),
              (route) => false,
            );
          });
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
  Future<void> signOut(BuildContext context) async {
    await _auth.signOut();
    await _googleSignIn.signOut();
    navigatorKey.currentState?.pushAndRemoveUntil(
      MaterialPageRoute(builder: (context) => LoginScreenDefensa()),
      (Route<dynamic> route) => false,
    );
  }

//Pasar a mayuscula la primera letra del nombre
  String capitalizeFirstLetter(String text) {
    if (text.isEmpty) return text;
    return text[0].toUpperCase() + text.substring(1);
  }

// Recuperar contraeña
  void resetPassword(String email, BuildContext context) async {
    FocusScope.of(context).unfocus();
    try {
      //Envia un correo de reestablecimiento de contraseña al email introducido
      await FirebaseAuth.instance.sendPasswordResetEmail(email: email);
      QuickAlert.show(
        context: context,
        type: QuickAlertType.success,
        title: "Email enviado correctamente a \n $email",
        text: "Revisa tu bandeja de entrada para restablecer tu contraseña.",
        confirmBtnText: "OK",
        confirmBtnColor: AppTheme.primary,
        onConfirmBtnTap: () {
          Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(builder: (context) => LoginScreen()),
            (route) => false,
          );
        },
      );
    } catch (e) {
      QuickAlert.show(
        context: context,
        type: QuickAlertType.error,
        title: "Error al enviar el correo",
        text: "Ocurrió un error. Inténtalo nuevamente.",
        confirmBtnText: "OK",
        confirmBtnColor: AppTheme.primary,
        onConfirmBtnTap: () {
          Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(builder: (context) => LoginScreen()),
            (route) => false,
          );
        },
      );
    }
  }

  void iniciarSesion(
      String email, String password, BuildContext context) async {
    try {
      CollectionReference usuarios =
          FirebaseFirestore.instance.collection('nuevosusuarios');
      QuerySnapshot querySnapshot =
          await usuarios.where('email', isEqualTo: email).limit(1).get();

      if (querySnapshot.docs.isNotEmpty) {
        var usuario = querySnapshot.docs.first;
        String userPassword = usuario['password'];

        if (userPassword == password) {
          QuickAlert.show(
            context: context,
            type: QuickAlertType.success,
            title: "Inicio de sesion correcto \n bienvenido $email",
            confirmBtnText: "OK",
            confirmBtnColor: AppTheme.primary,
            onConfirmBtnTap: () {
              AuthService auth = AuthService();
              //auth.signOut(context);
              Navigator.of(context).pop();
            },
          );
        } else {
          QuickAlert.show(
            context: context,
            type: QuickAlertType.error,
            title: "Error contraseña incorrecta",
            confirmBtnText: "OK",
            confirmBtnColor: AppTheme.primary,
            onConfirmBtnTap: () {
              Navigator.of(context).pop();
            },
          );
        }
      } else {
        QuickAlert.show(
          context: context,
          type: QuickAlertType.error,
          title: "Usuario no encontrado",
          confirmBtnText: "OK",
          confirmBtnColor: AppTheme.primary,
          onConfirmBtnTap: () {
            Navigator.of(context).pop();
          },
        );
      }
    } catch (e) {
      QuickAlert.show(
        context: context,
        type: QuickAlertType.error,
        title: "Error al iniciar sesion",
        confirmBtnText: "OK",
        confirmBtnColor: AppTheme.primary,
        onConfirmBtnTap: () {
          Navigator.of(context).pop();
        },
      );
    }
  }
}
