import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:frontend/enums/enums.dart';
import 'package:frontend/services/api_manager.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MostrarOutfitScreen extends StatefulWidget {
  const MostrarOutfitScreen({super.key});

  @override
  State<MostrarOutfitScreen> createState() => _MostrarOutfitScreenState();
}

class _MostrarOutfitScreenState extends State<MostrarOutfitScreen> {
  final ApiManager _apiManager = ApiManager();
  final List<dynamic> _outfits = [];

  @override
  void initState() {
    super.initState();
    _cargarOutfits();
  }

  Future<void> _cargarOutfits() async {
    setState(() => _outfits.clear());
    try {
      final stream = _apiManager.getOutfitsPropiosStream();
      await for (final outfit in stream) {
        if (!mounted) return;
        setState(() => _outfits.add(outfit));
      }
    } catch (e) {
      print("Error al cargar outfits: $e");
    }
  }

  Future<ImageProvider<Object>> decodeBase64OrMock(String? base64) async {
    final prefs = await SharedPreferences.getInstance();
    final email = prefs.getString('email');



    try {
      if (base64 != null && base64.isNotEmpty) {
        final bytes = base64Decode(base64);
        return MemoryImage(bytes);
      }
    } catch (e) {
      debugPrint('Error decoding image: $e');
    }

    return const AssetImage('assets/mock/ropa_mock.png');
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(12),
      child: GridView.builder(
        itemCount: _outfits.length,
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          mainAxisSpacing: 16,
          crossAxisSpacing: 16,
          childAspectRatio: 0.56,
        ),
        itemBuilder: (context, index) {
          final outfit = _outfits[index];
          final futureImage = decodeBase64OrMock(outfit['imagen']);
          final ocasiones = (outfit['ocasiones'] as List)
              .map((o) => OcasionEnum.values.firstWhere((e) => e.name == o).value)
              .join(', ');

          return FutureBuilder<ImageProvider<Object>>(
            future: futureImage,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.done && snapshot.hasData) {
                return Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    color: Colors.white,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.08),
                        blurRadius: 8,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  padding: const EdgeInsets.all(10),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Center(
                        child: Text(
                          outfit['titulo'] ?? 'Sin título',
                          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        ocasiones,
                        textAlign: TextAlign.center,
                        style: const TextStyle(fontSize: 12, fontStyle: FontStyle.italic),
                      ),
                      const SizedBox(height: 8),
                      Expanded(
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child: Image(
                            image: snapshot.data!,
                            fit: BoxFit.cover,
                            width: double.infinity,
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              } else {
                return const Center(child: CircularProgressIndicator());
              }
            },
          );
        },
      ),
    );
  }
}
