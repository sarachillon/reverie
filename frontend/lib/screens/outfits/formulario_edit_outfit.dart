import 'package:flutter/material.dart';
import 'package:frontend/enums/enums.dart';
import 'package:frontend/screens/utils/carga_screen.dart';
import 'package:frontend/services/api_manager.dart';
import 'package:frontend/screens/outfits/edit_collage_screen.dart';
import 'package:frontend/screens/utils/imagen_ajustada_widget.dart';
import 'package:google_fonts/google_fonts.dart';

class FormularioEditarOutfitScreen extends StatefulWidget {
  final Map<String, dynamic> outfit; // O tu modelo de Outfit
  const FormularioEditarOutfitScreen({super.key, required this.outfit});

  @override
  State<FormularioEditarOutfitScreen> createState() => _FormularioEditarOutfitScreenState();
}

class _FormularioEditarOutfitScreenState extends State<FormularioEditarOutfitScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _tituloController;
  late final TextEditingController _descripcionController;
  final ApiManager _apiManager = ApiManager();

  late List<OcasionEnum> _ocasiones;
  late List<TemporadaEnum> _temporadas;
  late List<ColorEnum> _colores;


  late String _originalTitulo;
  late String _originalDescripcion;
  late List<OcasionEnum> _originalOcasiones;
  late List<TemporadaEnum> _originalTemporadas;
  late List<ColorEnum> _originalColores;
  bool _fotoActualizada = false;


  @override
  void initState() {
    super.initState();
    _tituloController = TextEditingController(text: widget.outfit['titulo'] ?? '');
    _descripcionController = TextEditingController(text: widget.outfit['descripcion'] ?? '');
    _ocasiones = (widget.outfit['ocasiones'] as List?)?.map((e) => OcasionEnum.values.firstWhere((x) => x.name == e)).toList() ?? [];
    _temporadas = (widget.outfit['temporadas'] as List?)?.map((e) => TemporadaEnum.values.firstWhere((x) => x.name == e)).toList() ?? [];
    _colores = (widget.outfit['colores'] as List?)?.map((e) => ColorEnum.values.firstWhere((x) => x.name == e)).toList() ?? [];


      _originalTitulo = _tituloController.text;
      _originalDescripcion = _descripcionController.text;
      _originalOcasiones = List.of(_ocasiones);
      _originalTemporadas = List.of(_temporadas);
      _originalColores = List.of(_colores);
  }

Future<void> guardarCambios(BuildContext context) async {
  if (!_formKey.currentState!.validate()) return;

  // Compara para mandar solo los campos que han cambiado
  final String titulo = _tituloController.text.trim();
  final String descripcion = _descripcionController.text.trim();
  final List<OcasionEnum> ocasiones = List.of(_ocasiones);
  final List<TemporadaEnum> temporadas = List.of(_temporadas);
  final List<ColorEnum> colores = List.of(_colores);

  final bool tituloChanged = titulo != _originalTitulo;
  final bool descripcionChanged = descripcion != _originalDescripcion;
  final bool ocasionesChanged = !_listEquals(ocasiones, _originalOcasiones);
  final bool temporadasChanged = !_listEquals(temporadas, _originalTemporadas);
  final bool coloresChanged = !_listEquals(colores, _originalColores);

  if (!tituloChanged && !descripcionChanged && !ocasionesChanged && !temporadasChanged && !coloresChanged) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('No hay cambios para guardar')),
    );
    return;
  }

showDialog(
  context: context,
  barrierDismissible: false,
  builder: (_) => const Center(child: CircularProgressIndicator()),
);

  try {
    await _apiManager.editarOutfitPropio(
      id: widget.outfit['id'],
      titulo: tituloChanged ? titulo : null,
      descripcion: descripcionChanged ? descripcion : null,
      ocasiones: ocasionesChanged ? ocasiones : null,
      temporadas: temporadasChanged ? temporadas : null,
      colores: coloresChanged ? colores : null,
    );

    Navigator.pop(context); // Cerrar loader
    Navigator.pop(context, true); // Volver y notificar éxito
  } catch (e) {
    Navigator.pop(context);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Error al guardar cambios: $e')),
    );
  }
}

// Helper para comparar listas
bool _listEquals<T>(List<T> a, List<T> b) {
  if (a.length != b.length) return false;
  for (int i = 0; i < a.length; i++) {
    if (a[i] != b[i]) return false;
  }
  return true;
}


