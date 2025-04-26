import 'package:flutter/material.dart';
import 'package:frontend/enums/enums.dart';

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
          return ListTile(
            title: Text(categorias[index]),
            onTap: () => Navigator.pop(context, categorias[index]),
          );
        },
      ),
    );
  }
}
