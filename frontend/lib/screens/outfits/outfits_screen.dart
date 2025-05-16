import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:frontend/enums/enums.dart';
import 'package:frontend/screens/outfits/formulario_outfit_screen.dart';
import 'package:frontend/screens/outfits/filtros_outfit_screen.dart';
import 'package:frontend/screens/outfits/outfit_detail_screen.dart';
import 'package:frontend/screens/outfits/widget_outfit_small.dart';
import 'package:frontend/services/api_manager.dart';
import 'package:frontend/screens/outfits/widget_outfit_big.dart';


class OutfitsScreen extends StatefulWidget {
  const OutfitsScreen({super.key});

  @override
  State<OutfitsScreen> createState() => _OutfitsScreenState();

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

class _OutfitsScreenState extends State<OutfitsScreen> {
  final ApiManager _apiManager = ApiManager();
  final List<dynamic> _outfits = [];
  final TextEditingController _searchController = TextEditingController();

  bool _mostrarFiltros = false;
  bool _isSearching = false;
  bool _modoCuadricula = false;
  String _busqueda = '';
  Map<String, dynamic> filtros = {};

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

  void _cerrarFiltros() {
    setState(() => _mostrarFiltros = false);
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
        leading: IconButton(
          icon: Icon(
            _modoCuadricula ? Icons.auto_awesome_mosaic : Icons.crop_portrait,
            color: const Color(0xFFD4AF37),
          ),
          onPressed: () => setState(() => _modoCuadricula = !_modoCuadricula),
        ),
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
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 300),
            child: _modoCuadricula
                ? WidgetOutfitSmall(outfits: outfitsFiltrados)
                : WidgetOutfitBig( outfits: outfitsFiltrados),
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
    );
  }
}
