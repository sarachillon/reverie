import 'package:flutter/material.dart';
import 'package:frontend/screens/armarioVirtual/armario_screen.dart';
import 'package:frontend/screens/outfits/outfits_screen.dart';
import 'package:frontend/services/api_manager.dart';

class PerfilScreen extends StatefulWidget {
  const PerfilScreen({super.key});

  @override
  State<PerfilScreen> createState() => _PerfilScreenState();
}

class _PerfilScreenState extends State<PerfilScreen> {
  final ApiManager _apiManager = ApiManager();
  Map<String, dynamic>? usuario;

  @override
  void initState() {
    super.initState();
    _cargarPerfil();
  }

  Future<void> _cargarPerfil() async {
    final data = await _apiManager.getUsuarioActual(); // Implementa este método
    setState(() => usuario = data);
  }

  @override
  Widget build(BuildContext context) {
    if (usuario == null) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Perfil'),
          centerTitle: true,
          bottom: const TabBar(
            tabs: [
              Tab(icon: Icon(Icons.checkroom), text: 'Armario'),
              Tab(icon: Icon(Icons.style), text: 'Outfits'),
            ],
          ),
        ),
        body: Column(
          children: [
            const SizedBox(height: 20),
            CircleAvatar(
              radius: 50,
              child: const Icon(Icons.person, size: 50),
            ),
            const SizedBox(height: 10),
            Text(usuario!['username'], style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
            Text(usuario!['email'], style: const TextStyle(color: Colors.grey)),
            const Divider(),
            Expanded(
              child: TabBarView(
                children: [
                  ArmarioScreen(),
                  OutfitsScreen(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
