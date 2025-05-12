import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:frontend/enums/enums.dart';

class OutfitWidget extends StatelessWidget {
  final Map<String, dynamic> outfit;
  final Future<ImageProvider<Object>> Function(String?) decodeBase64OrMock;

  const OutfitWidget({
    super.key,
    required this.outfit,
    required this.decodeBase64OrMock,
  });

  @override
  Widget build(BuildContext context) {
    final imagenPrincipalFuture = decodeBase64OrMock(outfit['imagen'] as String?);

    return Column(
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
            child: Stack(
              children: [
                Column(
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
                  ],
                ),
                Positioned(
                  right: 12,
                  top: MediaQuery.of(context).size.height * 0.25,
                  child: Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: const Color(0xFFC9A86A),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      children: (outfit['articulos_propios'] as List).take(5).map((articulo) {
                        final imagenMiniFuture = decodeBase64OrMock(articulo['imagen'] as String?);
                        return FutureBuilder<ImageProvider<Object>>(
                          future: imagenMiniFuture,
                          builder: (context, snapshot) {
                            if (snapshot.connectionState == ConnectionState.done && snapshot.hasData) {
                              return Container(
                                margin: const EdgeInsets.symmetric(vertical: 4),
                                height: 50,
                                width: 50,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(color: Colors.black12),
                                  color: Colors.white,
                                ),
                                clipBehavior: Clip.antiAlias,
                                child: Image(image: snapshot.data!, fit: BoxFit.cover),
                              );
                            } else {
                              return const SizedBox(height: 50, width: 50);
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
          child: Icon(Icons.keyboard_arrow_up, size: 28, color: Colors.black38),
        ),
      ],
    );
  }
}
