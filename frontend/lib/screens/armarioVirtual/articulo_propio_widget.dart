import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:frontend/screens/armarioVirtual/articulo_propio_detail_screen.dart'; 

class ArticuloPropioWidget extends StatelessWidget {
  final String nombre;
  final dynamic articulo; 
  final VoidCallback? onTap;

  const ArticuloPropioWidget({
    Key? key,
    required this.nombre,
    required this.articulo,
    this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final imagenRaw = articulo['imagen'];
    final base64Image = (imagenRaw is String && imagenRaw.isNotEmpty) ? imagenRaw : null;

    return InkWell(
      onTap: () async {
        final result = await Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => ArticuloPropioDetailScreen(articulo: articulo),
          ),
        );

        if (result == true && onTap != null) {
          onTap!(); // Llama a onTap para que ArmarioScreen recargue
        }
      },
      child: Card(
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        clipBehavior: Clip.antiAlias,
        child: Column(
          children: [
            // Imagen cuadrada
            AspectRatio(
              aspectRatio: 1, // cuadrada
              child: base64Image != null
                  ? Image.memory(
                      base64Decode(base64Image),
                      fit: BoxFit.cover,
                      width: double.infinity,
                      errorBuilder: (context, error, stackTrace) =>
                          const Center(child: Icon(Icons.broken_image)),
                    )
                  : const Center(child: Icon(Icons.image)),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                nombre,
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
