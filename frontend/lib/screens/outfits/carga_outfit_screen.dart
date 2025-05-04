import 'package:flutter/material.dart';


class CargandoOutfitScreen extends StatelessWidget {
  const CargandoOutfitScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text('Generando tu outfit...'),
          ],
        ),
      ),
    );
  }
}
