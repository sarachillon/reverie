import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:frontend/enums/enums.dart';
import 'package:frontend/screens/outfits/outfit_detail_screen.dart';
import 'package:frontend/screens/perfil/perfil_screen.dart';
import 'package:frontend/services/share_utils.dart';
import 'package:frontend/screens/armarioVirtual/armario_screen.dart';
import 'package:frontend/screens/utils/imagen_ajustada_widget.dart';

class WidgetOutfitFeedSmall extends StatelessWidget {
  final List<dynamic> outfits;

  WidgetOutfitFeedSmall({super.key, required this.outfits});
  
  final GlobalKey<ArmarioScreenState> armarioKey = GlobalKey<ArmarioScreenState>();

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
          final username = outfit['usuario']?['username'] ?? 'demo_user';
          final fotoPerfil = outfit['usuario']?['foto_perfil'];

          final ocasiones = (outfit['ocasiones'] as List)
              .map((o) => OcasionEnum.values.firstWhere((e) => e.name == o).value)
              .join(', ');

          return GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => OutfitDetailScreen(outfitId: outfit['id'] as int)),
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
                  // Usuario + compartir
                  GestureDetector(
                    onTap: () {
                      final userId = outfit['usuario']?['id'];
                      if (userId != null) {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => PerfilScreen(userId: userId, armarioKey: armarioKey),
                          ),
                        );
                      }
                    },
                    child: Row(
                      children: [
                        CircleAvatar(
                          radius: 20,
                          backgroundColor: Colors.grey.shade300,
                          backgroundImage: (fotoPerfil != null && fotoPerfil.isNotEmpty)
                              ? MemoryImage(base64Decode(
                                  fotoPerfil.contains(',') ? fotoPerfil.split(',').last : fotoPerfil))
                              : null,
                          child: (fotoPerfil == null || fotoPerfil.isEmpty)
                              ? const Icon(Icons.person, color: Colors.white)
                              : null,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(username, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                        ),
                        IconButton(
                          icon: const Icon(Icons.ios_share, size: 16),
                          onPressed: () {
                            final imagen = outfit['imagen'];
                            final nombre = outfit['usuario']?['username'] ?? 'usuario';
                            if (imagen != null && imagen.isNotEmpty) {
                              ShareUtils.compartirOutfitSinMarca(
                                base64Imagen: outfit['imagen'],
                                username: nombre,
                              );
                            }
                          },
                        ),                         
                      ],
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    outfit['titulo'] ?? 'Sin título',
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    ocasiones,
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontSize: 11, fontStyle: FontStyle.italic),
                  ),
                  const SizedBox(height: 6),
                  Expanded(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: ImagenAjustada(
                        url: imagenUrl,
                        width: 100,
                        height: 100,
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
