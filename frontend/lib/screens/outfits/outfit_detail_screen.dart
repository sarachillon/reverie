import 'package:flutter/material.dart';
import 'package:frontend/enums/enums.dart';
import 'package:frontend/screens/armarioVirtual/articulo_propio_resumen.dart';
import 'package:frontend/screens/outfits/edit_collage_screen.dart';
import 'package:frontend/screens/outfits/formulario_edit_outfit.dart';
import 'package:frontend/screens/utils/imagen_ajustada_widget.dart';
import 'package:frontend/services/api_manager.dart';

class OutfitDetailScreen extends StatefulWidget {
  final int outfitId;
  const OutfitDetailScreen({Key? key, required this.outfitId}) : super(key: key);

  @override
  _OutfitDetailScreenState createState() => _OutfitDetailScreenState();
}

class _OutfitDetailScreenState extends State<OutfitDetailScreen> {
  final ApiManager _api = ApiManager();
  Map<String, dynamic>? _outfit;
  int? _currentUserId;
  bool _loading = true;
  bool? updated;

  @override
  void initState() {
    super.initState();
    _fetchData();
  }

  Future<void> _fetchData() async {
    final me = await _api.getUsuarioActual();
    final detail = await _api.getOutfitById(id: widget.outfitId);
    if (!mounted) return;
    setState(() {
      _currentUserId = me['id'] as int;
      _outfit = detail;
      _loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_loading || _outfit == null) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    final outfit = _outfit!;
    final ownerId = (outfit['usuario'] as Map<String, dynamic>?)?['id'] as int? ?? -1;
    final isOwner = ownerId == _currentUserId;

    final String titulo = outfit['titulo'] as String? ?? '';
    final String descripcion = (outfit['descripcion'] as String?)
            ?? (outfit['descripcion_generacion'] as String?)
            ?? '';
    final List<Map<String, dynamic>> articulos =
        List<Map<String, dynamic>>.from((outfit['articulos_propios'] as List<dynamic>?) ?? []);
    final String? imagenUrl = outfit['imagen'] as String?;

    final String ocasiones = (outfit['ocasiones'] as List<dynamic>?)
            ?.map((o) => OcasionEnum.values.firstWhere((e) => e.name == o).value)
            .join(', ') ?? '';
    final String temporadas = (outfit['temporadas'] as List<dynamic>?)
            ?.map((t) => TemporadaEnum.values.firstWhere((e) => e.name == t).value)
            .join(', ') ?? '';
    final List<ColorEnum> colores = (outfit['colores'] as List<dynamic>?)
            ?.map((c) => ColorEnum.values.firstWhere((e) => e.name == c))
            .toList() ?? [];

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Theme.of(context).cardColor,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: const Color(0xFFD4AF37)),
            onPressed: () => Navigator.of(context).pop(updated),
          ),
          title: Image.asset('assets/logo_reverie_text.png', height: 32),
          centerTitle: true,
          actions: [
            if (isOwner)
              IconButton(
                icon: const Icon(Icons.edit, color: Color(0xFFD4AF37)),
                onPressed: () async {
                  updated = await Navigator.push<bool>(
                    context,
                    MaterialPageRoute(
                      builder: (_) => FormularioEditarOutfitScreen(
                        outfit: outfit,
                    ),
                  )
                  );
                  if (updated == true) {
                    setState(() {
                      _loading = true;
                      _fetchData();
                    });
                  }
                },
              ),
                if (isOwner)
      IconButton(
        icon: const Icon(Icons.delete, color: const Color(0xFFD4AF37)),
        tooltip: 'Eliminar outfit',
        onPressed: () async {
          final confirm = await showDialog<bool>(
            context: context,
            builder: (ctx) => AlertDialog(
              title: const Text('Eliminar outfit'),
              content: const Text('¿Seguro que quieres eliminar este outfit? Esta acción no se puede deshacer.'),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(ctx).pop(false),
                  child: const Text('Cancelar'),
                ),
                TextButton(
                  onPressed: () => Navigator.of(ctx).pop(true),
                  style: TextButton.styleFrom(foregroundColor: Colors.redAccent),
                  child: const Text('Eliminar'),
                ),
              ],
            ),
          );
          if (confirm == true) {
            try {
             await _api.deleteOutfitPropio(id: widget.outfitId);
              if (mounted) Navigator.of(context).pop(true); // Regresa a la pantalla anterior
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Outfit eliminado correctamente')),
              );
            } catch (e) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Error al eliminar outfit: $e')),
              );
            }
          }
        },
      ),
          ],
          bottom: const TabBar(
            labelColor: Colors.black,
            indicatorColor: Color(0xFFC9A86A),
            tabs: [
              Tab(text: 'Outfit completo'),
              Tab(text: 'Artículos'),
            ],
          ),
        ),
        body: TabBarView(
          physics: const NeverScrollableScrollPhysics(),
          children: [
            // ───────────────────────────────────
            // Tab 1: Outfit completo + panel fijo abajo
            Stack(
              children: [
                if (imagenUrl != null && imagenUrl.isNotEmpty)
                SizedBox(
                  width: double.infinity,
                  height: 500, // o la altura que quieras
                  child: ImagenAjustada(
                    url: imagenUrl,
                    width: double.infinity,
                    height: 500,
                  ),
                ),
                Align(
                  alignment: Alignment.bottomCenter,
                  child: Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                      boxShadow: [
                        BoxShadow(color: Colors.black.withOpacity(0.2), blurRadius: 8),
                      ],
                    ),
                    padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Pequeña línea indicador
                        Container(
                          width: 40,
                          height: 4,
                          margin: const EdgeInsets.only(bottom: 12),
                          decoration: BoxDecoration(
                            color: Colors.grey[400],
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),

                        // Título
                        Text(
                          titulo,
                          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                          textAlign: TextAlign.center,
                        ),

                        // Descripción
                        if (descripcion.isNotEmpty) ...[
                          const SizedBox(height: 8),
                          Text(descripcion),
                        ],

                        // Ocasiones
                        if (ocasiones.isNotEmpty) ...[
                          const SizedBox(height: 12),
                          _infoRow('Ocasiones', ocasiones),
                        ],

                        // Temporadas
                        if (temporadas.isNotEmpty) ...[
                          const SizedBox(height: 8),
                          _infoRow('Temporadas', temporadas),
                        ],

                        // Colores
                        if (colores.isNotEmpty) ...[
                          const SizedBox(height: 8),
                          const Align(
                            alignment: Alignment.centerLeft,
                            child: Text('Colores:', style: TextStyle(fontWeight: FontWeight.bold)),
                          ),
                          const SizedBox(height: 6),
                          Wrap(
                            spacing: 8,
                            children: colores
                                .map((c) => Container(
                                      width: 20,
                                      height: 20,
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        color: _getColorFromEnum(c),
                                        border: Border.all(color: Colors.grey.shade600),
                                      ),
                                    ))
                                .toList(),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              ],
            ),

            // ───────────────────────────────────
            // Tab 2: Artículos
            ListView.builder(
              padding: const EdgeInsets.all(12),
              itemCount: articulos.length,
              itemBuilder: (context, i) => Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: ArticuloPropioResumen(articulo: articulos[i], usuarioActual_id: _currentUserId),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _infoRow(String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('$label: ', style: const TextStyle(fontWeight: FontWeight.bold)),
        Expanded(child: Text(value)),
      ],
    );
  }

  Color _getColorFromEnum(ColorEnum color) {
    switch (color) {
      case ColorEnum.AMARILLO:
        return Colors.yellow;
      case ColorEnum.NARANJA:
        return Colors.orange;
      case ColorEnum.ROJO:
        return Colors.red;
      case ColorEnum.ROSA:
        return Colors.pink;
      case ColorEnum.VIOLETA:
        return Colors.purple;
      case ColorEnum.AZUL:
        return Colors.blue;
      case ColorEnum.VERDE:
        return Colors.green;
      case ColorEnum.MARRON:
        return Colors.brown;
      case ColorEnum.GRIS:
        return Colors.grey;
      case ColorEnum.BLANCO:
        return Colors.white;
      case ColorEnum.NEGRO:
        return Colors.black;
    }
  }
}
