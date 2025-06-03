import 'package:flutter/material.dart';
import 'package:frontend/screens/armarioVirtual/armario_screen.dart';
import 'package:frontend/screens/perfil/perfil_screen.dart';
import 'dart:convert';
import 'package:frontend/services/api_manager.dart';


class SeguidoresSeguidosScreen extends StatefulWidget {
  final int userId;
  const SeguidoresSeguidosScreen({super.key, required this.userId});



  @override
  State<SeguidoresSeguidosScreen> createState() => _SeguidoresSeguidosScreenState();
}

class _SeguidoresSeguidosScreenState extends State<SeguidoresSeguidosScreen>
    with SingleTickerProviderStateMixin {

  final GlobalKey<ArmarioScreenState> armarioKey = GlobalKey<ArmarioScreenState>();
  final ApiManager _apiManager = ApiManager();
  final TextEditingController _searchController = TextEditingController();
  bool _isSearching = false;
  String _busqueda = '';

  List<Map<String, dynamic>> _seguidores = [];
  List<Map<String, dynamic>> _seguidos = [];
  int? _currentUserId;

  @override
  void initState() {
    super.initState();
    _cargarUsuarios();
  }

  Future<void> _cargarUsuarios() async {
    final seguidores = await _apiManager.obtenerSeguidores(widget.userId);
    final seguidos = await _apiManager.obtenerSeguidos(widget.userId);
    final yo = await _apiManager.getUsuarioActual();
    setState(() {
      _seguidores = seguidores;
      _seguidos = seguidos;
      _currentUserId = yo['id'];
    });
  }

  Future<void> _toggleSeguir(int idUsuario, bool siguiendo) async {
    if (siguiendo) {
      await _apiManager.dejarDeSeguirUsuario(idUsuario);
    } else {
      await _apiManager.seguirUsuario(idUsuario);
    }
    _cargarUsuarios();
  }

  Widget _buildUsuarioItem(Map<String, dynamic> usuario, bool siguiendo) {
  final esActual = usuario['id'] == _currentUserId;
  return GestureDetector(
    onTap: () {
      Navigator.of(context).push(MaterialPageRoute(
        builder: (context) => PerfilScreen(userId: usuario['id'], armarioKey: armarioKey,),
      ));
    },
    child: Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 5,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        children: [
          usuario['foto_perfil'] != null
              ? CircleAvatar(
                  radius: 24,
                  backgroundImage: MemoryImage(
                    base64Decode(usuario['foto_perfil']),
                  ),
                )
              : const CircleAvatar(
                  radius: 24,
                  child: Icon(Icons.person),
                ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              usuario['username'] ?? '',
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
            ),
          ),
          if (!esActual)
            GestureDetector(
              onTap: () => _toggleSeguir(usuario['id'], siguiendo),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                decoration: BoxDecoration(
                  color: siguiendo ? Colors.grey.shade300 : Colors.blue,
                  borderRadius: BorderRadius.circular(6),
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
  );
}


  List<Map<String, dynamic>> _filtrar(List<Map<String, dynamic>> lista) {
    if (_busqueda.isEmpty) return lista;
    return lista
        .where((u) => (u['username'] ?? '')
            .toLowerCase()
            .contains(_busqueda.toLowerCase()))
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Color(0xFFD4AF37)),
            onPressed: () => Navigator.pop(context),
          ),
          centerTitle: true,
          title: _isSearching
              ? TextField(
                  controller: _searchController,
                  autofocus: true,
                  onChanged: (value) => setState(() => _busqueda = value),
                  style: const TextStyle(color: Colors.black),
                  decoration: const InputDecoration(
                    hintText: 'Buscar...',
                    border: InputBorder.none,
                  ),
                )
              : Image.asset('assets/logo_reverie_text.png', height: 30),
          actions: [
            IconButton(
              icon: Icon(
                _isSearching ? Icons.close : Icons.search,
                color: const Color(0xFFD4AF37),
              ),
              onPressed: () {
                setState(() {
                  _isSearching = !_isSearching;
                  if (!_isSearching) {
                    _searchController.clear();
                    _busqueda = '';
                  }
                });
              },
            ),
          ],
          bottom: const TabBar(
            tabs: [
              Tab(text: 'Seguidores'),
              Tab(text: 'Seguidos'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            _buildLista(_filtrar(_seguidores), 'No tienes seguidores'),
            _buildLista(_filtrar(_seguidos), 'No hay usuarios seguidos'),
          ],
        ),
      ),
    );
  }

  Widget _buildLista(List<Map<String, dynamic>> usuarios, String mensajeVacio) {
    if (usuarios.isEmpty) {
      return Center(child: Text(mensajeVacio));
    }
    return ListView.builder(
      itemCount: usuarios.length,
      itemBuilder: (context, index) {
        final usuario = usuarios[index];
        // El usuario está seguido SI aparece en la lista de seguidos DEL USUARIO ACTUAL, no del perfil mostrado
        final siguiendo = _seguidos.any((u) => u['id'] == usuario['id'] && _currentUserId != usuario['id']);
        return _buildUsuarioItem(usuario, siguiendo);
      },
    );
  }
}
