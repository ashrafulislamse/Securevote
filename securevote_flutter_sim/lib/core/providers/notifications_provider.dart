import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:provider/provider.dart';

import '../../features/profile/data/profile_repository.dart';
import '../models/notification.dart';

/// Fetches the current user's notifications.
Future<List<Notification>> fetchNotifications() async {
  return ProfileRepository().getNotifications();
}

/// Fetches the current user's unread notification count.
Future<int> fetchUnreadNotificationCount() async {
  return ProfileRepository().getUnreadNotificationCount();
}

/// Async provider for the notifications list (latest 50, newest first).
final notificationsProvider = FutureProvider<List<Notification>>(
  create: (_) => fetchNotifications(),
  initialData: const <Notification>[],
);

/// Async provider for the unread notification count.
final unreadNotificationCountProvider = FutureProvider<int>(
  create: (_) => fetchUnreadNotificationCount(),
  initialData: 0,
);

/// Provider exposing the profile repository (used by the auto-refresh mixin).
final profileRepositoryProvider = Provider<ProfileRepository>(
  create: (_) => ProfileRepository(),
);

/// ChangeNotifier that polls the notifications API every 30 seconds.
///
/// The actual data is still owned by [notificationsProvider] (a
/// [FutureProvider]); this class just calls `ref.invalidate` on a fixed
/// cadence so the inbox / badge stay live without requiring a manual pull.
class NotificationsAutoRefresh extends ChangeNotifier {
  NotificationsAutoRefresh({this.interval = const Duration(seconds: 30)});

  final Duration interval;
  Timer? _timer;
  ProviderRef? _ref;

  /// Attaches the auto-refresh to a [Provider] context.
  ///
  /// Must be called inside a `MultiProvider` or by passing a [ProviderRef]
  /// directly (e.g. from a `ChangeNotifierProxyProvider`).
  void attach(ProviderRef ref) {
    _ref = ref;
  }

  void start() {
    _timer?.cancel();
    _timer = Timer.periodic(interval, (_) {
      _ref?.invalidate(notificationsProvider);
      _ref?.invalidate(unreadNotificationCountProvider);
    });
  }

  /// Refresh the providers once (e.g. on pull-to-refresh).
  Future<void> refresh() async {
    _ref?.invalidate(notificationsProvider);
    _ref?.invalidate(unreadNotificationCountProvider);
    // Yield to the microtask queue so the new state is observable to
    // listeners that call this from a callback.
    await Future<void>.delayed(Duration.zero);
  }

  @override
  void dispose() {
    _timer?.cancel();
    _timer = null;
    super.dispose();
  }
}

/// Provider that auto-refreshes notification providers on a fixed interval.
final notificationsAutoRefreshProvider =
    ChangeNotifierProvider<NotificationsAutoRefresh>(
  create: (_) {
    final notifier = NotificationsAutoRefresh();
    notifier.start();
    return notifier;
  },
);
