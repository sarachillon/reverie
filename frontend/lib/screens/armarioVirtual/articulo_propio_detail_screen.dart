import 'dart:io';
import 'package:flutter/material.dart';
import 'package:frontend/enums/enums.dart';
import 'package:frontend/screens/armarioVirtual/categoria_selector.dart';
import 'package:frontend/screens/armarioVirtual/subcategoria_selector.dart';
import 'package:frontend/services/api_manager.dart';

class ArticuloPropioDetailScreen extends StatefulWidget {
  final String? imagenUrl; 
  final Map<String, dynamic>? articuloData; 

  const ArticuloPropioDetailScreen({
    Key? key,
    this.imagenUrl,
    this.articuloData,
  }) : super(key: key);

  @override
  State<ArticuloPropioDetailScreen> createState() => _ArticuloPropioDetailScreenState();
}

class _ArticuloPropioDetailScreenState extends State<ArticuloPropioDetailScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nombreController = TextEditingController();
  final ApiManager _apiManager = ApiManager();

  CategoriaEnum? _categoria;
  dynamic _subcategoria;
  List<OcasionEnum> _ocasiones = [];
  List<TemporadaEnum> _temporadas = [];
  List<ColorEnum> _colores = [];

  bool _isEditing = false; // Controla si estamos en modo edición

  @override
  void initState() {
    super.initState();
    _initializeData();
  }

  void _initializeData() {
    if (widget.articuloData != null) {
      _nombreController.text = widget.articuloData!['nombre'] ?? '';
      _categoria = CategoriaEnum.values.firstWhere(
        (e) => e.value == widget.articuloData!['categoria'],
      );
      _subcategoria = widget.articuloData!['subcategoria'];
      _ocasiones = (widget.articuloData!['ocasiones'] as List?)
              ?.map((e) => OcasionEnum.values.firstWhere((o) => o.value == e))
              ?.whereType<OcasionEnum>()
              ?.toList() ??
          [];
      _temporadas = (widget.articuloData!['temporadas'] as List?)
              ?.map((e) => TemporadaEnum.values.firstWhere((t) => t.value == e))
              ?.whereType<TemporadaEnum>()
              ?.toList() ??
          [];
      _colores = (widget.articuloData!['colores'] as List?)
              ?.map((e) => ColorEnum.values.firstWhere((c) => c.value == Easing.emphasizedAccelerate))
              ?.whereType<ColorEnum>()
              ?.toList() ??
          [];
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

        if (_categoria == CategoriaEnum.Ropa) {
          subcategoriaRopa = SubcategoriaRopaEnum.values.firstWhere(
            (e) => e.value == _subcategoria,
            orElse: () => throw Exception("Subcategoría no válida para Ropa"),
          );
        } else if (_categoria == CategoriaEnum.Accesorios) {
          subcategoriaAccesorios = SubcategoriaAccesoriosEnum.values.firstWhere(
            (e) => e.value == _subcategoria,
            orElse: () => throw Exception("Subcategoría no válida para Accesorios"),
          );
        } else if (_categoria == CategoriaEnum.Calzado) {
          subcategoriaCalzado = SubcategoriaCalzadoEnum.values.firstWhere(
            (e) => e.value == _subcategoria,
            orElse: () => throw Exception("Subcategoría no válida para Calzado"),
          );
        }

        //  Aquí iría la lógica para guardar los cambios del artículo
        //  await _apiManager.actualizarArticuloPropio(
        //    id: widget.articuloData!['id'], // Suponiendo que el ID está en los datos
        //    nombre: _nombreController.text,
        //    categoria: _categoria!,
        //    subcategoriaRopa: subcategoriaRopa,
        //    subcategoriaAccesorios: subcategoriaAccesorios,
        //    subcategoriaCalzado: subcategoriaCalzado,
        //    ocasiones: _ocasiones,
        //    temporadas: _temporadas,
        //    colores: _colores,
        //  );

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Cambios guardados exitosamente.")),
        );

        setState(() {
          _isEditing = false; // Salir del modo edición después de guardar
        });
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Error al guardar los cambios: $e")),
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
      appBar: AppBar(
        title: Text(widget.articuloData == null ? "Nueva Prenda" : _isEditing ? "Editar Prenda" : "Detalles de la Prenda"),
        actions: [
          if (widget.articuloData != null)
            IconButton(
              icon: Icon(_isEditing ? Icons.save : Icons.edit),
              onPressed: () {
                setState(() {
                  if (_isEditing) {
                    _guardarPrenda();
                  } else {
                    _isEditing = true;
                  }
                });
              },
            ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Muestra la imagen desde la URL o un placeholder
            widget.imagenUrl != null
                ? Image.network(widget.imagenUrl!, height: 250)
                : Container(
                    height: 250,
                    color: Colors.grey[200],
                    child: const Center(child: Text("No Image")),
                  ),
            const SizedBox(height: 16),
            Form(
              key: _formKey,
              child: Column(
                children: [
                  // Campo de texto para el nombre
                  TextFormField(
                    controller: _nombreController,
                    decoration: const InputDecoration(labelText: "Nombre de la prenda"),
                    enabled: _isEditing,
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
                    onTap: _isEditing
                        ? () async {
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
                          }
                        : null,
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
                    onTap: _isEditing
                        ? () async {
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
                                            Navigator.pop(context, tempOcasiones);
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
                                _ocasiones = selectedOcasiones;
                              });
                            }
                          }
                        : null,
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
                    onTap: _isEditing
                        ? () async {
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
                          }
                        : null,
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
                              onTap: _isEditing
                                  ? () {
                                      setState(() {
                                        if (_colores.contains(color)) {
                                          _colores.remove(color);
                                        } else {
                                          _colores.add(color);
                                        }
                                      });
                                    }
                                  : null,
                              child: Container(
                                width: 30,
                                height: 30,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: _getColorFromEnum(color),
                                  border: Border.all(
                                    color: _colores.contains(color) ? Colors.black : Colors.grey,
                                    width: 2,
                                  ),
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: ColorEnum.values.skip(6).map((color) {
                            return InkWell(
                              onTap: _isEditing
                                  ? () {
                                      setState(() {
                                        if (_colores.contains(color)) {
                                          _colores.remove(color);
                                        } else {
                                          _colores.add(color);
                                        }
                                      });
                                    }
                                  : null,
                              child: Container(
                                width: 30,
                                height: 30,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: _getColorFromEnum(color),
                                  border: Border.all(
                                    color: _colores.contains(color) ? Colors.black : Colors.grey,
                                    width: 2,
                                  ),
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Botón para guardar la prenda (solo visible en modo edición)
                  if (_isEditing)
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
      case ColorEnum.Amarillo:
        return Colors.yellow;
      case ColorEnum.Naranja:
        return Colors.orange;
      case ColorEnum.Rojo:
        return Colors.red;
      case ColorEnum.Rosa:
        return Colors.pink;
      case ColorEnum.Violeta:
        return Colors.purple;
      case ColorEnum.Azul:
        return Colors.blue;
      case ColorEnum.Verde:
        return Colors.green;
      case ColorEnum.Marron:
        return Colors.brown;
      case ColorEnum.Gris:
        return Colors.grey;
      case ColorEnum.Blanco:
        return Colors.white;
      case ColorEnum.Negro:
        return Colors.black;
    }
  }
}