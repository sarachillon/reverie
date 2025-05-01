import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:frontend/enums/enums.dart';
import 'package:frontend/screens/armarioVirtual/categoria_selector.dart';
import 'package:frontend/screens/armarioVirtual/subcategoria_selector.dart';
import 'package:frontend/services/api_manager.dart';

class FormularioArticuloScreen extends StatefulWidget {
  final File? imagenFile;
  final Uint8List? imagenBytes;
  final dynamic articuloExistente;

  const FormularioArticuloScreen({
    super.key,
    this.imagenFile,
    this.imagenBytes,
    this.articuloExistente,

  });

  @override
  State<FormularioArticuloScreen> createState() => _FormularioArticuloScreenState();
}

class _FormularioArticuloScreenState extends State<FormularioArticuloScreen> {
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


  @override
  void initState() {
    super.initState();
    if (widget.articuloExistente != null) {
      final articulo = widget.articuloExistente;
      _nombreController.text = articulo['nombre'] ?? '';

      final categoriaEnum = CategoriaEnum.values.firstWhere(
        (e) => e.name == articulo['categoria'],
        orElse: () => CategoriaEnum.ROPA,
      );

      _categoria = categoriaEnum;

      final subcategorias = subcategoriasMap[categoriaEnum];
      if (subcategorias != null) {
        if (categoriaEnum == CategoriaEnum.ROPA) {
          _subcategoria = SubcategoriaRopaEnum.values.firstWhere(
            (e) => e.name == articulo['subcategoria'],
            orElse: () => SubcategoriaRopaEnum.CAMISETAS, 
          );
        } else if (categoriaEnum == CategoriaEnum.ACCESORIOS) {
          _subcategoria = SubcategoriaAccesoriosEnum.values.firstWhere(
            (e) => e.name == articulo['subcategoria'],
            orElse: () => SubcategoriaAccesoriosEnum.CINTURONES,
          );
        } else if (categoriaEnum == CategoriaEnum.CALZADO) {
          _subcategoria = SubcategoriaCalzadoEnum.values.firstWhere(
            (e) => e.name == articulo['subcategoria'],
            orElse: () => SubcategoriaCalzadoEnum.ZAPATILLAS,
          );
        }
      }

      _subcategoria = articulo['subcategoria'];

      if (articulo['ocasiones'] != null) {
        _ocasiones = List<String>.from(articulo['ocasiones'])
            .map((e) => OcasionEnum.values.firstWhere((o) => o.name.toUpperCase() == e.toUpperCase()))
            .toList();
      }

      if (articulo['temporadas'] != null) {
        _temporadas = List<String>.from(articulo['temporadas'])
            .map((e) => TemporadaEnum.values.firstWhere((t) => t.name.toUpperCase() == e.toUpperCase()))
            .toList();
      }

      if (articulo['colores'] != null) {
        _colores = List<String>.from(articulo['colores'])
            .map((e) => ColorEnum.values.firstWhere((c) => c.name.toUpperCase() == e.toUpperCase()))
            .toList();
      }
    }
  }


  Future<void> _guardarPrenda() async {
    if (_formKey.currentState!.validate() &&
        _categoria != null &&
        _subcategoria != null &&
        _ocasiones.isNotEmpty &&
        _temporadas.isNotEmpty &&
        _colores.isNotEmpty) {
      try {
        // Determina las subcategorías según la categoría seleccionada
        SubcategoriaRopaEnum? subcategoriaRopa;
        SubcategoriaAccesoriosEnum? subcategoriaAccesorios;
        SubcategoriaCalzadoEnum? subcategoriaCalzado;

        if (_categoria == CategoriaEnum.ROPA) {
          subcategoriaRopa = SubcategoriaRopaEnum.values.firstWhere(
            (e) => e.value == _subcategoria,
            orElse: () => throw Exception("Subcategoría no válida para Ropa"),
          );
        } else if (_categoria == CategoriaEnum.ACCESORIOS) {
          subcategoriaAccesorios = SubcategoriaAccesoriosEnum.values.firstWhere(
            (e) => e.value == _subcategoria,
            orElse: () => throw Exception("Subcategoría no válida para Accesorios"),
          );
        } else if (_categoria == CategoriaEnum.CALZADO) {
          subcategoriaCalzado = SubcategoriaCalzadoEnum.values.firstWhere(
            (e) => e.value == _subcategoria,
            orElse: () => throw Exception("Subcategoría no válida para Calzado"),
          );
        }

        Image foto;
        if (widget.imagenFile != null) {
          foto = Image.file(widget.imagenFile!);
        } else if (widget.imagenBytes != null) {
          foto = Image.memory(widget.imagenBytes!);
        } else {
          throw Exception("No se ha proporcionado imagen.");
        }

        // Llama a la función guardarArticuloPropio
        await _apiManager.guardarArticuloPropio(
          foto: foto,
          nombre: _nombreController.text,
          categoria: _categoria!,
          subcategoriaRopa: subcategoriaRopa,
          subcategoriaAccesorios: subcategoriaAccesorios,
          subcategoriaCalzado: subcategoriaCalzado,
          ocasiones: _ocasiones,
          temporadas: _temporadas,
          colores: _colores,
        );

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Prenda guardada exitosamente.")),
        );

        Navigator.pop(context); // Regresa a la pantalla anterior
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Error al guardar la prenda: $e")),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Por favor, completa todos los campos obligatorios.")),
      );
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
            if (widget.imagenFile != null)
              Image.file(widget.imagenFile!, height: 250, fit: BoxFit.cover)
            else if (widget.imagenBytes != null)
              Image.memory(widget.imagenBytes!, height: 250, fit: BoxFit.cover)
            else
              const SizedBox(height: 250),
            const SizedBox(height: 16),
            Form(
              key: _formKey,
              child: Column(
                children: [
                // ... (el resto de los campos no se modifican)

                  // Campo de texto para el nombre
                  TextFormField(
                    controller: _nombreController,
                    decoration: const InputDecoration(labelText: "Nombre de la prenda"),
                    validator: (value) => value == null || value.isEmpty ? "Introduce un nombre" : null,
                  ),
                  const SizedBox(height: 16),

                  // Selección de categoría y subcategoría
                  ListTile(
                    title: const Text("Selecciona categoría"),
                    subtitle: Text(
                      (_categoria == null)
                          ? "Selecciona una categoría y subcategoría"
                          : "${_categoria!.value}, ${_subcategoria is String ? _subcategoria : (_subcategoria?.value ?? '')}",
                    ),
                    trailing: const Icon(Icons.arrow_forward_ios),
                    onTap: () async {
                      final categoriaSeleccionada = await Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const CategoriaSelector()),
                      );

                      if (categoriaSeleccionada != null) {
                        // Convierte el valor seleccionado a CategoriaEnum si es un String
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

                  // Selección múltiple de ocasión (Dropdown)
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
                                    onPressed: () {
                                      Navigator.pop(context, tempOcasiones);  // Retorna la lista seleccionada
                                    },
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
                          _ocasiones.addAll(selectedOcasiones.where((ocasion) => !_ocasiones.contains(ocasion)));
                        });
                      }
                    },
                  ),

                  // Selección múltiple de temporada (Dropdown)
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

                  // Selección múltiple de colores
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
                        const SizedBox(height: 8), // Espaciado entre filas
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

                  // Botón para guardar la prenda
                  ElevatedButton(
                    onPressed: _guardarPrenda,
                    child: const Text("Guardar prenda"),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Método para obtener el color real desde el enum
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
