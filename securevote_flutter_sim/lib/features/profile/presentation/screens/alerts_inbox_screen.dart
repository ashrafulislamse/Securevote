import 'package:flutter/material.dart';

import '../../../../core/navigation/app_router.dart';
import '../../../../shared/widgets/premium_bottom_nav.dart';

class AlertsInboxScreen extends StatefulWidget {
  const AlertsInboxScreen({super.key});

  @override
  State<AlertsInboxScreen> createState() => _AlertsInboxScreenState();
}

class _AlertsInboxScreenState extends State<AlertsInboxScreen> {
  String _selectedFilter = 'All';
  final List<String> _filters = <String>[
    'All',
    'Elections',
    'KYC',
    'Security',
    'Results',
  ];

  // Sample notifications data
  final List<Map<String, dynamic>> _allNotifications = <Map<String, dynamic>>[
    <String, dynamic>{
      'icon': Icons.how_to_vote,
      'iconColor': const Color(0xFFB9C3FF),
      'title': 'Election Now Open',
      'message':
          'The 2024 Global Governance Vote is now active. Cast your secure ballot before Friday.',
      'time': '2m ago',
      'unread': true,
      'category': 'Elections',
      'actionLabel': 'Vote Now',
      'section': 'TODAY',
    },
    <String, dynamic>{
      'icon': Icons.verified_user,
      'iconColor': const Color(0xFF2ADEC0),
      'title': 'KYC Verified',
      'message':
          'Your identity verification has been processed successfully. Your account is now fully secure.',
      'time': '4h ago',
      'unread': true,
      'category': 'KYC',
      'section': 'TODAY',
    },
    <String, dynamic>{
      'icon': Icons.warning_amber_rounded,
      'iconColor': const Color(0xFFFF6B6B),
      'title': 'New Login Detected',
      'message':
          'A new login was detected from a Chrome browser in San Francisco, CA. Was this you?',
      'time': 'Yesterday',
      'unread': true,
      'category': 'Security',
      'actionLabel': 'Review',
      'isDanger': true,
      'section': 'YESTERDAY',
    },
    <String, dynamic>{
      'icon': Icons.bar_chart,
      'iconColor': const Color(0xFF8E90A0),
      'title': 'Community Results Live',
      'message':
          'The final tally for the Tech Hub Initiative is now available for public review.',
      'time': 'Yesterday',
      'unread': false,
      'category': 'Results',
      'section': 'YESTERDAY',
    },
    <String, dynamic>{
      'icon': Icons.campaign,
      'iconColor': const Color(0xFFD2BBFF),
      'title': 'Reminder: Vote Closes Soon',
      'message':
          'The Student Council Election closes in 6 hours. Make sure your voice is heard.',
      'time': 'Yesterday',
      'unread': false,
      'category': 'Elections',
      'section': 'YESTERDAY',
    },
  ];

  List<Map<String, dynamic>> get _filteredNotifications {
    if (_selectedFilter == 'All') {
      return _allNotifications;
    }
    return _allNotifications
        .where((n) => n['category'] == _selectedFilter)
        .toList();
  }

  int get _unreadCount =>
      _allNotifications.where((n) => n['unread'] == true).length;

