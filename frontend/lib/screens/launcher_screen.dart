import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/api_manager.dart';
import 'auth_screen.dart';
import 'home_screen.dart';

class LauncherScreen extends StatefulWidget {
  const LauncherScreen({Key? key}) : super(key: key);

  @override
  State<LauncherScreen> createState() => _LauncherScreenState();
}

class _LauncherScreenState extends State<LauncherScreen> {
  @override
  void initState() {
    super.initState();
    _navigate();
  }

  Future<void> _navigate() async {
    final prefs = await SharedPreferences.getInstance();
    final email = prefs.getString('email'); // Obtén el email de SharedPreferences

    if (email != null) {
      // Valida si el usuario existe en la base de datos
      final api = ApiManager.getInstance(email: email);
      final exists = await api.checkUserExists(email: email);
      print('Usuario existe en la base de datos: $exists');

      if (!mounted) return;

      if (exists) {
        // Si el usuario existe, redirige a HomeScreen
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => HomeScreen(userEmail: email)),
        );
      } else {
        // Si el usuario no existe, limpia SharedPreferences y redirige a AuthScreen
        await prefs.clear();
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const AuthScreen()),
        );
      }
    } else {
      // Si no hay email, redirige a AuthScreen
      print('No se encontró email en SharedPreferences. Redirigiendo a AuthScreen.');
      if (!mounted) return;
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const AuthScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(child: CircularProgressIndicator()),
    );
  }
}
