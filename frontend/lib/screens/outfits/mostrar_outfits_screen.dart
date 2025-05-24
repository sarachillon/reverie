import 'package:flutter/material.dart';
import 'package:frontend/screens/outfits/formulario_outfit_screen.dart';
import 'package:frontend/screens/outfits/widget_outfit_small.dart';
import 'package:frontend/services/api_manager.dart';

class MostrarOutfitScreen extends StatefulWidget {
  final int? userId;
  const MostrarOutfitScreen({super.key, this.userId});

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
      final filtros = widget.userId != null ? {'usuario_id': widget.userId} : null;
      final stream = _apiManager.getOutfitsPropiosStream(filtros: filtros);
      await for (final outfit in stream) {
        if (!mounted) return;
        setState(() => _outfits.add(outfit));
      }
    } catch (e) {
      print("Error al cargar outfits: $e");
    }
  }

  /*@override
  Widget build(BuildContext context) {
    
    if (_outfits.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }
    return WidgetOutfitSmall(outfits: _outfits);*/

  @override
  Widget build(BuildContext context) {
    if (_outfits.isEmpty) {
      // Mostramos un ListView horizontal con un único tile de "Añadir outfit"
      return SizedBox(
        height: 180, // ajusta la altura a tu gusto
        child: ListView(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 8),
          children: [
            if (widget.userId != null)
              GestureDetector(
                onTap: () async {
                  // Lanza tu pantalla para crear un nuevo outfit
                  final agregado = await Navigator.push<bool>(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const FormularioOutfitScreen(),
                    ),
                  );
                  // Si se añadió correctamente, recarga la lista
                  if (agregado == true) {
                    _cargarOutfits(); // O bien llama a 
                  }
                },
                child: Container(
                  width: 140,
                  margin: const EdgeInsets.only(right: 8),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.grey.shade300),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: const [
                      Icon(Icons.add, size: 32, color: Colors.grey),
                      SizedBox(height: 8),
                      Text(
                        'Añadir outfit',
                        style: TextStyle(fontSize: 14, color: Colors.grey),
                      ),
                    ],
                  ),
                ),
              )
            else
              // Si el usuario no puede añadir outfits (p. ej. no está logueado)
              Container(
                width: 140,
                alignment: Alignment.center,
                child: const Text(
                  'No hay outfits',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 14, color: Colors.grey),
                ),
              ),
          ],
        ),
      );
    }

    // Si ya hay outfits, muestra tu widget normal
    return WidgetOutfitSmall(outfits: _outfits);
  }

}



