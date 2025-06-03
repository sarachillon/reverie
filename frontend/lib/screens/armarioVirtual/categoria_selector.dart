import 'package:flutter/material.dart';
import 'package:frontend/enums/enums.dart';
import 'package:frontend/screens/armarioVirtual/subcategoria_selector.dart';

class CategoriaSelector extends StatelessWidget {
  const CategoriaSelector({super.key});

  @override
  Widget build(BuildContext context) {
    final categorias = CategoriaEnum.values.map((e) => e.value).toList();

    return Scaffold(
      appBar: AppBar(title: const Text("Selecciona categoría")),
      body: ListView.builder(
        itemCount: categorias.length,
        itemBuilder: (_, index) {
          final categoria = categorias[index];
          return ListTile(
            title: Text(categoria),
            onTap: () async {
              final subcategoria = await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => SubcategoriaSelector(categoria: categoria),
                ),
              );

              if (subcategoria != null) {
                Navigator.pop(context, {
                  'categoria': categoria,
                  'subcategoria': subcategoria,
                });
              }
            },
          );
        },
      ),
    );
  }
}
