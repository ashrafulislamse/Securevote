import 'package:flutter/material.dart';

import '../../core/navigation/app_router.dart';

class PremiumBottomNav extends StatelessWidget {
  const PremiumBottomNav({super.key, required this.currentIndex});

  final int currentIndex;

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
            final bool active = index == currentIndex;
            return Expanded(
              child: InkWell(
                borderRadius: BorderRadius.circular(14),
                onTap: () {
                  if (active) return;
                  Navigator.pushReplacementNamed(context, items[index].route);
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
                      Icon(
                        items[index].icon,
                        size: 20,
                        color: active
                            ? const Color(0xFFB9C3FF)
                            : const Color(0xFF8E90A0),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        items[index].label,
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
  });

  final IconData icon;
  final String label;
  final String route;
}
