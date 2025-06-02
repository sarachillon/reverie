import 'package:flutter/material.dart';
import 'package:frontend/screens/utils/imagen_ajustada_widget.dart';

class MiniArmarioFijar extends StatelessWidget {
  final List<Map<String, dynamic>> prendasFijadas;
  final VoidCallback onAddPressed;
  final void Function(int index) onRemove;

  const MiniArmarioFijar({
    Key? key,
    required this.prendasFijadas,
    required this.onAddPressed,
    required this.onRemove,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 80,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: prendasFijadas.length + 1,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
        itemBuilder: (context, index) {
          if (index == 0) {
            return GestureDetector(
              onTap: onAddPressed,
              child: Container(
                width: 68,
                height: 75,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  color: Colors.grey.shade200,
                  border: Border.all(color: Colors.grey.shade300),
                ),
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    mainAxisSize: MainAxisSize.min,
                    children: const [
                      Icon(Icons.add, size: 23, color: Color(0xFFD4AF37)),
                      SizedBox(height: 4),
                      Flexible(
                        child: Text(
                          'Fijar prenda',
                          style: TextStyle(fontSize: 11, color: Color(0xFFD4AF37)),
                          textAlign: TextAlign.center,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          } else {
            final articulo = prendasFijadas[index - 1];
            final url = articulo['urlFirmada'] ?? '';
            return Stack(
              children: [
                Container(
                  width: 68,
                  height: 75,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    color: Colors.white,
                    border: Border.all(color: Colors.grey.shade300),
                  ),
                  child: url.isNotEmpty
                      ? ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child: ImagenAjustada(
                            url: url,
                            width: 68,
                            height: 75,
                          ),
                        )
                      : Center(child: Icon(Icons.image, color: Colors.grey)),
                ),
                // Botón de eliminar en la esquina superior derecha
                Positioned(
                  top: 2,
                  right: 2,
                  child: GestureDetector(
                    onTap: () => onRemove(index - 1),
                    child: Container(
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white,
                      ),
                      padding: const EdgeInsets.all(2),
                      child: const Icon(Icons.close, size: 16, color: Colors.grey),
                    ),
                  ),
                ),
              ],
            );
          }
        },
      ),
    );
  }
}
