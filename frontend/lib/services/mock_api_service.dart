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
  Future<bool> checkUserExists({required String email}) async {
    if(email == "testing.reverie@gmail.com") {
      return true;
    } else {
      return false;
    }
  }

  @override
  Future<String> ping() async {
    return 'Pong!';
  }
}
