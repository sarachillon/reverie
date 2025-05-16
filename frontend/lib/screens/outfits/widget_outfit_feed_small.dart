import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:frontend/enums/enums.dart';
import 'package:frontend/screens/outfits/outfit_detail_screen.dart';

class WidgetOutfitFeedSmall extends StatelessWidget {
  final List<dynamic> outfits;

  const WidgetOutfitFeedSmall({super.key, required this.outfits});

  Future<ImageProvider<Object>> _decodeImage(String? base64) async {
    try {
      if (base64 != null && base64.isNotEmpty) {
        final bytes = base64Decode(base64);
        return MemoryImage(bytes);
      }
    } catch (_) {}
    return const AssetImage('assets/mock/ropa_mock.png');
  }

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
          final futureImage = _decodeImage(outfit['imagen']);
          final username = outfit['usuario']?['username'] ?? 'demo_user';
          final fotoPerfil = outfit['usuario']?['foto_perfil'];

          final ocasiones = (outfit['ocasiones'] as List)
              .map((o) => OcasionEnum.values.firstWhere((e) => e.name == o).value)
              .join(', ');

          return FutureBuilder<ImageProvider<Object>>(
            future: futureImage,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.done && snapshot.hasData) {
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
                        // Usuario + compartir
                        Row(
                          children: [
                            fotoPerfil != null
                                ? CircleAvatar(
                                    radius: 20,
                                    backgroundImage: MemoryImage(base64Decode(fotoPerfil)),
                                  )
                                : CircleAvatar(
                                    radius: 20,
                                    backgroundColor: Colors.grey.shade300,
                                    child: const Icon(Icons.person, color: Colors.white),
                                  ), 
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(username, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                            ),
                            const Icon(Icons.ios_share, size: 16),
                          ],
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
                            child: Image(
                              image: snapshot.data!,
                              fit: BoxFit.cover,
                              width: double.infinity,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              } else {
                return const Center(child: CircularProgressIndicator());
              }
            },
          );
        },
      ),
    );
  }
}
