import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:frontend/enums/enums.dart';
import 'package:frontend/services/share_utils.dart';
import 'package:http/http.dart' as http;

class WidgetOutfitFeedBig extends StatelessWidget {
  final List<dynamic> outfits;

  const WidgetOutfitFeedBig({super.key, required this.outfits});

  @override
  Widget build(BuildContext context) {
    return PageView.builder(
      key: const ValueKey('page'),
      scrollDirection: Axis.vertical,
      itemCount: outfits.length,
      itemBuilder: (context, index) {
        final outfit = outfits[index];
        final imagenUrl = outfit['imagen'];
        print("Imagen URL: $imagenUrl");
        final username = outfit['usuario']?['username'] ?? 'demo_user';
        final fotoPerfilUrl = outfit['usuario']?['foto_perfil'];

        return LayoutBuilder(
          builder: (context, constraints) {
            return Column(
              children: [
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 12,
                            offset: const Offset(0, 6),
                          ),
                        ],
                      ),
                      child: SingleChildScrollView(
                        child: Column(
                          children: [
                            // Usuario
                            Row(
                              children: [
                                fotoPerfilUrl != null
                                    ? CircleAvatar(
                                        radius: 20,
                                        backgroundImage: NetworkImage(fotoPerfilUrl),
                                      )
                                    : CircleAvatar(
                                        radius: 20,
                                        backgroundColor: Colors.grey.shade300,
                                        child: const Icon(Icons.person, color: Colors.white),
                                      ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: Text(username, style: const TextStyle(fontWeight: FontWeight.bold)),
                                ),
                                IconButton(
                                  icon: const Icon(Icons.ios_share, size: 16),
                                  onPressed: () async {
                                    if (imagenUrl != null && imagenUrl.isNotEmpty) {
                                      try {
                                        final response = await http.get(Uri.parse(imagenUrl));
                                        if (response.statusCode == 200) {
                                          final base64Img = base64Encode(response.bodyBytes);
                                          ShareUtils.compartirOutfitSinMarca(
                                            base64Imagen: base64Img,
                                            username: username,
                                          );
                                        }
                                      } catch (e) {
                                        print("❌ Error al compartir imagen: $e");
                                      }
                                    }
                                  },
                                ),
                              ],
                            ),
                            const SizedBox(height: 6),
                            Text(
                              outfit['titulo'] ?? 'Sin título',
                              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 4),
                            Text(
                              (outfit['ocasiones'] as List)
                                  .map((o) => OcasionEnum.values.firstWhere((e) => e.name == o).value)
                                  .join(', '),
                              textAlign: TextAlign.center,
                              style: const TextStyle(fontSize: 12, fontStyle: FontStyle.italic),
                            ),
                            const SizedBox(height: 10),
                            // Imagen principal
                            if (imagenUrl != null && imagenUrl.isNotEmpty)
                              ClipRRect(
                                borderRadius: BorderRadius.circular(12),
                                child: Image.network(
                                  imagenUrl,
                                  fit: BoxFit.cover,
                                  width: double.infinity,
                                  height: constraints.maxHeight * 0.60,
                                ),
                              )
                            else
                              SizedBox(height: constraints.maxHeight * 0.48),
                            const SizedBox(height: 10),
                            // Miniaturas
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
                              decoration: BoxDecoration(
                                color: const Color(0xFFC9A86A),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: (outfit['articulos_propios'] as List).take(5).map((articulo) {
                                  final miniUrl = articulo['imagen'];
                                  return Container(
                                    margin: const EdgeInsets.symmetric(horizontal: 4),
                                    height: 36,
                                    width: 36,
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(8),
                                      border: Border.all(color: Colors.black12),
                                      color: Colors.white,
                                    ),
                                    clipBehavior: Clip.antiAlias,
                                    child: miniUrl != null && miniUrl.isNotEmpty
                                        ? Image.network(miniUrl, fit: BoxFit.cover)
                                        : const SizedBox(),
                                  );
                                }).toList(),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
                const Icon(Icons.keyboard_arrow_down, size: 28, color: Colors.black38),
                const SizedBox(height: 12),
              ],
            );
          },
        );
      },
    );
  }
}
