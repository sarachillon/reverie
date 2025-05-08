import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:frontend/enums/enums.dart';
import 'package:frontend/screens/outfits/formulario_outfit_screen.dart';
import 'package:frontend/screens/outfits/filtros_outfit_screen.dart';
import 'package:frontend/screens/outfits/outfit_detail_screen.dart';
import 'package:frontend/services/api_manager.dart';

class OutfitsScreen extends StatefulWidget {
  const OutfitsScreen({super.key});

  @override
  State<OutfitsScreen> createState() => _OutfitsScreenState();
}

class _OutfitsScreenState extends State<OutfitsScreen> {
  final ApiManager _apiManager = ApiManager();
  final List<dynamic> _outfits = [];
  bool _mostrarFiltros = false;
  Map<String, dynamic> filtros = {};
  final PageController _pageController = PageController(viewportFraction: 0.85);
  int _currentPage = 0;

  @override
  void initState() {
    super.initState();
    _cargarOutfits();
  }

  Future<void> _cargarOutfits() async {
    setState(() {
      _outfits.clear();
    });
    try {
      final stream = _apiManager.getOutfitsPropiosStream(filtros: filtros);
      await for (final outfit in stream) {
        if (!mounted) return;
        setState(() {
          _outfits.add(outfit);
        });
      }
    } catch (e) {
      print("Error al cargar outfits: $e");
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
        title: const Text('Outfits'),
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_alt),
            onPressed: () => setState(() => _mostrarFiltros = true),
            tooltip: 'Mostrar filtros',
          ),
        ],
      ),
      body: Stack(
        children: [
          RefreshIndicator(
            onRefresh: _cargarOutfits,
            child: ListView(
              padding: const EdgeInsets.symmetric(vertical: 16),
              children: [
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16),
                  child: Text(
                    "Clasificar por ocasión",
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                ),
                const SizedBox(height: 8),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Row(
                    children: OcasionEnum.values.map((o) {
                      final seleccionadas = List<String>.from(filtros['ocasiones'] ?? []);
                      final selected = seleccionadas.contains(o.name);

                      return Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: ChoiceChip(
                          label: Text(o.value),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(100),
                          ),
                          selected: selected,
                          showCheckmark: false,
                          onSelected: (_) {
                            setState(() {
                              if (selected) {
                                seleccionadas.remove(o.name);
                              } else {
                                seleccionadas.add(o.name);
                              }

                              if (seleccionadas.isEmpty) {
                                filtros.remove('ocasiones');
                              } else {
                                filtros['ocasiones'] = List.from(seleccionadas);
                              }
                            });
                            _cargarOutfits();
                          },
                        ),
                      );
                    }).toList(),
                  ),
                ),
                const SizedBox(height: 20),
                if (_outfits.isEmpty)
                  const Center(
                    child: Padding(
                      padding: EdgeInsets.all(24),
                      child: Text('Cargando outfits...'),
                    ),
                  )
                else
                  SizedBox(
                    height: 440,
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        PageView.builder(
                          controller: _pageController,
                          itemCount: _outfits.length,
                          onPageChanged: (index) => setState(() => _currentPage = index),
                          itemBuilder: (context, index) {
                            final outfit = _outfits[index];
                            final imagenBase64 = outfit['imagen'] as String?;
                            final imagenBytes = (imagenBase64 != null && imagenBase64.isNotEmpty)
                                ? base64Decode(imagenBase64)
                                : null;

                            return GestureDetector(
                              onTap: () async {
                                final colores = (outfit['colores'] as List).map((c) => ColorEnum.values.firstWhere((e) => e.name == c)).toList();
                                final temporadas = (outfit['temporadas'] as List).map((t) => TemporadaEnum.values.firstWhere((e) => e.name == t)).toList();
                                final ocasiones = (outfit['ocasiones'] as List).map((t) => OcasionEnum.values.firstWhere((e) => e.name == t)).toList();

                                await Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => OutfitDetailScreen(
                                      titulo: outfit['titulo'],
                                      descripcion: outfit['descripcion'],
                                      colores: colores,
                                      temporadas: temporadas,
                                      ocasiones: ocasiones,
                                      articulosPropios: outfit['articulos_propios'],
                                    ),
                                  ),
                                );

                                _cargarOutfits();
                              },
                              child: Center(
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text(
                                      outfit['titulo'] ?? 'Sin título',
                                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
                                    ),
                                    const SizedBox(height: 10),
                                    Container(
                                      height: 400,
                                      width: 300,
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(12),
                                        color: Colors.grey[100],
                                        boxShadow: [
                                          BoxShadow(
                                            color: Colors.black12,
                                            blurRadius: 6,
                                            offset: Offset(0, 4),
                                          ),
                                        ],
                                      ),
                                      clipBehavior: Clip.antiAlias,
                                      child: imagenBytes != null
                                          ? Image.memory(
                                              imagenBytes,
                                              fit: BoxFit.cover,
                                              width: double.infinity,
                                              errorBuilder: (_, __, ___) => const Center(child: Icon(Icons.broken_image)),
                                            )
                                          : const Center(child: Icon(Icons.image_not_supported)),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                        if (_currentPage > 0)
                          Positioned(
                            left: 8,
                            child: IconButton(
                              icon: const Icon(Icons.arrow_back_ios),
                              onPressed: () {
                                _pageController.previousPage(
                                  duration: const Duration(milliseconds: 300),
                                  curve: Curves.easeInOut,
                                );
                              },
                            ),
                          ),
                        if (_currentPage < _outfits.length - 1)
                          Positioned(
                            right: 8,
                            child: IconButton(
                              icon: const Icon(Icons.arrow_forward_ios),
                              onPressed: () {
                                _pageController.nextPage(
                                  duration: const Duration(milliseconds: 300),
                                  curve: Curves.easeInOut,
                                );
                              },
                            ),
                          ),
                      ],
                    ),
                  ),
              ],
            ),
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
              child: FiltrosOutfitScreen(
                filtrosIniciales: filtros,
                onAplicar: (nuevosFiltros) {
                  setState(() {
                    filtros = nuevosFiltros;
                    _mostrarFiltros = false;
                  });
                  _cargarOutfits();
                },
                onCerrar: _cerrarFiltros,
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: _mostrarFiltros
          ? null
          : FloatingActionButton(
              onPressed: () async {
                final result = await Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const FormularioOutfitScreen()),
                );
                if (result == true) {
                  _cargarOutfits();
                }
              },
              child: const Icon(Icons.add),
              tooltip: 'Generar nuevo outfit',
            ),
    );
  }
}
