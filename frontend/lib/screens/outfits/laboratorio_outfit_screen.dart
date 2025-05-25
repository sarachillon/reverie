import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:frontend/enums/enums.dart';
import 'package:frontend/services/real_api_service.dart';
import '../utils/imagen_ajustada_widget.dart';

class LaboratorioScreen extends StatefulWidget {
  final int userId;
  const LaboratorioScreen({Key? key, required this.userId}) : super(key: key);

  @override
  _LaboratorioScreenState createState() => _LaboratorioScreenState();
}

class _LaboratorioScreenState extends State<LaboratorioScreen>
    with TickerProviderStateMixin {
  final RealApiService _api = RealApiService();
  late final StreamSubscription _subscription;
  List<Map<String, dynamic>> _articles = [];
  // ahora usamos GlobalKey para poder extraer estado de cada CollageItem
  final List<GlobalKey<_CollageItemState>> _itemKeys = [];
  final List<CollageItem> _items = [];
  final GlobalKey _canvasKey = GlobalKey();
  final TextEditingController _tituloController = TextEditingController();

  late TabController _mainTabController;
  late TabController _subTabController;
  final List<String> _categories = ['ROPA', 'CALZADO', 'ACCESORIOS'];
  final List<String> _subTabs = ['Arriba', 'Abajo', 'Cuerpo'];

  bool _searchMode = false;
  String _searchQuery = '';
  bool _showTrash = false;

  static const List<String> _arriba = [
    'CAMISAS', 'CAMISETAS', 'JERSEYS', 'TRAJES'
  ];
  static const List<String> _abajo = [
    'PANTALONES', 'VAQUEROS', 'FALDAS_CORTAS', 'FALDAS_LARGAS', 'BERMUDAS'
  ];
  static const List<String> _cuerpo = [
    'MONOS', 'VESTIDOS_CORTOS', 'VESTIDOS_LARGOS'
  ];

  @override
  void initState() {
    super.initState();
    _mainTabController = TabController(length: _categories.length, vsync: this)
      ..addListener(() {
        if (!_mainTabController.indexIsChanging) {
          setState(() {
            if (_mainTabController.index != 0) {
              _subTabController.index = 0;
            }
          });
        }
      });
    _subTabController = TabController(length: _subTabs.length, vsync: this)
      ..addListener(() {
        if (!_subTabController.indexIsChanging) setState(() {});
      });

    _subscription = _api
        .getArticulosPropiosStream(filtros: {'usuarioId': widget.userId})
        .listen(_onArticleEvent, onError: _onArticleError);
  }

  void _onArticleEvent(dynamic event) {
    if (!mounted) return;
    setState(() {
      if (event.containsKey('data') && event['data'] is List) {
        _articles = List<Map<String, dynamic>>.from(event['data']);
      } else {
        _articles.add(Map<String, dynamic>.from(event));
      }
    });
  }

  void _onArticleError(error) {
    if (!mounted) return;
    debugPrint('Error loading articles: $error');
  }

  @override
  void dispose() {
    _subscription.cancel();
    _mainTabController.dispose();
    _subTabController.dispose();
    _tituloController.dispose();
    super.dispose();
  }

  void _addItem(Map<String, dynamic> article) {
    final key = GlobalKey<_CollageItemState>();
    _itemKeys.add(key);
    setState(() {
      _items.add(
        CollageItem(
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
                _items.removeAt(idx);
                _itemKeys.removeAt(idx);
              });
            }
          },
        ),
      );
    });
  }

  void _clearGrid() => setState(() {
        _items.clear();
        _itemKeys.clear();
      });

