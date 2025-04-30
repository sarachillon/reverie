// Cambios clave marcados con comentarios
import 'package:flutter/material.dart';
import 'package:frontend/enums/enums.dart';

class FiltrosArticuloPropioScreen extends StatefulWidget {
  final Map<String, dynamic>? filtrosIniciales;
  final Function(Map<String, dynamic>) onAplicar;
  final VoidCallback onCerrar; // NUEVO: para cerrar con botón X

  const FiltrosArticuloPropioScreen({
    super.key,
    this.filtrosIniciales,
    required this.onAplicar,
    required this.onCerrar,
  });

  @override
  State<FiltrosArticuloPropioScreen> createState() => _FiltrosArticuloPropioScreenState();
}

class _FiltrosArticuloPropioScreenState extends State<FiltrosArticuloPropioScreen> {
  CategoriaEnum? _categoriaSeleccionada;
  String? _subcategoriaSeleccionada;
  List<OcasionEnum> _ocasionesSeleccionadas = [];
  List<TemporadaEnum> _temporadasSeleccionadas = [];
  List<ColorEnum> _coloresSeleccionados = [];

  List<String> _getSubcategoriasString(CategoriaEnum categoria) {
    switch (categoria) {
      case CategoriaEnum.ROPA:
        return SubcategoriaRopaEnum.values.map((e) => e.value).toList();
      case CategoriaEnum.CALZADO:
        return SubcategoriaCalzadoEnum.values.map((e) => e.value).toList();
      case CategoriaEnum.ACCESORIOS:
        return SubcategoriaAccesoriosEnum.values.map((e) => e.value).toList();
    }
  }

  dynamic _getEnumFromSubcategoria(String subcat, CategoriaEnum categoria) {
    switch (categoria) {
      case CategoriaEnum.ROPA:
        return SubcategoriaRopaEnum.values.firstWhere((e) => e.value == subcat);
      case CategoriaEnum.CALZADO:
        return SubcategoriaCalzadoEnum.values.firstWhere((e) => e.value == subcat);
      case CategoriaEnum.ACCESORIOS:
        return SubcategoriaAccesoriosEnum.values.firstWhere((e) => e.value == subcat);
    }
  }

