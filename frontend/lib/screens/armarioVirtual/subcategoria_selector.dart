import 'package:flutter/material.dart';
import 'package:frontend/enums/enums.dart';

class SubcategoriaSelector extends StatelessWidget {
  final String categoria;

  const SubcategoriaSelector({super.key, required this.categoria});

  @override
  Widget build(BuildContext context) {
    List<String> subcategorias = [];

    switch (categoria) {
      case 'Ropa':
        subcategorias = SubcategoriaRopaEnum.values.map((e) => e.value).toList();
        break;
      case 'Calzado':
        subcategorias = SubcategoriaCalzadoEnum.values.map((e) => e.value).toList();
        break;
      case 'Accesorios':
        subcategorias = SubcategoriaAccesoriosEnum.values.map((e) => e.value).toList();
        break;
    }

    return Scaffold(
      appBar: AppBar(title: const Text("Selecciona subcategoría")),
      body: ListView.builder(
        itemCount: subcategorias.length,
        itemBuilder: (_, index) {
          return ListTile(
            title: Text(subcategorias[index]),
            onTap: () => Navigator.pop(context, subcategorias[index]),
          );
        },
      ),
    );
  }
}
