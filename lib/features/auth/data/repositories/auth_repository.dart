import '../model/auth_model.dart';
import '../webservices/auth_service.dart';

abstract interface class AuthRepository {
  Future<Auth> login({
    required String email,
    required String password,
  });
  void close();
}

class DummyJsonAuthRepository implements AuthRepository {
  DummyJsonAuthRepository(this._service);

  final AuthService _service;

  @override
  Future<Auth> login({
    required String email,
    required String password,
  }) async {
    final data = await _service.login(
      username: email.trim(),
      password: password,
    );
    return Auth.fromJson(data, password: password);
  }

  @override
  void close() => _service.close();
}