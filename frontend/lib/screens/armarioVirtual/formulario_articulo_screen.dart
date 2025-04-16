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

  String? _categoria;
  String? _subcategoria;
  List<String> _ocasion = [];

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
                  TextFormField(
                    controller: _nombreController,
                    decoration: const InputDecoration(labelText: "Nombre de la prenda"),
                    validator: (value) => value == null || value.isEmpty ? "Introduce un nombre" : null,
                  ),
                  const SizedBox(height: 16),
                  ListTile(
                    title: Text(
                      _categoria == null || _subcategoria == null
                          ? "Selecciona una categoría y subcategoría"
                          : "$_categoria, $_subcategoria",
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
                  ListTile(
                    title: Text(
                      _ocasion.isEmpty ? "Selecciona ocasión" : _ocasion.join(", "),
                    ),
                    trailing: const Icon(Icons.arrow_forward_ios),
                    onTap: () async {
                      final selectedOcasiones = await showDialog<List<String>>(
                        context: context,
                        builder: (context) {
                          final List<String> tempSelectedOcasiones = List.from(_ocasion);
                          return StatefulBuilder(
                            builder: (context, setState) {
                              return AlertDialog(
                                title: const Text("Selecciona ocasiones"),
                                content: SingleChildScrollView(
                                  child: Column(
                                    children: OcasionEnum.values.map((ocasion) {
                                      return CheckboxListTile(
                                        title: Text(ocasion.value),
                                        value: tempSelectedOcasiones.contains(ocasion.value),
                                        onChanged: (isSelected) {
                                          setState(() {
                                            if (isSelected == true) {
                                              tempSelectedOcasiones.add(ocasion.value);
                                            } else {
                                              tempSelectedOcasiones.remove(ocasion.value);
                                            }
                                          });
                                        },
                                      );
                                    }).toList(),
                                  ),
                                ),
                                actions: [
                                  TextButton(
                                    onPressed: () => Navigator.pop(context, null), // Cancelar
                                    child: const Text("Cancelar"),
                                  ),
                                  TextButton(
                                    onPressed: () => Navigator.pop(context, tempSelectedOcasiones), // Confirmar
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
                          _ocasion = selectedOcasiones;
                        });
                      }
                    },
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: () {
                      if (_formKey.currentState!.validate() && _categoria != null && _subcategoria != null && _ocasion.isNotEmpty) {
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
}
