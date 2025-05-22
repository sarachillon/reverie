import 'package:flutter/material.dart';
import 'package:frontend/enums/enums.dart';
import 'package:frontend/screens/armarioVirtual/categoria_selector.dart';
import 'package:frontend/screens/armarioVirtual/subcategoria_selector.dart';
import 'package:frontend/services/api_manager.dart';

class FormularioEdicionArticuloPropioScreen extends StatefulWidget {
  final String imagenUrl;
  final dynamic articuloExistente;

  const FormularioEdicionArticuloPropioScreen({
    super.key,
    required this.imagenUrl,
    required this.articuloExistente,
  });

  @override
  State<FormularioEdicionArticuloPropioScreen> createState() => _FormularioEdicionArticuloPropioScreenState();
}

class _FormularioEdicionArticuloPropioScreenState extends State<FormularioEdicionArticuloPropioScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nombreController = TextEditingController();
  final ApiManager _apiManager = ApiManager();

  CategoriaEnum? _categoria;
  List<OcasionEnum> _ocasiones = [];
  dynamic _subcategoria;
  List<TemporadaEnum> _temporadas = [];
  List<ColorEnum> _colores = [];

  final Map<CategoriaEnum, List<dynamic>> subcategoriasMap = {
    CategoriaEnum.ROPA: SubcategoriaRopaEnum.values,
    CategoriaEnum.ACCESORIOS: SubcategoriaAccesoriosEnum.values,
    CategoriaEnum.CALZADO: SubcategoriaCalzadoEnum.values,
  };

  late String originalNombre;
  late CategoriaEnum originalCategoria;
  late dynamic originalSubcategoria;
  late List<OcasionEnum> originalOcasiones;
  late List<TemporadaEnum> originalTemporadas;
  late List<ColorEnum> originalColores;
  late int articuloId;

  @override
  void initState() {
    super.initState();
    final articulo = widget.articuloExistente;
    articuloId = articulo['id'];

    _nombreController.text = articulo['nombre'] ?? '';
    originalNombre = _nombreController.text;

    _categoria = CategoriaEnum.values.firstWhere(
      (e) => e.name == articulo['categoria'],
      orElse: () => CategoriaEnum.ROPA,
    );
    originalCategoria = _categoria!;

    if (_categoria == CategoriaEnum.ROPA) {
      _subcategoria = SubcategoriaRopaEnum.values.firstWhere(
        (e) => e.name == articulo['subcategoria'],
        orElse: () => SubcategoriaRopaEnum.CAMISETAS,
      );
    } else if (_categoria == CategoriaEnum.ACCESORIOS) {
      _subcategoria = SubcategoriaAccesoriosEnum.values.firstWhere(
        (e) => e.name == articulo['subcategoria'],
        orElse: () => SubcategoriaAccesoriosEnum.CINTURONES,
      );
    } else if (_categoria == CategoriaEnum.CALZADO) {
      _subcategoria = SubcategoriaCalzadoEnum.values.firstWhere(
        (e) => e.name == articulo['subcategoria'],
        orElse: () => SubcategoriaCalzadoEnum.ZAPATILLAS,
      );
    }
    originalSubcategoria = _subcategoria;

    _ocasiones = List<String>.from(articulo['ocasiones'])
        .map((e) => OcasionEnum.values.firstWhere((o) => o.name == e))
        .toList();
    originalOcasiones = List.from(_ocasiones);

    _temporadas = List<String>.from(articulo['temporadas'])
        .map((e) => TemporadaEnum.values.firstWhere((t) => t.name == e))
        .toList();
    originalTemporadas = List.from(_temporadas);

    _colores = List<String>.from(articulo['colores'])
        .map((e) => ColorEnum.values.firstWhere((c) => c.name == e))
        .toList();
    originalColores = List.from(_colores);
  }

  String _getSubcategoriaValue(dynamic sub) {
    if (sub is SubcategoriaRopaEnum) return sub.value;
    if (sub is SubcategoriaAccesoriosEnum) return sub.value;
    if (sub is SubcategoriaCalzadoEnum) return sub.value;
    return sub.toString();
  }

  Future<void> _editarArticulo() async {
    if (!_formKey.currentState!.validate()) return;

    try {
      SubcategoriaRopaEnum? subRopa;
      SubcategoriaAccesoriosEnum? subAccesorio;
      SubcategoriaCalzadoEnum? subCalzado;

      if (_categoria == CategoriaEnum.ROPA && _subcategoria is SubcategoriaRopaEnum) {
        subRopa = _subcategoria;
      } else if (_categoria == CategoriaEnum.ACCESORIOS && _subcategoria is SubcategoriaAccesoriosEnum) {
        subAccesorio = _subcategoria;
      } else if (_categoria == CategoriaEnum.CALZADO && _subcategoria is SubcategoriaCalzadoEnum) {
        subCalzado = _subcategoria;
      }

      final nombreChanged = _nombreController.text != originalNombre;
      final categoriaChanged = _categoria != originalCategoria;
      final subcategoriaChanged = _subcategoria != originalSubcategoria;
      final ocasionesChanged = !_listasIguales(_ocasiones, originalOcasiones);
      final temporadasChanged = !_listasIguales(_temporadas, originalTemporadas);
      final coloresChanged = !_listasIguales(_colores, originalColores);

      await _apiManager.editarArticuloPropio(
        id: articuloId,
        nombre: nombreChanged ? _nombreController.text : null,
        categoria: categoriaChanged ? _categoria : null,
        subcategoriaRopa: subRopa != originalSubcategoria ? subRopa : null,
        subcategoriaAccesorios: subAccesorio != originalSubcategoria ? subAccesorio : null,
        subcategoriaCalzado: subCalzado != originalSubcategoria ? subCalzado : null,
        ocasiones: ocasionesChanged ? _ocasiones : null,
        temporadas: temporadasChanged ? _temporadas : null,
        colores: coloresChanged ? _colores : null,
      );

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Cambios guardados correctamente")),
      );
      Navigator.pop(context, {
        ...widget.articuloExistente,
        if (nombreChanged) 'nombre': _nombreController.text,
        if (categoriaChanged) 'categoria': _categoria!.name,
        if (subcategoriaChanged) 'subcategoria': _subcategoria.name,
        if (ocasionesChanged) 'ocasiones': _ocasiones.map((e) => e.name).toList(),
        if (temporadasChanged) 'temporadas': _temporadas.map((e) => e.name).toList(),
        if (coloresChanged) 'colores': _colores.map((e) => e.name).toList(),
      });

    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error al editar la prenda: $e")),
      );
    }
  }

  bool _listasIguales(List a, List b) {
    if (a.length != b.length) return false;
    for (var item in a) {
      if (!b.contains(item)) return false;
    }
    return true;
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Editar Prenda")),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Image.network(widget.imagenUrl, height: 250, fit: BoxFit.cover),
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
                    title: const Text("Selecciona categoría"),
                    subtitle: Text(
                      (_categoria == null)
                          ? "Selecciona una categoría y subcategoría"
                          : "${_categoria!.value}, ${_getSubcategoriaValue(_subcategoria)}",
                    ),
                    trailing: const Icon(Icons.arrow_forward_ios),
                    onTap: () async {
                      final categoriaSeleccionada = await Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const CategoriaSelector()),
                      );

                      if (categoriaSeleccionada != null) {
                        final categoria = categoriaSeleccionada is String
                            ? CategoriaEnum.values.firstWhere(
                                (e) => e.value == categoriaSeleccionada,
                                orElse: () => throw Exception("Categoría no válida"),
                              )
                            : categoriaSeleccionada as CategoriaEnum;

                        final subcategoriaSeleccionada = await Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => SubcategoriaSelector(categoria: categoria.value),
                          ),
                        );

                        if (subcategoriaSeleccionada != null) {
                          setState(() {
                            _categoria = categoria;
                            _subcategoria = subcategoriaSeleccionada;
                          });
                        }
                      }
                    },
                  ),
                  ListTile(
                    title: const Text("Selecciona ocasiones"),
                    subtitle: Text(
                      _ocasiones.isEmpty
                          ? "Selecciona una o varias ocasiones"
                          : _ocasiones.map((e) => e.value).join(", "),
                    ),
                    trailing: const Icon(Icons.arrow_forward_ios),
                    onTap: () async {
                      final selectedOcasiones = await showDialog<List<OcasionEnum>>(
                        context: context,
                        builder: (context) {
                          final tempOcasiones = List<OcasionEnum>.from(_ocasiones);
                          return StatefulBuilder(
                            builder: (context, setState) {
                              return AlertDialog(
                                content: SingleChildScrollView(
                                  child: Column(
                                    children: OcasionEnum.values.map((ocasion) {
                                      return CheckboxListTile(
                                        title: Text(ocasion.value),
                                        value: tempOcasiones.contains(ocasion),
                                        onChanged: (isSelected) {
                                          setState(() {
                                            if (isSelected == true) {
                                              tempOcasiones.add(ocasion);
                                            } else {
                                              tempOcasiones.remove(ocasion);
                                            }
                                          });
                                        },
                                      );
                                    }).toList(),
                                  ),
                                ),
                                actions: [
                                  TextButton(
                                    onPressed: () => Navigator.pop(context, null),
                                    child: const Text("Cancelar"),
                                  ),
                                  TextButton(
                                    onPressed: () => Navigator.pop(context, tempOcasiones),
                                    child: const Text("Aceptar"),
                                  ),
                                ],
                              );
                            },
                          );
                        },
                      );

                      if (selectedOcasiones != null) {
                        setState(() {
                          _ocasiones = selectedOcasiones;
                        });
                      }
                    },
                  ),
                  ListTile(
                    title: const Text("Selecciona temporadas"),
                    subtitle: Text(
                      _temporadas.isEmpty
                          ? "Selecciona una o varias temporadas"
                          : _temporadas.map((e) => e.value).join(", "),
                    ),
                    trailing: const Icon(Icons.arrow_forward_ios),
                    onTap: () async {
                      final selectedTemporadas = await showDialog<List<TemporadaEnum>>(
                        context: context,
                        builder: (context) {
                          final tempTemporadas = List<TemporadaEnum>.from(_temporadas);
                          return StatefulBuilder(
                            builder: (context, setState) {
                              return AlertDialog(
                                content: SingleChildScrollView(
                                  child: Column(
                                    children: TemporadaEnum.values.map((temporada) {
                                      return CheckboxListTile(
                                        title: Text(temporada.value),
                                        value: tempTemporadas.contains(temporada),
                                        onChanged: (isSelected) {
                                          setState(() {
                                            if (isSelected == true) {
                                              tempTemporadas.add(temporada);
                                            } else {
                                              tempTemporadas.remove(temporada);
                                            }
                                          });
                                        },
                                      );
                                    }).toList(),
                                  ),
                                ),
                                actions: [
                                  TextButton(
                                    onPressed: () => Navigator.pop(context, null),
                                    child: const Text("Cancelar"),
                                  ),
                                  TextButton(
                                    onPressed: () => Navigator.pop(context, tempTemporadas),
                                    child: const Text("Aceptar"),
                                  ),
                                ],
                              );
                            },
                          );
                        },
                      );

                      if (selectedTemporadas != null) {
                        setState(() {
                          _temporadas = selectedTemporadas;
                        });
                      }
                    },
                  ),
                  ListTile(
                    title: const Text("Selecciona colores"),
                    subtitle: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: ColorEnum.values.take(6).map((color) {
                            return InkWell(
                              onTap: () {
                                setState(() {
                                  if (_colores.contains(color)) {
                                    _colores.remove(color);
                                  } else {
                                    _colores.add(color);
                                  }
                                });
                              },
                              child: Container(
                                width: 32,
                                height: 32,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: _colores.contains(color)
                                      ? _getColorFromEnum(color).withOpacity(0.7)
                                      : _getColorFromEnum(color),
                                  border: Border.all(
                                    color: Colors.black12,
                                    width: 2,
                                  ),
                                ),
                                child: _colores.contains(color)
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
                          }).toList(),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: ColorEnum.values.skip(6).map((color) {
                            return InkWell(
                              onTap: () {
                                setState(() {
                                  if (_colores.contains(color)) {
                                    _colores.remove(color);
                                  } else {
                                    _colores.add(color);
                                  }
                                });
                              },
                              child: Container(
                                width: 32,
                                height: 32,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: _colores.contains(color)
                                      ? _getColorFromEnum(color).withOpacity(0.7)
                                      : _getColorFromEnum(color),
                                  border: Border.all(
                                    color: Colors.black12,
                                    width: 2,
                                  ),
                                ),
                                child: _colores.contains(color)
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
                          }).toList(),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: _editarArticulo,
                    child: const Text("Guardar cambios"),
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
