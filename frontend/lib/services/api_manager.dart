import 'real_api_service.dart';
import 'mock_api_service.dart';
import 'api_service.dart';

class ApiManager {
  static ApiService? _instance;

  static ApiService getInstance({required String email}) {
    // Ya lo habíamos creado antes
    if (_instance != null) return _instance!;

    // Si es email de prueba se usa el mock, sino el real
    if (email == 'testing.reverie@gmail.com') {
      _instance = MockApiService();
    } else {
      _instance = RealApiService();
    }

    return _instance!;
  }

  // Para resetear si se cambia de usuario
  static void reset() {
    _instance = null;
  }
}

