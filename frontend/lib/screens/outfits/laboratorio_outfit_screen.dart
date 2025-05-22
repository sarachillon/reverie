import 'package:flutter/material.dart';
import 'package:frontend/services/api_manager.dart';

class LaboratorioOutfitScreen extends StatefulWidget {
  const LaboratorioOutfitScreen({super.key});

  @override
  State<LaboratorioOutfitScreen> createState() => _LaboratorioOutfitScreenState();
}

class _LaboratorioOutfitScreenState extends State<LaboratorioOutfitScreen> {
  final ApiManager _apiManager = ApiManager();
  List<dynamic> partesArriba = [];
  List<dynamic> partesAbajo = [];
  List<dynamic> calzado = [];
  List<dynamic> accesorios = [];

  int currentTopIndex = 0;
  int currentBottomIndex = 0;
  int currentShoeIndex = 0;
  Set<int> selectedAccessoryIds = {};
  bool mostrarParteAbajo = true;

  @override
  void initState() {
    super.initState();
    _cargarArticulos();
  }

  Future<void> _cargarArticulos() async {
    final usuario = await _apiManager.getUsuarioActual();
    final articulos = usuario['articulos_propios'];
    setState(() {
      partesArriba = articulos.where((a) => _esParteArriba(a['subcategoria'])).toList();
      partesAbajo = articulos.where((a) => _esParteAbajo(a['subcategoria'])).toList();
      calzado = articulos.where((a) => a['categoria'] == 'calzado').toList();
      accesorios = articulos.where((a) => a['categoria'] == 'accesorio').toList();
    });
  }

  bool _esParteArriba(String sub) {
    return [
      'CAMISAS', 'CAMISETAS', 'JERSEYS', 'MONOS', 'TRAJES'
    ].contains(sub);
  }

  bool _esParteAbajo(String sub) {
    return [
      'PANTALONES', 'VAQUEROS', 'FALDAS_CORTAS', 'FALDAS_LARGAS', 'BERMUDAS'
    ].contains(sub);
  }

  Widget _buildCarousel(String title, List<dynamic> items, int currentIndex, Function(int) onIndexChanged) {
    if (items.isEmpty) return const SizedBox.shrink();
    return Column(
      children: [
        Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        SizedBox(
          height: 200,
          child: PageView.builder(
            controller: PageController(viewportFraction: 0.6),
            onPageChanged: onIndexChanged,
            itemCount: items.length,
            itemBuilder: (context, index) {
              final img = items[index]['imagen'];
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.memory(
                    Uri.parse(img).data!.contentAsBytes(),
                    fit: BoxFit.cover,
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  void _abrirSelectorAccesorios() {
    showModalBottomSheet(
      context: context,
      builder: (_) => StatefulBuilder(
        builder: (context, setModalState) {
          return ListView(
            children: accesorios.map((a) {
              return CheckboxListTile(
                value: selectedAccessoryIds.contains(a['id']),
                title: Text(a['nombre'] ?? 'Sin nombre'),
                onChanged: (val) {
                  setModalState(() {
                    if (val == true) {
                      selectedAccessoryIds.add(a['id']);
                    } else {
                      selectedAccessoryIds.remove(a['id']);
                    }
                  });
                },
              );
            }).toList(),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Laboratorio de Outfits")),
      body: partesArriba.isEmpty || calzado.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _buildCarousel("Parte de arriba", partesArriba, currentTopIndex, (i) => setState(() => currentTopIndex = i)),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      const Text("Mostrar parte de abajo"),
                      Switch(
                        value: mostrarParteAbajo,
                        onChanged: (val) => setState(() => mostrarParteAbajo = val),
                      ),
                    ],
                  ),
                  if (mostrarParteAbajo)
                    _buildCarousel("Parte de abajo", partesAbajo, currentBottomIndex, (i) => setState(() => currentBottomIndex = i)),
                  const SizedBox(height: 16),
                  _buildCarousel("Calzado", calzado, currentShoeIndex, (i) => setState(() => currentShoeIndex = i)),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: _abrirSelectorAccesorios,
                    child: const Text("Seleccionar accesorios"),
                  ),
                ],
              ),
            ),
    );
  }
}
