import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:frontend/enums/enums.dart';

class OutfitDetailScreen extends StatelessWidget {
  final String titulo;
  final String? descripcion;
  final List<ColorEnum> colores;
  final List<TemporadaEnum> temporadas;
  final OcasionEnum ocasion;
  final List<dynamic> articulosPropios;

  const OutfitDetailScreen({
    super.key,
    required this.titulo,
    this.descripcion,
    required this.colores,
    required this.temporadas,
    required this.ocasion,
    required this.articulosPropios,
  });

  @override
  Widget build(BuildContext context) {
    final partesArriba = {
      SubcategoriaRopaEnum.CAMISAS,
      SubcategoriaRopaEnum.CAMISETAS,
      SubcategoriaRopaEnum.JERSEYS,
      SubcategoriaRopaEnum.MONOS,
      SubcategoriaRopaEnum.TRAJES,
    };
    final partesAbajo = {
      SubcategoriaRopaEnum.PANTALONES,
      SubcategoriaRopaEnum.VAQUEROS,
      SubcategoriaRopaEnum.FALDAS_CORTAS,
      SubcategoriaRopaEnum.FALDAS_LARGAS,
      SubcategoriaRopaEnum.BERMUDAS,
    };
    final cuerpoEntero = {
      SubcategoriaRopaEnum.MONOS,
      SubcategoriaRopaEnum.VESTIDOS_CORTOS,
      SubcategoriaRopaEnum.VESTIDOS_LARGOS,
    };

    dynamic prendaArriba;
    dynamic prendaAbajo;
    dynamic prendaCuerpoEntero;

    for (final articulo in articulosPropios) {
      final subStr = articulo['subcategoria'];
      if (subStr == null) continue;

      try {
        final sub = SubcategoriaRopaEnum.values.firstWhere((e) => e.name == subStr);

        if (cuerpoEntero.contains(sub)) {
          prendaCuerpoEntero = articulo;
        } else if (partesArriba.contains(sub)) {
          prendaArriba = articulo;
        } else if (partesAbajo.contains(sub)) {
          prendaAbajo = articulo;
        }
      } catch (_) {
        // Ignora subcategorías que no están en SubcategoriaRopaEnum
        continue;
      }
    }

    Widget buildImagen(dynamic articulo, {double width = 220, double height = 220}) {
      final imagenBase64 = articulo['imagen'];
      final imagenBytes = base64Decode(imagenBase64);
      return Image.memory(
        imagenBytes,
        width: width,
        height: height,
        fit: BoxFit.contain,
      );
    }


    Widget buildInfo(String label, String value) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 4.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "$label: ",
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            Flexible(child: Text(value)),
          ],
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Outfit generado')),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(titulo, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              if (descripcion != null && descripcion!.isNotEmpty)
                Text(descripcion!, style: const TextStyle(fontSize: 16, color: Colors.black87)),
              const SizedBox(height: 24),
              Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (prendaCuerpoEntero != null)
                      buildImagen(prendaCuerpoEntero, height: 320, width: 320),
                    if (prendaCuerpoEntero == null && prendaArriba != null)
                      buildImagen(prendaArriba, height: 220, width: 220),
                    if (prendaCuerpoEntero == null && prendaArriba != null && prendaAbajo != null)
                      const SizedBox(height: 12),
                    if (prendaCuerpoEntero == null && prendaAbajo != null)
                      buildImagen(prendaAbajo, height: 220, width: 220),
                  ],
                ),
              ),



              const SizedBox(height: 24),
              const Divider(),
              const SizedBox(height: 12),
              buildInfo("Ocasión", ocasion.value),
              buildInfo(
                "Colores",
                colores.map((c) => c.value).join(", "),
              ),
              buildInfo(
                "Temporadas",
                temporadas.map((t) => t.value).join(", "),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
