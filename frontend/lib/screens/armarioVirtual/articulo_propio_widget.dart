import 'dart:convert';
import 'package:flutter/material.dart';

class ArticuloPropioWidget extends StatelessWidget {
  final String nombre;
  final dynamic articulo; // Now 'articulo' will contain the 'imagen' data
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
      onTap: onTap,
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Imagen que ocupa todo el espacio disponible menos el espacio para el título
              Expanded(
                child: base64Image != null
                    ? Image.memory(
                        base64Decode(base64Image),
                        width: double.infinity,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return const SizedBox(
                            width: double.infinity,
                            child: Center(child: Icon(Icons.broken_image)),
                          );
                        },
                      )
                    : const SizedBox(
                        width: double.infinity,
                        child: Center(child: Icon(Icons.image)),
                      ),
              ),
              // Título centrado en la parte inferior
              Padding(
                padding: const EdgeInsets.only(top: 8.0),
                child: Center(
                  child: Text(
                    nombre,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}