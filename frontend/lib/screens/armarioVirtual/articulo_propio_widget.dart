import 'package:flutter/material.dart';
import 'package:frontend/enums/enums.dart';
import 'package:frontend/screens/armarioVirtual/pantalla_ver_todos.dart';
import 'package:frontend/screens/utils/imagen_ajustada_widget.dart';


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
    final imagenUrl = articulo['urlFirmada'] ?? '';

    final categoriaEnum = CategoriaEnum.values.firstWhere(
      (e) => e.name == articulo['categoria'],
      orElse: () => CategoriaEnum.ROPA,
    );

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
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => PantallaVerTodos(categoria: articulo['categoria']),
          ),
        );
      },
      child: Container(
        height: 210,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: const [
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
                child: ImagenAjustada(url: imagenUrl, width: 100, height:100)
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 8, 12, 2),
              child: Text(
                nombre,
                style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 0, 12, 8),
              child: Text(
                subcategoria,
                style: const TextStyle(fontSize: 13, color: Colors.grey),
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
