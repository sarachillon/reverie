import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class WelcomeScreen extends StatefulWidget {
  final VoidCallback onGoogleSignIn;

  const WelcomeScreen({Key? key, required this.onGoogleSignIn}) : super(key: key);

  @override
  _WelcomeScreenState createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller =
      AnimationController(vsync: this, duration: const Duration(milliseconds: 700))
        ..forward();
  late final Animation<Offset> _offsetAnimation = Tween<Offset>(
    begin: const Offset(0, 0.3),
    end: Offset.zero,
  ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic));

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Scaffold(
      body: Stack(
        children: [
          // Imagen de fondo oscurecida
          Positioned.fill(
            child: Image.asset(
              'assets/fondo_login.png',
              fit: BoxFit.cover,
            ),
          ),
          Positioned.fill(
            child: Container(
              color: Colors.black.withOpacity(0.6),
            ),
          ),
          SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: SlideTransition(
                  position: _offsetAnimation,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 38),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.8),
                        //color: Color(0xFFC9A86A).withOpacity(0.5),

                        borderRadius: BorderRadius.circular(32),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black26,
                            blurRadius: 26,
                            spreadRadius: 3,
                            offset: Offset(0, 10),
                          ),
                        ],
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Image.asset(
                            'assets/logo_reverie.png',
                            width: 150,
                            height: 150,
                          ),
                          const SizedBox(height: 18),
                          Text(
                            '¡Bienvenido a tu armario virtual!',
                            textAlign: TextAlign.center,
                            style: GoogleFonts.dancingScript(
                              fontSize: 32,
                              color: Color(0xFFD4AF37),
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 10),
                          Text(
                            'Descubre tu estilo con Reverie',
                            textAlign: TextAlign.center,
                            style: GoogleFonts.lato(
                              color: Colors.black87,
                              fontSize: 17,
                              fontWeight: FontWeight.w500,
                              letterSpacing: 0.1,
                            ),
                          ),
                          const SizedBox(height: 38),
                          ElevatedButton.icon(
                            onPressed: widget.onGoogleSignIn,
                            icon: Image.asset(
                              'assets/google_logo.png',
                              width: 26,
                              height: 26,
                            ),
                            label: const Text(
                              'Ingresar con Google',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: Color(0xFF222222),
                              ),
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.white,
                              foregroundColor: colors.primary,
                              elevation: 5,
                              padding: const EdgeInsets.symmetric(
                                vertical: 14.0,
                                horizontal: 28.0,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(22),
                              ),
                              side: BorderSide(
                                color: Colors.black,
                                width: 1.1,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
              
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
