import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/api_manager.dart';
import '../services/google_sign_in_service.dart';
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
  String? email = prefs.getString('email'); // 1. Mira si ya hay sesión

  if (email == null) {
  //2. Si no hay sesión, inicia sesión con Google
    final googleSignInService = GoogleSignInService();
    email = await googleSignInService.signInWithGoogle();
    if (email == null) {
      print('Inicio de sesión cancelado o fallido');
      return;
    }
  }

  // 3. Verifica si el usuario existe en la BD
  final api = ApiManager.getInstance(email: email);
  final userData = await api.loginWithEmail(email: email);
  print('userData: $userData');

  if (!mounted) return;

  if (userData != null) {
    // 4. Usuario existe → va a HomeScreen
    final accessToken = userData['access_token'];
    final userId = userData['id'].toString(); 

    await prefs.setString('token', accessToken);
    await prefs.setString('userId', userId); 

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => HomeScreen(userEmail: email)),
    );
  } else {
    // 5. Usuario NO existe → va a AuthScreen
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
