import 'package:flutter/material.dart';
import 'package:frontend/screens/armarioVirtual/articulo_propio_widget.dart';
import 'package:frontend/screens/armarioVirtual/filtros_articulo_propio_screen.dart';
import 'package:frontend/screens/armarioVirtual/subir_foto_screen.dart';
import 'package:frontend/services/api_manager.dart';
import 'package:frontend/screens/armarioVirtual/articulo_propio_resumen.dart';

class PantallaVerTodos extends StatefulWidget {
  final String categoria;

  const PantallaVerTodos({super.key, required this.categoria});

  @override
  State<PantallaVerTodos> createState() => _PantallaVerTodosState();
}

class _PantallaVerTodosState extends State<PantallaVerTodos> {
  final ApiManager _apiManager = ApiManager();
  final List<dynamic> _articulos = [];
  final TextEditingController _searchController = TextEditingController();
  Map<String, dynamic> filtros = {};
  bool _mostrarFiltros = false;
  bool _isSearching = false;
  String _busqueda = '';
  Map<String, dynamic>? usuarioActual;
  bool _loading = true;



  @override
  void initState() {
    super.initState();
    _inicializar();
  }

Future<void> _inicializar() async {
  usuarioActual = await _apiManager.getUsuarioActual();
  await _cargarArticulos();
  if (mounted) setState(() => _loading = false);
}


Future<void> _cargarArticulos() async {
  setState(() => _articulos.clear());
  try {
    final stream = _apiManager.getArticulosPropiosStream(filtros: filtros);
    await for (final articulo in stream) {
      if (!mounted) return;
      if ((articulo['categoria'] ?? '').toString().toUpperCase() == widget.categoria.toUpperCase()) {
        setState(() => _articulos.add(articulo));
      }
    }
  } catch (e) {
    print("Error al cargar artículos: $e");
  }
}


  void _cerrarFiltros() {
    setState(() => _mostrarFiltros = false);
  }

  @override
  Widget build(BuildContext context) {


 


    final articulosFiltrados = _articulos.where((articulo) {
      final nombre = (articulo['nombre'] ?? '').toString().toLowerCase();
      return nombre.contains(_busqueda.toLowerCase());
    }).toList();

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
                  hintText: 'Buscar...',
                  border: InputBorder.none,
                ),
              )
            : Image.asset(
                'assets/titulos/${widget.categoria.toUpperCase() == 'ROPA' ? 'ropa' : widget.categoria.toUpperCase() == 'CALZADO' ? 'calzado' : 'accesorios'}.png',
                height: 30,
              ),
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
          IconButton(
            icon: Icon(
              _mostrarFiltros ? Icons.close : Icons.filter_alt,
              color: const Color(0xFFD4AF37),
            ),
            onPressed: () {
              setState(() => _mostrarFiltros = !_mostrarFiltros);
            },
          ),
        ],
      ),
      body: Stack(
  children: [
    articulosFiltrados.isEmpty
        ? const Center(
            child: Text(
              'No hay artículos de este tipo',
              style: TextStyle(fontSize: 16, color: Colors.grey),
            ),
          )
        : GridView.builder(
            padding: const EdgeInsets.all(12),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 1,
              crossAxisSpacing: 30,
              mainAxisSpacing: 30,
              childAspectRatio: 3,
            ),
            itemCount: articulosFiltrados.length,
            itemBuilder: (context, index) {
              final articulo = articulosFiltrados[index];
              return ArticuloPropioResumen(
                articulo: articulo,
                usuarioActual: usuarioActual!,
              );
            },
          ),
    AnimatedPositioned(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
      top: 0,
      right: _mostrarFiltros ? 0 : -MediaQuery.of(context).size.width * 0.8,
      bottom: 0,
      width: MediaQuery.of(context).size.width * 0.8,
      child: Material(
        elevation: 16,
        child: FiltrosArticuloPropioScreen(
          filtrosIniciales: filtros,
          onAplicar: (nuevosFiltros) {
            setState(() {
              filtros = nuevosFiltros;
              _mostrarFiltros = false;
            });
            _cargarArticulos();
          },
          onCerrar: _cerrarFiltros,
        ),
      ),
    ),
  ],
),

    );
  }
}
