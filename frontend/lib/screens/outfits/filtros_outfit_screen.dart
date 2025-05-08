import 'package:flutter/material.dart';
import 'package:frontend/enums/enums.dart';

class FiltrosOutfitScreen extends StatefulWidget {
  final Map<String, dynamic>? filtrosIniciales;
  final Function(Map<String, dynamic>) onAplicar;
  final VoidCallback onCerrar;

  const FiltrosOutfitScreen({
    super.key,
    this.filtrosIniciales,
    required this.onAplicar,
    required this.onCerrar,
  });

  @override
  State<FiltrosOutfitScreen> createState() => _FiltrosOutfitScreenState();
}

class _FiltrosOutfitScreenState extends State<FiltrosOutfitScreen> {
  List<OcasionEnum> _ocasionesSeleccionadas = [];
  List<TemporadaEnum> _temporadasSeleccionadas = [];
  List<ColorEnum> _coloresSeleccionados = [];

  String _getEnumKey(dynamic e) => e.toString().split('.').last;

  @override
  Widget build(BuildContext context) {
    return Material(
      elevation: 16,
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
                            _ocasionesSeleccionadas.clear();
                            _temporadasSeleccionadas.clear();
                            _coloresSeleccionados.clear();
                          });
                        },
                        child: const Text('Limpiar'),
                      ),
                      IconButton(icon: const Icon(Icons.close), onPressed: widget.onCerrar),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 20),
              const Text('Ocasión', style: TextStyle(fontWeight: FontWeight.bold)),
              Wrap(
                spacing: 6,
                children: OcasionEnum.values.map((o) {
                  final selected = _ocasionesSeleccionadas.contains(o);
                  return ChoiceChip(
                    label: Text(o.value),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(100),
                    ),
                    showCheckmark: false,
                    selected: selected,
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
                children: TemporadaEnum.values.map((t) {
                  final selected = _temporadasSeleccionadas.contains(t);
                  return ChoiceChip(
                    label: Text(t.value),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(100),
                    ),
                    showCheckmark: false,
                    selected: selected,
                    onSelected: (_) {
                      setState(() {
                        selected ? _temporadasSeleccionadas.remove(t) : _temporadasSeleccionadas.add(t);
                      });
                    },
                  );
                }).toList(),
              ),
              const SizedBox(height: 20),
              const Text('Colores', style: TextStyle(fontWeight: FontWeight.bold)),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: ColorEnum.values.map((c) {
                  final selected = _coloresSeleccionados.contains(c);
                  return InkWell(
                    onTap: () {
                      setState(() {
                        selected ? _coloresSeleccionados.remove(c) : _coloresSeleccionados.add(c);
                      });
                    },
                    child: Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: _getColor(c).withOpacity(selected ? 0.7 : 1),
                        border: Border.all(color: Colors.black12),
                      ),
                      child: selected ? const Icon(Icons.check, size: 18) : null,
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 30),
              ElevatedButton(
                onPressed: () {
                  final filtros = <String, dynamic>{};
                  if (_ocasionesSeleccionadas.isNotEmpty) {
                    filtros['ocasiones'] = _ocasionesSeleccionadas.map(_getEnumKey).toList();
                  }
                  if (_temporadasSeleccionadas.isNotEmpty) {
                    filtros['temporadas'] = _temporadasSeleccionadas.map(_getEnumKey).toList();
                  }
                  if (_coloresSeleccionados.isNotEmpty) {
                    filtros['colores'] = _coloresSeleccionados.map(_getEnumKey).toList();
                  }
                  widget.onAplicar(filtros);
                },
                child: const Text("Aplicar filtros"),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Color _getColor(ColorEnum c) {
    switch (c) {
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
