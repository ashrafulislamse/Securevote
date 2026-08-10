import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../core/models/notification.dart' as notif;
import '../../../../core/navigation/app_router.dart';
import '../../../../core/providers/notifications_provider.dart';
import '../../../../shared/widgets/premium_bottom_nav.dart';

/// Inbox of all in-app notifications for the current user.
///
/// Backed by `GET /api/notifications`. Pulls to refresh, marks individual
/// items as read on tap, and exposes a "Mark all read" affordance.
class AlertsInboxScreen extends StatefulWidget {
  const AlertsInboxScreen({super.key});

  @override
  State<AlertsInboxScreen> createState() => _AlertsInboxScreenState();
}

class _AlertsInboxScreenState extends State<AlertsInboxScreen> {
  String _selectedFilter = 'All';
  final List<String> _filters = const <String>[
    'All',
    'Elections',
    'KYC',
    'Results',
    'Other',
  ];

  /// Maps a notification `type` to a UI filter bucket.
  String _categoryFor(notif.AppNotification n) {
    switch (n.type) {
      case 'kyc_approved':
      case 'kyc_rejected':
        return 'KYC';
      case 'election_opened':
      case 'election_closed':
        return 'Elections';
      case 'election_published':
      case 'vote_recorded':
        return 'Results';
      default:
        return 'Other';
    }
  }

  IconData _iconFor(notif.AppNotification n) {
    switch (n.type) {
      case 'kyc_approved':
      case 'kyc_rejected':
        return Icons.verified_user;
      case 'vote_recorded':
        return Icons.how_to_vote;
      case 'election_opened':
        return Icons.how_to_vote;
      case 'election_closed':
        return Icons.lock_clock;
      case 'election_published':
        return Icons.bar_chart;
      default:
        return Icons.notifications;
    }
  }

  Color _colorFor(notif.AppNotification n) {
    switch (n.type) {
      case 'kyc_approved':
        return const Color(0xFF2ADEC0);
      case 'kyc_rejected':
        return const Color(0xFFFF6B6B);
      case 'vote_recorded':
        return const Color(0xFFB9C3FF);
      case 'election_published':
        return const Color(0xFF8E90A0);
      case 'election_opened':
        return const Color(0xFFD2BBFF);
      case 'election_closed':
        return const Color(0xFFFFB454);
      default:
        return const Color(0xFFB9C3FF);
    }
  }

  String _relativeTime(DateTime when) {
    final diff = DateTime.now().difference(when);
    if (diff.inMinutes < 1) return 'Just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    if (diff.inDays < 2) return 'Yesterday';
    return '${diff.inDays}d ago';
  }

