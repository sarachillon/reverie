import 'package:flutter/material.dart';




class ImagenArticulo extends StatefulWidget {
  final String url;

  const ImagenArticulo({super.key, required this.url});

  @override
  State<ImagenArticulo> createState() => _ImagenArticuloState();
}

class _ImagenArticuloState extends State<ImagenArticulo> {
  double? ratio;

  @override
  void initState() {
    super.initState();
    _calcularProporcion();
  }

  void _calcularProporcion() {
    final image = Image.network(widget.url).image;
    image.resolve(const ImageConfiguration()).addListener(
      ImageStreamListener((info, _) {
        final ancho = info.image.width.toDouble();
        final alto = info.image.height.toDouble();
        setState(() {
          ratio = ancho / alto;
        });
      }),
    );
  }


  @override
  Widget build(BuildContext context) {
    return Container(
      width: 110,
      height: 110,
      padding: const EdgeInsets.all(3),
      decoration: BoxDecoration(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Image.network(
        widget.url,
        fit: BoxFit.contain,
        loadingBuilder: (context, child, loadingProgress) {
          if (loadingProgress == null) return child;
          return const Center(
            child: SizedBox(
              width: 32,
              height: 32,
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
          );
        },
        errorBuilder: (context, error, stackTrace) {
          return const Icon(Icons.broken_image, size: 40, color: Colors.grey);
        },
      ),
    );
  }



}
