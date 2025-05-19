import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/api_manager.dart';
import 'launcher_screen.dart';
import 'feed/feed_screen.dart';
import 'perfil/perfil_screen.dart';
import 'outfits/outfits_screen.dart';
import '../services/google_sign_in_service.dart';
import 'armarioVirtual/subir_foto_screen.dart';
import 'outfits/laboratorio_outfit_screen.dart';
import 'dart:convert';

class HomeScreen extends StatefulWidget {
  final String? userEmail;


  const HomeScreen({Key? key, this.userEmail}) : super(key: key);

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 1; 
  String? profileImageUrl;
  String? username;


  final List<Widget> _screens = [
    OutfitsScreen(),
    FeedScreen(),
    Container(), 
    LaboratorioOutfitScreen(),
    PerfilScreen(),
  ];

  @override
  void initState() {
    super.initState();
    _loadProfileImage();
  }

Future<void> _loadProfileImage() async {
  final user = await ApiManager().getUsuarioActual();
  setState(() {
    profileImageUrl = user['foto_perfil'];
    username = user['username'];
  });
}




  void _onAddPressed() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildAddOption(
                icon: Icons.checkroom,
                text: "Nuevo artículo",
                onTap: () async {
                  Navigator.pop(context);
                  final result = await Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const SubirFotoScreen()),
                  );
                  if (result == true) {
                    setState(() => _selectedIndex = 3); 
                  }
                },
              ),
              const SizedBox(height: 16),
              _buildAddOption(
                icon: Icons.auto_awesome,
                text: "Nuevo outfit",
                onTap: () async {
                  Navigator.pop(context);
                  await OutfitsScreen.crearNuevoOutfit(context);
                  setState(() => _selectedIndex = 0);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildAddOption({
    required IconData icon,
    required String text,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: const [
            BoxShadow(color: Colors.black12, blurRadius: 4, offset: Offset(0, 2)),
          ],
        ),
        child: Row(
          children: [
            Icon(icon, color: const Color(0xFFC9A86A), size: 28),
            const SizedBox(width: 16),
            Text(
              text,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _logout() async {
    final googleSignInService = GoogleSignInService();
    await googleSignInService.logout();

    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    ApiManager.reset();

    if (mounted) {
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => const LauncherScreen()),
        (route) => false,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_selectedIndex == 2 ? 1 : _selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex == 2 ? 1 : _selectedIndex,
        onTap: (index) {
          if (index == 2) {
            _onAddPressed();
          } else {
            setState(() => _selectedIndex = index);
          }
        },
        showSelectedLabels: true,
        showUnselectedLabels: false,
        selectedItemColor: const Color(0xFFC9A86A),
        unselectedItemColor: Colors.grey,
        selectedFontSize: 14,
        unselectedFontSize: 12,
        selectedLabelStyle: const TextStyle(fontWeight: FontWeight.bold),
        unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.bold),
        type: BottomNavigationBarType.fixed,
        items: [
          const BottomNavigationBarItem(
            icon: Icon(Icons.checkroom_outlined),
            label: 'Outfits',
          ),
          const BottomNavigationBarItem(
            icon: Icon(Icons.search_outlined),
            label: 'Feed',
          ),
          const BottomNavigationBarItem(
            icon: Icon(Icons.add_circle_rounded, size: 30),
            label: 'Nuevo',
          ),
          const BottomNavigationBarItem(
            icon: Icon(Icons.science_outlined),
            label: 'Laboratorio',
          ),
          BottomNavigationBarItem(
            icon: profileImageUrl != null && profileImageUrl!.isNotEmpty
                ? CircleAvatar(
                    radius: 12,
                    backgroundImage: MemoryImage(base64Decode(profileImageUrl!)),
                    backgroundColor: Colors.transparent,
                  )
                : const Icon(Icons.person),
            label: username,
          ),
        ],
      ),
    );
  }
}
