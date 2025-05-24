import 'dart:async';
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
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
  List<CollageItem> _items = [];
  final GlobalKey _canvasKey = GlobalKey();

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
    _mainTabController = TabController(
      length: _categories.length,
      vsync: this,
    )..addListener(() {
        if (!_mainTabController.indexIsChanging) {
          setState(() {
            if (_mainTabController.index != 0) {
              _subTabController.index = 0;
            }
          });
        }
      });
    _subTabController = TabController(
      length: _subTabs.length,
      vsync: this,
    )..addListener(() {
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
    debugPrint('Error loading articles: \$error');
  }

  @override
  void dispose() {
    _subscription.cancel();
    _mainTabController.dispose();
    _subTabController.dispose();
    super.dispose();
  }

void _addItem(Map<String, dynamic> article) {
  final key = UniqueKey();
  setState(() {
    _items.add(
      CollageItem(
        key: key,
        article: article,
        onRemove: () => setState(() => _items.removeWhere((w) => w.key == key)),
        onDragStart: () => setState(() => _showTrash = true),
        onDragEnd: (offset) {
          // ocultamos el icono de papelera
          setState(() => _showTrash = false);

          final screen = MediaQuery.of(context).size;
          const double iconSize = 30.0;
          const double padding = 20.0;

          // Definimos el área de la papelera en la esquina superior derecha,
          // 20px de margen, icono de 30px y 120px de tolerancia
          final trashRect = Rect.fromLTWH(
            screen.width - padding - iconSize,
            padding,
            iconSize,
            iconSize,
          ).inflate(120.0);

          // Si el punto final del gesto (offset) cae dentro de esa área,
          // eliminamos el elemento
          if (trashRect.contains(offset)) {
            setState(() => _items.removeWhere((w) => w.key == key));
          }
        },
      ),
    );
  });
}






  void _clearGrid() => setState(() => _items.clear());


  Future<void> _saveOutfit() async {
    final boundary =
        _canvasKey.currentContext!.findRenderObject() as RenderRepaintBoundary;
    final image = await boundary.toImage(pixelRatio: 3.0);
    final byteData = await
        image.toByteData(format: ui.ImageByteFormat.png);
    final pngBytes = byteData!.buffer.asUint8List();
    if (!mounted) return;
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => Scaffold(
          appBar: AppBar(title: const Text('Mi Collage')),
          body: Center(child: Image.memory(pngBytes)),
        ),
      ),
    );
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
          .where((a) => (a['nombre'] ?? '')
              .toLowerCase()
              .contains(_searchQuery.toLowerCase()))
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
          IconButton(onPressed: _clearGrid, icon: const Icon(Icons.clear_all)),
          TextButton(
            onPressed: _saveOutfit,
            child: const Text(
              'Guardar Outfit',
              style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 16),
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: Stack(
          children: [
            Column(
              children: [
                Expanded(
                  child: Stack(
                    clipBehavior: Clip.none,
                    children: [
                      CustomPaint(size: Size.infinite, painter: _GridPainter()),
                      RepaintBoundary(
                        key: _canvasKey,
                        child: Container(
                          color: Colors.transparent,
                          child: Stack(
                              clipBehavior: Clip.none, children: _items),
                        ),
                      ),
                    ],
                  ),
                ),
                const Divider(height: 1),
                _buildBottomPanel(),
              ],
            ),
            if (_showTrash)
              Positioned(
                top: 10,
                right: 10,
                child: Opacity(
                  opacity: 0.7,
                  child: Icon(
                    Icons.delete,
                    size: 30,
                    color: Colors.black,
                  ),
                ),
              )
          ],
        ),
      ),
    );
  }

  Widget _buildBottomPanel() {
  return Container(
    color: Colors.white,
    padding: const EdgeInsets.symmetric(vertical: 8),
    child: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          children: [
            Expanded(
              child: _searchMode
                  ? TextField(
                      decoration: const InputDecoration(
                        hintText: 'Buscar por nombre',
                        contentPadding: EdgeInsets.symmetric(horizontal: 12),
                      ),
                      onChanged: (v) => setState(() => _searchQuery = v),
                    )
                  : TabBar(
                      controller: _mainTabController,
                      tabs: _categories.map((c) => Tab(text: c)).toList(),
                      isScrollable: true,
                      indicatorSize: TabBarIndicatorSize.tab,
                    ),
            ),
            IconButton(
              icon: Icon(_searchMode ? Icons.close : Icons.search),
              onPressed: () => setState(() {
                _searchMode = !_searchMode;
                _searchQuery = '';
              }),
            ),
            IconButton(
              onPressed: _clearGrid,
              icon: const Icon(Icons.cleaning_services),
              tooltip: 'Limpiar grid',
            ),
          ],
        ),
        const Divider(height: 0),

        // Sub-tabs sólo para sección RO PA
        if (_mainTabController.index == 0 && !_searchMode) ...[
          TabBar(
            controller: _subTabController,
            tabs: _subTabs.map((s) => Tab(text: s)).toList(),
            labelColor: Theme.of(context).primaryColor,
            unselectedLabelColor: Colors.black54,
            indicatorColor: Theme.of(context).primaryColor,
          ),
        ],
        const Divider(height: 0),
        // Lista de artículos
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
      ],
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
  Offset _position = const Offset(100, 100);
  double _scale = 1.0;
  late Offset _startFocalPoint;
  late Offset _startPosition;
  late double _startScale;
  late Offset _lastGlobalFocal;
  bool _hapticTriggered = false;

  @override
  Widget build(BuildContext context) {
    final screen = MediaQuery.of(context).size;
    final trashRect = Rect.fromLTWH(
      (screen.width - 60) / 2,
      screen.height - 180,
      60,
      60,
    );
    return Positioned(
      left: _position.dx,
      top: _position.dy,
      child: GestureDetector(
        behavior: HitTestBehavior.translucent,
        onScaleStart: (details) {
          widget.onDragStart();
          _startFocalPoint = details.focalPoint;
          _startPosition = _position;
          _startScale = _scale;
          _lastGlobalFocal = details.focalPoint;
          _hapticTriggered = false;
        },
        onScaleUpdate: (details) {
          setState(() {
            _lastGlobalFocal = details.focalPoint;
            _position =
                _startPosition + (details.focalPoint - _startFocalPoint);
            _scale = (_startScale * details.scale).clamp(0.5, 2.0);
          });
          if (!_hapticTriggered && trashRect.contains(_lastGlobalFocal)) {
            HapticFeedback.lightImpact();
            _hapticTriggered = true;
          }
        },
        onScaleEnd: (details) {
          widget.onDragEnd(_lastGlobalFocal);
          if (trashRect.contains(_lastGlobalFocal)) {
            widget.onRemove();
          }
        },
        child: Transform(
          origin: const Offset(55, 55),
          transform: Matrix4.identity()..scale(_scale),
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
