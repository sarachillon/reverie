import 'package:flutter/material.dart';
import 'auth_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Inicio'),
        actions: [
          IconButton(
            icon: const Icon(Icons.exit_to_app),
            onPressed: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => const AuthScreen()),
              );
            },
          )
        ],
      ),
      body: const Center(
        child: Text(
          '¡Bienvenido a tu aplicación!',
          style: TextStyle(fontSize: 24),
        ),
      ),
    );
  }
}