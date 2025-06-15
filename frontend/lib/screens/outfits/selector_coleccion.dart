import 'package:flutter/material.dart';
import 'package:frontend/services/api_manager.dart';
import 'package:google_fonts/google_fonts.dart';

class SelectorColeccionBottomSheet extends StatefulWidget {
  final int outfitId;

  const SelectorColeccionBottomSheet({super.key, required this.outfitId});

  @override
  State<SelectorColeccionBottomSheet> createState() =>
      _SelectorColeccionBottomSheetState();
}

class _SelectorColeccionBottomSheetState
    extends State<SelectorColeccionBottomSheet> {
  final api = ApiManager();
  final TextEditingController _nuevoController = TextEditingController();

  List<dynamic> colecciones = [];
  bool loading = true;
  bool creando = false;

  @override
  void initState() {
    super.initState();
    _loadColecciones();
  }

  @override
  void dispose() {
    _nuevoController.dispose();
    super.dispose();
  }

  /* ──────────────────── DATA ──────────────────── */
  Future<void> _loadColecciones() async {
    final user = await api.getUsuarioActual();
    final res = await api.obtenerColeccionesDeUsuario(user['id']);
    if (!mounted) return;
    setState(() {
      colecciones = res;
      loading = false;
    });
  }

  Future<void> _guardarOutfit(int coleccionId) async {
    await api.addOutfitColeccion(
        coleccionId: coleccionId, outfitId: widget.outfitId);
    if (!mounted) return;
    Navigator.pop(context);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Outfit guardado en la colección')),
    );
  }

  Future<void> _crearYGuardar() async {
    final nombre = _nuevoController.text.trim();
    if (nombre.isEmpty) return;

    final user = await api.getUsuarioActual();
    setState(() => creando = true);

    try {
      await api.crearColeccion(
        nombre: nombre,
        userId: user['id'],
        outfitId: widget.outfitId, // se guarda al mismo tiempo
      );

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Colección creada y outfit guardado')),
      );
      Navigator.pop(context); // 🔚 cerramos el selector
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: $e'),
          backgroundColor: Colors.redAccent,
        ),
      );
    } finally {
      if (mounted) setState(() => creando = false);
    }
  }

  /* ──────────────────── UI ──────────────────── */
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 420,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: loading
            ? const Center(child: CircularProgressIndicator())
            : Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // tirador
                  Center(
                    child: Container(
                      width: 40,
                      height: 4,
                      margin: const EdgeInsets.only(bottom: 12),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade400,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  // campo + botón crear
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _nuevoController,
                          decoration: const InputDecoration(
                            hintText: 'Crear colección y añadir outfit',
                            isDense: true,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      creando
                          ? const SizedBox(
                              width: 24,
                              height: 24,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFFD4AF37),
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 16, vertical: 12),
                              ),
                              onPressed: _crearYGuardar,
                              child: const Text('Crear'),
                            ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  // encabezado
                  Text(
                    'Selecciona una colección',
                    style: GoogleFonts.poppins(
                        fontSize: 18, fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 12),
                  // lista
                  Expanded(
                    child: ListView.separated(
                      itemCount: colecciones.length,
                      separatorBuilder: (_, __) =>
                          const SizedBox(height: 8),
                      itemBuilder: (context, index) {
                        final coleccion = colecciones[index];
                        final nombre = coleccion['nombre'] ?? 'Sin nombre';
                        final List<dynamic> outfits =
                            coleccion['outfits'] ?? [];
                        final bool yaIncluido = outfits
                            .any((o) => o['id'] == widget.outfitId);

                        return ListTile(
                          title: Text(nombre),
                          trailing: yaIncluido
                              ? const Icon(Icons.check, color: Colors.green)
                              : const Icon(Icons.add, color: Colors.grey),
                          enabled: !yaIncluido,
                          onTap: yaIncluido
                              ? null
                              : () => _guardarOutfit(coleccion['id']),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          tileColor: Colors.grey.shade100,
                          hoverColor: Colors.grey.shade200,
                        );
                      },
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}
