import 'package:flutter/material.dart';
import 'package:frontend/screens/armarioVirtual/filtros_articulo_propio_screen.dart';
import 'package:frontend/screens/armarioVirtual/subir_foto_screen.dart';
import 'package:frontend/screens/armarioVirtual/articulo_propio_widget.dart';
import 'package:frontend/services/api_manager.dart';

class ArmarioScreen extends StatefulWidget {
  const ArmarioScreen({super.key});

  @override
  State<ArmarioScreen> createState() => _ArmarioScreenState();
}

class _ArmarioScreenState extends State<ArmarioScreen> {
  final ApiManager _apiManager = ApiManager();
  bool _mostrarFiltros = false;
  final List<dynamic> _articulos = [];
  final TextEditingController _searchController = TextEditingController();
  String _busqueda = '';
  Map<String, dynamic> filtros = {};

  @override
  void initState() {
    super.initState();
    _cargarArticulosPropios();
  }

  Future<void> _cargarArticulosPropios() async {
    setState(() {
      _articulos.clear();
    });
    try {
      final stream = _apiManager.getArticulosPropiosStream(filtros: filtros);
      await for (final articulo in stream) {
        if (!mounted) return;
        setState(() {
          _articulos.add(articulo);
        });
      }
    } catch (e) {
      print("Error al cargar artículos propios: $e");
    }
  }

  void _cerrarFiltros() {
    setState(() {
      _mostrarFiltros = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mi Armario'),
      ),
      body: Stack(
        children: [
          Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(10, 10, 10, 0),
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _searchController,
                        onChanged: (value) {
                          setState(() {
                            _busqueda = value;
                          });
                        },
                        decoration: InputDecoration(
                          hintText: 'Buscar por nombre',
                          prefixIcon: const Icon(Icons.search),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(100),
                          ),
                          isDense: true,
                          contentPadding: const EdgeInsets.all(10),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    IconButton(
                      icon: const Icon(Icons.filter_alt),
                      onPressed: () => setState(() => _mostrarFiltros = true),
                      tooltip: 'Mostrar filtros',
                    ),
                  ],
                ),
              ),
              Expanded(
                child: RefreshIndicator(
                  onRefresh: _cargarArticulosPropios,
                  child: _articulos.isEmpty
                      ? const Center(child: Text('No se encontraron artículos.'))
                      : GridView.builder(
                          key: PageStorageKey('grid'),
                          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            crossAxisSpacing: 10,
                            mainAxisSpacing: 10,
                            childAspectRatio: 0.75,
                          ),
                          padding: const EdgeInsets.all(10),
                          itemCount: _articulos.length,
                          itemBuilder: (context, index) {
                            final articulo = _articulos[index];
                            if (articulo is! Map<String, dynamic> || !articulo.containsKey('nombre')) {
                              return const Card(
                                child: Center(child: Text('Artículo inválido')),
                              );
                            }
                            final nombre = articulo['nombre'] as String? ?? 'Sin nombre';
                            return KeepAliveWrapper(
                              child: ArticuloPropioWidget(
                                nombre: nombre,
                                articulo: articulo,
                                onTap: _cargarArticulosPropios,
                              ),
                            );
                          },
                        ),
                ),
              ),
            ],
          ),
          AnimatedPositioned(
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut,
            top: 0,
            right: _mostrarFiltros ? 0 : -MediaQuery.of(context).size.width * 0.8,
            bottom: 0,
            width: MediaQuery.of(context).size.width * 0.8,
            child: Material(
              elevation: 16,
              child: FiltrosArticuloPropioScreen(
                filtrosIniciales: filtros,
                onAplicar: (nuevosFiltros) {
                  setState(() {
                    filtros = nuevosFiltros;
                    _mostrarFiltros = false;
                  });
                  _cargarArticulosPropios();
                },
                onCerrar: _cerrarFiltros,
              ),
            ),
          )
        ],
      ),
      floatingActionButton: _mostrarFiltros
          ? null
          : FloatingActionButton(
              onPressed: () async {
                final result = await Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const SubirFotoScreen()),
                );
                if (result == true) {
                  _cargarArticulosPropios();
                }
              },
              child: const Icon(Icons.add),
              tooltip: 'Añadir prenda',
            ),
    );
  }
}

class KeepAliveWrapper extends StatefulWidget {
  final Widget child;
  const KeepAliveWrapper({super.key, required this.child});

  @override
  State<KeepAliveWrapper> createState() => _KeepAliveWrapperState();
}

class _KeepAliveWrapperState extends State<KeepAliveWrapper>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return widget.child;
  }
}
