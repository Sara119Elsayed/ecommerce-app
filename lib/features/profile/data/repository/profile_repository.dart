import '../model/profile_model.dart';
import '../web_service/profile_service.dart';

abstract interface class ProfileRepository {
  Future<Profile> getProfile(int userId);
  void close();
}

class DummyJsonProfileRepository implements ProfileRepository {
  DummyJsonProfileRepository(this._service);

  final ProfileService _service;

  @override
  Future<Profile> getProfile(int userId) async {
    final data = await _service.getProfile(userId);
    return Profile.fromJson(data);
  }

  @override
  void close() => _service.close();
}