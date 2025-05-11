import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:frontend/screens/armarioVirtual/articulo_propio_detail_screen.dart';
import 'package:frontend/enums/enums.dart';


class ArticuloPropioWidget extends StatelessWidget {
  final String nombre;
  final dynamic articulo;
  final VoidCallback? onTap;

  const ArticuloPropioWidget({
    super.key,
    required this.nombre,
    required this.articulo,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final imagenBytes = base64Decode(articulo['imagen'] ?? '');
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

    return InkWell(
      onTap: () async {
        final result = await Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => ArticuloPropioDetailScreen(articulo: articulo),
          ),
        );

        if (result == true && onTap != null) {
          onTap!();
        }
      },
      child: Container(
        height: 210,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 6,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(16),
                topRight: Radius.circular(16),
              ),
              child: SizedBox(
                height: 130,
                width: double.infinity,
                child: imagenBytes != null
                    ? Image.memory(
                        imagenBytes,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) =>
                            const Center(child: Icon(Icons.broken_image)),
                      )
                    : const Center(child: Icon(Icons.image)),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 8, 12, 2),
              child: Text(
                nombre,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 0, 12, 8),
              child: Text(
                subcategoria,
                style: const TextStyle(
                  fontSize: 13,
                  color: Colors.grey,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
