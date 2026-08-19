import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../../../../core/models/election.dart';
import '../../../../core/navigation/app_router.dart';
import '../../../../core/providers/auth_provider.dart';
import '../../../../core/providers/notifications_provider.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../features/elections/data/elections_repository.dart';
import '../../../../shared/widgets/obsidian_scaffold.dart';
import '../../../../shared/widgets/premium_bottom_nav.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  static const List<String> _tabs = <String>['Active', 'Upcoming', 'Past'];
  static const double _headerMinExtent = 74;
  static const double _headerMaxExtent = 112;

  static const List<String> _months = <String>[
    'Jan',
    'Feb',
    'Mar',
    'Apr',
    'May',
    'Jun',
    'Jul',
    'Aug',
    'Sep',
    'Oct',
    'Nov',
    'Dec',
  ];

  int _selectedTabIndex = 0;
  late final ScrollController _scrollController;
  double _collapseT = 0;

  List<Election> _elections = const <Election>[];
  bool _loading = true;
  String? _error;
  bool _started = false;

  /// Tracks the last back-press so the user must press twice to exit.
  DateTime? _lastBackPress;

  /// Intercepts the system back button on the home (root) screen.
  ///
  /// The first back press shows a hint; a second press within 2s exits. This
  /// prevents the app from closing immediately on a single accidental back.
  void _handleBackToExit(BuildContext context) {
    final DateTime now = DateTime.now();
    final DateTime? last = _lastBackPress;
    if (last != null && now.difference(last) < const Duration(seconds: 2)) {
      SystemNavigator.pop();
    } else {
      _lastBackPress = now;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Press back again to exit'),
          behavior: SnackBarBehavior.floating,
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_started) {
      _started = true;
      _load();
    }
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final List<Election> elections = await context
          .read<ElectionsRepository>()
          .getElections();
      if (!mounted) {
        return;
      }
      setState(() {
        _elections = elections;
        _loading = false;
      });
    } catch (_) {
      if (!mounted) {
        return;
      }
      setState(() {
        _loading = false;
        _error = 'Could not load elections.';
      });
    }
  }

  static String _greeting() {
    final int hour = DateTime.now().hour;
    if (hour < 12) return 'Good morning,';
    if (hour < 17) return 'Good afternoon,';
    return 'Good evening,';
  }

  static bool _isActive(Election e) => e.status == 'active';
  static bool _isUpcoming(Election e) =>
      e.status == 'upcoming' || e.status == 'scheduled' || e.status == 'draft';
  static bool _isPast(Election e) =>
      e.status == 'closed' || e.status == 'published';

  static String _formatDate(DateTime d) {
    final List<String> months = _months;
    return '${months[d.month - 1]} ${d.day}, ${d.year}';
  }

  static String _formatRange(DateTime startsAt, DateTime endsAt) {
    final List<String> months = _months;
    final String sm = months[startsAt.month - 1];
    final String em = months[endsAt.month - 1];
    if (startsAt.year == endsAt.year && startsAt.month == endsAt.month) {
      return '$sm ${startsAt.day} - ${endsAt.day}, ${endsAt.year}';
    }
    return '$sm ${startsAt.day} - $em ${endsAt.day}, ${endsAt.year}';
  }

  static Election? _firstActive(List<Election> elections) {
    for (final Election e in elections) {
      if (_isActive(e)) {
        return e;
      }
    }
    return null;
  }

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController()..addListener(_handleScroll);
  }

  void _handleScroll() {
    final double extent = _headerMaxExtent - _headerMinExtent;
    final double next =
        (_scrollController.hasClients ? _scrollController.offset / extent : 0)
            .clamp(0, 1)
            .toDouble();
    if ((next - _collapseT).abs() > 0.01) {
      setState(() => _collapseT = next);
    }
  }

  @override
  void dispose() {
    _scrollController.removeListener(_handleScroll);
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final String activeTab = _tabs[_selectedTabIndex];
    final List<Election> allElections = _elections;
    final bool isLoading = _loading;
    final bool hasError = _error != null;

    final List<Election> visibleElections = _forTab(allElections, activeTab);
    final Election? activeElection = _firstActive(allElections);

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (bool didPop, Object? result) {
        if (didPop) return;
        _handleBackToExit(context);
      },
      child: ObsidianScaffold(
        bottomNavigationBar: Builder(
        builder: (context) {
          final count = context.watch<NotificationsProvider>().unreadCount;
          return PremiumBottomNav(currentIndex: 0, alertsUnreadCount: count);
        },
      ),
      child: RefreshIndicator(
        color: const Color(0xFFB9C3FF),
        onRefresh: _load,
        child: CustomScrollView(
          controller: _scrollController,
          physics: const BouncingScrollPhysics(
            parent: AlwaysScrollableScrollPhysics(),
          ),
          slivers: <Widget>[
            SliverAppBar(
              pinned: true,
              automaticallyImplyLeading: false,
              backgroundColor: Colors.transparent,
              surfaceTintColor: Colors.transparent,
              elevation: 0,
              scrolledUnderElevation: 0,
              expandedHeight: _headerMaxExtent,
              collapsedHeight: _headerMinExtent,
              toolbarHeight: _headerMinExtent,
              flexibleSpace: LayoutBuilder(
                builder: (BuildContext context, BoxConstraints constraints) {
                  final double currentHeight = constraints.biggest.height.clamp(
                    _headerMinExtent,
                    _headerMaxExtent,
                  );
                  final double t =
                      1 -
                      ((currentHeight - _headerMinExtent) /
                              (_headerMaxExtent - _headerMinExtent))
                          .clamp(0, 1);

                  return Container(
                    padding: EdgeInsets.only(
                      top: lerpDouble(10, 6, t)!,
                      bottom: lerpDouble(12, 8, t)!,
                    ),
                    color: const Color(0x1212182F),
                    child: Align(
                      alignment: Alignment.bottomCenter,
                      child: _topHeader(context, t),
                    ),
                  );
                },
              ),
            ),
            SliverToBoxAdapter(
              child: SizedBox(height: lerpDouble(14, 2, _collapseT)),
            ),
            SliverToBoxAdapter(
              child: _heroCard(context, _collapseT, activeElection),
            ),
            const SliverToBoxAdapter(child: SizedBox(height: 14)),
            SliverToBoxAdapter(child: _quickStatsRow(context, allElections)),
            const SliverToBoxAdapter(child: SizedBox(height: 14)),
            SliverToBoxAdapter(child: _tabsRow(context, allElections)),
            const SliverToBoxAdapter(child: SizedBox(height: 18)),
            SliverToBoxAdapter(
              child: Text(
                '$activeTab Elections',
                style: Theme.of(
                  context,
                ).textTheme.headlineSmall?.copyWith(fontSize: 30),
              ),
            ),
            const SliverToBoxAdapter(child: SizedBox(height: 12)),
            if (isLoading && allElections.isEmpty)
              const SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.symmetric(vertical: 32),
                  child: Center(
                    child: CircularProgressIndicator(color: Color(0xFFB9C3FF)),
                  ),
                ),
              )
            else if (hasError)
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 24),
                  child: Column(
                    children: <Widget>[
                      Icon(
                        Icons.cloud_off_rounded,
                        size: 40,
                        color: AppColors.textMuted.withValues(alpha: 0.7),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'Could not load elections.',
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                      const SizedBox(height: 12),
                      OutlinedButton(
                        onPressed: _load,
                        child: const Text('Retry'),
                      ),
                    ],
                  ),
                ),
              )
            else
              SliverToBoxAdapter(
                child: Column(
                  children: <Widget>[
                    for (
                      int i = 0;
                      i < visibleElections.length;
                      i++
                    ) ...<Widget>[
                      _electionItem(
                        context: context,
                        election: visibleElections[i],
                      ),
                      if (i != visibleElections.length - 1)
                        const SizedBox(height: 14),
                    ],
                  ],
                ),
              ),
            if (!isLoading && !hasError && visibleElections.isEmpty)
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.only(top: 12),
                  child: Text(
                    'No elections in this section.',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ),
              ),
            const SliverToBoxAdapter(child: SizedBox(height: 100)),
          ],
        ),
        ),
      ),
    );
  }

  List<Election> _forTab(List<Election> elections, String tab) {
    switch (tab) {
      case 'Active':
        return elections.where(_isActive).toList();
      case 'Upcoming':
        return elections.where(_isUpcoming).toList();
      case 'Past':
        return elections.where(_isPast).toList();
      default:
        return <Election>[];
    }
  }

  // ─── TOP HEADER ────────────────────────────────────────────────────────────

  Widget _topHeader(BuildContext context, double t) {
    final double avatarSize = lerpDouble(44, 34, t)!;
    final double actionSize = lerpDouble(44, 36, t)!;
    final double iconSize = lerpDouble(22, 18, t)!;
    final double nameSize = lerpDouble(26, 19, t)!;
    final double subtitleOpacity = (1 - (t * 1.8)).clamp(0, 1);

    final AuthProvider auth = context.watch<AuthProvider>();
    final String fullName = auth.user?.fullName ?? '';
    final String firstName = fullName.trim().isEmpty
        ? 'User'
        : fullName.trim().split(' ').first;

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: lerpDouble(12, 10, t)!,
        vertical: lerpDouble(9, 7, t)!,
      ),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(lerpDouble(22, 16, t)!),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: <Color>[
            Color.lerp(const Color(0x6B162041), const Color(0x8C162041), t)!,
            Color.lerp(const Color(0x50111831), const Color(0x73111831), t)!,
          ],
        ),
        border: Border.all(
          color: Colors.white.withValues(alpha: lerpDouble(0.08, 0.12, t)!),
        ),
      ),
      child: Row(
        children: <Widget>[
          // Avatar with online dot
          Stack(
            children: <Widget>[
              Container(
                width: avatarSize,
                height: avatarSize,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: AppColors.primary.withValues(alpha: 0.34),
                    width: 1.1,
                  ),
                  gradient: const LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: <Color>[Color(0xFF1A223A), Color(0xFF0C1226)],
                  ),
                ),
                child: Icon(
                  Icons.person_rounded,
                  size: iconSize,
                  color: const Color(0xFFDCE2FF),
                ),
              ),
              Positioned(
                bottom: 1,
                right: 1,
                child: Container(
                  width: lerpDouble(12, 10, t)!,
                  height: lerpDouble(12, 10, t)!,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: const Color(0xFF46F1E8),
                    border: Border.all(
                      color: const Color(0xFF090C14),
                      width: 1.5,
                    ),
                    boxShadow: const <BoxShadow>[
                      BoxShadow(
                        color: Color(0x6646F1E8),
                        blurRadius: 8,
                        spreadRadius: 1,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                ClipRect(
                  child: Align(
                    alignment: Alignment.centerLeft,
                    heightFactor: (1 - (t * 1.5)).clamp(0, 1),
                    child: Opacity(
                      opacity: subtitleOpacity,
                      child: Text(
                        _greeting(),
                        style: Theme.of(context).textTheme.labelMedium,
                      ),
                    ),
                  ),
                ),
                Row(
                  children: <Widget>[
                    Text(
                      firstName,
                      style: Theme.of(
                        context,
                      ).textTheme.headlineSmall?.copyWith(fontSize: nameSize),
                    ),
                    const SizedBox(width: 4),
                    Opacity(
                      opacity: lerpDouble(1, 0.42, t)!,
                      child: Icon(
                        Icons.waving_hand_rounded,
                        size: lerpDouble(15, 11, t),
                        color: const Color(0xFFFFD166),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          _squareAction(
            icon: Icons.notifications_rounded,
            onTap: () => Navigator.pushNamed(context, AppRouter.alertsInbox),
            size: actionSize,
            iconSize: lerpDouble(20, 17, t)!,
            dot: true,
          ),
          const SizedBox(width: 8),
          _squareAction(
            icon: Icons.shield_rounded,
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Security info'),
                  duration: Duration(seconds: 2),
                ),
              );
            },
            size: actionSize,
            iconSize: lerpDouble(20, 17, t)!,
          ),
        ],
      ),
    );
  }

  // ─── HERO CARD ─────────────────────────────────────────────────────────────

  Widget _heroCard(BuildContext context, double t, Election? activeElection) {
    if (activeElection == null) {
      return _noActiveCard(context);
    }

    final String statusLabel = 'Live Now';

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(32),
        color: const Color(0x0DFFFFFF), // glass effect
        border: Border.all(color: const Color(0x14FFFFFF)),
        boxShadow: const <BoxShadow>[
          BoxShadow(
            color: Color(0x4D000000),
            blurRadius: 32,
            offset: Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          // LIVE pill
          Transform.translate(
            offset: Offset(0, lerpDouble(0, -9, t)!),
            child: Row(
              children: <Widget>[
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(999),
                    border: Border.all(color: const Color(0x4A46F1E8)),
                    gradient: const LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: <Color>[Color(0x2A46F1E8), Color(0x1246F1E8)],
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      Container(
                        width: 6,
                        height: 6,
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          color: Color(0xFF46F1E8),
                        ),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        statusLabel.toUpperCase(),
                        style: Theme.of(context).textTheme.labelMedium
                            ?.copyWith(
                              color: const Color(0xFF46F1E8),
                              fontWeight: FontWeight.w700,
                              letterSpacing: 1.0,
                            ),
                      ),
                    ],
                  ),
                ),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(15),
                    color: const Color(0x5E0D1230),
                    border: Border.all(
                      color: Colors.white.withValues(alpha: 0.10),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: <Widget>[
                      Text(
                        'Ends',
                        style: Theme.of(context).textTheme.labelMedium,
                      ),
                      Text(
                        _formatDate(activeElection.endsAt),
                        style: Theme.of(context).textTheme.titleMedium
                            ?.copyWith(fontWeight: FontWeight.w700),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),

          // Title + org
          Text(
            activeElection.title,
            style: Theme.of(
              context,
            ).textTheme.displayLarge?.copyWith(fontSize: 27, height: 1.06),
          ),
          const SizedBox(height: 8),
          Row(
            children: <Widget>[
              Icon(
                Icons.location_city_rounded,
                size: 15,
                color: AppColors.textMuted,
              ),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  activeElection.organization ?? 'SecureVote Election',
                  style: Theme.of(
                    context,
                  ).textTheme.bodyMedium?.copyWith(fontSize: 14),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Candidate count + dates
          _heroFactsRow(context, activeElection),
          const SizedBox(height: 18),

          // Vote Now CTA
          InkWell(
            borderRadius: BorderRadius.circular(16),
            onTap: () => Navigator.pushNamed(
              context,
              AppRouter.electionDetails,
              arguments: activeElection,
            ),
            child: Container(
              height: 56,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                  colors: <Color>[Color(0xFFB9C3FF), Color(0xFFD2BBFF)],
                ),
                borderRadius: BorderRadius.circular(16),
                boxShadow: const <BoxShadow>[
                  BoxShadow(
                    color: Color(0x33B9C3FF),
                    blurRadius: 20,
                    offset: Offset(0, 0),
                  ),
                ],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Text(
                    'Vote Now',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontSize: 17,
                      fontWeight: FontWeight.w800,
                      color: const Color(0xFF090C14),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Container(
                    width: 26,
                    height: 26,
                    decoration: BoxDecoration(
                      color: const Color(0x12090C14),
                      borderRadius: BorderRadius.circular(999),
                    ),
                    child: const Icon(
                      Icons.arrow_forward_rounded,
                      color: Color(0xFF090C14),
                      size: 18,
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

  Widget _heroFactsRow(BuildContext context, Election election) {
    final int candidateCount = election.candidateCount ?? 0;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.07),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withValues(alpha: 0.12)),
      ),
      child: Row(
        children: <Widget>[
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                'Candidates',
                style: Theme.of(context).textTheme.labelMedium?.copyWith(
                  fontSize: 11,
                  color: AppColors.textMuted,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                '$candidateCount',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
          const Spacer(),
          _heroStatItem(
            context,
            _formatRange(election.startsAt, election.endsAt),
            'Voting Period',
          ),
        ],
      ),
    );
  }

  Widget _heroStatItem(BuildContext context, String value, String label) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: <Widget>[
        Text(
          value,
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
            fontSize: 15,
            fontWeight: FontWeight.w800,
          ),
        ),
        Text(
          label,
          style: Theme.of(context).textTheme.labelMedium?.copyWith(
            fontSize: 11,
            color: AppColors.textMuted,
          ),
        ),
      ],
    );
  }

  Widget _noActiveCard(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(32),
        color: const Color(0x0DFFFFFF),
        border: Border.all(color: const Color(0x14FFFFFF)),
        boxShadow: const <BoxShadow>[
          BoxShadow(
            color: Color(0x4D000000),
            blurRadius: 32,
            offset: Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Icon(
            Icons.event_busy_rounded,
            size: 40,
            color: AppColors.textMuted.withValues(alpha: 0.8),
          ),
          const SizedBox(height: 14),
          Text(
            'No Active Elections',
            style: Theme.of(
              context,
            ).textTheme.displayLarge?.copyWith(fontSize: 27, height: 1.06),
          ),
          const SizedBox(height: 8),
          Text(
            'There are no elections open for voting right now. Check back soon or browse all elections.',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              fontSize: 14,
              color: AppColors.textMuted,
            ),
          ),
          const SizedBox(height: 18),
          InkWell(
            borderRadius: BorderRadius.circular(16),
            onTap: () => Navigator.pushNamed(context, AppRouter.electionSearch),
            child: Container(
              height: 52,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                  colors: <Color>[Color(0xFFB9C3FF), Color(0xFFD2BBFF)],
                ),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Text(
                    'Browse Elections',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                      color: const Color(0xFF090C14),
                    ),
                  ),
                  const SizedBox(width: 8),
                  const Icon(
                    Icons.arrow_forward_rounded,
                    color: Color(0xFF090C14),
                    size: 18,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ─── QUICK STATS ROW ───────────────────────────────────────────────────────

  Widget _quickStatsRow(BuildContext context, List<Election> elections) {
    final int activeCount = elections.where(_isActive).length;
    return Row(
      children: <Widget>[
        _statCard(
          context,
          icon: Icons.how_to_vote_rounded,
          value: '${elections.length}',
          label: 'Elections',
        ),
        const SizedBox(width: 10),
        _statCard(
          context,
          icon: Icons.check_circle_rounded,
          value: '$activeCount',
          label: 'Active',
        ),
        const SizedBox(width: 10),
        _statCard(
          context,
          icon: Icons.notifications_active_rounded,
          value: '${elections.where(_isUpcoming).length}',
          label: 'Upcoming',
        ),
      ],
    );
  }

  Widget _statCard(
    BuildContext context, {
    required IconData icon,
    required String value,
    required String label,
  }) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.fromLTRB(14, 13, 14, 13),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          color: const Color(0xFF1A1B21),
          border: Border.all(color: const Color(0x0DFFFFFF)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Icon(
              icon,
              size: 18,
              color: AppColors.primary.withValues(alpha: 0.75),
            ),
            const SizedBox(height: 8),
            Text(
              value,
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontSize: 20,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: Theme.of(
                context,
              ).textTheme.labelMedium?.copyWith(fontSize: 11),
            ),
          ],
        ),
      ),
    );
  }

  // ─── TABS ROW ──────────────────────────────────────────────────────────────

  Widget _tabsRow(BuildContext context, List<Election> elections) {
    final int activeCount = elections.where(_isActive).length;
    final int upcomingCount = elections.where(_isUpcoming).length;
    final int pastCount = elections.where(_isPast).length;
    final List<int> counts = <int>[activeCount, upcomingCount, pastCount];

    return Container(
      padding: const EdgeInsets.all(6),
      decoration: BoxDecoration(
        color: const Color(0xFF191E2B),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
      ),
      child: Row(
        children: List<Widget>.generate(_tabs.length, (int index) {
          return Expanded(
            child: Padding(
              padding: EdgeInsets.only(
                right: index == _tabs.length - 1 ? 0 : 8,
              ),
              child: _TabChip(
                text: _tabs[index],
                active: _selectedTabIndex == index,
                count: counts[index],
                onTap: () => setState(() => _selectedTabIndex = index),
              ),
            ),
          );
        }),
      ),
    );
  }

  // ─── ELECTION ITEM ─────────────────────────────────────────────────────────

  Widget _electionItem({
    required BuildContext context,
    required Election election,
  }) {
    final bool isPast = _isPast(election);
    final Color statusColor = isPast
        ? const Color(0xFF8E90A0)
        : _isUpcoming(election)
        ? AppColors.primary
        : AppColors.tertiary;
    final String statusLabel = isPast
        ? 'Past'
        : _isUpcoming(election)
        ? 'Upcoming'
        : 'Active';
    final String actionLabel = isPast ? 'Results' : 'View Details';
    final IconData leadingIcon = isPast
        ? Icons.verified_rounded
        : Icons.calendar_today_rounded;
    final IconData trailingActionIcon = isPast
        ? Icons.bar_chart_rounded
        : Icons.chevron_right_rounded;
    final String dateLabel = isPast
        ? 'Ended ${_formatDate(election.endsAt)}'
        : _formatRange(election.startsAt, election.endsAt);
    final String route = isPast
        ? AppRouter.electionResults
        : AppRouter.electionDetails;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(22),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: isPast
              ? const <Color>[Color(0xFF111622), Color(0xFF0E1422)]
              : const <Color>[Color(0xFF141B2C), Color(0xFF101728)],
        ),
        border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          // Title + status badge
          Row(
            children: <Widget>[
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      election.title,
                      style: Theme.of(context).textTheme.headlineSmall
                          ?.copyWith(
                            fontSize: 17,
                            color: isPast
                                ? AppColors.textMuted.withValues(alpha: 0.75)
                                : null,
                          ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      election.organization ?? 'SecureVote Election',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        fontSize: 12.5,
                        color: isPast
                            ? AppColors.textMuted.withValues(alpha: 0.78)
                            : null,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 7,
                ),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  color: statusColor.withValues(alpha: 0.14),
                  border: Border.all(
                    color: statusColor.withValues(alpha: 0.35),
                  ),
                ),
                child: Text(
                  statusLabel,
                  style: TextStyle(
                    color: statusColor,
                    fontWeight: FontWeight.w700,
                    fontSize: 12,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),
          Divider(color: Colors.white.withValues(alpha: 0.08), height: 1),
          const SizedBox(height: 12),

          // Date + action row
          Row(
            children: <Widget>[
              Icon(leadingIcon, size: 17, color: AppColors.textMuted),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  dateLabel,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontSize: 14,
                    color: isPast
                        ? AppColors.textMuted.withValues(alpha: 0.90)
                        : null,
                  ),
                ),
              ),
              InkWell(
                onTap: () =>
                    Navigator.pushNamed(context, route, arguments: election),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    Text(
                      actionLabel,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontSize: 14,
                        color: isPast
                            ? AppColors.textMuted.withValues(alpha: 0.90)
                            : AppColors.primary,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Icon(
                      trailingActionIcon,
                      size: 17,
                      color: isPast
                          ? AppColors.textMuted.withValues(alpha: 0.90)
                          : AppColors.primary,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ─── SQUARE ACTION BUTTON ──────────────────────────────────────────────────

  Widget _squareAction({
    required IconData icon,
    required VoidCallback onTap,
    required double size,
    required double iconSize,
    bool dot = false,
  }) {
    return InkWell(
      borderRadius: BorderRadius.circular(14),
      onTap: onTap,
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(14),
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: <Color>[Color(0xFF1A2240), Color(0xFF11182E)],
          ),
          border: Border.all(color: Colors.white.withValues(alpha: 0.06)),
        ),
        child: Stack(
          children: <Widget>[
            Center(
              child: Icon(icon, size: iconSize, color: const Color(0xFFDCE2FF)),
            ),
            if (dot)
              Positioned(
                top: size * 0.22,
                right: size * 0.22,
                child: DecoratedBox(
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    color: Color(0xFFFFB6C8),
                  ),
                  child: SizedBox(width: size * 0.18, height: size * 0.18),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

// ─── TAB CHIP ──────────────────────────────────────────────────────────────────

class _TabChip extends StatelessWidget {
  const _TabChip({
    required this.text,
    required this.onTap,
    this.active = false,
    this.count = 0,
  });

  final String text;
  final bool active;
  final VoidCallback onTap;
  final int count;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(14),
      onTap: onTap,
      child: Container(
        height: 46,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(14),
          gradient: active
              ? const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: <Color>[Color(0xFF2B315A), Color(0xFF20264B)],
                )
              : null,
          color: active ? null : Colors.transparent,
        ),
        alignment: Alignment.center,
        child: FittedBox(
          fit: BoxFit.scaleDown,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Text(
                text,
                style: TextStyle(
                  color: active
                      ? const Color(0xFFD7DDFF)
                      : const Color(0xFFAFB4C8),
                  fontWeight: active ? FontWeight.w700 : FontWeight.w600,
                  fontSize: 15,
                ),
              ),
              if (count > 0) ...<Widget>[
                const SizedBox(width: 6),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 7,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: active
                        ? const Color(0xFF4B5ADF).withValues(alpha: 0.42)
                        : Colors.white.withValues(alpha: 0.14),
                    borderRadius: BorderRadius.circular(999),
                    border: Border.all(
                      color: active
                          ? const Color(0x996E7BFF)
                          : Colors.white.withValues(alpha: 0.22),
                    ),
                  ),
                  child: Text(
                    '[$count]',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: active
                          ? const Color(0xFFD9D4FF)
                          : const Color(0xFF9DA5D7),
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
