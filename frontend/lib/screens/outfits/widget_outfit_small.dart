import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:frontend/enums/enums.dart';
import 'package:frontend/screens/outfits/selector_coleccion.dart';
import 'package:frontend/services/share_utils.dart';
import 'package:frontend/screens/utils/imagen_ajustada_widget.dart';

class WidgetOutfitSmall extends StatelessWidget {
  final List<dynamic> outfits;
  final void Function(BuildContext, Map<String, dynamic>) onTapOutfit;

  const WidgetOutfitSmall({
    super.key,
    required this.outfits,
    required this.onTapOutfit,
  });

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
                  if (imagen != null && imagen.isNotEmpty) {
                    ShareUtils.compartirOutfitSinMarca(
                      base64Imagen: imagen,
                      username: 'usuario',
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
            onTap: () => onTapOutfit(context, outfit),
            onLongPress: () => _mostrarModalOpciones(context, outfit),
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
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          outfit['titulo'] ?? 'Sin título',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.more_vert, size: 18),
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                        onPressed: () => _mostrarModalOpciones(context, outfit),
                      ),
                    ],
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
