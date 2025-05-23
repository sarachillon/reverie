import 'package:flutter/material.dart';
import 'package:frontend/enums/enums.dart';
import 'package:frontend/screens/utils/carga_screen.dart';
import 'package:frontend/services/api_manager.dart';
import 'package:frontend/screens/outfits/outfit_confirmation_screen.dart';

class FormularioOutfitScreen extends StatefulWidget {
  const FormularioOutfitScreen({super.key});

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

    Future<bool?> generarOutfit(BuildContext context) async {
      // Mostrar loader de outfit
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => const CargandoScreen(type: CargandoType.outfit),
        ),
      );

      try {
        final outfit = await _apiManager.generarOutfitPropio(
          titulo: _tituloController.text,
          descripcion: _descripcionController.text,
          ocasiones: _ocasiones,
          temporadas: _temporadas,
          colores: _colores,
        );

        // Cerrar loader
        Navigator.pop(context);

        // Confirmar resultado
        final bool? resultado = await Navigator.push<bool>(
          context,
          MaterialPageRoute(
            builder: (_) => OutfitConfirmationScreen(
              outfit: outfit,
              mostrarAcciones: true,
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
          SnackBar(content: Text('Error al generar outfit: $e')),
        );
        return false;
      }

      // En cualquier otro caso, devuelve false
      return false;
    }

  @override
  Widget build(BuildContext context) {
    final primeraFila = ColorEnum.values.take(6);
    final segundaFila = ColorEnum.values.skip(6);

    return Scaffold(
      appBar: AppBar(title: const Text("Nuevo Outfit")),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
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