import 'package:flutter/material.dart';

class FiltrarArticulosScreen extends StatefulWidget {
  const FiltrarArticulosScreen({super.key});

  @override
  State<FiltrarArticulosScreen> createState() => _FiltrarArticulosScreenState();
}

class _FiltrarArticulosScreenState extends State<FiltrarArticulosScreen> {
  String? categoriaSeleccionada;
  List<String> coloresSeleccionados = [];
  List<String> ocasionesSeleccionadas = [];
  List<String> temporadasSeleccionadas = [];

  // Método para aplicar los filtros y regresar los datos a ArmarioScreen
  void _aplicarFiltros() {
    Navigator.pop(context, {
      'categoria': categoriaSeleccionada,
      'colores': coloresSeleccionados,
      'ocasiones': ocasionesSeleccionadas,
      'temporadas': temporadasSeleccionadas,
    });
  }

  // Método para limpiar los filtros
  void _limpiarFiltros() {
    setState(() {
      categoriaSeleccionada = null;
      coloresSeleccionados.clear();
      ocasionesSeleccionadas.clear();
      temporadasSeleccionadas.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Filtrar artículos'),
        actions: [
          IconButton(
            icon: const Icon(Icons.clear_all),
            onPressed: _limpiarFiltros,
            tooltip: 'Limpiar filtros',
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Filtro por Categoría
            const Text('Categoría', style: TextStyle(fontWeight: FontWeight.bold)),
            DropdownButton<String>(
              isExpanded: true,
              value: categoriaSeleccionada,
              hint: const Text('Selecciona una categoría'),
              items: ['Ropa', 'Calzado', 'Accesorios']
                  .map((categoria) => DropdownMenuItem<String>(
                        value: categoria,
                        child: Text(categoria),
                      ))
                  .toList(),
              onChanged: (value) {
                setState(() {
                  categoriaSeleccionada = value;
                });
              },
            ),
            const SizedBox(height: 16),

            // Filtro por Colores
            const Text('Colores', style: TextStyle(fontWeight: FontWeight.bold)),
            CheckboxListTile(
              title: const Text('Rojo'),
              value: coloresSeleccionados.contains('Rojo'),
              onChanged: (bool? value) {
                setState(() {
                  if (value == true) {
                    coloresSeleccionados.add('Rojo');
                  } else {
                    coloresSeleccionados.remove('Rojo');
                  }
                });
              },
            ),
            CheckboxListTile(
              title: const Text('Azul'),
              value: coloresSeleccionados.contains('Azul'),
              onChanged: (bool? value) {
                setState(() {
                  if (value == true) {
                    coloresSeleccionados.add('Azul');
                  } else {
                    coloresSeleccionados.remove('Azul');
                  }
                });
              },
            ),
            // Puedes añadir más colores aquí
            const SizedBox(height: 16),

            // Filtro por Ocasiones
            const Text('Ocasiones', style: TextStyle(fontWeight: FontWeight.bold)),
            CheckboxListTile(
              title: const Text('Casual'),
              value: ocasionesSeleccionadas.contains('Casual'),
              onChanged: (bool? value) {
                setState(() {
                  if (value == true) {
                    ocasionesSeleccionadas.add('Casual');
                  } else {
                    ocasionesSeleccionadas.remove('Casual');
                  }
                });
              },
            ),
            CheckboxListTile(
              title: const Text('De noche'),
              value: ocasionesSeleccionadas.contains('De noche'),
              onChanged: (bool? value) {
                setState(() {
                  if (value == true) {
                    ocasionesSeleccionadas.add('De noche');
                  } else {
                    ocasionesSeleccionadas.remove('De noche');
                  }
                });
              },
            ),
            // Puedes añadir más ocasiones aquí
            const SizedBox(height: 16),

            // Filtro por Temporadas
            const Text('Temporadas', style: TextStyle(fontWeight: FontWeight.bold)),
            CheckboxListTile(
              title: const Text('Primavera'),
              value: temporadasSeleccionadas.contains('Primavera'),
              onChanged: (bool? value) {
                setState(() {
                  if (value == true) {
                    temporadasSeleccionadas.add('Primavera');
                  } else {
                    temporadasSeleccionadas.remove('Primavera');
                  }
                });
              },
            ),
            CheckboxListTile(
              title: const Text('Invierno'),
              value: temporadasSeleccionadas.contains('Invierno'),
              onChanged: (bool? value) {
                setState(() {
                  if (value == true) {
                    temporadasSeleccionadas.add('Invierno');
                  } else {
                    temporadasSeleccionadas.remove('Invierno');
                  }
                });
              },
            ),
            // Puedes añadir más temporadas aquí
            const SizedBox(height: 16),

            // Botón de Aplicar filtros
            ElevatedButton(
              onPressed: _aplicarFiltros,
              child: const Text('Aplicar filtros'),
            ),
          ],
        ),
      ),
    );
  }
}
