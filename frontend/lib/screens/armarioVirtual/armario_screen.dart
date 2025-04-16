import 'dart:io';
import 'package:flutter/material.dart';
import 'package:frontend/screens/armarioVirtual/formulario_articulo_screen.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';

class ArmarioScreen extends StatefulWidget {
  const ArmarioScreen({super.key});

  @override
  State<ArmarioScreen> createState() => _ArmarioScreenState();
}

class _ArmarioScreenState extends State<ArmarioScreen> {
  File? _imagenSeleccionada;
  bool _isPicking = false;

  Future<void> _pedirPermisos() async {
    await [
      Permission.camera,
      Permission.photos, // iOS
      Permission.storage, // Android
    ].request();
  }

  Future<void> _seleccionarDesdeGaleria() async {
    if (_isPicking) return;
    _isPicking = true;

    try {
      await _pedirPermisos();

      final picker = ImagePicker();
      final pickedFile = await picker.pickImage(source: ImageSource.gallery);

      if (pickedFile != null) {
        final imagen = File(pickedFile.path);
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => FormularioArticuloScreen(imagen: imagen),
          ),
        );
      }
    } catch (e) {
      print("Error al seleccionar imagen de galería: $e");
    } finally {
      _isPicking = false;
    }
  }

  Future<void> _sacarFotoConCamara() async {
    if (_isPicking) return;
    _isPicking = true;

    try {
      await _pedirPermisos();

      final picker = ImagePicker();
      final pickedFile = await picker.pickImage(source: ImageSource.camera);

      if (pickedFile != null) {
        final imagen = File(pickedFile.path);
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => FormularioArticuloScreen(imagen: imagen),
          ),
        );
      }
    } catch (e) {
      print("Error al tomar foto: $e");
    } finally {
      _isPicking = false;
    }
  }

  void _mostrarOpcionesImagen(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (_) {
        return SafeArea(
          child: Wrap(
            children: [
              ListTile(
                leading: const Icon(Icons.camera_alt),
                title: const Text('Sacar foto'),
                onTap: () {
                  Navigator.of(context).pop();
                  Future.delayed(const Duration(milliseconds: 200), _sacarFotoConCamara);
                },
              ),
              ListTile(
                leading: const Icon(Icons.photo_library),
                title: const Text('Elegir de la galería'),
                onTap: () {
                  Navigator.of(context).pop();
                  Future.delayed(const Duration(milliseconds: 200), _seleccionarDesdeGaleria);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Mi Armario')),
      body: Center(
        child: _imagenSeleccionada != null
            ? Image.file(_imagenSeleccionada!)
            : const Text('Contenido del armario'),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _mostrarOpcionesImagen(context),
        child: const Icon(Icons.add),
        tooltip: 'Añadir prenda',
      ),
    );
  }
}
