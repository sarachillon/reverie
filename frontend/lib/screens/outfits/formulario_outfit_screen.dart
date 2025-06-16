import 'package:flutter/material.dart';
import 'package:frontend/enums/enums.dart';
import 'package:frontend/screens/armarioVirtual/articulo_propio_widget.dart';
import 'package:frontend/screens/armarioVirtual/mini_armario_horizontal.dart';
import 'package:frontend/screens/armarioVirtual/seleccionar_prendas_user.dart';
import 'package:frontend/screens/utils/carga_screen.dart';
import 'package:frontend/screens/utils/imagen_ajustada_widget.dart';
import 'package:frontend/services/api_manager.dart';
import 'package:frontend/screens/outfits/outfit_confirmation_screen.dart';
import 'package:google_fonts/google_fonts.dart';

class FormularioOutfitScreen extends StatefulWidget {
  const FormularioOutfitScreen({super.key, this.userId});
  final int? userId;


  @override
  State<FormularioOutfitScreen> createState() => _FormularioOutfitScreenState();
}

  class _FormularioOutfitScreenState extends State<FormularioOutfitScreen> {
    final _formKey = GlobalKey<FormState>();
    final _tituloController = TextEditingController();
    final _descripcionController = TextEditingController();
    final ApiManager _apiManager = ApiManager();

    List<OcasionEnum> _ocasiones = [];
    List<TemporadaEnum> _temporadas = [];
    List<ColorEnum> _colores = [];

    List<Map<String, dynamic>> prendasFijadas = []; 
    List<Map<String, dynamic>> articulosUsuario = [];

  @override
  void initState() {
    super.initState();
    cargarArticulosUsuario();
  }

  Future<void> cargarArticulosUsuario() async {
    setState(() => articulosUsuario = []);
    try {
      final stream = _apiManager.getArticulosPropiosStream();
      List<Map<String, dynamic>> nuevos = [];
      await for (final articulo in stream) {
        if (!mounted) return;
        if (articulo is Map && articulo.containsKey('categoria')) {
          nuevos.add(articulo as Map<String, dynamic>);
        }
      }
      setState(() {
        articulosUsuario = nuevos;
      });
    } catch (e) {
      print("Error al cargar artículos: $e");
    }
  }

    Future<bool?> generarOutfit(BuildContext context) async {
      // Mostrar loader de outfit
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => const CargandoScreen(type: CargandoType.outfit),
        ),
      );

      int id = prendasFijadas[0]['id'];
      try {
        final outfit = await _apiManager.generarOutfitPropio(
          titulo: _tituloController.text,
          descripcion: _descripcionController.text,
          ocasiones: _ocasiones,
          temporadas: _temporadas,
          colores: _colores,
          articulo_fijo_id: id,
        );

        // Cerrar loader
        Navigator.pop(context);

        // Confirmar resultado
        final bool? resultado = await Navigator.push<bool>(
          context,
          MaterialPageRoute(
            builder: (_) => OutfitConfirmationScreen(
              outfit: outfit,
              onAceptar: () => Navigator.pop(context, true),
              onRechazar: () async {
                await _apiManager.deleteOutfitPropio(id: outfit['id']);
                Navigator.pop(context, false);
              },
            ),
          ),
        );

        // Si el usuario aceptó, cierra este formulario devolviendo true
        if (resultado == true && mounted) {
          Navigator.pop(context, true);
          return true;
        }
      } catch (e) {
        // Cerrar loader en caso de error
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('No se ha podido generar un outfit de estas caracteristicas. Por favor, completa tu armario para poder hacerlo')),
        );
        return false;
      }

      // En cualquier otro caso, devuelve false
      return false;
    }

  Future<List<Map<String, dynamic>>?> showSeleccionarPrendasModal(
  BuildContext context,
  List<Map<String, dynamic>> articulosUsuario,
  List<Map<String, dynamic>> yaSeleccionados,
) async {
  final seleccionados = [...yaSeleccionados];

  return showModalBottomSheet<List<Map<String, dynamic>>>(
    context: context,
    isScrollControlled: true,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (context) {
      return StatefulBuilder(
        builder: (context, setState) {
          return SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 12),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text('Selecciona prendas', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                  const SizedBox(height: 14),
                  Expanded(
                    child: ListView.separated(
                      itemCount: articulosUsuario.length,
                      separatorBuilder: (_, __) => const Divider(height: 1),
                      itemBuilder: (context, i) {
                        final articulo = articulosUsuario[i];
                        final url = articulo['urlFirmada'] ?? '';
                        final yaFijado = seleccionados.any((a) => a['id'] == articulo['id']);
                        return ListTile(
                          leading: url.isNotEmpty
                              ? ClipRRect(
                                  borderRadius: BorderRadius.circular(8),
                                  child: ImagenAjustada(
                                    url: url,
                                    width: 48,
                                    height: 48,
                                  ),
                                )
                              : const SizedBox(width: 48, height: 48, child: Icon(Icons.image)),
                          title: Text(articulo['nombre'] ?? 'Sin nombre'),
                          trailing: Checkbox(
                            value: yaFijado,
                            onChanged: (val) {
                              setState(() {
                                if (val == true) {
                                  seleccionados.add(articulo);
                                } else {
                                  seleccionados.removeWhere((a) => a['id'] == articulo['id']);
                                }
                              });
                            },
                          ),
                          onTap: () {
                            setState(() {
                              if (yaFijado) {
                                seleccionados.removeWhere((a) => a['id'] == articulo['id']);
                              } else {
                                seleccionados.add(articulo);
                              }
                            });
                          },
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 10),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Color(0xFFD4AF37),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                      ),
                      onPressed: () => Navigator.pop(context, seleccionados),
                      child: const Text("Guardar", style: TextStyle(color: Colors.white, fontSize: 16)),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      );
    },
  );
}


  @override
  Widget build(BuildContext context) {
    final primeraFila = ColorEnum.values.take(6);
    final segundaFila = ColorEnum.values.skip(6);

    return Scaffold(
      appBar: AppBar(leading: IconButton(
        icon: const Icon(Icons.arrow_back, color: Color(0xFFD4AF37)),
        onPressed: () => Navigator.pop(context),
      ),
      title: Text(
      'Generar Outfit Automáticamente',
      style: GoogleFonts.dancingScript(
        fontSize: 30,
        color: Color(0xFFD4AF37),
        fontWeight: FontWeight.w600,
      ),
      ),
    ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
              _buildTitulo("Escoge una prenda para fijar"),
              const SizedBox(height: 12),
              MiniArmarioFijar(
                prendasFijadas: prendasFijadas,
                onAddPressed: () async {
                  // Espera a que termine de cargar si sigue vacío
                  if (articulosUsuario.isEmpty) await cargarArticulosUsuario();

                  final seleccionados = await showModalBottomSheet<List<Map<String, dynamic>>>(
                    context: context,
                    isScrollControlled: true,
                    shape: const RoundedRectangleBorder(
                      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                    ),
                    builder: (_) => SeleccionarPrendasUsuarioWidget(
                      articulosUsuario: articulosUsuario,
                      yaSeleccionados: prendasFijadas,
                      // si tu widget admite parámetro para limitar a 1 selección,
                      // también puedes pasarle aquí maxSeleccion: 1
                    ),
                  );

                  if (seleccionados != null && seleccionados.isNotEmpty) {
                    setState(() {
                      // ⇒ Nos quedamos sólo con la primera prenda elegida
                      prendasFijadas = [seleccionados.first];
                    });
                  }
                },
                onRemove: (index) {
                  setState(() {
                    prendasFijadas.removeAt(index);
                  });
                },
              ),


                _buildTitulo("Información básica"),
                const SizedBox(height: 12),
                const Text("Nombre del outfit", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                const SizedBox(height: 4),
                TextFormField(
                  controller: _tituloController,
                  decoration: const InputDecoration(
                    hintText: "Introduce un nombre",
                    isDense: true,
                    contentPadding: EdgeInsets.symmetric(vertical: 10),
                    border: UnderlineInputBorder(),
                  ),
                  style: const TextStyle(fontSize: 15),
                  validator: (value) => value == null || value.isEmpty ? "Campo obligatorio" : null,
                ),
                const SizedBox(height: 16),
                const Text("Descripción", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                const SizedBox(height: 4),
                TextFormField(
                  controller: _descripcionController,
                  maxLines: 3,
                  textAlignVertical: TextAlignVertical.top,
                  decoration: const InputDecoration(
                    hintText: "Opcional",
                    alignLabelWithHint: true,
                    border: OutlineInputBorder(),
                    isDense: true,
                  ),
                  style: const TextStyle(fontSize: 15),
                ),
                const SizedBox(height: 16),
                const Text("Ocasión", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                const SizedBox(height: 4),
                Wrap(
                  spacing: 6,
                  children: OcasionEnum.values.map((o) {
                    final selected = _ocasiones.contains(o);
                    return ChoiceChip(
                      label: Text(o.value, style: const TextStyle(fontSize: 15)),
                      selected: selected,
                      backgroundColor: Colors.transparent,
                      labelStyle: TextStyle(color: Colors.black),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(100)),
                      showCheckmark: false,
                      onSelected: (isSelected) {
                        setState(() {
                          isSelected ? _ocasiones.add(o) : _ocasiones.remove(o);
                        });
                      },
                    );
                  }).toList(),
                ),
                const SizedBox(height: 24),
                _buildTitulo("Filtros avanzados (opcionales)"),
                const SizedBox(height: 12),
                const Text("Temporada", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 6,
                  runSpacing: 0,
                  children: TemporadaEnum.values.map((t) {
                    final selected = _temporadas.contains(t);
                    return ChoiceChip(
                      label: Text(t.value),
                      selected: selected,
                      backgroundColor: Colors.transparent,
                      labelStyle: const TextStyle(color: Colors.black),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(100)),
                      showCheckmark: false,
                      onSelected: (_) {
                        setState(() {
                          selected ? _temporadas.remove(t) : _temporadas.add(t);
                        });
                      },
                    );
                  }).toList(),
                ),
                const SizedBox(height: 12),
                const Text("Colores", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: primeraFila.map(_buildColorCircle).toList(),
                ),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: segundaFila.map(_buildColorCircle).toList(),
                ),
                const SizedBox(height: 32),
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: () {
                      if (_formKey.currentState!.validate()) {
                        generarOutfit(context);
                      }
                    },
                    child: const Text("Generar outfit", style: TextStyle(fontSize: 18)),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTitulo(String texto) {
    return Text(texto, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold));
  }

  Widget _buildColorCircle(ColorEnum color) {
    final selected = _colores.contains(color);
    return InkWell(
      onTap: () {
        setState(() {
          selected ? _colores.remove(color) : _colores.add(color);
        });
      },
      child: Container(
        width: 32,
        height: 32,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: selected ? _getColorFromEnum(color).withOpacity(0.7) : _getColorFromEnum(color),
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