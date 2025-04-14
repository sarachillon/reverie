import 'package:flutter/material.dart';
import 'screens/auth_screen.dart'; 
import 'screens/home_screen.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

// Define el MaterialColor personalizado
const int _primaryValue = 0xFFC9A86A;

const MaterialColor customReverieColor = MaterialColor(
  _primaryValue,
  <int, Color>{
    50: Color(0xFFFFF3E0), // Un tono más claro
    100: Color(0xFFFFE0B2), // Otro tono más claro
    200: Color(0xFFFFCC80), // Tono intermedio
    300: Color(0xFFFFB74D), // Tono más oscuro
    400: Color(0xFFFFA726), // Tono más oscuro
    500: Color(_primaryValue), // Tu color principal
    600: Color(0xFFB97745), // Marrón medio
    700: Color(0xFF9C6A3F), // Marrón más oscuro
    800: Color(0xFF815735), // Marrón aún más oscuro
    900: Color(0xFF65442A), // Marrón más profundo
  },
);

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: ".env");
  final prefs = await SharedPreferences.getInstance();
  final email = prefs.getString('email');

  runApp(ReverieApp(initialRoute: email != null ? 'home' : 'auth'));
}

class ReverieApp extends StatelessWidget {
  final String initialRoute;
  ReverieApp({required this.initialRoute});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Reverie',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: Color(0xFFC9A86A),
      ),
      textTheme: GoogleFonts.workSansTextTheme(
        Theme.of(context).textTheme,
      ),
      scaffoldBackgroundColor: Colors.white,
    ),
      home: initialRoute == 'home' ? HomeScreen() : AuthScreen(),
    );
  }
}




