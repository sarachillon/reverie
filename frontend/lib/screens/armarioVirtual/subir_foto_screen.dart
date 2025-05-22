import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:frontend/screens/armarioVirtual/formulario_articulo_screen.dart';

class SubirFotoScreen extends StatefulWidget {
  const SubirFotoScreen({super.key});

  @override
  State<SubirFotoScreen> createState() => _SubirFotoScreenState();
}

class _SubirFotoScreenState extends State<SubirFotoScreen> {
  bool _isPicking = false;
  final PageController _pageController = PageController();
  int _paginaActual = 0;

  final List<String> ejemplos = [
    'assets/articulos/top_negro.png',
    'assets/articulos/falda_cuadros.png',
    'assets/articulos/vaqueros_pull.png',
    'assets/articulos/botas_altas.png',
    'assets/articulos/camiseta_larga.png',
  ];

  Future<void> _pedirPermisos() async {
    Map<Permission, PermissionStatus> statuses;

    if (Platform.isAndroid) {
      final sdk = (await DeviceInfoPlugin().androidInfo).version.sdkInt;
      statuses = sdk >= 33
          ? await [Permission.camera, Permission.photos].request()
          : await [Permission.camera, Permission.storage].request();
    } else {
      statuses = await [Permission.camera, Permission.photos].request();
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

  Future<void> _seleccionarImagen(ImageSource source) async {
    if (_isPicking) return;
    _isPicking = true;

    try {
      await _pedirPermisos();
      final picker = ImagePicker();
      final pickedFile = await picker.pickImage(source: source);
      

      if (pickedFile != null) {
        final originalFile = File(pickedFile.path);

        final result = await Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => FormularioArticuloScreen(imagenOriginal: originalFile),
          ),
        );

        if (result == true) {
          Navigator.pop(context, true);
        }
      }
    } catch (e) {
      print("Error al seleccionar imagen: $e");
    } finally {
      _isPicking = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Subir prenda")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Text(
              "Sube una foto de tu prenda sobre una superficie plana. ¡Así tus outfits se verán mejor! Aquí tienes algunos ejemplos:",
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 400,
              child: PageView.builder(
                controller: _pageController,
                itemCount: ejemplos.length,
                onPageChanged: (index) => setState(() => _paginaActual = index),
                itemBuilder: (_, index) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12.0),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(16),
                      child: Image.asset(
                        ejemplos[index],
                        fit: BoxFit.cover,
                      ),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(ejemplos.length, (index) {
                return AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  width: _paginaActual == index ? 12 : 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: _paginaActual == index ? const Color(0xFF9C6A3F) : Colors.grey[400],
                    borderRadius: BorderRadius.circular(4),
                  ),
                );
              }),
            ),
            const Spacer(),
            ElevatedButton.icon(
              icon: const Icon(Icons.camera_alt),
              label: const Text("Sacar foto"),
              onPressed: () => _seleccionarImagen(ImageSource.camera),
            ),
            const SizedBox(height: 10),
            ElevatedButton.icon(
              icon: const Icon(Icons.photo_library),
              label: const Text("Elegir de la galería"),
              onPressed: () => _seleccionarImagen(ImageSource.gallery),
            ),
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }
}
