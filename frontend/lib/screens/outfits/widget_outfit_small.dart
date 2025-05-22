import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:frontend/enums/enums.dart';
import 'package:frontend/screens/outfits/outfit_detail_screen.dart';
import 'package:frontend/services/api_manager.dart';
import 'package:shared_preferences/shared_preferences.dart';

class WidgetOutfitSmall extends StatelessWidget {
  final List<dynamic> outfits;

  const WidgetOutfitSmall({super.key, required this.outfits});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(12),
      child: GridView.builder(
        itemCount: outfits.length,
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          mainAxisSpacing: 16,
          crossAxisSpacing: 16,
          childAspectRatio: 0.56,
        ),
        itemBuilder: (context, index) {
          final outfit = outfits[index];
          final imagenUrl = outfit['imagen'] as String? ?? '';
          final ocasiones = (outfit['ocasiones'] as List)
              .map((o) => OcasionEnum.values.firstWhere((e) => e.name == o).value)
              .join(', ');

          return GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => OutfitDetailScreen(outfit: outfit)),
              );
            },
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.08),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              padding: const EdgeInsets.all(10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Center(
                    child: Text(
                      outfit['titulo'] ?? 'Sin título',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    ocasiones,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 12,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Expanded(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: Image.network(
                        imagenUrl,
                        fit: BoxFit.cover,
                        width: double.infinity,
                        // Indicador de carga
                        loadingBuilder: (context, child, loadingProgress) {
                          if (loadingProgress == null) return child;
                          return const Center(child: CircularProgressIndicator());
                        },
                        // En caso de error al cargar
                        errorBuilder: (context, error, stackTrace) {
                          return const Center(child: Icon(Icons.broken_image));
                        },
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}