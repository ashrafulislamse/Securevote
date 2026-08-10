import '../../../core/models/user.dart';

/// Contract for profile data access.
///
/// Kept in the `domain` layer so higher layers depend on the abstraction
/// rather than the concrete data source.
abstract class ProfileRepositoryInterface {
  /// Fetches the current user's full profile.
  Future<User> getProfile();

  /// Updates profile fields (fullName / phone).
  Future<User> updateProfile({String? fullName, String? phone});
}