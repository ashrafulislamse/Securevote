import '../../../core/models/user.dart';
import '../domain/profile_repository_interface.dart';
import '../../auth/data/auth_repository.dart';

/// Data access for profile operations.
///
/// Profile endpoints are currently served by the auth layer, so this
/// repository delegates to [AuthRepository]. It can grow its own endpoints
/// (e.g. photos, preferences) once the backend adds them.
class ProfileRepository implements ProfileRepositoryInterface {
  ProfileRepository({AuthRepository? authRepository})
      : _auth = authRepository ?? AuthRepository();

  final AuthRepository _auth;

  @override
  Future<User> getProfile() => _auth.me();

  @override
  Future<User> updateProfile({String? fullName, String? phone}) =>
      _auth.updateProfile(fullName: fullName, phone: phone);
}