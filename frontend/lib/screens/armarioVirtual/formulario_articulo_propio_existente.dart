import 'package:flutter/material.dart';
import 'package:frontend/enums/enums.dart';
import 'package:frontend/screens/armarioVirtual/categoria_selector.dart';
import 'package:frontend/screens/armarioVirtual/subcategoria_selector.dart';
import 'package:frontend/services/api_manager.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'dart:io';

class FormularioArticuloDesdeExistenteScreen extends StatefulWidget {
  final Map<String, dynamic> articulo;

  const FormularioArticuloDesdeExistenteScreen({super.key, required this.articulo});

  @override
  State<FormularioArticuloDesdeExistenteScreen> createState() => _FormularioArticuloDesdeExistenteScreenState();
}

class _FormularioArticuloDesdeExistenteScreenState extends State<FormularioArticuloDesdeExistenteScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nombreController = TextEditingController();
  final ApiManager _apiManager = ApiManager();

  String? _imagenUrl;

  CategoriaEnum? _categoria;
  dynamic _subcategoria;
  List<OcasionEnum> _ocasiones = [];
  List<TemporadaEnum> _temporadas = [];
  List<ColorEnum> _colores = [];

  final Map<CategoriaEnum, List<dynamic>> subcategoriasMap = {
    CategoriaEnum.ROPA: SubcategoriaRopaEnum.values,
    CategoriaEnum.ACCESORIOS: SubcategoriaAccesoriosEnum.values,
    CategoriaEnum.CALZADO: SubcategoriaCalzadoEnum.values,
  };

  @override
  void initState() {
    super.initState();
    final articulo = widget.articulo;
    _nombreController.text = articulo['nombre'] ?? '';
    _categoria = CategoriaEnum.values.firstWhere((e) => e.name == articulo['categoria'], orElse: () => CategoriaEnum.ROPA);
    _subcategoria = articulo['subcategoria'];
    _ocasiones = (articulo['ocasiones'] as List?)?.map((e) => OcasionEnum.values.firstWhere((o) => o.name == e)).toList() ?? [];
    _temporadas = (articulo['temporadas'] as List?)?.map((e) => TemporadaEnum.values.firstWhere((t) => t.name == e)).toList() ?? [];
    _colores = (articulo['colores'] as List?)?.map((e) => ColorEnum.values.firstWhere((c) => c.name == e)).toList() ?? [];
    _imagenUrl = articulo['foto'] ?? '';
  }



  Future<void> _guardarPrenda() async {
  if (!_formKey.currentState!.validate() ||
      _categoria == null ||
      _subcategoria == null ||
      _ocasiones.isEmpty ||
      _temporadas.isEmpty ||
      _colores.isEmpty ||
      _imagenUrl == null) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Por favor, completa todos los campos obligatorios.")),
    );
    return;
  }

  try {
    // 1. Descargar imagen de la URL y guardarla como File temporal
    final response = await http.get(Uri.parse(_imagenUrl!));
    final tempDir = await getTemporaryDirectory();
    final tempFile = File('${tempDir.path}/articulo.png');
    await tempFile.writeAsBytes(response.bodyBytes);

    // 2. Mapear subcategoría
    SubcategoriaRopaEnum? subRopa;
    SubcategoriaAccesoriosEnum? subAccesorio;
    SubcategoriaCalzadoEnum? subCalzado;

    if (_categoria == CategoriaEnum.ROPA) {
      subRopa = SubcategoriaRopaEnum.values.firstWhere((e) => e.name == _subcategoria);
    } else if (_categoria == CategoriaEnum.ACCESORIOS) {
      subAccesorio = SubcategoriaAccesoriosEnum.values.firstWhere((e) => e.name == _subcategoria);
    } else if (_categoria == CategoriaEnum.CALZADO) {
      subCalzado = SubcategoriaCalzadoEnum.values.firstWhere((e) => e.name == _subcategoria);
    }

    // 3. Llamada al API
    await _apiManager.guardarArticuloPropioDesdeArchivo(
      imagenFile: tempFile,
      nombre: _nombreController.text,
      categoria: _categoria!,
      subcategoriaRopa: subRopa,
      subcategoriaAccesorios: subAccesorio,
      subcategoriaCalzado: subCalzado,
      ocasiones: _ocasiones,
      temporadas: _temporadas,
      colores: _colores,
    );

    if (mounted) Navigator.pop(context, true);
  } catch (e) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("Error al guardar la prenda: $e")),
    );
  }
}


  Color _getColorFromEnum(ColorEnum color) {
    switch (color) {
      case ColorEnum.AMARILLO: return Colors.yellow;
      case ColorEnum.NARANJA: return Colors.orange;
      case ColorEnum.ROJO: return Colors.red;
      case ColorEnum.ROSA: return Colors.pink;
      case ColorEnum.VIOLETA: return Colors.purple;
      case ColorEnum.AZUL: return Colors.blue;
      case ColorEnum.VERDE: return Colors.green;
      case ColorEnum.MARRON: return Colors.brown;
      case ColorEnum.GRIS: return Colors.grey;
      case ColorEnum.BLANCO: return Colors.white;
      case ColorEnum.NEGRO: return Colors.black;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Nueva Prenda")),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _imagenUrl != null
              ? Image.network(_imagenUrl!, height: 250, fit: BoxFit.cover)
              : const SizedBox(height: 250, child: Center(child: Text("Sin imagen disponible"))),
            const SizedBox(height: 16),
            Form(
              key: _formKey,
              child: Column(
                children: [
                  TextFormField(
                    controller: _nombreController,
                    decoration: const InputDecoration(labelText: "Nombre de la prenda"),
                    validator: (value) => value == null || value.isEmpty ? "Introduce un nombre" : null,
                  ),
                  const SizedBox(height: 16),
                  ListTile(
                    title: const Text("Categoría y subcategoría"),
                    subtitle: Text(_categoria == null || _subcategoria == null ? "Selecciona" : "${_categoria!.value}, $_subcategoria"),
                    trailing: const Icon(Icons.arrow_forward_ios),
                    onTap: () async {
                      final categoriaSeleccionada = await Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const CategoriaSelector()),
                      );
                      if (categoriaSeleccionada != null) {
                        final subSeleccionada = await Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => SubcategoriaSelector(categoria: categoriaSeleccionada.value)),
                        );
                        if (subSeleccionada != null) {
                          setState(() {
                            _categoria = categoriaSeleccionada;
                            _subcategoria = subSeleccionada;
                          });
                        }
                      }
                    },
                  ),
                  ListTile(
                    title: const Text("Selecciona ocasiones"),
                    subtitle: Text(_ocasiones.isEmpty ? "Selecciona una o varias" : _ocasiones.map((e) => e.value).join(", ")),
                    trailing: const Icon(Icons.arrow_forward_ios),
                    onTap: () async {
                      final seleccionadas = await showDialog<List<OcasionEnum>>(
                        context: context,
                        builder: (context) {
                          final temp = List<OcasionEnum>.from(_ocasiones);
                          return StatefulBuilder(
                            builder: (context, setState) {
                              return AlertDialog(
                                content: SingleChildScrollView(
                                  child: Column(
                                    children: OcasionEnum.values.map((o) {
                                      return CheckboxListTile(
                                        title: Text(o.value),
                                        value: temp.contains(o),
                                        onChanged: (v) => setState(() => v! ? temp.add(o) : temp.remove(o)),
                                      );
                                    }).toList(),
                                  ),
                                ),
                                actions: [
                                  TextButton(onPressed: () => Navigator.pop(context), child: const Text("Cancelar")),
                                  TextButton(onPressed: () => Navigator.pop(context, temp), child: const Text("Aceptar")),
                                ],
                              );
                            },
                          );
                        },
                      );
                      if (seleccionadas != null) setState(() => _ocasiones = seleccionadas);
                    },
                  ),
                  ListTile(
                    title: const Text("Selecciona temporadas"),
                    subtitle: Text(_temporadas.isEmpty ? "Selecciona una o varias" : _temporadas.map((e) => e.value).join(", ")),
                    trailing: const Icon(Icons.arrow_forward_ios),
                    onTap: () async {
                      final seleccionadas = await showDialog<List<TemporadaEnum>>(
                        context: context,
                        builder: (context) {
                          final temp = List<TemporadaEnum>.from(_temporadas);
                          return StatefulBuilder(
                            builder: (context, setState) {
                              return AlertDialog(
                                content: SingleChildScrollView(
                                  child: Column(
                                    children: TemporadaEnum.values.map((t) {
                                      return CheckboxListTile(
                                        title: Text(t.value),
                                        value: temp.contains(t),
                                        onChanged: (v) => setState(() => v! ? temp.add(t) : temp.remove(t)),
                                      );
                                    }).toList(),
                                  ),
                                ),
                                actions: [
                                  TextButton(onPressed: () => Navigator.pop(context), child: const Text("Cancelar")),
                                  TextButton(onPressed: () => Navigator.pop(context, temp), child: const Text("Aceptar")),
                                ],
                              );
                            },
                          );
                        },
                      );
                      if (seleccionadas != null) setState(() => _temporadas = seleccionadas);
                    },
                  ),
                  ListTile(
                    title: const Text("Selecciona colores"),
                    subtitle: Wrap(
                      spacing: 8,
                      children: ColorEnum.values.map((c) {
                        final seleccionado = _colores.contains(c);
                        return GestureDetector(
                          onTap: () => setState(() => seleccionado ? _colores.remove(c) : _colores.add(c)),
                          child: Container(
                            width: 32,
                            height: 32,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: seleccionado ? _getColorFromEnum(c).withOpacity(0.7) : _getColorFromEnum(c),
                              border: Border.all(color: Colors.black26),
                            ),
                            child: seleccionado ? const Icon(Icons.check, size: 18, color: Colors.white) : null,
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: _guardarPrenda,
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 16),
                      textStyle: const TextStyle(fontSize: 16),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    child: const Text("Añadir a mi armario"),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}