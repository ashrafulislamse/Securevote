import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:provider/provider.dart';

import '../../features/profile/data/profile_repository.dart';
import '../models/notification.dart';

/// ChangeNotifier that owns the current user's notifications list.
///
/// Acts as the single source of truth for the inbox / detail screens and the
/// unread badge shown in the bottom navigation. The actual HTTP work is
/// delegated to [ProfileRepository].
class NotificationsProvider extends ChangeNotifier {
  NotificationsProvider({ProfileRepository? repository})
    : _repository = repository ?? ProfileRepository() {
    _start();
  }

  final ProfileRepository _repository;
  Timer? _timer;

  List<AppNotification> _notifications = const <AppNotification>[];
  bool _loading = false;
  String? _error;
  int _unreadCount = 0;

  /// Polling cadence for the auto-refresh.
  final Duration interval = const Duration(seconds: 30);

  /// The latest notifications, newest first. Empty until the first fetch
  /// completes (or while [loading] is true on the very first load).
  List<AppNotification> get notifications => _notifications;

  /// Whether a fetch is currently in flight.
  bool get loading => _loading;

  /// The last error message from a failed fetch, or null when there is none.
  String? get error => _error;

  /// Number of notifications where `read == false`.
  int get unreadCount => _unreadCount;

  void _start() {
    // Kick off the first fetch and start the polling timer.
    refresh();
    _timer = Timer.periodic(interval, (_) => refresh());
  }

  /// Re-fetches the notifications list from the server.
  Future<void> refresh() async {
    _setLoading(true);
    try {
      final list = await _repository.getNotifications();
      _notifications = list;
      _unreadCount = list.where((n) => !n.read).length;
      _error = null;
    } catch (e) {
      _error = e.toString();
    } finally {
      _setLoading(false);
    }
  }

  /// Marks a single notification as read and updates local state.
  Future<void> markRead(String id) async {
    final idx = _notifications.indexWhere((n) => n.id == id);
    if (idx == -1) return;
    final original = _notifications[idx];
    if (original.read) return;

    // Optimistic update so the badge updates immediately.
    final updated = original.copyWith(read: true);
    final newList = List<AppNotification>.from(_notifications);
    newList[idx] = updated;
    _notifications = newList;
    _unreadCount = _unreadCount > 0 ? _unreadCount - 1 : 0;
    notifyListeners();

    try {
      await _repository.markRead(id);
    } catch (_) {
      // Best-effort: keep the optimistic update even if the call fails.
    }
  }

  /// Marks every notification as read.
  Future<void> markAllRead() async {
    if (_notifications.every((n) => n.read)) return;
    final newList = _notifications
        .map((n) => n.read ? n : n.copyWith(read: true))
        .toList(growable: false);
    _notifications = newList;
    _unreadCount = 0;
    notifyListeners();

    try {
      await _repository.markAllRead();
    } catch (_) {
      // Best-effort.
    }
  }

  /// Removes a notification from the local list and best-effort deletes it
  /// on the server.
  ///
  /// The local list and unread badge are updated optimistically; a failed
  /// server delete is ignored since the local state is already correct.
  Future<void> removeLocal(String id) async {
    final idx = _notifications.indexWhere((n) => n.id == id);
    if (idx == -1) return;
    final wasUnread = !_notifications[idx].read;
    final newList = List<AppNotification>.from(_notifications)..removeAt(idx);
    _notifications = newList;
    if (wasUnread && _unreadCount > 0) {
      _unreadCount -= 1;
    }
    notifyListeners();

    // Best-effort server delete.
    try {
      await _repository.deleteNotification(id);
    } catch (_) {
      // Ignore — the local state is already updated.
    }
  }

  void _setLoading(bool value) {
    if (_loading == value) return;
    _loading = value;
    notifyListeners();
  }

  @override
  void dispose() {
    _timer?.cancel();
    _timer = null;
    super.dispose();
  }
}

/// Provider definition for the [NotificationsProvider] singleton.
///
/// Register it at the app root with `ChangeNotifierProvider`:
/// ```dart
/// ChangeNotifierProvider<NotificationsProvider>(
///   create: (_) => NotificationsProvider(),
/// );
/// ```
typedef NotificationsProviderFactory =
    ChangeNotifierProvider<NotificationsProvider>;
