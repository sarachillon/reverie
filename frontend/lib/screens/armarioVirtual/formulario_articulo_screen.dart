import 'dart:io';
import 'package:flutter/material.dart';
import 'package:frontend/enums/enums.dart';
import 'package:frontend/screens/armarioVirtual/categoria_selector.dart';
import 'package:frontend/screens/armarioVirtual/subcategoria_selector.dart';

class FormularioArticuloScreen extends StatefulWidget {
  final File imagen;

  const FormularioArticuloScreen({super.key, required this.imagen});

  @override
  State<FormularioArticuloScreen> createState() => _FormularioArticuloScreenState();
}

class _FormularioArticuloScreenState extends State<FormularioArticuloScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nombreController = TextEditingController();

  CategoriaEnum? _categoria;
  SubcategoriaRopaEnum? _subcategoria;
  List<OcasionEnum> _ocasiones = []; // Selección múltiple para ocasión
  List<TemporadaEnum> _temporadas = []; // Selección múltiple para temporada
  List<ColorEnum> _colores = []; // Selección múltiple para colores

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Nueva Prenda")),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Image.file(widget.imagen, height: 250),
            const SizedBox(height: 16),
            Form(
              key: _formKey,
              child: Column(
                children: [
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
                          : "${_categoria!.value}, ${_subcategoria!.value}",
                    ),
                    trailing: const Icon(Icons.arrow_forward_ios),
                    onTap: () async {
                      final categoria = await Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const CategoriaSelector()),
                      );
                      if (categoria != null) {
                        final subcategoria = await Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => SubcategoriaSelector(categoria: categoria)),
                        );
                        if (subcategoria != null) {
                          setState(() {
                            _categoria = categoria;
                            _subcategoria = subcategoria;
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
                                width: 30, // Tamaño reducido
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
                                width: 30, // Tamaño reducido
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

                  // Botón para guardar la prenda
                  ElevatedButton(
                    onPressed: () {
                      if (_formKey.currentState!.validate() &&
                          _categoria != null &&
                          _subcategoria != null &&
                          _ocasiones.isNotEmpty &&
                          _temporadas.isNotEmpty &&
                          _colores.isNotEmpty) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              "Prenda añadida al armario virtual (simulado)",
                            ),
                          ),
                        );
                        Navigator.pop(context);
                      }
                    },
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
