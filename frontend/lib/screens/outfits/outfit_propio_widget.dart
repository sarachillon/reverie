import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:frontend/screens/outfits/outfit_detail_screen.dart';
import 'package:frontend/enums/enums.dart';

class OutfitWidget extends StatelessWidget {
  final dynamic outfit;
  final VoidCallback? onTap;

  const OutfitWidget({
    Key? key,
    required this.outfit,
    this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final titulo = outfit['titulo'] ?? 'Sin título';
    final imagenBase64 = outfit['imagen'] as String?;
    final imagenBytes = (imagenBase64 != null && imagenBase64.isNotEmpty)
        ? base64Decode(imagenBase64)
        : null;

    return InkWell(
      onTap: () async {
        final colores = (outfit['colores'] as List).map((c) => ColorEnum.values.firstWhere((e) => e.name == c)).toList();
        final temporadas = (outfit['temporadas'] as List).map((t) => TemporadaEnum.values.firstWhere((e) => e.name == t)).toList();
        final ocasiones = (outfit['ocasiones'] as List).map((t) => OcasionEnum.values.firstWhere((e) => e.name == t)).toList();

        await Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => OutfitDetailScreen(
              titulo: titulo,
              descripcion: outfit['descripcion_generacion'],
              colores: colores,
              temporadas: temporadas,
              ocasiones: ocasiones,
              articulosPropios: outfit['articulos_propios'],
            ),
          ),
        );

        if (onTap != null) onTap!();
      },
      child: Card(
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        clipBehavior: Clip.antiAlias,
        child: Column(
          children: [
            AspectRatio(
              aspectRatio: 1,
              child: imagenBytes != null
                  ? Image.memory(
                      imagenBytes,
                      fit: BoxFit.cover,
                      width: double.infinity,
                      errorBuilder: (_, __, ___) => const Center(child: Icon(Icons.broken_image)),
                    )
                  : const Center(child: Icon(Icons.image_not_supported)),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                titulo,
                style: const TextStyle(fontWeight: FontWeight.bold),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
