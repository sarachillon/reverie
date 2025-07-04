import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:frontend/enums/enums.dart';
import 'package:frontend/screens/outfits/outfit_detail_screen.dart';
import 'package:frontend/screens/outfits/selector_coleccion.dart';
import 'package:frontend/services/share_utils.dart';
import 'package:frontend/screens/utils/imagen_ajustada_widget.dart';

class WidgetOutfitFeedBig extends StatelessWidget {
  final List<dynamic> outfits;

  const WidgetOutfitFeedBig({super.key, required this.outfits});

  void _mostrarModalOpciones(BuildContext context, dynamic outfit) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      backgroundColor: Colors.white,
      builder: (context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.bookmark_border),
                title: const Text('Guardar'),
                onTap: () {
                  Navigator.pop(context);
                  showModalBottomSheet(
                    context: context,
                    shape: const RoundedRectangleBorder(
                      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                    ),
                    builder: (_) => SelectorColeccionBottomSheet(outfitId: outfit['id']),
                  );
                },
              ),
              ListTile(
                leading: const Icon(Icons.ios_share),
                title: const Text('Compartir'),
                onTap: () {
                  Navigator.pop(context);
                  final imagen = outfit['imagen'];
                  final nombre = outfit['usuario']?['username'] ?? 'usuario';
                  if (imagen != null && imagen.isNotEmpty) {
                    ShareUtils.compartirOutfitSinMarca(
                      base64Imagen: imagen,
                      username: nombre,
                    );
                  }
                },
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return PageView.builder(
      key: const ValueKey('page'),
      scrollDirection: Axis.vertical,
      itemCount: outfits.length,
      itemBuilder: (context, index) {
        final outfit = outfits[index];
        final imagenUrl = outfit['imagen'] as String? ?? '';
        final username = outfit['usuario']?['username'] ?? 'demo_user';
        final fotoPerfil = outfit['usuario']?['foto_perfil'];
        final ocasiones = (outfit['ocasiones'] as List)
            .map((o) => OcasionEnum.values.firstWhere((e) => e.name == o).value)
            .join(', ');

        return GestureDetector(
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => OutfitDetailScreen(outfitId: outfit['id'] as int),
            ),
          ),
          onLongPress: () => _mostrarModalOpciones(context, outfit),
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
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Usuario + 3 puntos
                      Row(
                        children: [
                          fotoPerfil != null && fotoPerfil.isNotEmpty
                              ? CircleAvatar(
                                  radius: 20,
                                  backgroundImage: MemoryImage(
                                    fotoPerfil.contains(',')
                                        ? base64Decode(fotoPerfil.split(',').last)
                                        : base64Decode(fotoPerfil),
                                  ),
                                )
                              : CircleAvatar(
                                  radius: 20,
                                  backgroundColor: Colors.grey.shade300,
                                  child: const Icon(Icons.person, color: Colors.white),
                                ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              username,
                              style: const TextStyle(fontWeight: FontWeight.bold),
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.more_vert),
                            onPressed: () => _mostrarModalOpciones(context, outfit),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Center(
                        child: Text(
                          outfit['titulo'] ?? 'Sin título',
                          style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        ocasiones,
                        textAlign: TextAlign.center,
                        style: const TextStyle(fontSize: 14, fontStyle: FontStyle.italic),
                      ),
                      const SizedBox(height: 12),
                      Expanded(
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: ImagenAjustada(
                            url: imagenUrl,
                            width: double.infinity,
                            height: double.infinity,
                          ),
                        ),
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
                              final miniUrl = articulo['urlFirmada'] as String? ?? '';
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
                                child: ImagenAjustada(
                                  url: miniUrl,
                                  width: 40,
                                  height: 40,
                                ),
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
