import 'package:flutter/material.dart';
import 'package:frontend/screens/outfits/formulario_outfit_screen.dart';
import 'package:frontend/screens/outfits/filtros_outfit_screen.dart';
import 'package:frontend/screens/outfits/outfit_detail_screen.dart';
import 'package:frontend/screens/outfits/widget_outfit_feed_small.dart';
import 'package:frontend/screens/outfits/widget_outfit_small.dart';
import 'package:frontend/screens/outfits/widget_outfit_big.dart';
import 'package:frontend/services/api_manager.dart';
import 'package:google_fonts/google_fonts.dart';

class OutfitsScreen extends StatefulWidget {
  const OutfitsScreen({Key? key}) : super(key: key);

  @override
  State<OutfitsScreen> createState() => OutfitsScreenState();

  /// Utilidad estática para lanzar el formulario y, cuando vuelva con éxito,
  /// refrescar la pantalla completa.
  static Future<void> crearNuevoOutfit(BuildContext context) async {
    final nuevoOutfit = await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const FormularioOutfitScreen()),
    );

    if (nuevoOutfit != null) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const OutfitsScreen()),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Hubo un error al crear el outfit'),
          backgroundColor: Colors.redAccent,
          duration: Duration(seconds: 2),
        ),
      );
    }
  }
}

class OutfitsScreenState extends State<OutfitsScreen>
    with TickerProviderStateMixin {
  /* ────────────────────  STATE  ─────────────────── */
  final ApiManager _apiManager = ApiManager();
  final List<dynamic> _outfits = [];
  final List<dynamic> _colecciones = [];
  final TextEditingController _searchController = TextEditingController();

  bool _mostrarFiltros = false;
  bool _isSearching = false;
  bool _modoCuadricula = false;
  String _busqueda = '';
  Map<String, dynamic> filtros = {};
  Map<String, dynamic>? _usuarioActual;

  late final TabController _tabController;

  /* ────────────────────  INIT  ─────────────────── */
  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this)
      ..addListener(() {
        if (!_tabController.indexIsChanging) return;
        if (_tabController.index == 0) {
          cargarOutfits();
        } else if (_tabController.index == 1) {
          cargarColecciones();
        }
        setState(() {});
      });
    _inicializarPantalla();
  }

  Future<void> _inicializarPantalla() async {
    await cargarUsuarioActual();
    await Future.wait([
      cargarOutfits(),
    ]);
  }

  /* ────────────────────  API  ─────────────────── */
  Future<void> cargarUsuarioActual() async {
    try {
      final user = await _apiManager.getUsuarioActual();
      setState(() => _usuarioActual = user);
    } catch (e) {
      debugPrint('Error al obtener usuario: $e');
    }
  }

  Future<void> cargarOutfits() async {
    setState(() => _outfits.clear());
    try {
      final stream = _apiManager.getOutfitsPropiosStream(filtros: filtros);
      await for (final outfit in stream) {
        if (!mounted) return;
        setState(() => _outfits.add(outfit));
      }
    } catch (e) {
      debugPrint('Error al cargar outfits: $e');
    }
  }

  Future<void> cargarColecciones() async {
    try {
      final userId = _usuarioActual?['id'];
      if (userId == null) return;

      final data = await _apiManager.obtenerColeccionesDeUsuario(userId);
      setState(() {
        _colecciones
          ..clear()
          ..addAll(data);
      });
    } catch (e) {
      debugPrint('Error al cargar colecciones: $e');
    }
  }

  /* ─────────────────  ELIMINAR COLECCIÓN  ───────────────── */
  Future<void> _confirmarEliminarColeccion(int coleccionId) async {
    final bool? aceptar = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Eliminar colección'),
        content: const Text(
            '¿Seguro que deseas eliminar la colección?\nTodos los outfits guardados se quitarán de la lista.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFD4AF37),
              foregroundColor: Colors.white,
            ),
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );

    if (aceptar == true) {
      await _apiManager.deleteColeccion(coleccionId: coleccionId);
      if (!mounted) return;
      Navigator.pop(context); // cerrar el bottom‑sheet
      await cargarColecciones();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Colección eliminada')),
      );
    }
  }

  /* ────────────────────  UI HELPERS  ─────────────────── */
