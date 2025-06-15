import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:frontend/enums/enums.dart';
import 'package:frontend/screens/utils/imagen_ajustada_widget.dart';

class OutfitConfirmationScreen extends StatelessWidget {
  final Map<String, dynamic> outfit;
  final bool mostrarAcciones;
  final VoidCallback? onAceptar;
  final VoidCallback? onRechazar;

  const OutfitConfirmationScreen({
    super.key,
    required this.outfit,
    this.mostrarAcciones = false,
    this.onAceptar,
    this.onRechazar,
  });

  @override
  Widget build(BuildContext context) {

    final String? imagenUrl = outfit['imagen'];

    try {
      imagenUrl != null
      ? Image.network(imagenUrl)
      : Placeholder();
    } catch (e) {
      print("ERROR al decodificar imagen: $e");
    }


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
      ),
      body: Stack(
  children: [
    if (imagenUrl != null)
      SizedBox(
        width: double.infinity,
        height: MediaQuery.of(context).size.width * 1.5, 
        child: ImagenAjustada(url: imagenUrl, width: 100, height:100),
      ),

    Align(
      alignment: Alignment.bottomCenter,
      child: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 10)],
        ),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Text(
                  outfit['titulo'] ?? '',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
                ),
              ),
              if ((outfit['descripcion_generacion'] ?? '').toString().isNotEmpty) ...[
                const SizedBox(height: 12),
                Center(child: Text(outfit['descripcion_generacion'])),
              ],
              if (mostrarAcciones) ...[
                const SizedBox(height: 24),
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(backgroundColor: Colors.green.shade700, textStyle: const TextStyle(color: Colors.white)),
                        onPressed: onAceptar,
                        child: const Text("Aceptar", style: TextStyle(color: Colors.white)),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(backgroundColor: Colors.red.shade700, textStyle: const TextStyle(color: Colors.white)),
                        onPressed: onRechazar,
                        child: const Text("Rechazar", style: TextStyle(color: Colors.white)),
                      ),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    ),
  ],
),

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