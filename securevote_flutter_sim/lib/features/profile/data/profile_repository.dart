import '../../../core/models/notification.dart';
import '../../../core/models/user.dart';
import '../../../core/network/api_client.dart';
import '../domain/profile_repository_interface.dart';
import '../../auth/data/auth_repository.dart';

/// Data access for profile operations.
///
/// Profile endpoints are currently served by the auth layer, so this
/// repository delegates to [AuthRepository]. It can grow its own endpoints
/// (e.g. photos, preferences) once the backend adds them.
class ProfileRepository implements ProfileRepositoryInterface {
  ProfileRepository({AuthRepository? authRepository, ApiClient? api})
      : _auth = authRepository ?? AuthRepository(),
        _api = api ?? ApiClient.instance;

  final AuthRepository _auth;
  final ApiClient _api;

  @override
  Future<User> getProfile() => _auth.me();

  @override
  Future<User> updateProfile({String? fullName, String? phone}) =>
      _auth.updateProfile(fullName: fullName, phone: phone);

  // ---------------------------------------------------------------------------
  // Notifications
  // ---------------------------------------------------------------------------

  /// Fetches the latest notifications for the current user (newest first).
  Future<List<AppNotification>> getNotifications() async {
    final data =
        await _api.getApi('/api/notifications') as Map<String, dynamic>;
    final list = data['notifications'] as List<dynamic>? ?? const [];
    return list
        .map((n) => AppNotification.fromJson(n as Map<String, dynamic>))
        .toList();
  }

  /// Fetches the count of unread notifications.
  Future<int> getUnreadNotificationCount() async {
    final data =
        await _api.getApi('/api/notifications/unread-count')
            as Map<String, dynamic>;
    return (data['count'] as num?)?.toInt() ?? 0;
  }

  /// Marks a single notification as read.
  Future<void> markRead(String id) async {
    await _api.postApi('/api/notifications/$id/read');
  }

  /// Marks all notifications as read. Returns the number of rows updated.
  Future<int> markAllRead() async {
    final data =
        await _api.postApi('/api/notifications/read-all')
            as Map<String, dynamic>;
    return (data['updated'] as num?)?.toInt() ?? 0;
  }
}