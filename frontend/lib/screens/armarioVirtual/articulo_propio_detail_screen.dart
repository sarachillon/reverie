import 'package:flutter/material.dart';
import 'package:frontend/enums/enums.dart';
import 'package:frontend/screens/armarioVirtual/formulario_edicion_articulo_propio_screen.dart';
import 'package:frontend/services/api_manager.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ArticuloPropioDetailScreen extends StatefulWidget {
  final dynamic articulo;

  const ArticuloPropioDetailScreen({super.key, required this.articulo});

  @override
  State<ArticuloPropioDetailScreen> createState() => _ArticuloPropioDetailScreenState();
}

class _ArticuloPropioDetailScreenState extends State<ArticuloPropioDetailScreen> {
  final ApiManager _apiManager = ApiManager();
  late dynamic articulo;

  @override
  void initState() {
    super.initState();
    articulo = widget.articulo;
  }

  Future<void> eliminarArticulo(int id, BuildContext context) async {
    try {
      await _apiManager.deleteArticuloPropio(id: id);
      Navigator.pop(context, true);
    } catch (e) {
      print('Error al eliminar el artículo: $e');
    }
  }

  Future<String?> _getEmail() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('email');
  }

  @override
  Widget build(BuildContext context) {
    final nombre = articulo['nombre'] ?? '';
    final categoriaEnum = CategoriaEnum.values.firstWhere(
      (e) => e.name == articulo['categoria'],
      orElse: () => CategoriaEnum.ROPA,
    );
    final categoria = categoriaEnum.value;

    String subcategoria = '';
    switch (categoriaEnum) {
      case CategoriaEnum.ROPA:
        subcategoria = SubcategoriaRopaEnum.values
            .firstWhere((e) => e.name == articulo['subcategoria'], orElse: () => SubcategoriaRopaEnum.CAMISETAS)
            .value;
        break;
      case CategoriaEnum.ACCESORIOS:
        subcategoria = SubcategoriaAccesoriosEnum.values
            .firstWhere((e) => e.name == articulo['subcategoria'], orElse: () => SubcategoriaAccesoriosEnum.CINTURONES)
            .value;
        break;
      case CategoriaEnum.CALZADO:
        subcategoria = SubcategoriaCalzadoEnum.values
            .firstWhere((e) => e.name == articulo['subcategoria'], orElse: () => SubcategoriaCalzadoEnum.ZAPATILLAS)
            .value;
        break;
    }

    final ocasiones = (articulo['ocasiones'] as List?)?.map((e) => OcasionEnum.values.firstWhere((o) => o.name == e, orElse: () => OcasionEnum.CASUAL).value).join(', ') ?? '';
    final temporadas = (articulo['temporadas'] as List?)?.map((e) => TemporadaEnum.values.firstWhere((t) => t.name == e, orElse: () => TemporadaEnum.VERANO).value).join(', ') ?? '';
    final colores = (articulo['colores'] as List?)?.cast<String>().toList() ?? [];
    String imagenUrl = articulo['foto'] ?? '';
    final id = articulo['id'] ?? '';

    return FutureBuilder<String?>(
      future: _getEmail(),
      builder: (context, snapshot) {
        //final email = snapshot.data ?? '';

        return Scaffold(
          backgroundColor: Colors.white,
          appBar: AppBar(
            backgroundColor: Theme.of(context).cardColor,
            elevation: 0,
            leading: IconButton(
              icon: const Icon(Icons.chevron_left, color: Colors.black),
              onPressed: () => Navigator.pop(context),
            ),
            centerTitle: true,
            title: Image.asset('assets/logo_reverie_text.png', height: 32),
            actions: [
              IconButton(
                icon: const Icon(Icons.edit, color: Colors.black),
                onPressed: () async {
                  final imagenUrl = articulo['foto'] ?? '';
                  final updatedArticulo = await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => FormularioEdicionArticuloPropioScreen(
                        imagenUrl: imagenUrl,
                        articuloExistente: articulo,
                      ),
                    ),
                  );
                  if (updatedArticulo != null) {
                    setState(() => articulo = updatedArticulo);
                  }
                },
              ),
              IconButton(
                icon: const Icon(Icons.delete, color: Colors.black),
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (ctx) => AlertDialog(
                      title: const Text("Eliminar prenda"),
                      content: Text('¿Eliminar "$nombre"?'),
                      actions: [
                        TextButton(onPressed: () => Navigator.of(ctx).pop(), child: const Text("Cancelar")),
                        TextButton(onPressed: () => eliminarArticulo(id, context), child: const Text("Eliminar", style: TextStyle(color: Colors.black))),
                      ],
                    ),
                  );
                },
              ),
            ],
          ),
          body: Column(
            children: [
              const SizedBox(height: 8),
              AspectRatio(
                aspectRatio: 1,
                child: Image.network(imagenUrl, fit: BoxFit.cover),
              ),
              Expanded(
                child: SingleChildScrollView(
                  child: Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: Theme.of(context).cardColor,
                      borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
                      boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 10, offset: Offset(0, -2))],
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Center(
                          child: Text(
                            nombre,
                            style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
                          ),
                        ),
                        const SizedBox(height: 24),
                        _buildPrettyRow("Categoría", categoria),
                        _buildPrettyRow("Subcategoría", subcategoria),
                        _buildPrettyRow("Ocasiones", ocasiones),
                        _buildPrettyRow("Temporadas", temporadas),
                        const SizedBox(height: 24),
                        const Text("Colores", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                        const SizedBox(height: 8),
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: colores.map((colorName) {
                            final colorEnum = ColorEnum.values.firstWhere(
                              (c) => c.name.toUpperCase() == colorName.toUpperCase(),
                              orElse: () => ColorEnum.BLANCO,
                            );
                            return Container(
                              width: 32,
                              height: 32,
                              decoration: BoxDecoration(
                                color: _getColorFromEnum(colorEnum),
                                shape: BoxShape.circle,
                                border: Border.all(color: Colors.black12, width: 2),
                              ),
                            );
                          }).toList(),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildPrettyRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("$label: ", style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          Expanded(child: Text(value, style: const TextStyle(fontSize: 16))),
        ],
      ),
    );
  }
Color _getColorFromEnum(ColorEnum color) {
    switch (color) {
      case ColorEnum.AMARILLO:
        return Colors.yellow;
      case ColorEnum.NARANJA:
        return Colors.orange;
      case ColorEnum.ROJO:
        return Colors.red;
      case ColorEnum.ROSA:
        return Colors.pink;
      case ColorEnum.VIOLETA:
        return Colors.purple;
      case ColorEnum.AZUL:
        return Colors.blue;
      case ColorEnum.VERDE:
        return Colors.green;
      case ColorEnum.MARRON:
        return Colors.brown;
      case ColorEnum.GRIS:
        return Colors.grey;
      case ColorEnum.BLANCO:
        return Colors.white;
      case ColorEnum.NEGRO:
        return Colors.black;
    }
  }
}
