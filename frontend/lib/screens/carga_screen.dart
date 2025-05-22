import 'package:flutter/material.dart';

/// Tipo de carga: artículo u outfit
enum CargandoType { articulo, outfit }

/// Pantalla genérica de carga que muestra un indicador y un mensaje dinámico
class CargandoScreen extends StatelessWidget {
  final CargandoType type;

  const CargandoScreen({Key? key, required this.type}) : super(key: key);

  /// Mensaje según el tipo de carga
  String get _mensaje {
    switch (type) {
      case CargandoType.articulo:
        return 'Guardando artículo...';
      case CargandoType.outfit:
        return 'Generando tu outfit...';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const CircularProgressIndicator(),
            const SizedBox(height: 16),
            Text(
              _mensaje,
              style: const TextStyle(fontSize: 16),
            ),
          ],
        ),
      ),
    );
  }
}