@override
Widget build(BuildContext context) {
  final primeraFila = ColorEnum.values.take(6);
  final segundaFila = ColorEnum.values.skip(6);

  return Scaffold(
      appBar: AppBar(leading: IconButton(
        icon: const Icon(Icons.arrow_back, color: Color(0xFFD4AF37)),
        onPressed: () => Navigator.pop(context, _fotoActualizada),
      ),
      title: Text(
      'Editar Outfit',
      style: GoogleFonts.dancingScript(
        fontSize: 30,
        color: Color(0xFFD4AF37),
        fontWeight: FontWeight.w600,
      ),
      ),
    ),
    body: SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Imagen con botón editar superpuesto
              if (widget.outfit['imagen'] != null)
                Stack(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(18),
                      child: ImagenAjustada(
                        url: widget.outfit['imagen'],
                        width: double.infinity,
                        height: 200,
                      ),
                    ),
                    Positioned(
                      bottom: 12,
                      right: 12,
                      child: Material(
                        color: Colors.white,
                        shape: const CircleBorder(),
                        elevation: 4,
                        child: IconButton(
                          icon: const Icon(Icons.edit, color: Colors.black),
                          tooltip: "Editar collage",
                          onPressed: () async {
                            final result = await Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => EditCollageScreen(
                                  outfit: widget.outfit,
                                  initialItems: widget.outfit['items'] != null
                                      ? (widget.outfit['items'] as List).cast<Map<String, dynamic>>()
                                      : [],
                                  outfitId: widget.outfit['id'],
                                ),
                              ),
                            );
                            if (result == true) {
                              final nuevo = await _apiManager.getOutfitById(id: widget.outfit['id']);
                              setState(() {
                                _fotoActualizada = true;
                                widget.outfit['imagen'] = nuevo['imagen'];
                              });
                            }
                          },

                        ),
                      ),
                    ),
                  ],
                ),
              const SizedBox(height: 24),
                _buildTitulo("Información básica"),
                const SizedBox(height: 12),
                const Text("Nombre del outfit", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                const SizedBox(height: 4),
                TextFormField(
                  controller: _tituloController,
                  decoration: const InputDecoration(
                    hintText: "Introduce un nombre",
                    isDense: true,
                    contentPadding: EdgeInsets.symmetric(vertical: 10),
                    border: UnderlineInputBorder(),
                  ),
                  style: const TextStyle(fontSize: 15),
                  validator: (value) => value == null || value.isEmpty ? "Campo obligatorio" : null,
                ),
                const SizedBox(height: 16),
                const Text("Descripción", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                const SizedBox(height: 4),
                TextFormField(
                  controller: _descripcionController,
                  maxLines: 3,
                  textAlignVertical: TextAlignVertical.top,
                  decoration: const InputDecoration(
                    hintText: "Opcional",
                    alignLabelWithHint: true,
                    border: OutlineInputBorder(),
                    isDense: true,
                  ),
                  style: const TextStyle(fontSize: 15),
                ),
                const SizedBox(height: 16),
                const Text("Ocasión", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                const SizedBox(height: 4),
                Wrap(
                  spacing: 6,
                  children: OcasionEnum.values.map((o) {
                    final selected = _ocasiones.contains(o);
                    return ChoiceChip(
                      label: Text(o.value, style: const TextStyle(fontSize: 15)),
                      selected: selected,
                      backgroundColor: Colors.transparent,
                      labelStyle: const TextStyle(color: Colors.black),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(100)),
                      showCheckmark: false,
                      onSelected: (isSelected) {
                        setState(() {
                          isSelected ? _ocasiones.add(o) : _ocasiones.remove(o);
                        });
                      },
                    );
                  }).toList(),
                ),
                const SizedBox(height: 24),
                _buildTitulo("Filtros avanzados (opcionales)"),
                const SizedBox(height: 12),
                const Text("Temporada", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 6,
                  runSpacing: 0,
                  children: TemporadaEnum.values.map((t) {
                    final selected = _temporadas.contains(t);
                    return ChoiceChip(
                      label: Text(t.value),
                      selected: selected,
                      backgroundColor: Colors.transparent,
                      labelStyle: const TextStyle(color: Colors.black),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(100)),
                      showCheckmark: false,
                      onSelected: (_) {
                        setState(() {
                          selected ? _temporadas.remove(t) : _temporadas.add(t);
                        });
                      },
                    );
                  }).toList(),
                ),
                const SizedBox(height: 12),
                const Text("Colores", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: primeraFila.map(_buildColorCircle).toList(),
                ),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: segundaFila.map(_buildColorCircle).toList(),
                ),
                const SizedBox(height: 32),
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: () => guardarCambios(context),
                    child: const Text("Guardar cambios", style: TextStyle(fontSize: 18)),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTitulo(String texto) {
    return Text(texto, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold));
  }

  Widget _buildColorCircle(ColorEnum color) {
    final selected = _colores.contains(color);
    return InkWell(
      onTap: () {
        setState(() {
          selected ? _colores.remove(color) : _colores.add(color);
        });
      },
      child: Container(
        width: 32,
        height: 32,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: selected ? _getColorFromEnum(color).withOpacity(0.7) : _getColorFromEnum(color),
          border: Border.all(color: Colors.black12, width: 2),
        ),
        child: selected
            ? Center(
                child: Icon(
                  Icons.check,
                  color: color == ColorEnum.BLANCO ? Colors.black : Colors.white,
                  size: 18,
                ),
              )
            : null,
      ),
    );
  }

  Color _getColorFromEnum(ColorEnum color) {
    switch (color) {
      case ColorEnum.AMARILLO:
        return Colors.yellow;
      case ColorEnum.NARANJA:
        return Colors.orange;
      case ColorEnum.ROJO:
        return Colors.red;
      case ColorEnum.ROSA:
        return Colors.pink;
      case ColorEnum.VIOLETA:
        return Colors.purple;
      case ColorEnum.AZUL:
        return Colors.blue;
      case ColorEnum.VERDE:
        return Colors.green;
      case ColorEnum.MARRON:
        return Colors.brown;
      case ColorEnum.GRIS:
        return Colors.grey;
      case ColorEnum.BLANCO:
        return Colors.white;
      case ColorEnum.NEGRO:
        return Colors.black;
    }
  }
}
