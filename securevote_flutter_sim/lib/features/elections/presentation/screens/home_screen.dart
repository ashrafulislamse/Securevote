import 'dart:ui';

import 'package:flutter/material.dart';

import '../../../../core/navigation/app_router.dart';
import '../../../../core/services/storage_service.dart';
import '../../../../core/theme/app_colors.dart';
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

  int _selectedTabIndex = 0;
  late final ScrollController _scrollController;
  double _collapseT = 0;

  static const List<_ElectionItemData> _allElections = <_ElectionItemData>[
    _ElectionItemData(
      title: 'Alumni Board Selection',
      subtitle: 'Global Alumni Association',
      status: 'Active',
      dateLabel: 'Oct 12 - Oct 18, 2025',
      actionLabel: 'View Details',
      leadingIcon: Icons.calendar_today_rounded,
      trailingActionIcon: Icons.chevron_right_rounded,
      route: AppRouter.electionDetails,
      turnoutRatio: 0.62,
    ),
    _ElectionItemData(
      title: 'City Debate Referendum',
      subtitle: 'Public Affairs Council',
      status: 'Active',
      dateLabel: 'Oct 15 - Oct 20, 2025',
      actionLabel: 'View Details',
      leadingIcon: Icons.calendar_today_rounded,
      trailingActionIcon: Icons.chevron_right_rounded,
      route: AppRouter.electionDetails,
      turnoutRatio: 0.38,
    ),
    _ElectionItemData(
      title: 'Faculty Representative Vote',
      subtitle: 'School of Engineering',
      status: 'Upcoming',
      dateLabel: 'Nov 05 - Nov 07, 2025',
      actionLabel: 'Remind Me',
      leadingIcon: Icons.calendar_today_rounded,
      trailingActionIcon: Icons.notifications_none_rounded,
      route: AppRouter.electionSearch,
    ),
    _ElectionItemData(
      title: 'National Youth Committee',
      subtitle: 'Civic Alliance Board',
      status: 'Upcoming',
      dateLabel: 'Nov 12 - Nov 14, 2025',
      actionLabel: 'Remind Me',
      leadingIcon: Icons.calendar_today_rounded,
      trailingActionIcon: Icons.notifications_none_rounded,
      route: AppRouter.electionSearch,
    ),
    _ElectionItemData(
      title: 'National Tech Council 2024',
      subtitle: 'MDEC Malaysia',
      status: 'Past',
      dateLabel: 'Ended Dec 20, 2024',
      actionLabel: 'Results',
      leadingIcon: Icons.verified_rounded,
      trailingActionIcon: Icons.bar_chart_rounded,
      route: AppRouter.electionResults,
    ),
    _ElectionItemData(
      title: 'Campus Innovation Ballot',
      subtitle: 'Student Senate Office',
      status: 'Past',
      dateLabel: 'Ended Sep 02, 2024',
      actionLabel: 'Results',
      leadingIcon: Icons.verified_rounded,
      trailingActionIcon: Icons.bar_chart_rounded,
      route: AppRouter.electionResults,
    ),
  ];

  int get _activeCount =>
      _allElections.where((e) => e.status == 'Active').length;
  int get _upcomingCount =>
      _allElections.where((e) => e.status == 'Upcoming').length;

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
    final List<_ElectionItemData> visibleElections = _allElections
        .where((e) => e.status == activeTab)
        .toList();

    return ObsidianScaffold(
      bottomNavigationBar: const PremiumBottomNav(currentIndex: 0),
      child: CustomScrollView(
        controller: _scrollController,
        physics: const BouncingScrollPhysics(),
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
          SliverToBoxAdapter(child: _heroCard(context, _collapseT)),
          const SliverToBoxAdapter(child: SizedBox(height: 14)),
          SliverToBoxAdapter(child: _quickStatsRow(context)),
          const SliverToBoxAdapter(child: SizedBox(height: 14)),
          SliverToBoxAdapter(child: _tabsRow(context)),
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
          SliverToBoxAdapter(
            child: Column(
              children: <Widget>[
                for (int i = 0; i < visibleElections.length; i++) ...<Widget>[
                  _electionItem(context: context, data: visibleElections[i]),
                  if (i != visibleElections.length - 1)
                    const SizedBox(height: 14),
                ],
              ],
            ),
          ),
          if (visibleElections.isEmpty)
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
    );
  }

  // ─── TOP HEADER ────────────────────────────────────────────────────────────

  Widget _topHeader(BuildContext context, double t) {
    final double avatarSize = lerpDouble(44, 34, t)!;
    final double actionSize = lerpDouble(44, 36, t)!;
    final double iconSize = lerpDouble(22, 18, t)!;
    final double nameSize = lerpDouble(26, 19, t)!;
    final double subtitleOpacity = (1 - (t * 1.8)).clamp(0, 1);

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
                        'Good morning,',
                        style: Theme.of(context).textTheme.labelMedium,
                      ),
                    ),
                  ),
                ),
                Row(
                  children: <Widget>[
                    Text(
                      StorageService.getUser()?['fullName']?.split(' ').first ?? 'User',
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
            onTap: () {},
            size: actionSize,
            iconSize: lerpDouble(20, 17, t)!,
          ),
        ],
      ),
    );
  }

  // ─── HERO CARD ─────────────────────────────────────────────────────────────

  Widget _heroCard(BuildContext context, double t) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(32),
        color: const Color(0x0DFFFFFF), // rgba(255,255,255,0.05) - glass effect
        border: Border.all(
          color: const Color(0x14FFFFFF), // rgba(255,255,255,0.08)
        ),
        boxShadow: const <BoxShadow>[
          BoxShadow(
            color: Color(0x4D000000), // rgba(0,0,0,0.3)
            blurRadius: 32,
            offset: Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          // LIVE pill + timer
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
                        'LIVE NOW',
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
                    boxShadow: const <BoxShadow>[
                      BoxShadow(
                        color: Color(0x22000000),
                        blurRadius: 10,
                        offset: Offset(0, 3),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        'Closes in',
                        style: Theme.of(context).textTheme.labelMedium,
                      ),
                      Text(
                        '2h 14m',
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
            'Student Council\nElection 2025',
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
              Text(
                'City University Malaysia',
                style: Theme.of(
                  context,
                ).textTheme.bodyMedium?.copyWith(fontSize: 14),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Candidate stack + vote stats
          _candidateStatsRow(context),
          const SizedBox(height: 18),

          // Turnout progress
          Row(
            children: <Widget>[
              Text(
                'Turnout Progress',
                style: Theme.of(
                  context,
                ).textTheme.titleMedium?.copyWith(fontSize: 15),
              ),
              const Spacer(),
              Text(
                '47%',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          ClipRRect(
            borderRadius: BorderRadius.circular(999),
            child: SizedBox(
              height: 10,
              child: LinearProgressIndicator(
                value: 0.47,
                backgroundColor: Colors.white.withValues(alpha: 0.08),
                valueColor: const AlwaysStoppedAnimation<Color>(
                  Color(0xFFB8AFFF),
                ),
              ),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            '3,203 votes remaining to reach quorum',
            style: Theme.of(context).textTheme.labelMedium?.copyWith(
              fontSize: 11,
              color: const Color(0xFF97A1D6),
            ),
          ),
          const SizedBox(height: 18),

          // Vote Now CTA with clean gradient
          InkWell(
            borderRadius: BorderRadius.circular(16),
            onTap: () =>
                Navigator.pushNamed(context, AppRouter.electionDetails),
            child: Container(
              height: 56,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                  colors: <Color>[
                    Color(0xFFB9C3FF), // primary
                    Color(0xFFD2BBFF), // secondary
                  ],
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

  // Candidate avatars + vote/eligible counts inside hero card
  Widget _candidateStatsRow(BuildContext context) {
    const List<Map<String, dynamic>> candidates = <Map<String, dynamic>>[
      <String, dynamic>{
        'initials': 'AM',
        'colors': <Color>[Color(0xFF5A6BFF), Color(0xFF3B4DCF)],
        'textColor': Color(0xFFC0C8FF),
      },
      <String, dynamic>{
        'initials': 'SR',
        'colors': <Color>[Color(0xFFFF7B5A), Color(0xFFCF4B3B)],
        'textColor': Color(0xFFFFD0C8),
      },
      <String, dynamic>{
        'initials': 'NL',
        'colors': <Color>[Color(0xFF46F1A0), Color(0xFF1DB86A)],
        'textColor': Color(0xFFB0FAD6),
      },
    ];

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.07),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withValues(alpha: 0.12)),
      ),
      child: Row(
        children: <Widget>[
          // Avatar stack
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
              const SizedBox(height: 6),
              SizedBox(
                height: 30,
                width: candidates.length * 22.0 + 30,
                child: Stack(
                  children: <Widget>[
                    for (int i = 0; i < candidates.length; i++)
                      Positioned(
                        left: i * 22.0,
                        child: Container(
                          width: 30,
                          height: 30,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: candidates[i]['colors'] as List<Color>,
                            ),
                            border: Border.all(
                              color: const Color(0xFF090C14),
                              width: 2,
                            ),
                          ),
                          alignment: Alignment.center,
                          child: Text(
                            candidates[i]['initials'] as String,
                            style: TextStyle(
                              fontSize: 9,
                              fontWeight: FontWeight.w700,
                              color: candidates[i]['textColor'] as Color,
                            ),
                          ),
                        ),
                      ),
                    Positioned(
                      left: candidates.length * 22.0,
                      child: Container(
                        width: 30,
                        height: 30,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.white.withValues(alpha: 0.10),
                          border: Border.all(
                            color: const Color(0xFF090C14),
                            width: 2,
                          ),
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          '+2',
                          style: TextStyle(
                            fontSize: 9,
                            fontWeight: FontWeight.w700,
                            color: AppColors.textMuted,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const Spacer(),
          _heroStatItem(context, '2,847', 'Votes Cast'),
          const SizedBox(width: 18),
          _heroStatItem(context, '6,050', 'Eligible'),
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
            fontSize: 17,
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

  // ─── QUICK STATS ROW ───────────────────────────────────────────────────────

  Widget _quickStatsRow(BuildContext context) {
    return Row(
      children: <Widget>[
        _statCard(
          context,
          icon: Icons.how_to_vote_rounded,
          value: '${_allElections.length}',
          label: 'Elections',
        ),
        const SizedBox(width: 10),
        _statCard(
          context,
          icon: Icons.check_circle_rounded,
          value: '3',
          label: 'Voted',
        ),
        const SizedBox(width: 10),
        _statCard(
          context,
          icon: Icons.notifications_active_rounded,
          value: '2',
          label: 'Reminders',
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
          color: const Color(0xFF1A1B21), // surface-container-low
          border: Border.all(
            color: const Color(0x0DFFFFFF), // rgba(255,255,255,0.05)
          ),
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

  Widget _tabsRow(BuildContext context) {
    final List<int> counts = <int>[_activeCount, _upcomingCount, 0];

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
    required _ElectionItemData data,
  }) {
    final Color statusColor = data.status == 'Active'
        ? AppColors.tertiary
        : data.status == 'Upcoming'
        ? AppColors.primary
        : const Color(0xFF8E90A0);
    final bool isPast = data.status == 'Past';

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
                      data.title,
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
                      data.subtitle,
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
                  data.status,
                  style: TextStyle(
                    color: statusColor,
                    fontWeight: FontWeight.w700,
                    fontSize: 12,
                  ),
                ),
              ),
            ],
          ),

          // Mini turnout bar for Active only
          if (data.status == 'Active' && data.turnoutRatio > 0) ...<Widget>[
            const SizedBox(height: 12),
            ClipRRect(
              borderRadius: BorderRadius.circular(999),
              child: SizedBox(
                height: 3,
                child: LinearProgressIndicator(
                  value: data.turnoutRatio,
                  backgroundColor: Colors.white.withValues(alpha: 0.06),
                  valueColor: AlwaysStoppedAnimation<Color>(
                    statusColor.withValues(alpha: 0.7),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              '${(data.turnoutRatio * 100).toInt()}% turnout',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: statusColor.withValues(alpha: 0.92),
              ),
            ),
          ],

          const SizedBox(height: 12),
          Divider(color: Colors.white.withValues(alpha: 0.08), height: 1),
          const SizedBox(height: 12),

          // Date + action row
          Row(
            children: <Widget>[
              Icon(data.leadingIcon, size: 17, color: AppColors.textMuted),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  data.dateLabel,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontSize: 14,
                    color: isPast
                        ? AppColors.textMuted.withValues(alpha: 0.90)
                        : null,
                  ),
                ),
              ),
              InkWell(
                onTap: () => Navigator.pushNamed(context, data.route),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    Text(
                      data.actionLabel,
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
                      data.trailingActionIcon,
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

// ─── DATA MODEL ────────────────────────────────────────────────────────────────

class _ElectionItemData {
  const _ElectionItemData({
    required this.title,
    required this.subtitle,
    required this.status,
    required this.dateLabel,
    required this.actionLabel,
    required this.leadingIcon,
    required this.trailingActionIcon,
    required this.route,
    this.turnoutRatio = 0.0,
  });

  final String title;
  final String subtitle;
  final String status;
  final String dateLabel;
  final String actionLabel;
  final IconData leadingIcon;
  final IconData trailingActionIcon;
  final String route;
  final double turnoutRatio;
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
