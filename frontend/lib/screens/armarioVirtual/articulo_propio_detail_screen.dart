import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:frontend/enums/enums.dart';
import 'package:frontend/screens/armarioVirtual/formulario_articulo_screen.dart';
import 'package:frontend/services/api_manager.dart';


class ArticuloPropioDetailScreen extends StatelessWidget {
  final dynamic articulo;
  final ApiManager _apiManager = ApiManager();


  ArticuloPropioDetailScreen({super.key, required this.articulo});

  Future<void> eliminarArticulo(int id) async {
    try {
      await _apiManager.deleteArticuloPropio(id: id);
      // Aquí puedes manejar la respuesta después de eliminar el artículo
    } catch (e) {
      // Manejo de errores
      print('Error al eliminar el artículo: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final nombre = articulo['nombre'] ?? '';

    // Parsear categoria
    final categoriaEnum = CategoriaEnum.values.firstWhere(
      (e) => e.name == articulo['categoria'],
      orElse: () => CategoriaEnum.ROPA,
    );
    final categoria = categoriaEnum.value;

    // Parsear subcategoría según la categoría
    String subcategoria = '';
    switch (categoriaEnum) {
      case CategoriaEnum.ROPA:
        final sub = SubcategoriaRopaEnum.values.firstWhere(
          (e) => e.name == articulo['subcategoria'],
          orElse: () => SubcategoriaRopaEnum.CAMISETAS,
        );
        subcategoria = sub.value;
        break;
      case CategoriaEnum.ACCESORIOS:
        final sub = SubcategoriaAccesoriosEnum.values.firstWhere(
          (e) => e.name == articulo['subcategoria'],
          orElse: () => SubcategoriaAccesoriosEnum.CINTURONES,
        );
        subcategoria = sub.value;
        break;
      case CategoriaEnum.CALZADO:
        final sub = SubcategoriaCalzadoEnum.values.firstWhere(
          (e) => e.name == articulo['subcategoria'],
          orElse: () => SubcategoriaCalzadoEnum.ZAPATILLAS,
        );
        subcategoria = sub.value;
        break;
    }

    final ocasiones = (articulo['ocasiones'] as List?)
            ?.map((e) => OcasionEnum.values.firstWhere((o) => o.name == e).value)
            .join(', ') ??
        '';

    final temporadas = (articulo['temporadas'] as List?)
            ?.map((e) => TemporadaEnum.values.firstWhere((t) => t.name == e).value)
            .join(', ') ??
        '';

    final colores = (articulo['colores'] as List?)
            ?.map((e) => ColorEnum.values.firstWhere((c) => c.name == e).value)
            .join(', ') ??
        '';

    final imagenBytes = base64Decode(articulo['imagen'] ?? '');

    final id = articulo['id'] ?? '';

    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          SingleChildScrollView(
            padding: const EdgeInsets.only(bottom: 80),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                  height: 400,
                  width: double.infinity,
                  child: Image.memory(imagenBytes, fit: BoxFit.cover),
                ),
                const SizedBox(height: 24),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                  child: Text(
                    nombre,
                    style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                  ),
                ),
                const SizedBox(height: 24),
                _buildInfoSection("Categoría y subcategoría", "$categoria, $subcategoria"),
                _buildInfoSection("Ocasiones", ocasiones),
                _buildInfoSection("Temporadas", temporadas),
                _buildInfoSection("Colores", colores),
                const SizedBox(height: 40),
              ],
            ),
          ),
          Positioned(
            top: 40,
            left: 16,
            child: CircleAvatar(
              backgroundColor: Colors.white.withOpacity(0.8),
              child: IconButton(
                icon: const Icon(Icons.chevron_left),
                onPressed: () => Navigator.pop(context),
              ),
            ),
          ),
          Positioned(
            top: 40,
            right: 16,
            child: CircleAvatar(
              backgroundColor: Colors.white.withOpacity(0.8),
              child: IconButton(
                icon: const Icon(Icons.delete),
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (ctx) => AlertDialog(
                      title: const Text("Eliminar prenda"),
                      content: Text('¿Quieres eliminar la prenda: $nombre?', style: TextStyle(fontSize: 16)),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.of(ctx).pop(),
                          child: const Text("Cancelar"),
                        ),
                        TextButton(
                          onPressed: () {
                            Navigator.of(ctx).pop();
                            eliminarArticulo(id).then((_) {
                              Navigator.pop(context, true); // Cierra la pantalla actual
                            });
                          },
                          child: const Text("Eliminar", style: TextStyle(color: Colors.black)),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SizedBox(
          width: double.infinity,
          height: 50,
          child: ElevatedButton(
            onPressed: () {
              final imagenBytes = base64Decode(articulo['imagen']);
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => FormularioArticuloScreen(
                    imagenBytes: imagenBytes,
                    articuloExistente: articulo,
                  ),
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text(
              'Editar',
              style: TextStyle(fontSize: 18),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInfoSection(String title, String content) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 4),
          Text(content, style: const TextStyle(fontSize: 16)),
        ],
      ),
    );
  }
}
