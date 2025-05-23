import 'package:flutter/material.dart';

class WelcomeScreen extends StatefulWidget {
  final VoidCallback onGoogleSignIn;

  const WelcomeScreen({Key? key, required this.onGoogleSignIn}) : super(key: key);

  @override
  _WelcomeScreenState createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller =
      AnimationController(vsync: this, duration: const Duration(seconds: 1))
        ..forward();
  late final Animation<double> _scaleAnimation = Tween<double>(
    begin: 0.8,
    end: 1.0,
  ).animate(
    CurvedAnimation(parent: _controller, curve: Curves.easeOutBack),
  );

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [colors.primary, colors.secondary],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: SafeArea(
          child: Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ScaleTransition(
                    scale: _scaleAnimation,
                    child: Image.asset(
                      'assets/logo_reverie.png',
                      width: 180,
                      height: 180,
                    ),
                  ),
                  const SizedBox(height: 24),
                  const Text(
                    '¡Descubre tu estilo con Reverie!',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'La moda que imaginas, a tu alcance.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 48),
                  ElevatedButton.icon(
                    onPressed: widget.onGoogleSignIn,
                    icon: Image.asset(
                      'assets/google_logo.png',
                      width: 24,
                      height: 24,
                    ),
                    label: Text(
                      'Ingresar con Google',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: colors.primary,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      foregroundColor: colors.primary, backgroundColor: Colors.white,
                      elevation: 4,
                      padding: const EdgeInsets.symmetric(
                        vertical: 12.0,
                        horizontal: 20.0,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30.0),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
