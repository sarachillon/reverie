

abstract class ApiService {
  Future<void> registerUser({
    required String email,
    required String username,
    required int edad,
    required String genero_pref,
  });

  Future<bool> checkUserExists({required String email});
  
  Future<String> ping();

}
