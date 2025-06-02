import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:frontend/services/real_api_service.dart';
import 'package:google_fonts/google_fonts.dart';
import '../utils/imagen_ajustada_widget.dart';

class EditCollageScreen extends StatefulWidget {
  final int outfitId;
  final List<Map<String, dynamic>> initialItems;

  const EditCollageScreen({
    Key? key,
    required this.outfitId,
    required this.initialItems, required Map<String, dynamic> outfit,
  }) : super(key: key);

  @override
  _EditCollageScreenState createState() => _EditCollageScreenState();
}

class _EditCollageScreenState extends State<EditCollageScreen>
    with TickerProviderStateMixin {
  final RealApiService _api = RealApiService();
  final List<GlobalKey<_CollageItemState>> _itemKeys = [];
  final List<CollageItem> _items = [];
  final GlobalKey _canvasKey = GlobalKey();
  bool _loading = true;
  bool _showTrash = false;
  List<Map<String, dynamic>> _articulos = [];

  @override
  void initState() {
    super.initState();
    _loadArticles();
  }

  Future<void> _loadArticles() async {
    List<Map<String, dynamic>> articulos = [];
    for (var item in widget.initialItems) {
      final article = await _api.getArticuloPropioPorId(id: item['articulo_id']);
      final urlFirmada = article['urlFirmada'] as String?;
      if (urlFirmada != null && urlFirmada.isNotEmpty) {
        articulos.add(article..['__itemData'] = item); // Guardamos el itemData para cuando se añada
      }
    }
    setState(() {
      _articulos = articulos;
      _loading = false;
    });
  }

void _addItem(Map<String, dynamic> article, Map<String, dynamic> initialData) {
  final key = GlobalKey<_CollageItemState>();
  _itemKeys.add(key);
  setState(() {
    _items.add(CollageItem(
      key: key,
      article: article,
      onRemove: () {
        setState(() {
          final idx = _items.indexWhere((w) => w.key == key);
          _items.removeAt(idx);
          _itemKeys.removeAt(idx);
        });
      },
      onDragStart: () => setState(() => _showTrash = true),
      onDragEnd: (offset) {
        setState(() => _showTrash = false);

        // --- ZONA DE BORRADO ---
        final screen = MediaQuery.of(context).size;
        const iconSize = 30.0, padding = 20.0;
        final trashArea = Rect.fromLTWH(
          screen.width - padding - iconSize,
          padding,
          iconSize,
          iconSize,
        ).inflate(120);

        if (trashArea.contains(offset)) {
          setState(() {
            final idx = _items.indexWhere((w) => w.key == key);
            if (idx != -1) {
              _items.removeAt(idx);
              _itemKeys.removeAt(idx);
            }
          });
        }
      },
    ));
  });
}




  Future<void> _showPreviewDialog(Uint8List pngBytes, {bool confirmButton = false, VoidCallback? onConfirm}) async {
  await showDialog(
    context: context,
    barrierDismissible: !confirmButton,
    builder: (_) => AlertDialog(
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      title: Center(
        child: Text(
          'Previsualización del collage',
          style: GoogleFonts.dancingScript(
            fontSize: 28,
            color: const Color(0xFFD4AF37),
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
      content: Container(
        width: 260,
        height: 260,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          color: Colors.grey[50],
        ),
        child: Center(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: Image.memory(
              pngBytes,
              width: 240,
              height: 240,
              fit: BoxFit.contain,
            ),
          ),
        ),
      ),
      actionsAlignment: MainAxisAlignment.center,
      actions: [
        TextButton(
          style: TextButton.styleFrom(
            foregroundColor: Colors.grey[700],
            textStyle: const TextStyle(fontSize: 15),
          ),
          onPressed: () => Navigator.of(context).pop(false),
          child: const Text('Cancelar'),
        ),
        if (confirmButton)
          ElevatedButton(
            onPressed: onConfirm,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFD4AF37),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            ),
            child: const Text('Guardar collage', style: TextStyle(color: Colors.white, fontSize: 15)),
          ),
      ],
    ),
  );
}

