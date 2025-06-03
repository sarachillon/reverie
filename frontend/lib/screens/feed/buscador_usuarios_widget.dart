import 'package:flutter/material.dart';
import 'dart:convert';

import 'package:frontend/services/api_manager.dart';

class BuscadorUsuariosWidget extends StatefulWidget {
  final void Function(Map<String, dynamic> usuario) onUsuarioTap;
  const BuscadorUsuariosWidget({super.key, required this.onUsuarioTap});

  @override
  State<BuscadorUsuariosWidget> createState() => _BuscadorUsuariosWidgetState();
}

class _BuscadorUsuariosWidgetState extends State<BuscadorUsuariosWidget> {
  final TextEditingController _searchController = TextEditingController();
  final ApiManager _apiManager = ApiManager();

  List<Map<String, dynamic>> _usuarios = [];
  String _busqueda = '';
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _cargarUsuarios();
  }

  Future<void> _cargarUsuarios() async {
    setState(() => _loading = true);
    final data = await _apiManager.getAllUsers();
    setState(() {
      _usuarios = data;
      _loading = false;
    });
  }

  List<Map<String, dynamic>> get _filtrados {
    if (_busqueda.isEmpty) return _usuarios;
    return _usuarios.where((u) =>
        (u['username'] ?? '').toLowerCase().contains(_busqueda.toLowerCase())
    ).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(64),
        child: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          centerTitle: true,
          automaticallyImplyLeading: false,
          title: const Text('Buscar usuarios', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
          actions: [
            IconButton(
              icon: const Icon(Icons.close, color: Color(0xFFD4AF37)),
              onPressed: () => Navigator.of(context).pop(),
              tooltip: "Cerrar",
            ),
          ],
          bottom: PreferredSize(
            preferredSize: const Size.fromHeight(56),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  hintText: "Buscar usuario...",
                  prefixIcon: const Icon(Icons.search),
                  fillColor: Colors.grey[100],
                  filled: true,
                  contentPadding: const EdgeInsets.symmetric(vertical: 0, horizontal: 8),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                ),
                onChanged: (value) => setState(() => _busqueda = value),
              ),
            ),
          ),
        ),
      ),
      body: _loading
        ? const Center(child: CircularProgressIndicator())
        : _filtrados.isEmpty
            ? const Center(child: Text("No se encontraron usuarios"))
            : ListView.builder(
                padding: const EdgeInsets.symmetric(vertical: 8),
                itemCount: _filtrados.length,
                itemBuilder: (context, idx) {
                  final usuario = _filtrados[idx];
                  return InkWell(
                    borderRadius: BorderRadius.circular(12),
                    onTap: () => widget.onUsuarioTap(usuario),
                    child: Container(
                      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.04),
                            blurRadius: 5,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Row(
                        children: [
                          usuario['foto_perfil'] != null && usuario['foto_perfil'] != ""
                            ? CircleAvatar(
                                radius: 24,
                                backgroundImage: MemoryImage(base64Decode(usuario['foto_perfil'])),
                              )
                            : const CircleAvatar(
                                radius: 24,
                                child: Icon(Icons.person),
                              ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              usuario['username'] ?? '',
                              style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
    );
  }
}
