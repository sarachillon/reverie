import 'api_service.dart';

class MockApiService implements ApiService {
  Map<String, dynamic>? fakeUser;

  @override
  Future<void> registerUser({
    required String email,
    required String username,
    required int edad,
    required String genero_pref,
  }) async {
    
  }

  @override
  Future<String> ping() async {
    return 'Pong!';
  }
}
