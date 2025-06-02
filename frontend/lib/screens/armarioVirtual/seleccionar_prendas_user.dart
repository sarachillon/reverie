import 'package:flutter/material.dart';
import 'package:frontend/screens/utils/imagen_ajustada_widget.dart';

class SeleccionarPrendasUsuarioWidget extends StatefulWidget {
  final List<Map<String, dynamic>> articulosUsuario;
  final List<Map<String, dynamic>> yaSeleccionados;

  const SeleccionarPrendasUsuarioWidget({
    Key? key,
    required this.articulosUsuario,
    required this.yaSeleccionados,
  }) : super(key: key);

  @override
  State<SeleccionarPrendasUsuarioWidget> createState() => _SeleccionarPrendasUsuarioWidgetState();
}

class _SeleccionarPrendasUsuarioWidgetState extends State<SeleccionarPrendasUsuarioWidget> {
  int? selectedId;
  late List<Map<String, dynamic>> _filtered;
  String _query = '';

  @override
  void initState() {
    super.initState();
    // Seleccionamos el primero ya seleccionado si hay
    selectedId = widget.yaSeleccionados.isNotEmpty ? widget.yaSeleccionados.first['id'] : null;
    _filtered = widget.articulosUsuario;
  }

  void _search(String query) {
    setState(() {
      _query = query;
      _filtered = widget.articulosUsuario.where((a) {
        final nombre = (a['nombre'] ?? '').toLowerCase();
        return nombre.contains(query.toLowerCase());
      }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    final mq = MediaQuery.of(context);
    return SafeArea(
      child: Container(
        color: Colors.white, // <-- fondo blanco forzado
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: SizedBox(
            height: mq.size.height * 0.75,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text('Selecciona prenda a fijar', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                const SizedBox(height: 12),
                TextField(
                  decoration: const InputDecoration(
                    prefixIcon: Icon(Icons.search),
                    hintText: 'Buscar artículo...',
                    border: OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(12))),
                    contentPadding: EdgeInsets.symmetric(horizontal: 8, vertical: 0),
                  ),
                  onChanged: _search,
                ),
                const SizedBox(height: 12),
                Expanded(
                  child: _filtered.isEmpty
                      ? const Center(child: Text('No hay resultados'))
                      : ListView.separated(
                          itemCount: _filtered.length,
                          separatorBuilder: (_, __) => const Divider(height: 1),
                          itemBuilder: (context, i) {
                            final articulo = _filtered[i];
                            final url = articulo['urlFirmada'] ?? '';
                            final isSelected = articulo['id'] == selectedId;
                            return ListTile(
                              tileColor: isSelected ? const Color(0xFFF7F1E1) : Colors.white,
                              leading: Stack(
                                alignment: Alignment.topRight,
                                children: [
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(8),
                                    child: Container(
                                      color: Colors.grey.shade200,
                                      width: 52,
                                      height: 52,
                                      child: ImagenAjustada(
                                        url: url,
                                        width: 52,
                                        height: 52,
                                      ),
                                    ),
                                  ),
                                  if (isSelected)
                                    const Positioned(
                                      top: 2,
                                      right: 2,
                                      child: Icon(Icons.check_circle, color: Color(0xFFD4AF37), size: 18),
                                    ),
                                ],
                              ),
                              title: Text(articulo['nombre'] ?? 'Sin nombre'),
                              subtitle: Text(articulo['categoria'] ?? ''),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                                side: isSelected
                                    ? const BorderSide(color: Color(0xFFD4AF37), width: 2)
                                    : BorderSide.none,
                              ),
                              onTap: () {
                                setState(() {
                                  selectedId = articulo['id'];
                                });
                              },
                            );
                          },
                        ),
                ),
                const SizedBox(height: 10),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Color(0xFFD4AF37),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                    ),
                    onPressed: selectedId != null
                        ? () {
                            final seleccion = widget.articulosUsuario
                                .firstWhere((a) => a['id'] == selectedId, orElse: () => {});
                            Navigator.pop(context, seleccion.isNotEmpty ? [seleccion] : []);
                          }
                        : null,
                    child: const Text("Guardar", style: TextStyle(color: Colors.white, fontSize: 16)),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
