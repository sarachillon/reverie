import 'dart:io';
import 'package:flutter/material.dart';
import 'package:frontend/screens/armarioVirtual/formulario_articulo_propio_existente.dart';
import 'package:frontend/screens/utils/imagen_ajustada_widget.dart';
import 'package:frontend/services/api_manager.dart';
import 'package:google_fonts/google_fonts.dart';
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

  void showLoader(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const Center(child: CircularProgressIndicator()),
    );
  }

  void hideLoader(BuildContext context) {
    if (Navigator.of(context).canPop()) Navigator.of(context).pop();
  }


  Future<void> _seleccionarImagen(ImageSource source) async {
    if (_isPicking) return;
    _isPicking = true;

    showLoader(context);

    try {
      await _pedirPermisos();
      final picker = ImagePicker();
      final pickedFile = await picker.pickImage(source: source);

      hideLoader(context);

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
      hideLoader(context);
      print("Error al seleccionar imagen: $e");
    } finally {
      _isPicking = false;
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(leading: IconButton(
        icon: const Icon(Icons.arrow_back, color: Color(0xFFD4AF37)),
        onPressed: () => Navigator.pop(context),
      ),
      title: Text(
      'Subir prenda',
      style: GoogleFonts.dancingScript(
        fontSize: 30,
        color: Color(0xFFD4AF37),
        fontWeight: FontWeight.w600,
      ),
      ),
    ),
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
            const SizedBox(height: 10),
            ElevatedButton.icon(
              icon: const Icon(Icons.library_books),
              label: const Text("Añadir de la base de datos"),
              onPressed: () async {
                showLoader(context);
                final articuloSeleccionado = await showModalBottomSheet<Map<String, dynamic>>(
                  context: context,
                  isScrollControlled: true,
                  backgroundColor: Colors.white,
                  shape: const RoundedRectangleBorder(
                    borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                  ),
                  builder: (_) => ArticuloBDSearchWidget(),
                );
                hideLoader(context);

                if (articuloSeleccionado != null && mounted) {
                  showLoader(context);
                  final result = await Navigator.push<bool?>(
                    context,
                    MaterialPageRoute(
                      builder: (_) => FormularioArticuloDesdeExistenteScreen(
                        articulo: articuloSeleccionado,
                      ),
                      fullscreenDialog: true,
                    ),
                  );
                  hideLoader(context);

                  if (result == true && mounted) {
                    Navigator.pop(context, true);
                  }
                }
},

            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}




class ArticuloBDSearchWidget extends StatefulWidget {
  const ArticuloBDSearchWidget({Key? key}) : super(key: key);

  @override
  State<ArticuloBDSearchWidget> createState() => _ArticuloBDSearchWidgetState();
}

class _ArticuloBDSearchWidgetState extends State<ArticuloBDSearchWidget> {
  List<Map<String, dynamic>> _articulos = [];
  List<Map<String, dynamic>> _filtered = [];
  bool _loading = true;
  String _query = '';

  @override
  void initState() {
    super.initState();
    _loadArticulos();
  }

  Future<void> _loadArticulos() async {
    final articulos = await ApiManager().getTodosLosArticulosDeBD();
    if (!mounted) return;
    setState(() {
      _articulos = List<Map<String, dynamic>>.from(articulos);
      _filtered = _articulos;
      _loading = false;
    });
  }

  void _search(String query) {
    setState(() {
      _query = query;
      _filtered = _articulos.where((a) {
        final nombre = (a['nombre'] ?? '').toLowerCase();
        return nombre.contains(query.toLowerCase());
      }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    final mq = MediaQuery.of(context);
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: SizedBox(
          height: mq.size.height * 0.75,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('Añadir artículo de la base de datos', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
              const SizedBox(height: 12),
              TextField(
                decoration: const InputDecoration(
                  prefixIcon: Icon(Icons.search),
                  hintText: 'Buscar artículo...',
                  border: OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(12))),
                  contentPadding: EdgeInsets.symmetric(horizontal: 8, vertical: 0),
                ),
                onChanged: _search,
              ),
              const SizedBox(height: 12),
              Expanded(
                child: _loading
                    ? const Center(child: CircularProgressIndicator())
                    : _filtered.isEmpty
                        ? const Center(child: Text('No hay resultados'))
                        : ListView.separated(
                            itemCount: _filtered.length,
                            separatorBuilder: (_, __) => const Divider(height: 1),
                            itemBuilder: (context, i) {
                              final articulo = _filtered[i];
                              final url = articulo['urlFirmada'] ?? '';
                              return ListTile(
                                leading: url.isNotEmpty
                                    ? ClipRRect(
                                        borderRadius: BorderRadius.circular(8),
                                        child: Container(
                                          color: Colors.grey.shade200,
                                          width: 52,
                                          height: 52,
                                          child: ImagenAjustada(
                                            url: url,
                                            width: 52,
                                            height: 52,
                                          ),
                                        ),
                                      )
                                    : const SizedBox(
                                        width: 52,
                                        height: 52,
                                        child: Center(child: Icon(Icons.image)),
                                      ),
                                title: Text(articulo['nombre'] ?? 'Sin nombre'),
                                subtitle: Text(articulo['categoria'] ?? ''),
                                onTap: () => Navigator.pop(context, articulo),
                              );    
                            },
                          ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}