Future<void> _saveManualOutfit() async {
  // 1) Renderizamos el canvas
  final boundary =
      _canvasKey.currentContext!.findRenderObject() as RenderRepaintBoundary;
  final image = await boundary.toImage(pixelRatio: 3.0);
  final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
  final pngBytes = byteData!.buffer.asUint8List();

  // 2) Construimos payload de items
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

  // 3) Diálogo de confirmación
    final saved = await showDialog<bool>(
    context: context,
    builder: (context) {
      String title = '';
      List<OcasionEnum> selectedOcasiones = [];

      return StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          backgroundColor: Colors.white,
          title: const Text('Guardar outfit'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Campo de título
                TextField(
                  decoration: const InputDecoration(
                    labelText: 'Título *',
                  ),
                  onChanged: (v) => setState(() => title = v.trim()),
                ),
                const SizedBox(height: 8),

                // Ocasiones
                const Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'Ocasión *',
                    style: TextStyle(fontSize: 14),
                  ),
                ),
                const SizedBox(height: 4),
                Wrap(
                  spacing: 4,
                  runSpacing: 4,
                  children: OcasionEnum.values.map((o) {
                    final isSelected = selectedOcasiones.contains(o);
                    return ChoiceChip(
                      label: Text(o.value, style: const TextStyle(fontSize: 12)),
                      selected: isSelected,
                      visualDensity: VisualDensity.compact,
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(100)),
                      showCheckmark: false,
                      onSelected: (sel) {
                        setState(() {
                          if (sel) {
                            selectedOcasiones.add(o);
                          } else {
                            selectedOcasiones.remove(o);
                          }
                        });
                      },
                    );
                  }).toList(),
                ),
                const SizedBox(height: 16),

                // Previsualización
                Container(
                  width: 260,
                  height: 260,
                  color: Colors.white,
                  child: Center(
                    child: Image.memory(
                      pngBytes,
                      width: 240,
                      height: 240,
                      fit: BoxFit.contain,
                    ),
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Cancelar'),
            ),
            ElevatedButton(
              // sólo habilita si hay título y al menos una ocasión
              onPressed: title.isNotEmpty && selectedOcasiones.isNotEmpty
                  ? () async {
                      final ok = await _api.crearOutfitManual(
                        titulo: title,
                        ocasiones: selectedOcasiones,
                        items: itemsPayload,
                        imagenBase64: base64Encode(pngBytes),
                      );
                      Navigator.of(context).pop(ok);
                    }
                  : null,
              child: const Text('Guardar'),
            ),
          ],
        ),
      );
    },
  );

  // 4) Feedback
  if (saved == true) {
    ScaffoldMessenger.of(context)
        .showSnackBar(const SnackBar(content: Text('Outfit guardado')));
  } else if (saved == false) {
    ScaffoldMessenger.of(context)
        .showSnackBar(const SnackBar(content: Text('Error al guardar')));
  }
}


  List<Map<String, dynamic>> _currentList() {
    final cat = _categories[_mainTabController.index];
    var list = _articles.where((a) => a['categoria'] == cat).toList();
    if (cat == 'ROPA') {
      if (_subTabController.index == 0) {
        list = list.where((a) => _arriba.contains(a['subcategoria'])).toList();
      } else if (_subTabController.index == 1) {
        list = list.where((a) => _abajo.contains(a['subcategoria'])).toList();
      } else {
        list = list.where((a) => _cuerpo.contains(a['subcategoria'])).toList();
      }
    }
    if (_searchMode && _searchQuery.isNotEmpty) {
      list = list
          .where((a) =>
              (a['nombre'] ?? '').toLowerCase().contains(_searchQuery))
          .toList();
    }
    return list;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Laboratorio de Outfits'),
        actions: [
          TextButton(
            onPressed: _saveManualOutfit,
            child: const Text(
              'Guardar Outfit',
              style:
                  TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: Stack(children: [
          Column(children: [
            Expanded(
              child: Stack(clipBehavior: Clip.none, children: [
                CustomPaint(size: Size.infinite, painter: _GridPainter()),
                RepaintBoundary(
                  key: _canvasKey,
                  child: Container(
                    color: Colors.transparent,
                    child: Stack(
                      clipBehavior: Clip.none,
                      children: _items,
                    ),
                  ),
                ),
              ]),
            ),
            const Divider(height: 1),
            _buildBottomPanel(),
          ]),
          if (_showTrash)
            const Positioned(
              top: 20,
              right: 20,
              child: Opacity(
                opacity: 0.7,
                child: Icon(Icons.delete, size: 30, color: Colors.black),
              ),
            ),
        ]),
      ),
    );
  }

  Widget _buildBottomPanel() {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        Row(children: [
          Expanded(
            child: _searchMode
                ? TextField(
                    decoration: const InputDecoration(
                        hintText: 'Buscar por nombre',
                        contentPadding:
                            EdgeInsets.symmetric(horizontal: 12)),
                    onChanged: (v) => setState(() => _searchQuery = v),
                  )
                : TabBar(
                    controller: _mainTabController,
                    tabs: _categories.map((c) => Tab(text: c)).toList(),
                    isScrollable: true,
                  ),
          ),
          IconButton(
            icon: Icon(_searchMode ? Icons.close : Icons.search),
            onPressed: () =>
                setState(() => _searchMode = !_searchMode),
          ),
          IconButton(
            onPressed: _clearGrid,
            icon: const Icon(Icons.cleaning_services),
          ),
        ]),
        const Divider(height: 0),
        if (_mainTabController.index == 0 && !_searchMode)
          TabBar(
            controller: _subTabController,
            tabs: _subTabs.map((s) => Tab(text: s)).toList(),
            labelColor: Theme.of(context).primaryColor,
            unselectedLabelColor: Colors.black54,
          ),
        const Divider(height: 0),
        SizedBox(
          height: 150,
          child: TabBarView(
            controller: _mainTabController,
            children: _categories.map((_) {
              final list = _currentList();
              return ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.all(12),
                itemCount: list.length,
                itemBuilder: (ctx, i) {
                  final article = list[i];
                  final url = article['urlFirmada'] as String?;
                  if (url == null || url.isEmpty) {
                    return const SizedBox(width: 90);
                  }
                  return GestureDetector(
                    onTap: () => _addItem(article),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      child: ImagenAjustada(
                        url: url,
                        width: 110,
                        height: 110,
                      ),
                    ),
                  );
                },
              );
            }).toList(),
          ),
        ),
      ]),
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
          _startRotation = rotation;        // <-- ROTACIÓN INICIAL
          _lastFocal = details.focalPoint;
        },
        onScaleUpdate: (details) {
          final dx = details.focalPoint.dx - _startFocal.dx;
          final dy = details.focalPoint.dy - _startFocal.dy;

          setState(() {
            // Muevo la imagen
            position = _startPos + Offset(dx, dy);
            
            // Ajusto el scale sólo si difiere lo suficiente de 1
            if ((details.scale - 1).abs() > 0.01) {
              scale = (_startScale * details.scale).clamp(0.5, 2.0);
            }
            
            // Ajusto la rotación sólo si supera un umbral
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
