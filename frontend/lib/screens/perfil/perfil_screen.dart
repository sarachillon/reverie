import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:frontend/screens/armarioVirtual/armario_screen.dart';
import 'package:frontend/screens/perfil/mostrar_outfits_screen.dart';
import 'package:frontend/services/api_manager.dart';
import 'package:frontend/screens/perfil/editar_perfil_screen.dart';
import 'package:frontend/screens/perfil/seguidores_seguidos_screen.dart';
import 'package:frontend/screens/launcher_screen.dart';
import 'package:frontend/services/google_sign_in_service.dart';
import 'package:shared_preferences/shared_preferences.dart';


class PerfilScreen extends StatefulWidget {
  final int? userId;
  final GlobalKey<ArmarioScreenState> armarioKey;
  const PerfilScreen({
    Key? key,
    this.userId,
    required this.armarioKey,
  }) : super(key: key);

  @override
  State<PerfilScreen> createState() => _PerfilScreenState();
}

class _PerfilScreenState extends State<PerfilScreen> {
  final ApiManager _apiManager = ApiManager();
  Map<String, dynamic>? usuario;
  Map<String, dynamic>? usuarioActual;
  bool siguiendo = false;
  bool esPropioPerfil = true;
  int numArticulos = 0;
  int numOutfits = 0;
  int numSeguidos = 0;
  int numSeguidores = 0;

  @override
  void initState() {
    super.initState();
    _cargarPerfil();
  }

  @override
  void didUpdateWidget(covariant PerfilScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    _cargarPerfil();
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

  Future<void> _cargarPerfil() async {
    final actual = await _apiManager.getUsuarioActual();
    final token = await GoogleSignInService().getToken();
    print("Token de usuario actual: $token");
    setState(() => usuarioActual = actual);

    Map<String, dynamic> usuarioPerfil;
    bool esPropio = true;

    if (widget.userId != null && widget.userId != actual['id']) {
      usuarioPerfil = await _apiManager.getUserById(id: widget.userId!);
      esPropio = false;
      final seguidos = await _apiManager.obtenerSeguidos(actual['id']);
      siguiendo = seguidos.any((u) => u['id'] == usuarioPerfil['id']);
    } else {
      usuarioPerfil = actual;
    }

    final List<dynamic> resultados = await Future.wait([
      _apiManager.getNumeroArticulos(usuarioId: usuarioPerfil['id']),
      _apiManager.getNumeroOutfits(usuarioId: usuarioPerfil['id']),
      _apiManager.obtenerSeguidos(usuarioPerfil['id']),
      _apiManager.obtenerSeguidores(usuarioPerfil['id']),
    ]);

    setState(() {
      usuario = usuarioPerfil;
      esPropioPerfil = esPropio;
      numArticulos = resultados[0] as int;
      numOutfits = resultados[1] as int;
      numSeguidos = (resultados[2] as List).length;
      numSeguidores = (resultados[3] as List).length;
    });
  }

  Future<void> _toggleSeguir() async {
    if (usuario == null) return;
    if (siguiendo) {
      await _apiManager.dejarDeSeguirUsuario(usuario!['id']);
      numSeguidores -= 1;
    } else {
      await _apiManager.seguirUsuario(usuario!['id']);
      numSeguidores += 1;
    }
    setState(() => siguiendo = !siguiendo);
  }

  void _actualizarContadoresDesdeTab() {
    if (esPropioPerfil) _cargarPerfil();
  }

@override
Widget build(BuildContext context) {
  if (usuario == null) {
    return const Scaffold(
      body: Center(child: CircularProgressIndicator()),
    );
  }

  if (esPropioPerfil) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 1,
        centerTitle: true,
        title: Image.asset('assets/logo_reverie_text.png', height: 35),
        actions: [
          IconButton(
            icon: const Icon(Icons.mode_edit_sharp, color: Color(0xFFD4AF37)),
            onPressed: () async {
              final actualizado = await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => EditarPerfilScreen(usuario: usuario!),
                ),
              );
              if (actualizado == true) {
                _cargarPerfil();
              }
            },
          ),
          IconButton(
            icon: const Icon(Icons.logout_outlined, color: Color(0xFFD4AF37)),
            onPressed: _logout,
          ),
        ],
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 20),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                usuario!['foto_perfil'] != null
                    ? CircleAvatar(
                        radius: 40,
                        backgroundImage: MemoryImage(base64Decode(usuario!['foto_perfil'])),
                      )
                    : const CircleAvatar(
                        radius: 40,
                        child: Icon(Icons.person, size: 40),
                      ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            usuario!['username'] ?? '',
                            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                          ),
                          Row(
                            children: [
                              _buildStatItem('Seguidores', numSeguidores, () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => SeguidoresSeguidosScreen(userId: usuario!['id']),
                                  ),
                                );
                              }),
                              const SizedBox(width: 12),
                              _buildStatItem('Seguidos', numSeguidos, () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => SeguidoresSeguidosScreen(userId: usuario!['id']),
                                  ),
                                );
                              }),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),
          Expanded(
            child: ArmarioScreen(
              key: widget.armarioKey,
              userId: usuario!['id'],
              onContenidoActualizado: _actualizarContadoresDesdeTab,
            ),
          ),
        ],
      ),
    );
  }

  // Si es otro usuario, muestra TabBar con ambos tabs
  return DefaultTabController(
    length: 2,
    child: Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 1,
        centerTitle: true,
        title: Image.asset('assets/logo_reverie_text.png', height: 35),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 20),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                usuario!['foto_perfil'] != null
                    ? CircleAvatar(
                        radius: 40,
                        backgroundImage: MemoryImage(base64Decode(usuario!['foto_perfil'])),
                      )
                    : const CircleAvatar(
                        radius: 40,
                        child: Icon(Icons.person, size: 40),
                      ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            usuario!['username'] ?? '',
                            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                          ),
                          Row(
                            children: [
                              _buildStatItem('Seguidores', numSeguidores, () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => SeguidoresSeguidosScreen(userId: usuario!['id']),
                                  ),
                                );
                              }),
                              const SizedBox(width: 12),
                              _buildStatItem('Seguidos', numSeguidos, () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => SeguidoresSeguidosScreen(userId: usuario!['id']),
                                  ),
                                );
                              }),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      // Botón seguir/no seguir solo si no es tu perfil
                      GestureDetector(
                        onTap: _toggleSeguir,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          decoration: BoxDecoration(
                            color: siguiendo ? Colors.grey.shade300 : Colors.blue,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            siguiendo ? 'Siguiendo' : 'Seguir',
                            style: TextStyle(
                              color: siguiendo ? Colors.black : Colors.white,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),
          TabBar(
            tabs: [
              Tab(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.door_sliding_outlined),
                    const SizedBox(width: 6),
                    Text('$numArticulos Prendas', style: const TextStyle(fontSize: 12)),
                  ],
                ),
              ),
              Tab(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.checkroom_outlined),
                    const SizedBox(width: 6),
                    Text('$numOutfits Outfits', style: const TextStyle(fontSize: 12)),
                  ],
                ),
              ),
            ],
          ),
          Expanded(
            child: TabBarView(
              children: [
                ArmarioScreen(
                  key: widget.armarioKey,
                  userId: usuario!['id'],
                  onContenidoActualizado: _actualizarContadoresDesdeTab,
                ),
                MostrarOutfitScreen(userId: usuario!['id']),
              ],
            ),
          ),
        ],
      ),
    ),
  );
}



  Widget _buildStatItem(String label, int count, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text('$count', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          Text(label, style: const TextStyle(fontSize: 12)),
        ],
      ),
    );
  }
}
