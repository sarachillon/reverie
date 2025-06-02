import 'package:flutter/material.dart';
import 'package:frontend/screens/armarioVirtual/articulo_propio_resumen.dart';
import 'package:frontend/screens/armarioVirtual/filtros_articulo_propio_screen.dart';
import 'package:frontend/screens/armarioVirtual/subir_foto_screen.dart';
import 'package:frontend/services/api_manager.dart';
import 'package:google_fonts/google_fonts.dart';

class PantallaVerTodos extends StatefulWidget {
  final String categoria;
  final VoidCallback? onContenidoActualizado;
  final int? usuario_id;

  const PantallaVerTodos({
    super.key,
    required this.categoria,
    this.onContenidoActualizado,
    this.usuario_id,
  });

  @override
  State<PantallaVerTodos> createState() => _PantallaVerTodosState();
}

class _PantallaVerTodosState extends State<PantallaVerTodos> {
  final ApiManager _apiManager = ApiManager();
  final List<dynamic> _articulos = [];
  final TextEditingController _searchController = TextEditingController();
  Map<String, dynamic> filtros = {};
  //bool _mostrarFiltros = false;
  bool _isSearching = false;
  String _busqueda = '';
  Map<String, dynamic>? usuarioActual;

  @override
  void initState() {
    super.initState();
    _cargarArticulos();
    _getUsuarioActual();
  }


String get _tituloImagen {
  switch (widget.categoria.toUpperCase()) {
    case 'ROPA':
      return 'Ropa';
    case 'CALZADO':
      return 'Calzado';
    case 'ACCESORIOS':
      return 'Accesorios';
    default:
      return 'Artículos';
  }
}


  Future<void> _getUsuarioActual() async {
    final actual = await _apiManager.getUsuarioActual();
    setState(() => usuarioActual = actual);
  }

  Future<void> _cargarArticulos() async {
    setState(() {
      _articulos.clear();
    });

    final filtrosConCategoria = {
      ...filtros,
      'categoria': widget.categoria,
      'usuario_id': widget.usuario_id,
    };

    final stream = _apiManager.getArticulosPropiosStream(filtros: filtrosConCategoria);
    await for (final articulo in stream) {
      if (!mounted) return;
      setState(() {
        _articulos.add(articulo);
      });
    }

    widget.onContenidoActualizado?.call();
  }


  List<dynamic> _filtrarPorBusqueda() {
    if (_busqueda.isEmpty) return _articulos;
    return _articulos
        .where((a) => (a['nombre'] ?? '').toLowerCase().contains(_busqueda.toLowerCase()))
        .toList();
  }


@override
Widget build(BuildContext context) {
  final articulosFiltrados = _filtrarPorBusqueda();

  return Scaffold(
    appBar: AppBar(
      centerTitle: true,
      title: _isSearching
          ? TextField(
              controller: _searchController,
              autofocus: true,
              onChanged: (value) => setState(() => _busqueda = value),
              style: const TextStyle(color: Colors.black),
              decoration: const InputDecoration(
                hintText: 'Buscar por nombre...',
                border: InputBorder.none,
              ),
            )
          :Text(
              '${_tituloImagen}',
              style: GoogleFonts.dancingScript(
                fontSize: 30,
                color: Color(0xFFD4AF37),
                fontWeight: FontWeight.w600,
              ),
            ),
      actions: [
        IconButton(
          icon: Icon(_isSearching ? Icons.close : Icons.search, color: const Color(0xFFD4AF37)),
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
    ),
      body: Column(
        children: [
          
          Expanded(
            child: articulosFiltrados.isEmpty
                ? const Center(child: Text('No se encontraron artículos.'))
                : ListView.separated(
                    padding: const EdgeInsets.all(12),
                    itemCount: articulosFiltrados.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 12),
                    itemBuilder: (context, index) {
                      final articulo = articulosFiltrados[index];
                      return ArticuloPropioResumen(
                        articulo: articulo,
                        onActualizado: _cargarArticulos,
                        usuarioActual_id: usuarioActual?['id'],
                      );
                    },
                  ),
          ),
        ],
      ),
      floatingActionButton: usuarioActual != null
    ? FloatingActionButton(
        onPressed: () async {
          final resultado = await Navigator.push<bool>(
            context,
            MaterialPageRoute(builder: (_) => const SubirFotoScreen()),
          );
          if (resultado == true) {
            // recarga esta pantalla
            await _cargarArticulos();
            // notifica al padre (PerfilScreen) para recargar todo
            widget.onContenidoActualizado?.call();
          }
        },
        child: const Icon(Icons.add),
      )
    : null,

    );
  }
}
