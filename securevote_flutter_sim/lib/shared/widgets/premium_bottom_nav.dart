import 'package:flutter/material.dart';

import '../../core/navigation/app_router.dart';

class PremiumBottomNav extends StatelessWidget {
  const PremiumBottomNav({
    super.key,
    required this.currentIndex,
    this.alertsUnreadCount = 0,
  });

  final int currentIndex;

  /// Number of unread alerts to display as a dot badge on the Alerts tab.
  final int alertsUnreadCount;

  @override
  Widget build(BuildContext context) {
    const List<_NavItem> items = <_NavItem>[
      _NavItem(
        icon: Icons.home_rounded,
        label: 'Home',
        route: AppRouter.homeScreen,
      ),
      _NavItem(
        icon: Icons.search_rounded,
        label: 'Search',
        route: AppRouter.electionSearch,
      ),
      _NavItem(
        icon: Icons.how_to_vote_rounded,
        label: 'Votes',
        route: AppRouter.myVotes,
      ),
      _NavItem(
        icon: Icons.notifications_rounded,
        label: 'Alerts',
        route: AppRouter.alertsInbox,
        alertsIndex: 3,
      ),
      _NavItem(
        icon: Icons.person_rounded,
        label: 'Profile',
        route: AppRouter.profileHub,
      ),
    ];

    return SafeArea(
      top: false,
      minimum: const EdgeInsets.fromLTRB(14, 0, 14, 12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(24),
          color: const Color(0xCC0D0E13),
          border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
          boxShadow: const <BoxShadow>[
            BoxShadow(
              color: Color(0x7A000000),
              blurRadius: 24,
              offset: Offset(0, 12),
            ),
          ],
        ),
        child: Row(
          children: List<Widget>.generate(items.length, (int index) {
            final _NavItem item = items[index];
            final bool active = index == currentIndex;
            final bool showBadge = item.alertsIndex == index &&
                alertsUnreadCount > 0;
            return Expanded(
              child: InkWell(
                borderRadius: BorderRadius.circular(14),
                onTap: () {
                  if (active) return;
                  Navigator.pushReplacementNamed(context, item.route);
                },
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 220),
                  curve: Curves.easeOutCubic,
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(14),
                    color: active
                        ? const Color(0x26B9C3FF)
                        : Colors.transparent,
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      Stack(
                        clipBehavior: Clip.none,
                        children: <Widget>[
                          Icon(
                            item.icon,
                            size: 20,
                            color: active
                                ? const Color(0xFFB9C3FF)
                                : const Color(0xFF8E90A0),
                          ),
                          if (showBadge)
                            Positioned(
                              right: -6,
                              top: -4,
                              child: Container(
                                constraints: const BoxConstraints(
                                  minWidth: 16,
                                  minHeight: 16,
                                ),
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFFF6B6B),
                                  borderRadius: BorderRadius.circular(8),
                                  boxShadow: <BoxShadow>[
                                    BoxShadow(
                                      color: const Color(0xFFFF6B6B)
                                          .withValues(alpha: 0.4),
                                      blurRadius: 6,
                                    ),
                                  ],
                                ),
                                alignment: Alignment.center,
                                child: Text(
                                  alertsUnreadCount > 9
                                      ? '9+'
                                      : '$alertsUnreadCount',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 9,
                                    fontWeight: FontWeight.w800,
                                    height: 1,
                                  ),
                                ),
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 2),
                      Text(
                        item.label,
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                          color: active
                              ? const Color(0xFFB9C3FF)
                              : const Color(0xFF8E90A0),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          }),
        ),
      ),
    );
  }
}

class _NavItem {
  const _NavItem({
    required this.icon,
    required this.label,
    required this.route,
    this.alertsIndex,
  });

  final IconData icon;
  final String label;
  final String route;

  /// Set to the index that this item appears at; used to show the unread
  /// badge. Only the alerts item should set this.
  final int? alertsIndex;
}
