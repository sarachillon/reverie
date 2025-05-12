import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:frontend/enums/enums.dart';
import 'package:frontend/screens/outfits/formulario_outfit_screen.dart';
import 'package:frontend/screens/outfits/filtros_outfit_screen.dart';
import 'package:frontend/services/api_manager.dart';
import 'package:shared_preferences/shared_preferences.dart';

class OutfitsScreen extends StatefulWidget {
  const OutfitsScreen({super.key});

  @override
  State<OutfitsScreen> createState() => _OutfitsScreenState();
}

class _OutfitsScreenState extends State<OutfitsScreen> {
  final ApiManager _apiManager = ApiManager();
  final List<dynamic> _outfits = [];
  bool _mostrarFiltros = false;
  bool _isSearching = false;
  String _busqueda = '';
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _cargarOutfits();
  }

  Future<void> _cargarOutfits() async {
    setState(() => _outfits.clear());
    try {
      final stream = _apiManager.getOutfitsPropiosStream(filtros: filtros);
      await for (final outfit in stream) {
        if (!mounted) return;
        setState(() => _outfits.add(outfit));
      }
    } catch (e) {
      print("Error al cargar outfits: $e");
    }
  }

  Map<String, dynamic> filtros = {};

  void _cerrarFiltros() {
    setState(() => _mostrarFiltros = false);
  }

Future<ImageProvider<Object>> decodeBase64OrMock(String? base64) async {
  final prefs = await SharedPreferences.getInstance();
  final email = prefs.getString('email');

  if (email == 'testing.reverie@gmail.com') {
    return const AssetImage('assets/mock/ropa_mock.png');
  }

  try {
    if (base64 != null && base64.isNotEmpty) {
      final bytes = base64Decode(base64);
      return MemoryImage(bytes);
    }
  } catch (e) {
    debugPrint('Error decoding image: $e');
  }

  return const AssetImage('assets/mock/ropa_mock.png');
}


  @override
  Widget build(BuildContext context) {
    final outfitsFiltrados = _outfits.where((outfit) {
      final titulo = (outfit['titulo'] ?? '').toString().toLowerCase();
      return titulo.contains(_busqueda.toLowerCase());
    }).toList();

    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: _isSearching
            ? TextField(
                controller: _searchController,
                autofocus: true,
                onChanged: (value) => setState(() => _busqueda = value),
                style: const TextStyle(color: Colors.black),
                decoration: const InputDecoration(
                  hintText: 'Buscar outfits...',
                  border: InputBorder.none,
                ),
              )
            : Image.asset('assets/titulos/Outfits.png', height: 30),
        actions: [
          IconButton(
            icon: Icon(_isSearching ? Icons.close : Icons.search, color: const Color(0xFFD4AF37)),
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
          IconButton(
            icon: Icon(_mostrarFiltros ? Icons.close : Icons.filter_alt, color: const Color(0xFFD4AF37)),
            onPressed: () => setState(() => _mostrarFiltros = !_mostrarFiltros),
          ),
        ],
      ),
      body: Stack(
        children: [
          PageView.builder(
            scrollDirection: Axis.vertical,
            itemCount: outfitsFiltrados.length,
            itemBuilder: (context, index) {
              final outfit = outfitsFiltrados[index];
              final imagenPrincipalFuture = decodeBase64OrMock(outfit['imagen'] as String?);

              return GestureDetector(
              
                child: Column(
                  children: [
                    Expanded(
                      child: Container(
                        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.1),
                              blurRadius: 12,
                              offset: const Offset(0, 6),
                            ),
                          ],
                        ),
                        child: Stack(
  children: [
    Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Center(
          child: Text(
            outfit['titulo'] ?? 'Sin título',
            style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
          ),
        ),
        const SizedBox(height: 6),
        Text(
          (outfit['ocasiones'] as List)
              .map((o) => OcasionEnum.values.firstWhere((e) => e.name == o).value)
              .join(', '),
          style: const TextStyle(fontSize: 14, fontStyle: FontStyle.italic),
        ),
        const SizedBox(height: 12),
        FutureBuilder<ImageProvider<Object>>(
          future: imagenPrincipalFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.done && snapshot.hasData) {
              return ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image(
                  image: snapshot.data!,
                  fit: BoxFit.cover,
                  width: double.infinity,
                  height: MediaQuery.of(context).size.height * 0.55,
                ),
              );
            } else {
              return const SizedBox();
            }
          },
        ),
      ],
    ),
    Positioned(
      right: 12,
      top: MediaQuery.of(context).size.height * 0.25,
      child: Container(
        padding: const EdgeInsets.all(6),
        decoration: BoxDecoration(
          color: const Color(0xFFC9A86A),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: (outfit['articulos_propios'] as List).take(5).map((articulo) {
            final imagenMiniFuture = decodeBase64OrMock(articulo['imagen'] as String?);
            return FutureBuilder<ImageProvider<Object>>(
              future: imagenMiniFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.done && snapshot.hasData) {
                  return Container(
                    margin: const EdgeInsets.symmetric(vertical: 4),
                    height: 50,
                    width: 50,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.black12),
                      color: Colors.white,
                    ),
                    clipBehavior: Clip.antiAlias,
                    child: Image(image: snapshot.data!, fit: BoxFit.cover),
                  );
                } else {
                  return const SizedBox(height: 50, width: 50);
                }
              },
            );
          }).toList(),
        ),
      ),
    ),
  ],
),

                      ),
                    ),
                    const Padding(
                      padding: EdgeInsets.only(bottom: 16),
                      child: Icon(Icons.keyboard_arrow_up, size: 28, color: Colors.black38),
                    ),
                  ],
                ),
              );
            },
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
      floatingActionButton: !_mostrarFiltros
          ? FloatingActionButton(
              backgroundColor: const Color(0xFFC9A86A),
              onPressed: () async {
                final nuevoOutfit = await Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const FormularioOutfitScreen()),
                );

                if (nuevoOutfit != null && mounted) {
                  setState(() {
                    _outfits.insert(0, nuevoOutfit); // Lo añade al principio de la lista
                  });
                }
              },

              child: const Icon(Icons.add, color: Colors.white),
              tooltip: 'Generar nuevo outfit',
            )
          : null,
    );
  }
}

