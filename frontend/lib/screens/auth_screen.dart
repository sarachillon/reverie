import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'home_screen.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  late final GoogleSignIn _googleSignIn;
  GoogleSignInAccount? _currentUser;

  @override
  void initState() {
    super.initState();
    _googleSignIn = GoogleSignIn(
      scopes: ['email', 'profile'],
    );

    _googleSignIn.onCurrentUserChanged.listen((account) {
      setState(() => _currentUser = account);
    });
    _googleSignIn.signInSilently();
  }

  Future<void> _signIn() async {
    try {
      final user = await _googleSignIn.signIn();
      if (user != null && mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const HomeScreen()),
        );
      }
    } catch (error) {
      print('Error durante el inicio de sesión: $error');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: ${error.toString()}')),
        );
      }
    }
  }

  Future<void> _signOut() async {
    await _googleSignIn.signOut();
    setState(() => _currentUser = null);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Inicio de sesión')),
      body: Center(
        child: _currentUser != null
            ? Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('Conectado como ${_currentUser?.email}'),
                  ElevatedButton(
                    onPressed: _signOut,
                    child: const Text('Cerrar sesión'),
                  ),
                ],
              )
            : ElevatedButton(
                onPressed: _signIn,
                child: const Text('Iniciar con Google'),
              ),
      ),
    );
  }
}