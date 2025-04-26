import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:shared_preferences/shared_preferences.dart';

class GoogleSignInService with ChangeNotifier {
  static final GoogleSignIn _googleSignIn = GoogleSignIn(
    scopes: ['email'],
  );

  bool _isLoggedIn = false;
  String? _userId;

  bool get isLoggedIn => _isLoggedIn;
  String? get userId => _userId;

  Future<void> setUserData(bool isLoggedIn, String? userId) async {
    _isLoggedIn = isLoggedIn;
    _userId = userId;

    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isLoggedIn', isLoggedIn);
    if (userId != null) await prefs.setString('userId', userId);

    notifyListeners();
  }

  // Función para obtener el token de acceso
  Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('accessToken'); // Retorna el token almacenado
  }

  /// Inicia sesión con Google y devuelve el email si tuvo éxito
  Future<String?> signInWithGoogle() async {
    try {
      final user = await _googleSignIn.signIn();
      if (user != null) {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('email', user.email); // Guarda el email
        _isLoggedIn = true;
        _userId = user.id;
        notifyListeners();
        return user.email;
      } else {
        print("Inicio de sesión cancelado por el usuario.");
        return null;
      }
    } catch (e) {
      print("Error durante el inicio de sesión con Google: $e");
      return null;
    }
  }

  Future<void> logout() async {
    try {
      await _googleSignIn.signOut();
      final prefs = await SharedPreferences.getInstance();
      await prefs.clear(); // Limpia todo al cerrar sesión
      _isLoggedIn = false;
      _userId = null;
      notifyListeners();
    } catch (e) {
      print("Error al cerrar sesión: $e");
    }
  }
}
