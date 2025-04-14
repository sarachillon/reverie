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
      _currentUser = account;

      final email = _currentUser!.email;
      ApiManager.getInstance(email: email);

      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('email', email);

      if (mounted) setState(() {});
    } catch (error) {
      print("Error al iniciar sesión: $error");
    }
  }

  Future<void> _submit() async {
  if (_formKey.currentState!.validate()) {
    final prefs = await SharedPreferences.getInstance();
    final email = _currentUser!.email;
    final username = _usernameController.text;
    final edad = int.parse(_ageController.text);

    // Guardar en SharedPreferences
    await prefs.setString('username', username);
    await prefs.setInt('edad', edad);
    await prefs.setString('genero_pref', _genderPref);

    // Guardar en backend (solo si es API real)
    final api = ApiManager.getInstance(email: email);
    await api.registerUser(
      email: email,
      username: username,
      edad: edad,
      genero_pref: _genderPref,
    );

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => HomeScreen()),
    );
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
                // Imagen centrada
                Image.asset(
                  'assets/logo_reverie_text.png', 
                  width: 200,
                  height: 100,
                  fit: BoxFit.contain,
                ),

                
                SizedBox(height: 30),

                // Nombre de usuario
                SizedBox(
                  width: 300,
                  child: TextFormField(
                    controller: _usernameController,
                    decoration: InputDecoration(
                      labelText: 'Nombre de usuario',
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) => value == null || value.isEmpty ? 'Introduce un nombre' : null,
                  ),
                ),
                
                SizedBox(height: 30), 
                
                // Edad
                SizedBox(
                  width: 300,
                  child: TextFormField(
                    controller: _ageController,
                    decoration: InputDecoration(
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
                
                SizedBox(height: 40), 
                
                // Preferencia de ropa
                Column(
                  children: [
                    Text('Prefieres ropa de:', style: TextStyle(fontSize: 16)),
                    SizedBox(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        _buildGenderOption('Mujer'),
                        SizedBox(width: 30),
                        _buildGenderOption('Hombre'),
                        SizedBox(width: 30),
                        _buildGenderOption('Ambos'),
                      ],
                    ),
                  ],
                ),
                
                SizedBox(height: 50), 
                
                // Botón de enviar
                ElevatedButton(
                  onPressed: _submit,
                  child: Text('Empezar', style: TextStyle(fontSize: 16)),
                  style: ElevatedButton.styleFrom(
                    padding: EdgeInsets.symmetric(horizontal: 40, vertical: 15),
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
          SizedBox(height: 5),
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