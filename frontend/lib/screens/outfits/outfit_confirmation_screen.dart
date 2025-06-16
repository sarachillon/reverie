import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:frontend/services/api_manager.dart';

class OutfitConfirmationScreen extends StatelessWidget {
  final Map<String, dynamic> outfit;
  final VoidCallback? onAceptar;
  final VoidCallback? onRechazar;

  const OutfitConfirmationScreen({
    Key? key,
    required this.outfit,
    this.onAceptar,
    this.onRechazar,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final imagenUrl = outfit['imagen'] as String?;
    final titulo = outfit['titulo'] as String? ?? '';
    final ocasionesList = outfit['ocasiones'] as List<dynamic>?;
    final ocasiones = ocasionesList != null ? ocasionesList.join(', ') : '';

    // Colors
    final borderGreen = Colors.green.shade400;
    final borderRed = Colors.red.shade300;
    final bgGreen = Colors.green.shade100;
    final bgRed = Colors.red.shade100;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: Theme.of(context).cardColor,
        elevation: 0,
        centerTitle: true,
        title: Image.asset('assets/logo_reverie_text.png', height: 32),
      ),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Instruction arrows
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 24),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: const [
                      SizedBox(width: 6),
                      Text(
                        'Rechazar',
                        style: TextStyle(
                            color: Colors.red,
                            fontSize: 16,
                            fontWeight: FontWeight.w500),
                      ),
                      SizedBox(width: 6),
                      Icon(Icons.arrow_back, color: Colors.red),

                    ],
                    
                  ),
                  Row(
                    children: const [
                      Icon(Icons.arrow_forward, color: Colors.green),
                      SizedBox(width: 6),

                      Text(
                        'Guardar',
                        style: TextStyle(
                            color: Colors.green,
                            fontSize: 16,
                            fontWeight: FontWeight.w500),
                      ),
                      SizedBox(width: 6),
                    ],
                  ),
                ],
              ),
            ),
            // Image area
            Expanded(
              child: imagenUrl == null
                  ? Center(
                      child: Text(
                        'No hay imagen disponible',
                        style: TextStyle(color: Colors.grey[600], fontSize: 16),
                      ),
                    )
                  : Container(
                      decoration: BoxDecoration(
                        border: Border(
                          left: BorderSide(color: borderGreen, width: 2),
                          right: BorderSide(color: borderRed, width: 2),
                        ),
                      ),
                      child: Dismissible(
                        key: Key(imagenUrl),
                        direction: DismissDirection.horizontal,
                        background: Container(
                          decoration: BoxDecoration(
                            border: Border(
                              left: BorderSide(color: borderGreen, width: 6),
                            ),
                            color: bgGreen,
                          ),
                          alignment: Alignment.centerLeft,
                          padding: const EdgeInsets.only(left: 16),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: const [
                              Icon(Icons.check, color: Colors.green),
                              SizedBox(width: 6),
                              Text(
                                'Guardando...',
                                style: TextStyle(
                                    color: Colors.green,
                                    fontSize: 16,
                                    fontWeight: FontWeight.w500),
                              ),
                            ],
                          ),
                        ),
                        secondaryBackground: Container(
                          decoration: BoxDecoration(
                            border: Border(
                              right: BorderSide(color: borderRed, width: 6),
                            ),
                            color: bgRed,
                          ),
                          alignment: Alignment.centerRight,
                          padding: const EdgeInsets.only(right: 16),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: const [
                              Text(
                                'Rechazando...',
                                style: TextStyle(
                                    color: Colors.red,
                                    fontSize: 16,
                                    fontWeight: FontWeight.w500),
                              ),
                              SizedBox(width: 6),
                              Icon(Icons.delete, color: Colors.red),
                            ],
                          ),
                        ),
                        onDismissed: (direction) async {
                          if (direction == DismissDirection.startToEnd) {
                            onAceptar?.call();
                          } else {    
                            onRechazar?.call();
                          }
                        },
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 24, vertical: 32),
                          child: Center(
                            child: Image.network(
                              imagenUrl,
                              fit: BoxFit.contain,
                              width: double.infinity,
                              height: double.infinity,
                              errorBuilder: (c, _, __) => const Icon(
                                Icons.broken_image,
                                size: 100,
                                color: Colors.grey,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
            ),
            // Title and occasion
            if (titulo.isNotEmpty || ocasiones.isNotEmpty)
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    if (titulo.isNotEmpty)
                      Text(
                        titulo,
                        style: const TextStyle(
                            fontSize: 20, fontWeight: FontWeight.bold),
                        textAlign: TextAlign.center,
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