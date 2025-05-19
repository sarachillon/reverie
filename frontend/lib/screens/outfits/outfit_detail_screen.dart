import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:frontend/enums/enums.dart';
import 'package:frontend/screens/armarioVirtual/articulo_propio_resumen.dart';

class OutfitDetailScreen extends StatelessWidget {
  final Map<String, dynamic> outfit;


  const OutfitDetailScreen({super.key, required this.outfit});

  @override
  Widget build(BuildContext context) {
    final String titulo = outfit['titulo'] ?? '';
    final String descripcion = outfit['descripcion'] ?? outfit['descripcion_generacion'] ?? '';
    final List<dynamic> articulos = outfit['articulos_propios'] ?? [];

    final List<String> ocasiones = (outfit['ocasiones'] as List?)?.map((o) =>
        OcasionEnum.values.firstWhere((e) => e.name == o, orElse: () => OcasionEnum.CASUAL).value).toList() ?? [];

    final List<String> temporadas = (outfit['temporadas'] as List?)?.map((t) =>
        TemporadaEnum.values.firstWhere((e) => e.name == t, orElse: () => TemporadaEnum.VERANO).value).toList() ?? [];

    final List<ColorEnum> colores = (outfit['colores'] as List?)?.map((c) =>
        ColorEnum.values.firstWhere((e) => e.name == c, orElse: () => ColorEnum.BLANCO)).toList() ?? [];

    Uint8List? imagenBytes;


    try {
      final raw = outfit['imagen'];
      if (raw != null && raw.isNotEmpty) {
        final base64Str = raw.contains(',') ? raw.split(',').last : raw;
        imagenBytes = base64Decode(base64Str);
      }
    } catch (e) {
      print("ERROR al decodificar imagen: $e");
    }

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: Theme.of(context).cardColor,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.chevron_left, color: Colors.black),
            onPressed: () => Navigator.pop(context),
          ),
          centerTitle: true,
          title: Image.asset('assets/logo_reverie_text.png', height: 32),
          bottom: const TabBar(
            labelColor: Colors.black,
            indicatorColor: Color(0xFFC9A86A),
            tabs: [
              Tab(text: 'Outfit completo'),
              Tab(text: 'Artículos'),
            ],
          ),
        ),
        body: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    titulo,
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
                    textAlign: TextAlign.center,
                  ),
                  if (descripcion.isNotEmpty) ...[
                    const SizedBox(height: 8),
                    Text(
                      descripcion,
                      textAlign: TextAlign.center,
                      style: const TextStyle(fontSize: 14),
                    ),
                  ],
                ],
              ),
            ),
            const Divider(),
            Expanded(
              child: TabBarView(
                children: [
                  // TAB 1: Outfit completo
                  ListView(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    children: [
                      if (imagenBytes != null)
                        Padding(
                          padding: const EdgeInsets.only(bottom: 24),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(16),
                            child: Image.memory(imagenBytes, fit: BoxFit.contain),
                          ),
                        ),
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF7F7F7),
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.05),
                              blurRadius: 4,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              "Información del outfit",
                              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 12),
                            _buildInfoRow("Ocasiones", ocasiones.join(', ')),
                            const SizedBox(height: 8),
                            _buildInfoRow("Temporadas", temporadas.join(', ')),
                            const SizedBox(height: 8),
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                const Text("Colores:", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                                const SizedBox(width: 8),
                                ...colores.map((c) => Container(
                                  width: 16,
                                  height: 16,
                                  margin: const EdgeInsets.only(right: 6),
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: _getColorFromEnum(c),
                                    border: Border.all(color: Colors.grey.shade600),
                                  ),
                                )),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),

                  // TAB 2: Artículos
                  ListView.builder(
                    padding: const EdgeInsets.all(12),
                    physics: const BouncingScrollPhysics(),
                    itemCount: articulos.length,
                    itemBuilder: (context, index) {
                      final articulo = articulos[index];
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: ArticuloPropioResumen(articulo: articulo, usuarioActual: outfit['usuario']),
                      );
                    },
                  ),

                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("$label: ", style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
          Expanded(child: Text(value, style: const TextStyle(fontSize: 14))),
        ],
      ),
    );
  }

  Color _getColorFromEnum(ColorEnum color) {
    switch (color) {
      case ColorEnum.AMARILLO: return Colors.yellow;
      case ColorEnum.NARANJA: return Colors.orange;
      case ColorEnum.ROJO: return Colors.red;
      case ColorEnum.ROSA: return Colors.pink;
      case ColorEnum.VIOLETA: return Colors.purple;
      case ColorEnum.AZUL: return Colors.blue;
      case ColorEnum.VERDE: return Colors.green;
      case ColorEnum.MARRON: return Colors.brown;
      case ColorEnum.GRIS: return Colors.grey;
      case ColorEnum.BLANCO: return Colors.white;
      case ColorEnum.NEGRO: return Colors.black;
    }
  }
}
