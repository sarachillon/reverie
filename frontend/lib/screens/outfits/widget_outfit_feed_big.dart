import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:frontend/enums/enums.dart';
import 'package:frontend/screens/outfits/outfit_detail_screen.dart';

class WidgetOutfitFeedBig extends StatelessWidget {
  final List<dynamic> outfits;

  const WidgetOutfitFeedBig({super.key, required this.outfits});

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
    return PageView.builder(
      key: const ValueKey('page'),
      scrollDirection: Axis.vertical,
      itemCount: outfits.length,
      itemBuilder: (context, index) {
        final outfit = outfits[index];
        final imagenPrincipalFuture = _decodeImage(outfit['imagen']);
        final username = outfit['usuario']?['username'] ?? 'demo_user';
        final fotoPerfil = outfit['usuario']?['foto_perfil'];

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
                                const SizedBox(width: 10),
                                Expanded(
                                  child: Text(username, style: const TextStyle(fontWeight: FontWeight.bold)),
                                ),
                                IconButton(
                                  icon: const Icon(Icons.ios_share, size: 20),
                                  onPressed: () {},
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
                            // Imagen
                            FutureBuilder<ImageProvider<Object>>(
                              future: imagenPrincipalFuture,
                              builder: (context, snapshot) {
                                if (snapshot.connectionState == ConnectionState.done && snapshot.hasData) {
                                  return ClipRRect(
                                    borderRadius: BorderRadius.circular(12),
                                    child: Image(
                                      image: snapshot.data!,
                                      fit: BoxFit.cover,
                                      width: double.infinity,
                                      height: constraints.maxHeight * 0.60,
                                    ),
                                  );
                                } else {
                                  return SizedBox(height: constraints.maxHeight * 0.48);
                                }
                              },
                            ),
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
                                  final imagenMiniFuture = _decodeImage(articulo['imagen']);
                                  return FutureBuilder<ImageProvider<Object>>(
                                    future: imagenMiniFuture,
                                    builder: (context, snapshot) {
                                      if (snapshot.connectionState == ConnectionState.done && snapshot.hasData) {
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
                                          child: Image(image: snapshot.data!, fit: BoxFit.cover),
                                        );
                                      } else {
                                        return const SizedBox(height: 36, width: 36);
                                      }
                                    },
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
