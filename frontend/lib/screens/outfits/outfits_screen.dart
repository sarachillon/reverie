
import 'package:flutter/material.dart';
import 'package:frontend/screens/outfits/formulario_outfit_screen.dart';

class OutfitsScreen extends StatefulWidget {
  const OutfitsScreen({super.key});

  @override
  State<OutfitsScreen> createState() => _OutfitsScreenState();
}

class _OutfitsScreenState extends State<OutfitsScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Outfits')),
      body: const Center(child: Text('Aquí se mostrarán los outfits generados.')),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const FormularioOutfitScreen()),
          );
          if (result == true) {
            // Aquí puedes recargar outfits si hiciste una generación
          }
        },
        child: const Icon(Icons.add),
        tooltip: 'Generar nuevo outfit',
      ),
    );
  }
}
