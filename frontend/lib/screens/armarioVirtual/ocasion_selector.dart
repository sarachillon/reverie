import 'package:flutter/material.dart';
import 'package:frontend/enums/enums.dart';

class OcasionSelector extends StatelessWidget {
  const OcasionSelector({super.key});

  @override
  Widget build(BuildContext context) {
    final ocasion = OcasionEnum.values.map((e) => e.value).toList();

    return Scaffold(
      appBar: AppBar(title: const Text("Selecciona ocasión")),
      body: ListView.builder(
        itemCount: ocasion.length,
        itemBuilder: (_, index) {
          return ListTile(
            title: Text(ocasion[index]),
            onTap: () => Navigator.pop(context, ocasion[index]),
          );
        },
      ),
    );
  }
}
