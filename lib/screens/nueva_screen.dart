import 'package:NutriMate/providers/user_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/usuario.dart';

class NuevaScreen extends StatefulWidget {
  const NuevaScreen({Key? key}) : super(key: key);

  @override
  State<NuevaScreen> createState() => _NuevaScreenState();
}

class _NuevaScreenState extends State<NuevaScreen> {
  @override
  Widget build(BuildContext context) {
    final Usuario user = Provider.of<UserProvider>(context).usuario!;

    return Scaffold(
      body: Center(
        child: Text(user.name),
      ),
    );
  }
}
