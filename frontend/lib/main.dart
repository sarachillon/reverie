
import 'package:frontend/screens/launcher_screen.dart';

import 'screens/auth_screen.dart'; 
import 'screens/home_screen.dart';
import 'services/api_manager.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

// Define el MaterialColor personalizado
const int _primaryValue = 0xFFC9A86A;

const MaterialColor customReverieColor = MaterialColor(
  _primaryValue,
  <int, Color>{
    50: Color(0xFFFFF3E0), 
    100: Color(0xFFFFE0B2), 
    200: Color(0xFFFFCC80), 
    300: Color(0xFFFFB74D), 
    400: Color(0xFFFFA726), 
    500: Color(_primaryValue), 
    600: Color(0xFFB97745), 
    700: Color(0xFF9C6A3F), 
    800: Color(0xFF815735), 
    900: Color(0xFF65442A), 
  },
);

/*void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load();  
  final prefs = await SharedPreferences.getInstance();
  final email = prefs.getString('email');
  Widget home;

  if (email != null) {
    final api = ApiManager.getInstance(email: email);
    final exists = await api.checkUserExists(email: email);
    home = exists ? HomeScreen(userEmail: email) : const AuthScreen();
  } else {
    home = const AuthScreen();
  }


  runApp(ReverieApp(initialRoute: home is HomeScreen ? 'home' : 'auth', userEmail: email));
}*/

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load();  
  runApp(ReverieApp());
}


class ReverieApp extends StatelessWidget {
  /*final String initialRoute;
  final String? userEmail;

  ReverieApp({required this.initialRoute, this.userEmail});
  */

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
      home: const LauncherScreen(),
    );
  }
}