  String _getEnumKey(dynamic enumValue) {
    return enumValue.toString().split('.').last;
  }

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerRight,
      child: FractionallySizedBox(
        child: Material(
          elevation: 10,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(20),
            bottomLeft: Radius.circular(20),
          ),
          clipBehavior: Clip.antiAlias,
          color: Colors.white,
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: ListView(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Filtros', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                      Row(
                        children: [
                          TextButton(
                            onPressed: () {
                              setState(() {
                                _categoriaSeleccionada = null;
                                _subcategoriaSeleccionada = null;
                                _ocasionesSeleccionadas.clear();
                                _temporadasSeleccionadas.clear();
                                _coloresSeleccionados.clear();
                              });
                            },
                            child: const Text('Limpiar filtros'),
                          ),
                          IconButton(
                            icon: const Icon(Icons.close),
                            onPressed: widget.onCerrar,
                          ),
                        ],
                      ),
                    ],
                  ),


                  const SizedBox(height: 10),
                  const Text('Categoría', style: TextStyle(fontWeight: FontWeight.bold)),
                  DropdownButton<CategoriaEnum>(
                    value: _categoriaSeleccionada,
                    isExpanded: true,
                    hint: const Text('Selecciona una categoría'),
                    items: CategoriaEnum.values.map((categoria) {
                      return DropdownMenuItem(
                        value: categoria,
                        child: Text(categoria.value),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setState(() {
                        _categoriaSeleccionada = value;
                        _subcategoriaSeleccionada = null;
                      });
                    },
                  ),

                  const SizedBox(height: 10),
                  if (_categoriaSeleccionada != null) ...[
                    const Text('Subcategoría', style: TextStyle(fontWeight: FontWeight.bold)),
                    DropdownButton<String>(
                      value: _subcategoriaSeleccionada,
                      isExpanded: true,
                      hint: const Text('Selecciona una subcategoría'),
                      items: _getSubcategoriasString(_categoriaSeleccionada!).map((subcat) {
                        return DropdownMenuItem(
                          value: subcat,
                          child: Text(subcat),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setState(() {
                          _subcategoriaSeleccionada = value;
                        });
                      },
                    ),
                  ],

                  const SizedBox(height: 20),
                  const Text('Ocasión', style: TextStyle(fontWeight: FontWeight.bold)),
                  Wrap(
                    spacing: 6,
                    runSpacing: 0,
                    children: OcasionEnum.values.map((o) {
                      final selected = _ocasionesSeleccionadas.contains(o);
                      return ChoiceChip(
                        label: Text(o.value),
                        selected: selected,
                        backgroundColor: Colors.transparent,
                        labelStyle: TextStyle(color: Colors.black),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(100),
                        ),
                        showCheckmark: false,
                        onSelected: (_) {
                          setState(() {
                            selected ? _ocasionesSeleccionadas.remove(o) : _ocasionesSeleccionadas.add(o);
                          });
                        },
                      );

                    }).toList(),
                  ),

                  const SizedBox(height: 20),
                  const Text('Temporada', style: TextStyle(fontWeight: FontWeight.bold)),
                  Wrap(
                    spacing: 6,
                    runSpacing: 0,
                    children: TemporadaEnum.values.map((t) {
                      final selected = _temporadasSeleccionadas.contains(t);
                      return ChoiceChip(
                        label: Text(t.value),
                        selected: selected,
                        backgroundColor: Colors.transparent,
                        labelStyle: TextStyle(color: Colors.black),
                        showCheckmark: false,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(100),
                        ),
                        onSelected: (_) {
                          setState(() {
                            selected ? _temporadasSeleccionadas.remove(t) : _temporadasSeleccionadas.add(t);
                          });
                        },
                      );
                    }).toList(),
                  ),

                  const Text('Color', style: TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: ColorEnum.values.take(6).map((color) {
                          final selected = _coloresSeleccionados.contains(color);
                          return InkWell(
                            onTap: () {
                              setState(() {
                                selected ? _coloresSeleccionados.remove(color) : _coloresSeleccionados.add(color);
                              });
                            },
                            child: Container(
                              width: 32,
                              height: 32,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: selected
                                    ? _getColorFromEnum(color).withOpacity(0.7)
                                    : _getColorFromEnum(color),
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
                        }).toList(),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: ColorEnum.values.skip(6).map((color) {
                          final selected = _coloresSeleccionados.contains(color);
                          return InkWell(
                            onTap: () {
                              setState(() {
                                selected ? _coloresSeleccionados.remove(color) : _coloresSeleccionados.add(color);
                              });
                            },
                            child: Container(
                              width: 32,
                              height: 32,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: selected
                                    ? _getColorFromEnum(color).withOpacity(0.7)
                                    : _getColorFromEnum(color),
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
                        }).toList(),
                      ),
                    ],
                  ),


                  const SizedBox(height: 30),
                  ElevatedButton(
                    onPressed: () {
                      final filtros = <String, dynamic>{};
                      if (_categoriaSeleccionada != null) {
                        filtros['categoria'] = _getEnumKey(_categoriaSeleccionada!);
                        if (_subcategoriaSeleccionada != null) {
                          final subcatEnum = _getEnumFromSubcategoria(_subcategoriaSeleccionada!, _categoriaSeleccionada!);
                          if (subcatEnum != null) {
                            filtros['subcategoria'] = _getEnumKey(subcatEnum);
                          }
                        }
                      }
                      if (_ocasionesSeleccionadas.isNotEmpty) {
                        filtros['ocasiones'] = _ocasionesSeleccionadas.map((e) => _getEnumKey(e)).toList();
                      }
                      if (_temporadasSeleccionadas.isNotEmpty) {
                        filtros['temporadas'] = _temporadasSeleccionadas.map((e) => _getEnumKey(e)).toList();
                      }
                      if (_coloresSeleccionados.isNotEmpty) {
                        filtros['colores'] = _coloresSeleccionados.map((e) => _getEnumKey(e)).toList();
                      }

                      widget.onAplicar(filtros);
                      widget.onCerrar(); // también cerramos desde aquí
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.black87,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                    child: const Text('Aplicar filtros'),
                  ),
                ],
              ),
            ),
          ),
        ),
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
