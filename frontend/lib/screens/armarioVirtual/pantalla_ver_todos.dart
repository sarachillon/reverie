import 'package:flutter/material.dart';
import 'package:frontend/screens/armarioVirtual/articulo_propio_resumen.dart';
import 'package:frontend/screens/armarioVirtual/filtros_articulo_propio_screen.dart';
import 'package:frontend/screens/armarioVirtual/subir_foto_screen.dart';
import 'package:frontend/services/api_manager.dart';

class PantallaVerTodos extends StatefulWidget {
  final String categoria;
  final VoidCallback? onContenidoActualizado;

  const PantallaVerTodos({
    super.key,
    required this.categoria,
    this.onContenidoActualizado,
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

  void _abrirFiltros() async {
    final nuevosFiltros = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => FiltrosArticuloPropioScreen(
          filtrosIniciales: filtros,
          onAplicar: (nuevosFiltros) {
            setState(() {
              filtros = nuevosFiltros;
              //_mostrarFiltros = true;
            });
            _cargarArticulos();
          },
          onCerrar: () {
            setState(() {
              //_mostrarFiltros = false;
            });
          },
        ),
      ),
    );

    if (nuevosFiltros != null) {
      setState(() {
        filtros = nuevosFiltros;
      });
      _cargarArticulos();
    }
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
        title: Text(widget.categoria),
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: _abrirFiltros,
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12),
            child: TextField(
              controller: _searchController,
              onChanged: (value) {
                setState(() {
                  _busqueda = value;
                  _isSearching = value.isNotEmpty;
                });
              },
              decoration: InputDecoration(
                hintText: 'Buscar por nombre',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _isSearching
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          setState(() {
                            _searchController.clear();
                            _busqueda = '';
                            _isSearching = false;
                          });
                        },
                      )
                    : null,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
              ),
            ),
          ),
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
                        usuarioActual: usuarioActual,
                        onActualizado: _cargarArticulos,
                      );
                    },
                  ),
          ),
        ],
      ),
      floatingActionButton: usuarioActual != null
          ? FloatingActionButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const SubirFotoScreen()),
                );
              },
              child: const Icon(Icons.add),
            )
          : null,
    );
  }
}