Future<void> _saveCollage() async {
  final expectedIds = widget.initialItems.map((e) => e['articulo_id']).toSet();
  final presentIds = _items.map((w) => w.article['id']).toSet();
  if (expectedIds.difference(presentIds).isNotEmpty) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Debes colocar todos los artículos antes de guardar el collage.')),
    );
    return;
  }

  final boundary = _canvasKey.currentContext!.findRenderObject() as RenderRepaintBoundary;
  final image = await boundary.toImage(pixelRatio: 3.0);
  final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
  final pngBytes = byteData!.buffer.asUint8List();
  final base64Img = base64Encode(pngBytes);

  final itemsPayload = <Map<String, dynamic>>[];
  for (var i = 0; i < _items.length; i++) {
    final state = _itemKeys[i].currentState!;
    itemsPayload.add({
      'articulo_id': _items[i].article['id'],
      'x': state.position.dx,
      'y': state.position.dy,
      'scale': state.scale,
      'rotation': state.rotation,
      'z_index': i,
    });
  }

  final confirm = await showDialog<bool>(
    context: context,
    barrierDismissible: false,
    builder: (_) => AlertDialog(
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      title: Center(
        child: Text( 'Previsualización del collage' ),
      ),
      content: Container(
        width: 260,
        height: 260,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          color: Colors.grey[50],
        ),
        child: Center(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: Image.memory(
              pngBytes,
              width: 240,
              height: 240,
              fit: BoxFit.contain,
            ),
          ),
        ),
      ),
      actionsAlignment: MainAxisAlignment.center,
      actions: [
        TextButton(
          style: TextButton.styleFrom(
            foregroundColor: Colors.grey[700],
            textStyle: const TextStyle(fontSize: 15),
          ),
          onPressed: () => Navigator.of(context).pop(false),
          child: const Text('Cancelar'),
        ),
        ElevatedButton(
          onPressed: () => Navigator.of(context).pop(true),
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFFD4AF37),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          ),
          child: const Text('Guardar collage', style: TextStyle(color: Colors.white, fontSize: 15)),
        ),
      ],
    ),
  );

  if (confirm == true) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const Center(child: CircularProgressIndicator()),
    );
    try {
      await _api.editarCollageOutfitPropio(
        outfitId: widget.outfitId,
        items: itemsPayload,
        imagenBase64: base64Img,
      );
      if (mounted) {
        Navigator.pop(context); // cierra loader
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Collage guardado correctamente')),
        );
        Navigator.pop(context, true); // Sale y notifica éxito
      }
    } catch (e) {
      if (mounted) {
        Navigator.pop(context); // cierra loader
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al guardar collage: $e')),
        );
      }
    }
  }
}


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(leading: IconButton(
        icon: const Icon(Icons.arrow_back, color: Color(0xFFD4AF37)),
        onPressed: () => Navigator.pop(context),
      ),
        title: Text(
        'Editar Collage',
        style: GoogleFonts.dancingScript(
          fontSize: 30,
          color: Color(0xFFD4AF37),
          fontWeight: FontWeight.w600,
        ),
      ),
        actions: [
          IconButton(
            icon: const Icon(Icons.save, color: Color(0xFFD4AF37)),
            onPressed: _saveCollage,
          ),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : SafeArea(
              child: Column(
                children: [
                  Expanded(
                    child: Stack(
                      children: [
                        // Fondo de puntos
                        CustomPaint(
                          size: Size.infinite,
                          painter: _GridPainter(),
                        ),
                        // Collage que se guarda (sin fondo)
                        RepaintBoundary(
                          key: _canvasKey,
                          child: Container(
                            color: Colors.transparent,
                            child: Stack(children: _items),
                          ),
                        ),
                        if (_showTrash)
                          const Positioned(
                            top: 20,
                            right: 20,
                            child: Opacity(
                              opacity: 0.7,
                              child: Icon(Icons.delete, size: 30, color: Colors.black),
                            ),
                          ),
                      ],
                    ),
                  ),

                  Container(
                    height: 130,
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    color: Colors.white,
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      itemCount: _articulos.length,
                      separatorBuilder: (_, __) => const SizedBox(width: 16),
                      itemBuilder: (ctx, i) {
                        final article = _articulos[i];
                        final url = article['urlFirmada'] as String?;
                        final itemData = article['__itemData'] as Map<String, dynamic>;
                        return url == null
                            ? const SizedBox.shrink()
                            : GestureDetector(
                                onTap: () => _addItem(article, itemData),
                                child: ImagenAjustada(
                                  url: url,
                                  width: 90,
                                  height: 90,
                                ),
                              );
                      },
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}

class _GridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    const step = 40.0;
    final paint = Paint()..color = Colors.grey.withOpacity(0.6);
    for (double x = 0; x < size.width; x += step) {
      for (double y = 0; y < size.height; y += step) {
        canvas.drawCircle(Offset(x, y), 1, paint);
      }
    }
  }
  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}


class CollageItem extends StatefulWidget {
  final Map<String, dynamic> article;
  final VoidCallback onRemove;
  final VoidCallback onDragStart;
  final void Function(Offset) onDragEnd;

  const CollageItem({
    Key? key,
    required this.article,
    required this.onRemove,
    required this.onDragStart,
    required this.onDragEnd,
  }) : super(key: key);

  @override
  _CollageItemState createState() => _CollageItemState();
}

class _CollageItemState extends State<CollageItem> {
  Offset position = const Offset(100, 100);
  double scale = 1.0;
  double rotation = 0.0;

  // Guarda estado al iniciar el gesto
  late Offset _startFocal, _startPos, _lastFocal;
  late double _startScale, _startRotation;

  @override
  Widget build(BuildContext context) {
    return Positioned(
      left: position.dx,
      top: position.dy,
      child: GestureDetector(
        behavior: HitTestBehavior.translucent,
        onScaleStart: (details) {
          widget.onDragStart();
          _startFocal = details.focalPoint;
          _startPos = position;
          _startScale = scale;
          _startRotation = rotation;      
          _lastFocal = details.focalPoint;
        },
        onScaleUpdate: (details) {
          final dx = details.focalPoint.dx - _startFocal.dx;
          final dy = details.focalPoint.dy - _startFocal.dy;

          setState(() {
            // Mueve la imagen
            position = _startPos + Offset(dx, dy);

            // Ajusta el scale sólo si difiere lo suficiente de 1
            if ((details.scale - 1).abs() > 0.01) {
              scale = (_startScale * details.scale).clamp(0.5, 2.0);
            }

            // Ajusta la rotación sólo si supera un umbral
            if (details.rotation.abs() > 0.01) {
              rotation = _startRotation + details.rotation;
            }
          });

          _lastFocal = details.focalPoint;
        },
        onScaleEnd: (details) =>
          widget.onDragEnd(_lastFocal),
        child: Transform(
          origin: const Offset(55, 55),
          transform: Matrix4.identity()
            ..translate(55.0, 55.0)
            ..rotateZ(rotation)
            ..scale(scale)
            ..translate(-55.0, -55.0),
          child: ImagenAjustada(
            url: widget.article['urlFirmada'],
            width: 110,
            height: 110,
          ),
        ),
      ),
    );
  }
}
