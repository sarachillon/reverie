import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:frontend/enums/enums.dart';
import 'package:frontend/screens/armarioVirtual/formulario_edicion_articulo_propio_screen.dart';
import 'package:frontend/screens/armarioVirtual/formulario_articulo_propio_existente.dart';
import 'package:frontend/services/api_manager.dart';

class ArticuloPropioResumen extends StatefulWidget {
  final dynamic articulo;
  final Map<String, dynamic>? usuarioActual;

  const ArticuloPropioResumen({
    super.key,
    required this.articulo,
    required this.usuarioActual,
  });

  @override
  State<ArticuloPropioResumen> createState() => _ArticuloPropioResumenState();
}

class _ArticuloPropioResumenState extends State<ArticuloPropioResumen> {
  final ApiManager _apiManager = ApiManager();
  late dynamic articulo;

  @override
  void initState() {
    super.initState();
    articulo = widget.articulo;
  }

  Future<void> eliminarArticulo(int id) async {
    try {
      await _apiManager.deleteArticuloPropio(id: id);
      Navigator.pop(context, true);
    } catch (e) {
      print('Error al eliminar el artículo: $e');
    }
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
        subcategoria = SubcategoriaRopaEnum.values.firstWhere(
          (e) => e.name == articulo['subcategoria'],
          orElse: () => SubcategoriaRopaEnum.CAMISETAS,
        ).value;
        break;
      case CategoriaEnum.ACCESORIOS:
        subcategoria = SubcategoriaAccesoriosEnum.values.firstWhere(
          (e) => e.name == articulo['subcategoria'],
          orElse: () => SubcategoriaAccesoriosEnum.CINTURONES,
        ).value;
        break;
      case CategoriaEnum.CALZADO:
        subcategoria = SubcategoriaCalzadoEnum.values.firstWhere(
          (e) => e.name == articulo['subcategoria'],
          orElse: () => SubcategoriaCalzadoEnum.ZAPATILLAS,
        ).value;
        break;
    }

    final ocasiones = (articulo['ocasiones'] as List?)?.map((e) =>
        OcasionEnum.values.firstWhere((o) => o.name == e, orElse: () => OcasionEnum.CASUAL).value).join(', ') ?? '';
    final temporadas = (articulo['temporadas'] as List?)?.map((e) =>
        TemporadaEnum.values.firstWhere((t) => t.name == e, orElse: () => TemporadaEnum.VERANO).value).join(', ') ?? '';
    final colores = (articulo['colores'] as List?)?.cast<String>().toList() ?? [];
    final imagenBytes = base64Decode(articulo['imagen'] ?? '');
    final id = articulo['id'];
    final emailArticulo = articulo['usuario']?['email'];
    final emailUsuarioActual = widget.usuarioActual?['email'];
    final esPropio = emailUsuarioActual != null && emailUsuarioActual == emailArticulo;

    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(12),
        boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 4)],
      ),
      padding: const EdgeInsets.all(8),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Image.memory(imagenBytes, width: 100, height: 100, fit: BoxFit.cover),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Stack(
              children: [
                Positioned(
                  right: 0,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: esPropio
                        ? [
                            IconButton(
                              padding: EdgeInsets.zero,
                              iconSize: 18,
                              icon: const Icon(Icons.edit, size: 18),
                              color: Color(0xFFC9A86A),
                              onPressed: () async {
                                final updated = await Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => FormularioEdicionArticuloPropioScreen(
                                      imagenBytes: imagenBytes,
                                      articuloExistente: articulo,
                                    ),
                                  ),
                                );
                                if (updated != null) {
                                  setState(() => articulo = updated);
                                }
                              },
                            ),
                            IconButton(
                              padding: EdgeInsets.zero,
                              iconSize: 18,
                              icon: const Icon(Icons.delete, size: 18),
                              color: Color(0xFFC9A86A),
                              onPressed: () => eliminarArticulo(id),
                            ),
                          ]
                        : [
                            IconButton(
                              icon: const Icon(Icons.add),
                              tooltip: "Añadir a mi armario",
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => FormularioArticuloDesdeExistenteScreen(articulo: articulo),
                                  ),
                                );
                              },
                            ),
                          ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(nombre, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold), maxLines: 1, overflow: TextOverflow.ellipsis),
                    Text("Categoría: $categoria", style: const TextStyle(fontSize: 12)),
                    Text("Subcat.: $subcategoria", style: const TextStyle(fontSize: 12)),
                    Text("Ocasión: $ocasiones", style: const TextStyle(fontSize: 12), maxLines: 1, overflow: TextOverflow.ellipsis),
                    Text("Temporada: $temporadas", style: const TextStyle(fontSize: 12), maxLines: 1, overflow: TextOverflow.ellipsis),
                    const SizedBox(height: 4),
                    Wrap(
                      spacing: 4,
                      runSpacing: 4,
                      children: colores.map((c) {
                        final colorEnum = ColorEnum.values.firstWhere(
                          (ce) => ce.name.toUpperCase() == c.toUpperCase(),
                          orElse: () => ColorEnum.BLANCO,
                        );
                        return Container(
                          width: 14,
                          height: 14,
                          decoration: BoxDecoration(
                            color: _getColorFromEnum(colorEnum),
                            shape: BoxShape.circle,
                            border: Border.all(color: const Color.fromARGB(239, 0, 0, 0)),
                          ),
                        );
                      }).toList(),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Color _getColorFromEnum(ColorEnum color) {
    switch (color) {
      case ColorEnum.AMARILLO: return Colors.yellow;
      case ColorEnum.NARANJA: return Colors.orange;
      case ColorEnum.ROJO: return Colors.red;
      case ColorEnum.ROSA: return Colors.pink;
      case ColorEnum.VIOLETA: return Colors.purple;
      case ColorEnum.AZUL: return Colors.blue;
      case ColorEnum.VERDE: return Colors.green;
      case ColorEnum.MARRON: return Colors.brown;
      case ColorEnum.GRIS: return Colors.grey;
      case ColorEnum.BLANCO: return Colors.white;
      case ColorEnum.NEGRO: return Colors.black;
    }
  }
}
