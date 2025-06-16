import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:frontend/enums/enums.dart';
import 'package:frontend/screens/outfits/outfit_detail_screen.dart';
import 'package:frontend/screens/outfits/selector_coleccion.dart';
import 'package:frontend/screens/perfil/perfil_screen.dart';
import 'package:frontend/screens/armarioVirtual/armario_screen.dart';
import 'package:frontend/screens/utils/imagen_ajustada_widget.dart';
import 'package:frontend/services/api_manager.dart';

class WidgetOutfitFeedSmall extends StatelessWidget {
  final List<dynamic> outfits;
  final bool toEliminateFromColection;
  final int? coleccionId;
  final String? coleccionNombre;
  final void Function(int outfitId)? onRemoved;

  WidgetOutfitFeedSmall({
    super.key,
    required this.outfits,
    this.toEliminateFromColection = false,
    this.coleccionId,
    this.coleccionNombre,
    this.onRemoved,
  }) : assert(
          !toEliminateFromColection || coleccionId != null,
          'Se requiere coleccionId cuando toEliminateFromColection es true',
        );

  final GlobalKey<ArmarioScreenState> armarioKey = GlobalKey<ArmarioScreenState>();

  void _removeFromCollection(BuildContext context, int outfitId) async {
    try {
      await ApiManager().removeOutfitDeColeccion(
        coleccionId: coleccionId!,
        outfitId: outfitId,
      );
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Outfit eliminado de la colección')),
      );
      onRemoved?.call(outfitId);
    } catch (e) {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error al eliminar: \$e'),
          backgroundColor: Colors.redAccent,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(12),
      child: GridView.builder(
        shrinkWrap: true,
        physics: const BouncingScrollPhysics(),
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

          void _showSaveSheet() {
            showModalBottomSheet(
              context: context,
              shape: const RoundedRectangleBorder(
                borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
              ),
              builder: (_) => SelectorColeccionBottomSheet(outfitId: outfit['id']),
            );
          }

          void _showMenuSheet() {
            showModalBottomSheet(
              context: context,
              shape: const RoundedRectangleBorder(
                borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
              ),
              backgroundColor: Colors.white,
              builder: (_) {
                return SafeArea(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      ListTile(
                        leading: const Icon(Icons.bookmark_border),
                        title: const Text('Guardar'),
                        onTap: () {
                          Navigator.pop(context);
                          _showSaveSheet();
                        },
                      ),
                      if (toEliminateFromColection)
                        ListTile(
                          leading:
                              const Icon(Icons.delete_outline),
                          title: Text('Eliminar de la colección ${coleccionNombre ?? ''}'),
                          onTap: () =>
                              _removeFromCollection(context, outfit['id'] as int),
                        ),
                    ],
                  ),
                );
              },
            );
          }

          return GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) =>
                      OutfitDetailScreen(outfitId: outfit['id'] as int),
                ),
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
                  Row(
                    children: [
                      GestureDetector(
                        onTap: () {
                          final userId = outfit['usuario']?['id'];
                          if (userId != null) {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => PerfilScreen(
                                    userId: userId,
                                    armarioKey: armarioKey),
                              ),
                            );
                          }
                        },
                        child: CircleAvatar(
                          radius: 20,
                          backgroundColor: Colors.grey.shade300,
                          backgroundImage: (fotoPerfil != null && fotoPerfil.isNotEmpty && !fotoPerfil.contains('http'))
                              ? MemoryImage(base64Decode(
                                  fotoPerfil.contains(',') ? fotoPerfil.split(',').last : fotoPerfil))
                              : (fotoPerfil != null && fotoPerfil.contains('http'))
                                  ? NetworkImage(fotoPerfil)
                                  : null,
                          child: (fotoPerfil == null || fotoPerfil.isEmpty)
                              ? const Icon(Icons.person, color: Colors.white)
                              : null,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          username,
                          style: const TextStyle(
                              fontSize: 12, fontWeight: FontWeight.bold),
                        ),
                      ),
                      if (toEliminateFromColection)
                        IconButton(
                          icon: const Icon(Icons.more_vert, size: 20),
                          onPressed: _showMenuSheet,
                        )
                      else
                        IconButton(
                          icon: const Icon(Icons.bookmark_border, size: 20),
                          onPressed: _showSaveSheet,
                        ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    outfit['titulo'] ?? 'Sin título',
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                        fontSize: 14, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    ocasiones,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                        fontSize: 11, fontStyle: FontStyle.italic),
                  ),
                  const SizedBox(height: 6),
                  Expanded(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: ImagenAjustada(
                        url: imagenUrl,
                        width: double.infinity,
                        height: double.infinity,
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
