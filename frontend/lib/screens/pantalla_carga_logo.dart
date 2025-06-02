import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

class PantallaCargaProcesandoImagen extends StatefulWidget {
  const PantallaCargaProcesandoImagen({super.key});

  @override
  State<PantallaCargaProcesandoImagen> createState() => _PantallaCargaProcesandoImagenState();
}

class _PantallaCargaProcesandoImagenState extends State<PantallaCargaProcesandoImagen> {
  late VideoPlayerController _controller;
  bool _videoTerminado = false;

  @override
  void initState() {
    super.initState();
    _controller = VideoPlayerController.asset('assets/video/carga_logo.mp4')
      ..initialize().then((_) {
        setState(() {});
        _controller.play();
      });

    _controller.addListener(() {
      if (_controller.value.position >= _controller.value.duration && !_videoTerminado) {
        setState(() {
          _videoTerminado = true;
        });
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        alignment: Alignment.center,
        children: [
          // Video
          if (_controller.value.isInitialized)
            Center(
              child: AspectRatio(
                aspectRatio: _controller.value.aspectRatio,
                child: VideoPlayer(_controller),
              ),
            ),
          // Cuando termina el video, muestra el loader debajo
          if (_videoTerminado)
            Positioned(
              bottom: 64,
              left: 0,
              right: 0,
              child: Column(
                children: const [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text(
                    'Procesando la imagen...',
                    style: TextStyle(fontSize: 18),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}
