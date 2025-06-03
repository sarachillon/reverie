import 'dart:async';
import 'package:flutter/material.dart';
import 'package:frontend/screens/outfits/outfit_detail_screen.dart';
import 'package:frontend/services/api_manager.dart';
import 'package:frontend/screens/outfits/widget_outfit_small.dart';
import 'package:frontend/screens/outfits/widget_outfit_big.dart';


class MostrarOutfitScreen extends StatefulWidget {
  final int? userId;
  const MostrarOutfitScreen({super.key, this.userId});

  @override
  State<MostrarOutfitScreen> createState() => _MostrarOutfitScreenState();
}

class _MostrarOutfitScreenState extends State<MostrarOutfitScreen> {
  final ApiManager _apiManager = ApiManager();
  final TextEditingController _searchController = TextEditingController();
  List<Map<String, dynamic>> _outfits = [];
  StreamSubscription<Map<String, dynamic>>? _subscription;

  bool _modoCuadricula = true;
  String _busqueda = '';

  @override
  void initState() {
    super.initState();
    _cargarOutfits();
  }

  Future<void> _cargarOutfits() async {
    setState(() => _outfits.clear());
    try {
      final filtros = widget.userId != null ? {'user_id': widget.userId} : null;
      final stream = _apiManager.getOutfitsPropiosStream(filtros: filtros);
      await for (final outfit in stream) {
        if (!mounted) return;
        setState(() => _outfits.add(outfit));
      }
    } catch (e) {
      print("Error al cargar outfits: $e");
    }
  }

  @override
  void dispose() {
    _subscription?.cancel();
    _searchController.dispose();
    super.dispose();
  }



  @override
  Widget build(BuildContext context) {
    final outfitsFiltrados = _outfits.where((outfit) {
      final titulo = (outfit['titulo'] ?? '').toString().toLowerCase();
      return titulo.contains(_busqueda.toLowerCase());
    }).toList();

    return Scaffold(
      body: outfitsFiltrados.isEmpty
          ? const Center(child: Text('No hay outfits.'))
          : _modoCuadricula
                ? WidgetOutfitSmall( outfits: outfitsFiltrados,
                    onTapOutfit: (context, outfit) async {
                      final eliminado = await Navigator.push<bool>(
                        context,
                        MaterialPageRoute(
                          builder: (_) => OutfitDetailScreen(outfitId: outfit['id']),
                        ),
                      );
                      if (eliminado == true) {
                        _cargarOutfits();
                      }
                    },
                  )
                : WidgetOutfitBig(
                    outfits: outfitsFiltrados,
                    onTapOutfit: (context, outfit) async {
                      final eliminado = await Navigator.push<bool>(
                        context,
                        MaterialPageRoute(
                          builder: (_) => OutfitDetailScreen(outfitId: outfit['id']),
                        ),
                      );
                      if (eliminado == true) {
                        _cargarOutfits();
                      }
                    },
                  ),
    );
  }
}


