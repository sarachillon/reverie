import 'package:flutter/material.dart';
import 'package:frontend/screens/armarioVirtual/articulo_propio_widget.dart';
import 'package:frontend/screens/armarioVirtual/pantalla_ver_todos.dart';
import 'package:frontend/screens/armarioVirtual/subir_foto_screen.dart';
import 'package:frontend/services/api_manager.dart';

class ArmarioScreen extends StatefulWidget {
  const ArmarioScreen({super.key});

  @override
  State<ArmarioScreen> createState() => _ArmarioScreenState();
}

class _ArmarioScreenState extends State<ArmarioScreen> {
  final ApiManager _apiManager = ApiManager();
  final List<dynamic> _articulos = [];

  @override
  void initState() {
    super.initState();
    _cargarArticulosPropios();
  }

  Future<void> _cargarArticulosPropios() async {
    setState(() => _articulos.clear());
    try {
      final stream = _apiManager.getArticulosPropiosStream();
      await for (final articulo in stream) {
        if (!mounted) return;
        setState(() => _articulos.add(articulo));
      }
    } catch (e) {
      print("Error al cargar artículos propios: $e");
    }
  }

  Widget _buildCategoriaHorizontal(String categoria, List<dynamic> articulos) {
    final articulosCategoria = articulos
        .where((a) => (a['categoria'] ?? '').toString().toUpperCase() == categoria)
        .toList();

    if (articulosCategoria.isEmpty) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                categoria[0] + categoria.substring(1).toLowerCase(),
                style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
              ),
              const Spacer(),
              GestureDetector(
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => PantallaVerTodos(categoria: categoria),
                  ),
                ),
                child: Row(
                  children: const [
                    Text("Ver todos", style: TextStyle(fontSize: 12, color: Colors.grey)),
                    SizedBox(width: 4),
                    Icon(Icons.arrow_forward_ios_rounded, size: 12, color: Colors.grey),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          SizedBox(
            height: 190,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 4),
              itemCount: articulosCategoria.length,
              separatorBuilder: (_, __) => const SizedBox(width: 12),
              itemBuilder: (context, index) {
                final articulo = articulosCategoria[index];
                return SizedBox(
                  width: 150,
                  child: ArticuloPropioWidget(
                    nombre: articulo['nombre'] ?? '',
                    articulo: articulo,
                    onTap: _cargarArticulosPropios,
                    
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: RefreshIndicator(
        onRefresh: _cargarArticulosPropios,
        child: _articulos.isEmpty
            ? const Center(child: Text('No se encontraron artículos.'))
            : ListView(
                children: [
                  _buildCategoriaHorizontal('ROPA', _articulos),
                  _buildCategoriaHorizontal('CALZADO', _articulos),
                  _buildCategoriaHorizontal('ACCESORIOS', _articulos),
                  const SizedBox(height: 80),
                ],
              ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          showModalBottomSheet(
            context: context,
            shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
            ),
            builder: (BuildContext context) {
              return SafeArea(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    ListTile(
                      leading: const Icon(Icons.camera_alt),
                      title: const Text('Subir prenda'),
                      onTap: () async {
                        Navigator.pop(context);
                        final result = await Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => const SubirFotoScreen()),
                        );
                        if (result == true) {
                          _cargarArticulosPropios();
                        }
                      },
                    ),
                  ],
                ),
              );
            },
          );
        },
        child: const Icon(Icons.add),
        tooltip: 'Añadir prenda',
      ),
    );
  }
}
