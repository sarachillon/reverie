import 'package:flutter/material.dart';
import 'package:frontend/screens/launcher_screen.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/api_manager.dart';
import 'auth_screen.dart';
import 'colecciones_screen.dart';
import 'buscador_screen.dart';
import 'armarioVirtual/armario_screen.dart';
import 'outfits_screen.dart';

class HomeScreen extends StatefulWidget {
  final String? userEmail;

  const HomeScreen({Key? key, this.userEmail}) : super(key: key);

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;

  final List<Widget> _screens = [
    ColeccionesScreen(),
    BuscadorScreen(),
    ArmarioScreen(),
    OutfitsScreen(),
  ];

  Future<void> _logout() async {
    final GoogleSignIn _googleSignIn = GoogleSignIn();
    await _googleSignIn.signOut();

    final prefs = await SharedPreferences.getInstance();
    await prefs.clear(); 
    ApiManager.reset();

    if (mounted) {
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => const AuthScreen()),
        (route) => false,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Reverie'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: _logout,
            tooltip: 'Cerrar sesión',
          )
        ],
      ),
      body: _screens[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: (index) => setState(() => _selectedIndex = index),
        selectedItemColor: const Color(0xFFC9A86A),
        unselectedItemColor: Colors.grey,
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.collections_bookmark),
            label: 'Colecciones',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.search),
            label: 'Buscador',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.checkroom),
            label: 'Armario',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.style),
            label: 'Outfits',
          ),
        ],
      ),
    );
  }
}
