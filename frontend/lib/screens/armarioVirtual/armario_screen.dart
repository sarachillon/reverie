import 'dart:io';
import 'package:flutter/material.dart';
import 'package:frontend/screens/armarioVirtual/formulario_articulo_screen.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:device_info_plus/device_info_plus.dart';

class ArmarioScreen extends StatefulWidget {
  const ArmarioScreen({super.key});

  @override
  State<ArmarioScreen> createState() => _ArmarioScreenState();
}

class _ArmarioScreenState extends State<ArmarioScreen> {
  File? _imagenSeleccionada;
  bool _isPicking = false;

  Future<void> _pedirPermisos() async {
  Map<Permission, PermissionStatus> statuses;

  if (Platform.isAndroid) {
    final sdk = (await DeviceInfoPlugin().androidInfo).version.sdkInt;

    statuses = sdk >= 33
        ? await [Permission.camera, Permission.photos].request()
        : await [Permission.camera, Permission.storage].request();
  } else {
    statuses = await [Permission.camera, Permission.photos].request(); // iOS
  }

  if (statuses.values.any((status) => status.isPermanentlyDenied)) {
    await showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Permisos necesarios'),
        content: const Text('Concede los permisos necesarios en la configuración.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancelar')),
          TextButton(onPressed: () => openAppSettings(), child: const Text('Abrir configuración')),
        ],
      ),
    );
  }
}


  Future<void> _seleccionarDesdeGaleria() async {
    if (_isPicking) return;
    _isPicking = true;

    try {
      await _pedirPermisos();

      final picker = ImagePicker();
      final pickedFile = await picker.pickImage(source: ImageSource.gallery);

      if (pickedFile != null) {
        setState(() {
          _imagenSeleccionada = File(pickedFile.path); // Asigna la imagen seleccionada
        });

        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => FormularioArticuloScreen(imagen: _imagenSeleccionada!),
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
