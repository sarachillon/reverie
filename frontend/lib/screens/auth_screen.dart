import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:google_sign_in/google_sign_in.dart';
import '../services/api_manager.dart';
import 'home_screen.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({Key? key}) : super(key: key);

  @override
  _AuthScreenState createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _ageController = TextEditingController();
  String _genderPref = 'Ambos';
  GoogleSignInAccount? _currentUser;

  @override
  void initState() {
    super.initState();
    _signInWithGoogle();
  }

  Future<void> _signInWithGoogle() async {
    final GoogleSignIn _googleSignIn = GoogleSignIn();
    try {
      final account = await _googleSignIn.signIn();
      if (account == null) return;

      final email = account.email;

      // Guarda el email en SharedPreferences
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('email', email);

      setState(() {
        _currentUser = account;
      });
    } catch (e) {
      print('Error durante el inicio de sesión: $e');
      // Maneja errores inesperados
      if (!mounted) return;
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const AuthScreen()),
      );
    }
  }

  Future<void> _submit() async {
    if (_formKey.currentState!.validate()) {
      final prefs = await SharedPreferences.getInstance();
      final email = _currentUser!.email;
      final username = _usernameController.text;
      final edad = int.parse(_ageController.text);

      // Guardar en backend 
      final api = ApiManager.getInstance(email: email);
      final userData = await api.registerUser(
        email: email,
        username: username,
        edad: edad,
        genero_pref: _genderPref,
      );

      if (!mounted) return;

      // Verificar que los datos devueltos sean correctos
      if (userData != null) {
        print ('Usuario registrado: $userData');

        var accessToken = userData['access_token'];
        var user = userData['user'];
        var userId = user['id'].toString();

        // Guardar token y user_id en SharedPreferences
        await prefs.setString('token', accessToken);
        await prefs.setString('userId', userId);

        // Redirigir a la pantalla de inicio
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => HomeScreen(userEmail: email)),
        );
      } else {
        // Manejo de error si la respuesta no contiene los datos esperados
        print('Error: No se recibió el token de acceso o el ID del usuario');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al registrar el usuario, por favor intenta de nuevo.')),
        );
      }
    }


  }

  @override
  Widget build(BuildContext context) {
    if (_currentUser == null) {
      return Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(15),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Image.asset(
                  'assets/logo_reverie_text.png',
                  width: 200,
                  height: 100,
                  fit: BoxFit.contain,
                ),
                const SizedBox(height: 30),
                SizedBox(
                  width: 300,
                  child: TextFormField(
                    controller: _usernameController,
                    decoration: const InputDecoration(
                      labelText: 'Nombre de usuario',
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) =>
                        value == null || value.isEmpty ? 'Introduce un nombre' : null,
                  ),
                ),
                const SizedBox(height: 30),
                SizedBox(
                  width: 300,
                  child: TextFormField(
                    controller: _ageController,
                    decoration: const InputDecoration(
                      labelText: 'Edad',
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.number,
                    validator: (value) {
                      if (value == null || value.isEmpty) return 'Introduce tu edad';
                      final edad = int.tryParse(value);
                      if (edad == null || edad < 18 || edad > 100) return 'Edad no válida';
                      return null;
                    },
                  ),
                ),
                const SizedBox(height: 40),
                Column(
                  children: [
                    const Text('Prefieres ropa de:', style: TextStyle(fontSize: 16)),
                    const SizedBox(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        _buildGenderOption('Mujer'),
                        const SizedBox(width: 30),
                        _buildGenderOption('Hombre'),
                        const SizedBox(width: 30),
                        _buildGenderOption('Ambos'),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 50),
                ElevatedButton(
                  onPressed: _submit,
                  child: const Text('Empezar', style: TextStyle(fontSize: 16)),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildGenderOption(String gender) {
    return InkWell(
      onTap: () => setState(() => _genderPref = gender),
      child: Column(
        children: [
          Text(
            gender,
            style: TextStyle(
              fontSize: _genderPref == gender ? 18 : 16,
              fontWeight: _genderPref == gender ? FontWeight.bold : FontWeight.normal,
            ),
          ),
          const SizedBox(height: 5),
          Container(
            height: 2,
            width: 60,
            color: _genderPref == gender ? const Color(0xFFC9A86A) : Colors.grey,
          ),
        ],
      ),
    );
  }
}