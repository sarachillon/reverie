import 'package:flutter/material.dart';
import 'package:frontend/enums/enums.dart';

class FiltrosArticuloPropioScreen extends StatefulWidget {
  final Map<String, dynamic>? filtrosIniciales;
  final Function(Map<String, dynamic>) onAplicar;

  const FiltrosArticuloPropioScreen({
    super.key,
    this.filtrosIniciales,
    required this.onAplicar,
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
        return SubcategoriaRopaEnum.values.firstWhere(
          (e) => e.value == subcat
        );
      case CategoriaEnum.CALZADO:
        return SubcategoriaCalzadoEnum.values.firstWhere(
          (e) => e.value == subcat
        );
      case CategoriaEnum.ACCESORIOS:
        return SubcategoriaAccesoriosEnum.values.firstWhere(
          (e) => e.value == subcat
        );
    }
  }

  String _getEnumKey(dynamic enumValue) {
    return enumValue.toString().split('.').last;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Filtros")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
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
              spacing: 8,
              children: OcasionEnum.values.map((o) {
                return FilterChip(
                  label: Text(o.value),
                  selected: _ocasionesSeleccionadas.contains(o),
                  onSelected: (sel) {
                    setState(() {
                      sel ? _ocasionesSeleccionadas.add(o) : _ocasionesSeleccionadas.remove(o);
                    });
                  },
                );
              }).toList(),
            ),

            const SizedBox(height: 20),
            const Text('Temporada', style: TextStyle(fontWeight: FontWeight.bold)),
            Wrap(
              spacing: 8,
              children: TemporadaEnum.values.map((t) {
                return FilterChip(
                  label: Text(t.value),
                  selected: _temporadasSeleccionadas.contains(t),
                  onSelected: (sel) {
                    setState(() {
                      sel ? _temporadasSeleccionadas.add(t) : _temporadasSeleccionadas.remove(t);
                    });
                  },
                );
              }).toList(),
            ),

            const SizedBox(height: 20),
            const Text('Color', style: TextStyle(fontWeight: FontWeight.bold)),
            Wrap(
              spacing: 8,
              children: ColorEnum.values.map((c) {
                return FilterChip(
                  label: Text(c.value),
                  selected: _coloresSeleccionados.contains(c),
                  onSelected: (sel) {
                    setState(() {
                      sel ? _coloresSeleccionados.add(c) : _coloresSeleccionados.remove(c);
                    });
                  },
                );
              }).toList(),
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
                Navigator.pop(context);
              },
              child: const Text('Aplicar filtros'),
            ),
          ],
        ),
      ),
    );
  }
}