void _mostrarModalColeccion(
  int coleccionId,
  String nombre,
  List<dynamic> outfitsOriginal,
) {
  // hacemos una copia mutable
  List<dynamic> outfits = List.of(outfitsOriginal);

  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (context) => FractionallySizedBox(
      heightFactor: 0.85,
      child: StatefulBuilder(
        builder: (context, setStateModal) {
          return Container(
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
            ),
            child: Column(
              children: [
                const SizedBox(height: 8),
                // tirador
                Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade400,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(height: 12),
                // título + papelera
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        nombre,
                        style: GoogleFonts.poppins(
                          fontSize: 20,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete_outline),
                        onPressed: () => _confirmarEliminarColeccion(coleccionId),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                // lista de outfits
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: WidgetOutfitFeedSmall(
                      outfits: outfits,
                      toEliminateFromColection: true,
                      coleccionId: coleccionId,
                      coleccionNombre: nombre,
                      // ←--- aquí recibimos el id eliminado
                      onRemoved: (int id) {
                        setStateModal(() {
                          outfits.removeWhere((o) => o['id'] == id);
                        });
                        // refrescamos la lista de colecciones del tab principal
                        cargarColecciones();
                      },
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    ),
  );
}

  void _cerrarFiltros() => setState(() => _mostrarFiltros = false);

  /* ────────────────────  BUILD  ─────────────────── */
  @override
  Widget build(BuildContext context) {
    final outfitsFiltrados = _outfits.where((outfit) {
      final titulo = (outfit['titulo'] ?? '').toString().toLowerCase();
      return titulo.contains(_busqueda.toLowerCase());
    }).toList();

    return Scaffold(
      appBar: _buildAppBar(),
      body: Stack(
        children: [
          _buildTabBarView(outfitsFiltrados),
          _buildPanelFiltros(),
        ],
      ),
    );
  }

  /* ---------------- APP BAR ---------------- */
  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      centerTitle: true,
      title: _isSearching
          ? TextField(
              controller: _searchController,
              autofocus: true,
              onChanged: (v) => setState(() => _busqueda = v),
              style: const TextStyle(color: Colors.black),
              decoration: const InputDecoration(
                hintText: 'Buscar outfits...',
                border: InputBorder.none,
              ),
            )
          : Text(
              'Mis Outfits',
              style: GoogleFonts.dancingScript(
                fontSize: 30,
                color: const Color(0xFFD4AF37),
                fontWeight: FontWeight.w600,
              ),
            ),
      bottom: TabBar(
        controller: _tabController,
        indicatorColor: const Color(0xFFD4AF37),
        labelColor: const Color(0xFFD4AF37),
        unselectedLabelColor: Colors.black54,
        tabs: const [
          Tab(text: 'Mis Outfits'),
          Tab(text: 'Mis Colecciones'),
        ],
      ),
      leading: IconButton(
        icon: Icon(
          _modoCuadricula ? Icons.auto_awesome_mosaic : Icons.crop_portrait,
          color: const Color(0xFFD4AF37),
        ),
        onPressed: () => setState(() => _modoCuadricula = !_modoCuadricula),
      ),
      actions: [
        if (_tabController.index == 0)
          IconButton(
            icon: Icon(_isSearching ? Icons.close : Icons.search,
                color: const Color(0xFFD4AF37)),
            onPressed: () {
              setState(() {
                _isSearching = !_isSearching;
                if (!_isSearching) {
                  _searchController.clear();
                  _busqueda = '';
                }
              });
            },
          ),
        if (_tabController.index == 0)
          IconButton(
            icon: Icon(_mostrarFiltros ? Icons.close : Icons.filter_alt,
                color: const Color(0xFFD4AF37)),
            onPressed: () =>
                setState(() => _mostrarFiltros = !_mostrarFiltros),
          ),
        if (_tabController.index == 1)
          IconButton(
            icon: const Icon(Icons.add, color: Color(0xFFD4AF37)),
            onPressed: _crearColeccion,
          ),
      ],
    );
  }

  /* ---------------- TAB BAR VIEW ---------------- */
  Widget _buildTabBarView(List<dynamic> outfitsFiltrados) {
    return TabBarView(
      controller: _tabController,
      children: [
        // ─── TAB 1: Mis outfits ──────────────────────────────────────────
        AnimatedSwitcher(
          duration: const Duration(milliseconds: 300),
          child: _modoCuadricula
              ? WidgetOutfitSmall(
                  outfits: outfitsFiltrados,
                  onTapOutfit: _onTapOutfit,
                )
              : WidgetOutfitBig(
                  outfits: outfitsFiltrados,
                  onTapOutfit: _onTapOutfit,
                ),
        ),

        // ─── TAB 2: Colecciones guardadas ───────────────────────────────
        _colecciones.isEmpty
            ? _buildVacioColecciones()
            : ListView.builder(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                itemCount: _colecciones.length,
                itemBuilder: (context, index) {
                  final coleccion = _colecciones[index];
                  final List<dynamic> outfits = coleccion['outfits'] ?? [];
                  final String nombre = coleccion['nombre'] ?? 'Sin título';
                  final primerosOutfits = outfits.take(2).toList();

                  return Card(
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                    elevation: 2,
                    margin: const EdgeInsets.symmetric(vertical: 8),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 6, vertical: 5),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                "    " + nombre,
                                style: const TextStyle(
                                    fontSize: 18, fontWeight: FontWeight.bold),
                              ),
                              TextButton(
                                onPressed: () => _mostrarModalColeccion(
                                    coleccion['id'], nombre, outfits),
                                child: const Text('Ver más'),
                              ),
                            ],
                          ),
                          outfits.isEmpty
                              ? const Padding(
                                  padding: EdgeInsets.symmetric(vertical: 12),
                                  child: Center(
                                    child: Text(
                                      'Esta colección está vacía.',
                                      style: TextStyle(color: Colors.grey),
                                    ),
                                  ),
                                )
                              : SizedBox(
                                  height: 300,
                                  child: WidgetOutfitFeedSmall(
                                    outfits: outfits,
                                  ),
                                ),
                        ],
                      ),
                    ),
                  );
                },
              ),
      ],
    );
  }

  /* ---------------- EMPTY STATE COLECCIONES ---------------- */
  Widget _buildVacioColecciones() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: const [
          Icon(Icons.folder_open, size: 64, color: Colors.grey),
          SizedBox(height: 12),
          Text(
            'No tienes colecciones aún. Crea una para añadir outfits.',
            style: TextStyle(color: Colors.grey),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  /* ---------------- PANEL FILTROS ---------------- */
  Widget _buildPanelFiltros() {
    return AnimatedPositioned(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
      top: 0,
      right: _mostrarFiltros
          ? 0
          : -MediaQuery.of(context).size.width * 0.8,
      bottom: 0,
      width: MediaQuery.of(context).size.width * 0.8,
      child: Material(
        elevation: 16,
        child: FiltrosOutfitScreen(
          filtrosIniciales: filtros,
          onAplicar: (nuevosFiltros) {
            setState(() {
              filtros = nuevosFiltros;
              _mostrarFiltros = false;
            });
            cargarOutfits();
          },
          onCerrar: _cerrarFiltros,
        ),
      ),
    );
  }

  /* ---------------- HELPERS ---------------- */
  void _onTapOutfit(BuildContext context, Map<String, dynamic> outfit) async {
    final eliminado = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (_) => OutfitDetailScreen(outfitId: outfit['id']),
      ),
    );
    if (eliminado == true) cargarOutfits();
  }

  Future<void> _crearColeccion() async {
    final userId = _usuarioActual?['id'];
    if (userId == null) return;

    final nombre = await showDialog<String>(
      context: context,
      builder: (context) {
        final controller = TextEditingController();
        return AlertDialog(
          title: const Text('Nueva colección'),
          content: TextField(
            controller: controller,
            decoration:
                const InputDecoration(hintText: 'Nombre de la colección'),
            autofocus: true,
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancelar'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pop(context, controller.text.trim()),
              child: const Text('Crear'),
            ),
          ],
        );
      },
    );

    if (nombre != null && nombre.isNotEmpty) {
      await _apiManager.crearColeccion(nombre: nombre, userId: userId);
      await cargarColecciones();
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Colección creada')),
      );
    }
  }
}