  String _sectionFor(DateTime when) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final that = DateTime(when.year, when.month, when.day);
    if (that == today) return 'TODAY';
    if (that == today.subtract(const Duration(days: 1))) return 'YESTERDAY';
    if (now.difference(when).inDays < 7) return 'THIS WEEK';
    return 'EARLIER';
  }

  Future<void> _handleRefresh() async {
    await context.read<NotificationsProvider>().refresh();
  }

  Future<void> _handleMarkAllRead() async {
    final provider = context.read<NotificationsProvider>();
    if (provider.notifications.every((n) => n.read)) return;
    try {
      await provider.markAllRead();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to mark all read: $e')),
      );
    }
  }

  Future<void> _handleOpen(notif.AppNotification n) async {
    if (!n.read) {
      // markRead does an optimistic local update; no need to await the
      // server call before navigating.
      unawaited(context.read<NotificationsProvider>().markRead(n.id));
    }
    if (!mounted) return;
    await Navigator.pushNamed(
      context,
      AppRouter.notificationDetail,
      arguments: n,
    );
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<NotificationsProvider>();
    final items = provider.notifications;
    final isLoading = provider.loading && items.isEmpty;
    final hasError = provider.error != null && items.isEmpty;
    final unreadCount = provider.unreadCount;

    return Scaffold(
      backgroundColor: const Color(0xFF0B0D12),
      body: SafeArea(
        child: Column(
          children: <Widget>[
            // AppBar
            Container(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 12),
              color: const Color(0xFF0B0D12),
              child: Row(
                children: <Widget>[
                  const Text(
                    'Notifications',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                      letterSpacing: -0.3,
                    ),
                  ),
                  const Spacer(),
                  if (items.any((n) => !n.read))
                    TextButton(
                      onPressed: _handleMarkAllRead,
                      style: TextButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        minimumSize: Size.zero,
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                      child: const Text(
                        'Mark all read',
                        style: TextStyle(
                          color: Color(0xFFB9C3FF),
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                ],
              ),
            ),
            // Filter Tabs
            Container(
              height: 56,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Builder(
                builder: (context) {
                  final counts = <String, int>{};
                  for (final filter in _filters) {
                    counts[filter] = filter == 'All'
                        ? items.length
                        : items.where((n) => _categoryFor(n) == filter).length;
                  }
                  return ListView.separated(
                    scrollDirection: Axis.horizontal,
                    itemCount: _filters.length,
                    separatorBuilder: (_, __) => const SizedBox(width: 8),
                    itemBuilder: (context, index) {
                      final String filter = _filters[index];
                      final bool isActive = _selectedFilter == filter;
                      final int count = counts[filter] ?? 0;
                      return GestureDetector(
                        onTap: () {
                          setState(() {
                            _selectedFilter = filter;
                          });
                        },
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(20),
                            gradient: isActive
                                ? const LinearGradient(
                                    colors: <Color>[
                                      Color(0xFFB9C3FF),
                                      Color(0xFFD2BBFF),
                                    ],
                                  )
                                : null,
                            color: isActive ? null : const Color(0xFF1A1D28),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: <Widget>[
                              Text(
                                filter,
                                style: TextStyle(
                                  color: isActive
                                      ? Colors.black
                                      : Colors.white.withValues(alpha: 0.7),
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              if (count > 0) ...<Widget>[
                                const SizedBox(width: 6),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 6,
                                    vertical: 2,
                                  ),
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(8),
                                    color: isActive
                                        ? Colors.black.withValues(alpha: 0.2)
                                        : Colors.white.withValues(alpha: 0.1),
                                  ),
                                  child: Text(
                                    count.toString(),
                                    style: TextStyle(
                                      fontSize: 11,
                                      fontWeight: FontWeight.w700,
                                      color: isActive
                                          ? Colors.black
                                          : Colors.white.withValues(alpha: 0.6),
                                    ),
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ),

            // Notifications List
            Expanded(
              child: Builder(
                builder: (context) {
                  if (isLoading) {
                    return const Center(
                      child: CircularProgressIndicator(color: Color(0xFFB9C3FF)),
                    );
                  }
                  if (hasError) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          Icon(
                            Icons.cloud_off_outlined,
                            size: 64,
                            color: Colors.white.withValues(alpha: 0.2),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'Could not load notifications',
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.white.withValues(alpha: 0.6),
                            ),
                          ),
                          const SizedBox(height: 8),
                          TextButton(
                            onPressed: _handleRefresh,
                            child: const Text('Retry'),
                          ),
                        ],
                      ),
                    );
                  }
                  final filtered = _selectedFilter == 'All'
                      ? items
                      : items
                          .where((n) => _categoryFor(n) == _selectedFilter)
                          .toList();
                  if (filtered.isEmpty) {
                    return RefreshIndicator(
                      color: const Color(0xFFB9C3FF),
                      backgroundColor: const Color(0xFF131722),
                      onRefresh: _handleRefresh,
                      child: ListView(
                        physics: const AlwaysScrollableScrollPhysics(),
                        children: <Widget>[
                          SizedBox(
                            height: MediaQuery.of(context).size.height * 0.6,
                            child: Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: <Widget>[
                                  Icon(
                                    Icons.notifications_off_outlined,
                                    size: 64,
                                    color: Colors.white.withValues(alpha: 0.2),
                                  ),
                                  const SizedBox(height: 16),
                                  Text(
                                    items.isEmpty
                                        ? 'No notifications yet'
                                        : 'Nothing in this filter',
                                    style: TextStyle(
                                      fontSize: 16,
                                      color:
                                          Colors.white.withValues(alpha: 0.4),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  }

                  // Group by section label.
                  final groups = <String, List<notif.AppNotification>>{};
                  for (final n in filtered) {
                    final section = _sectionFor(n.createdAt);
                    groups.putIfAbsent(
                      section,
                      () => <notif.AppNotification>[],
                    );
                    groups[section]!.add(n);
                  }

                  return RefreshIndicator(
                    color: const Color(0xFFB9C3FF),
                    backgroundColor: const Color(0xFF131722),
                    onRefresh: _handleRefresh,
                    child: ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: groups.keys.length,
                      itemBuilder: (context, sectionIndex) {
                        final String section =
                            groups.keys.elementAt(sectionIndex);
                        final List<notif.AppNotification> sectionItems =
                            groups[section]!;
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            if (sectionIndex > 0) const SizedBox(height: 24),
                            Padding(
                              padding: const EdgeInsets.only(
                                left: 4,
                                bottom: 12,
                              ),
                              child: Text(
                                section,
                                style: TextStyle(
                                  color: Colors.white.withValues(alpha: 0.4),
                                  fontSize: 11,
                                  fontWeight: FontWeight.w700,
                                  letterSpacing: 1,
                                ),
                              ),
                            ),
                            ...sectionItems.asMap().entries.map((entry) {
                              final int idx = entry.key;
                              final notif.AppNotification notification =
                                  entry.value;
                              return Padding(
                                padding: EdgeInsets.only(
                                  bottom: idx < sectionItems.length - 1 ? 12 : 0,
                                ),
                                child: _buildPremiumNotificationCard(
                                  notification: notification,
                                ),
                              );
                            }),
                          ],
                        );
                      },
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: PremiumBottomNav(
        currentIndex: 3,
        alertsUnreadCount: unreadCount,
      ),
    );
  }

  Widget _buildPremiumNotificationCard({
    required notif.AppNotification notification,
  }) {
    final bool unread = !notification.read;
    final Color iconColor = _colorFor(notification);

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: unread
              ? const <Color>[Color(0xFF1E2332), Color(0xFF181C28)]
              : const <Color>[Color(0xFF1A1D28), Color(0xFF16191F)],
        ),
        border: Border.all(
          color: unread
              ? const Color(0xFFB9C3FF).withValues(alpha: 0.2)
              : Colors.white.withValues(alpha: 0.05),
          width: unread ? 1.5 : 1,
        ),
        boxShadow: unread
            ? <BoxShadow>[
                BoxShadow(
                  color: const Color(0xFFB9C3FF).withValues(alpha: 0.1),
                  blurRadius: 20,
                  offset: const Offset(0, 4),
                ),
              ]
            : null,
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => _handleOpen(notification),
          borderRadius: BorderRadius.circular(20),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                // Icon with gradient background
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(14),
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: <Color>[
                        iconColor.withValues(alpha: 0.2),
                        iconColor.withValues(alpha: 0.1),
                      ],
                    ),
                    border: Border.all(
                      color: iconColor.withValues(alpha: 0.3),
                    ),
                  ),
                  child: Icon(
                    _iconFor(notification),
                    color: iconColor,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 14),
                // Content
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Row(
                        children: <Widget>[
                          Expanded(
                            child: Text(
                              notification.title,
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                                color: Colors.white,
                                letterSpacing: -0.3,
                              ),
                            ),
                          ),
                          if (unread)
                            Container(
                              width: 8,
                              height: 8,
                              decoration: const BoxDecoration(
                                shape: BoxShape.circle,
                                color: Color(0xFFB9C3FF),
                              ),
                            ),
                        ],
                      ),
                      if (notification.body.isNotEmpty) ...<Widget>[
                        const SizedBox(height: 6),
                        Text(
                          notification.body,
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.white.withValues(alpha: 0.7),
                            height: 1.5,
                            letterSpacing: -0.2,
                          ),
                          maxLines: 3,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                      const SizedBox(height: 12),
                      Row(
                        children: <Widget>[
                          Icon(
                            Icons.access_time,
                            size: 14,
                            color: Colors.white.withValues(alpha: 0.4),
                          ),
                          const SizedBox(width: 4),
                          Text(
                            _relativeTime(notification.createdAt),
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.white.withValues(alpha: 0.4),
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
