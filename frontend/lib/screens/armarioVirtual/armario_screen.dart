import 'dart:io';
import 'package:flutter/material.dart';
import 'package:frontend/screens/armarioVirtual/formulario_articulo_screen.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:frontend/screens/armarioVirtual/articulo_propio_widget.dart';
import 'package:frontend/services/api_manager.dart';

class ArmarioScreen extends StatefulWidget {
  const ArmarioScreen({super.key});

  @override
  State<ArmarioScreen> createState() => _ArmarioScreenState();
}

class _ArmarioScreenState extends State<ArmarioScreen> {
  final ApiManager _apiManager = ApiManager();
  File? _imagenSeleccionada;
  bool _isPicking = false;
  List<dynamic> _articulos = []; // Lista para almacenar los artículos
  Map<String, dynamic> filtros = {}; // Para almacenar los filtros

  @override
  void initState() {
    super.initState();
    _cargarArticulosPropios(); // Cargar los artículos al inicializar la pantalla
  }


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


  Future<void> _cargarArticulosPropios() async {
    try {
      final stream = _apiManager.getArticulosPropiosStream(filtros: filtros);
      stream.listen((articulo) {
        setState(() {
          _articulos.add(articulo);
        });
      });
    } catch (e) {
      print("Error al cargar artículos propios: $e");
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
          _imagenSeleccionada = File(pickedFile.path);
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
      body: _articulos.isEmpty
          ? const Center(child: Text('Aún no hay artículos en tu armario.'))
          : GridView.builder(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 10,
                mainAxisSpacing: 10,
                childAspectRatio: 0.75,
              ),
              padding: const EdgeInsets.all(10),
              itemCount: _articulos.length,
              itemBuilder: (context, index) {
                try {
                  final articulo = _articulos[index];
                  if (articulo is! Map<String, dynamic> || !articulo.containsKey('nombre')) {
                    return const Card(
                      child: Center(child: Text('Artículo inválido')),
                    );
                  }
                  return ArticuloPropioWidget(
                    nombre: articulo['nombre'],
                    articulo: articulo,
                    onTap: () {
                      print('Artículo seleccionado: ${articulo['nombre']}');
                    },
                  );
                } catch (e) {
                  print("Error al construir el artículo $index: $e");
                  return const Card(
                    child: Center(child: Text('Error al cargar el artículo')),
                  );
                }
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _mostrarOpcionesImagen(context),
        child: const Icon(Icons.add),
        tooltip: 'Añadir prenda',
      ),
      bottomNavigationBar: BottomAppBar(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            IconButton(
              icon: const Icon(Icons.list),
              onPressed: _cargarArticulosPropios,
            ),
            IconButton(
              icon: const Icon(Icons.filter_list),
              onPressed: () {
                // Lógica para abrir la pantalla de filtros
              },
            ),
          ],
        ),
      ),
    );
  }
}