  @override
  Widget build(BuildContext context) {
    final List<Map<String, dynamic>> notifications = _filteredNotifications;
    final Map<String, List<Map<String, dynamic>>> groupedNotifications =
        <String, List<Map<String, dynamic>>>{};

    for (final notification in notifications) {
      final String section = notification['section'] as String;
      groupedNotifications.putIfAbsent(section, () => <Map<String, dynamic>>[]);
      groupedNotifications[section]!.add(notification);
    }

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
                  if (_unreadCount > 0)
                    TextButton(
                      onPressed: () {
                        setState(() {
                          for (final notification in _allNotifications) {
                            notification['unread'] = false;
                          }
                        });
                      },
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
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: _filters.length,
                separatorBuilder: (_, __) => const SizedBox(width: 8),
                itemBuilder: (context, index) {
                  final String filter = _filters[index];
                  final bool isActive = _selectedFilter == filter;
                  final int count = filter == 'All'
                      ? _allNotifications.length
                      : _allNotifications
                            .where((n) => n['category'] == filter)
                            .length;

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
              ),
            ),

            // Notifications List
            Expanded(
              child: notifications.isEmpty
                  ? Center(
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
                            'No notifications',
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.white.withValues(alpha: 0.4),
                            ),
                          ),
                        ],
                      ),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: groupedNotifications.keys.length,
                      itemBuilder: (context, sectionIndex) {
                        final String section = groupedNotifications.keys
                            .elementAt(sectionIndex);
                        final List<Map<String, dynamic>> sectionNotifications =
                            groupedNotifications[section]!;

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
                            ...sectionNotifications.asMap().entries.map((
                              entry,
                            ) {
                              final int idx = entry.key;
                              final Map<String, dynamic> notification =
                                  entry.value;
                              return Padding(
                                padding: EdgeInsets.only(
                                  bottom: idx < sectionNotifications.length - 1
                                      ? 12
                                      : 0,
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
            ),
          ],
        ),
      ),
      bottomNavigationBar: const PremiumBottomNav(currentIndex: 3),
    );
  }

  Widget _buildPremiumNotificationCard({
    required Map<String, dynamic> notification,
  }) {
    final bool unread = notification['unread'] as bool;
    final bool isDanger = notification['isDanger'] as bool? ?? false;

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: unread
              ? <Color>[const Color(0xFF1E2332), const Color(0xFF181C28)]
              : <Color>[const Color(0xFF1A1D28), const Color(0xFF16191F)],
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
          onTap: () {
            setState(() {
              notification['unread'] = false;
            });
            Navigator.pushNamed(context, AppRouter.notificationDetail);
          },
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
                        (notification['iconColor'] as Color).withValues(
                          alpha: 0.2,
                        ),
                        (notification['iconColor'] as Color).withValues(
                          alpha: 0.1,
                        ),
                      ],
                    ),
                    border: Border.all(
                      color: (notification['iconColor'] as Color).withValues(
                        alpha: 0.3,
                      ),
                    ),
                  ),
                  child: Icon(
                    notification['icon'] as IconData,
                    color: notification['iconColor'] as Color,
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
                              notification['title'] as String,
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
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: const Color(0xFFB9C3FF),
                                boxShadow: <BoxShadow>[
                                  BoxShadow(
                                    color: const Color(
                                      0xFFB9C3FF,
                                    ).withValues(alpha: 0.5),
                                    blurRadius: 8,
                                    spreadRadius: 1,
                                  ),
                                ],
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Text(
                        notification['message'] as String,
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.white.withValues(alpha: 0.7),
                          height: 1.5,
                          letterSpacing: -0.2,
                        ),
                        maxLines: 3,
                        overflow: TextOverflow.ellipsis,
                      ),
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
                            notification['time'] as String,
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.white.withValues(alpha: 0.4),
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          if (notification['actionLabel'] != null) ...<Widget>[
                            const Spacer(),
                            Container(
                              height: 32,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                              ),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(10),
                                gradient: isDanger
                                    ? LinearGradient(
                                        colors: <Color>[
                                          const Color(
                                            0xFFFF6B6B,
                                          ).withValues(alpha: 0.2),
                                          const Color(
                                            0xFFFF6B6B,
                                          ).withValues(alpha: 0.1),
                                        ],
                                      )
                                    : const LinearGradient(
                                        colors: <Color>[
                                          Color(0xFFB9C3FF),
                                          Color(0xFFD2BBFF),
                                        ],
                                      ),
                              ),
                              child: Center(
                                child: Text(
                                  notification['actionLabel'] as String,
                                  style: TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w700,
                                    color: isDanger
                                        ? const Color(0xFFFF6B6B)
                                        : Colors.black,
                                  ),
                                ),
                              ),
                            ),
                          ],
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
