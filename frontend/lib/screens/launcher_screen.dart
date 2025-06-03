import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../services/api_manager.dart';
import '../services/google_sign_in_service.dart';
import 'auth_screen.dart';
import 'home_screen.dart';
import 'welcome_screen.dart';

class LauncherScreen extends StatefulWidget {
  const LauncherScreen({Key? key}) : super(key: key);

  @override
  State<LauncherScreen> createState() => _LauncherScreenState();
}

class _LauncherScreenState extends State<LauncherScreen> {
  /// Maneja el flujo de inicio de sesión con Google y navegación posterior.
  Future<void> _handleGoogleSignIn() async {
    final prefs = await SharedPreferences.getInstance();

    // 1. Iniciar sesión con Google
    final googleSignInService = GoogleSignInService();
    final String? email = await googleSignInService.signInWithGoogle();
    if (email == null) {
      debugPrint('Inicio de sesión cancelado o fallido');
      return;
    }
    await prefs.setString('email', email);

    // 2. Verificar existencia del usuario en la base de datos
    final api = ApiManager.getInstance(email: email);
    final userData = await api.loginWithEmail(email: email);

    if (!mounted) return;

    if (userData != null) {
      // Usuario existe → navegar a HomeScreen
      final accessToken = userData['access_token'] as String;
      final userId = userData['id'];
      final userIdString = userId.toString();
      await prefs.setString('accessToken', accessToken);
      await prefs.setString('userId', userIdString);

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => HomeScreen(userId: userId, userEmail: email),
        ),
      );
    } else {
      // Usuario NO existe → navegar a AuthScreen
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => const AuthScreen(),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return WelcomeScreen(
      onGoogleSignIn: _handleGoogleSignIn,
    );
  }
}
