import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:frontend/enums/enums.dart';
import 'package:frontend/screens/outfits/outfit_detail_screen.dart';

class WidgetOutfitBig extends StatelessWidget {
  final List<dynamic> outfits;

Future<ImageProvider<Object>> _decodeImage(String? base64) async {
  try {
    if (base64 != null && base64.isNotEmpty) {
      final bytes = base64Decode(base64);
      return MemoryImage(bytes);
    }
  } catch (_) {}
  return const AssetImage('assets/mock/ropa_mock.png');
}


  const WidgetOutfitBig({
    super.key,
    required this.outfits,
  });

  @override
  Widget build(BuildContext context) {
    return PageView.builder(
      key: const ValueKey('page'),
      scrollDirection: Axis.vertical,
      itemCount: outfits.length,
      itemBuilder: (context, index) {
        final outfit = outfits[index];
        final imagenPrincipalFuture = _decodeImage(outfit['imagen']);

        return GestureDetector(
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => OutfitDetailScreen(outfit: outfit)),
          ),
          child: Column(
            children: [
              Expanded(
                child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
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
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Center(
                        child: Text(
                          outfit['titulo'] ?? 'Sin título',
                          style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        (outfit['ocasiones'] as List)
                            .map((o) => OcasionEnum.values.firstWhere((e) => e.name == o).value)
                            .join(', '),
                        style: const TextStyle(fontSize: 14, fontStyle: FontStyle.italic),
                      ),
                      const SizedBox(height: 12),
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
                                height: MediaQuery.of(context).size.height * 0.55,
                              ),
                            );
                          } else {
                            return const SizedBox();
                          }
                        },
                      ),
                      const SizedBox(height: 12),
                      Align(
                        alignment: Alignment.center,
                        child: Container(
                          padding: const EdgeInsets.all(6),
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
                                      height: 40,
                                      width: 40,
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(8),
                                        border: Border.all(color: Colors.black12),
                                        color: Colors.white,
                                      ),
                                      clipBehavior: Clip.antiAlias,
                                      child: Image(image: snapshot.data!, fit: BoxFit.cover),
                                    );
                                  } else {
                                    return const SizedBox(height: 40, width: 40);
                                  }
                                },
                              );
                            }).toList(),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const Padding(
                padding: EdgeInsets.only(bottom: 16),
                child: Icon(Icons.keyboard_arrow_down, size: 28, color: Colors.black38),
              ),
            ],
          ),
        );
      },
    );
  }
}
