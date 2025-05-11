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
    final imagenRaw = articulo['fotoUrl'];
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
            SizedBox(
            height: 40,
                child: Center(
                  child: Text(
                    nombre,
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                    softWrap: true,
                    maxLines: 2,
                    overflow: TextOverflow.fade,
                  ),
                ),
              ),

          ],
        ),
      ),
    );
  }
}
