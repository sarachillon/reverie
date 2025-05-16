import 'package:flutter/material.dart';
import 'package:frontend/screens/outfits/widget_outfit_small.dart';
import 'package:frontend/services/api_manager.dart';

class MostrarOutfitScreen extends StatefulWidget {
  const MostrarOutfitScreen({super.key});

  @override
  State<MostrarOutfitScreen> createState() => _MostrarOutfitScreenState();
}

class _MostrarOutfitScreenState extends State<MostrarOutfitScreen> {
  final ApiManager _apiManager = ApiManager();
  final List<dynamic> _outfits = [];

  @override
  void initState() {
    super.initState();
    _cargarOutfits();
  }

  Future<void> _cargarOutfits() async {
    setState(() => _outfits.clear());
    try {
      final stream = _apiManager.getOutfitsPropiosStream();
      await for (final outfit in stream) {
        if (!mounted) return;
        setState(() => _outfits.add(outfit));
      }
    } catch (e) {
      print("Error al cargar outfits: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return WidgetOutfitSmall(outfits: _outfits);
  }
}
