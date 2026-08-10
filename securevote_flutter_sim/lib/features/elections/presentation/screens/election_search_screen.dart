import 'package:flutter/material.dart';

import '../../../../core/navigation/app_router.dart';
import '../../../../shared/widgets/premium_bottom_nav.dart';

class ElectionSearchScreen extends StatefulWidget {
  const ElectionSearchScreen({super.key});

  @override
  State<ElectionSearchScreen> createState() => _ElectionSearchScreenState();
}

class _ElectionSearchScreenState extends State<ElectionSearchScreen> {
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocus = FocusNode();
  String _selectedFilter = 'All';
  String _sortBy = 'Newest';

  final List<String> _filters = <String>['All', 'Active', 'Upcoming', 'Past'];

  final List<String> _sortOptions = <String>['Newest', 'Oldest', 'Popular'];

  final List<Map<String, dynamic>> _allElections = <Map<String, dynamic>>[
    <String, dynamic>{
      'title': 'Student Council Election 2025',
      'organization': 'City University Malaysia',
      'status': 'Active',
      'meta': 'Ends in 2 days',
      'icon': Icons.school,
      'participants': 2847,
      'voted': false,
      'date': DateTime(2024, 10, 24),
    },
    <String, dynamic>{
      'title': 'Global Tech Consortium Board',
      'organization': 'General Board Members',
      'status': 'Active',
      'meta': 'Ends in 5 days',
      'icon': Icons.business,
      'participants': 12400,
      'voted': false,
      'date': DateTime(2024, 10, 20),
    },
    <String, dynamic>{
      'title': 'Community Garden Proposal',
      'organization': 'Oakwood HOA',
      'status': 'Upcoming',
      'meta': 'Starts Nov 15',
      'icon': Icons.park,
      'participants': 450,
      'voted': false,
      'date': DateTime(2024, 11, 15),
    },
    <String, dynamic>{
      'title': 'Board of Directors 2024',
      'organization': 'Tech Corp',
      'status': 'Past',
      'meta': 'Ended Oct 12',
      'icon': Icons.gavel,
      'participants': 8200,
      'voted': true,
      'date': DateTime(2024, 10, 12),
    },
    <String, dynamic>{
      'title': 'Faculty Representative Vote',
      'organization': 'School of Engineering',
      'status': 'Upcoming',
      'meta': 'Starts Nov 5',
      'icon': Icons.engineering,
      'participants': 1200,
      'voted': false,
      'date': DateTime(2024, 11, 5),
    },
  ];

  List<Map<String, dynamic>> get _filteredElections {
    List<Map<String, dynamic>> filtered = _allElections;

    // Filter by status
    if (_selectedFilter != 'All') {
      filtered = filtered.where((e) => e['status'] == _selectedFilter).toList();
    }

    // Filter by search query
    if (_searchController.text.isNotEmpty) {
      final String query = _searchController.text.toLowerCase();
      filtered = filtered.where((e) {
        final String title = (e['title'] as String).toLowerCase();
        final String org = (e['organization'] as String).toLowerCase();
        return title.contains(query) || org.contains(query);
      }).toList();
    }

    // Sort
    if (_sortBy == 'Newest') {
      filtered.sort(
        (a, b) => (b['date'] as DateTime).compareTo(a['date'] as DateTime),
      );
    } else if (_sortBy == 'Oldest') {
      filtered.sort(
        (a, b) => (a['date'] as DateTime).compareTo(b['date'] as DateTime),
      );
    } else if (_sortBy == 'Popular') {
      filtered.sort(
        (a, b) =>
            (b['participants'] as int).compareTo(a['participants'] as int),
      );
    }

    return filtered;
  }

  @override
  void dispose() {
    _searchController.dispose();
    _searchFocus.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final List<Map<String, dynamic>> elections = _filteredElections;

    return Scaffold(
      backgroundColor: const Color(0xFF0D0E13),
      body: SafeArea(
        child: Column(
          children: <Widget>[
            // Header with Search
            Container(
              padding: const EdgeInsets.fromLTRB(16, 24, 16, 16),
              decoration: BoxDecoration(
                color: const Color(0xFF0D0E13).withValues(alpha: 0.8),
              ),
              child: Row(
                children: <Widget>[
                  // Back Button (animated - only show when typing)
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 250),
                    curve: Curves.easeInOut,
                    width: _searchController.text.isNotEmpty ? 40 : 0,
                    child: _searchController.text.isNotEmpty
                        ? Container(
                            width: 40,
                            height: 48,
                            margin: const EdgeInsets.only(right: 12),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(24),
                              color: const Color(0xFF2A2C36),
                            ),
                            child: Material(
                              color: Colors.transparent,
                              child: InkWell(
                                onTap: () {
                                  setState(() {
                                    _searchController.clear();
                                    _searchFocus.unfocus();
                                  });
                                },
                                borderRadius: BorderRadius.circular(24),
                                child: const Icon(
                                  Icons.arrow_back,
                                  size: 20,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          )
                        : const SizedBox.shrink(),
                  ),

                  // Search Input Field (animated width)
                  Expanded(
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 250),
                      curve: Curves.easeInOut,
                      height: 48,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(24),
                        color: const Color(0xFF2A2C36),
                        border: Border.all(
                          color: _searchFocus.hasFocus
                              ? const Color(0xFFB9C3FF).withValues(alpha: 0.3)
                              : const Color(0xFF444654).withValues(alpha: 0.3),
                          width: 1.5,
                        ),
                      ),
                      child: Row(
                        children: <Widget>[
                          const SizedBox(width: 16),
                          Icon(
                            Icons.search,
                            color: _searchFocus.hasFocus
                                ? const Color(0xFFB9C3FF)
                                : const Color(0xFF8E90A0),
                            size: 22,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: TextField(
                              controller: _searchController,
                              focusNode: _searchFocus,
                              autofocus: false,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 15,
                                fontWeight: FontWeight.w400,
                              ),
                              decoration: const InputDecoration(
                                hintText: 'Search elections, candidates...',
                                hintStyle: TextStyle(
                                  color: Color(0xFF8E90A0),
                                  fontSize: 15,
                                  fontWeight: FontWeight.w400,
                                ),
                                border: InputBorder.none,
                                isDense: true,
                                contentPadding: EdgeInsets.symmetric(
                                  vertical: 14,
                                ),
                              ),
                              onChanged: (value) {
                                setState(() {});
                              },
                            ),
                          ),
                          // Clear button (animated - only show when typing)
                          AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            width: _searchController.text.isNotEmpty ? 40 : 0,
                            child: _searchController.text.isNotEmpty
                                ? GestureDetector(
                                    onTap: () {
                                      setState(() {
                                        _searchController.clear();
                                      });
                                    },
                                    child: Container(
                                      width: 40,
                                      height: 40,
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        color: const Color(0xFF3A3C46),
                                      ),
                                      child: Icon(
                                        Icons.close,
                                        color: Colors.white.withValues(
                                          alpha: 0.7,
                                        ),
                                        size: 18,
                                      ),
                                    ),
                                  )
                                : const SizedBox.shrink(),
                          ),
                          const SizedBox(width: 8),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Filter Chips
            Container(
              height: 52,
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: _filters.length,
                separatorBuilder: (_, __) => const SizedBox(width: 12),
                itemBuilder: (context, index) {
                  final String filter = _filters[index];
                  final bool isActive = _selectedFilter == filter;

                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        _selectedFilter = filter;
                      });
                    },
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 8,
                      ),
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
                        color: isActive ? null : const Color(0xFF1E1F25),
                        border: isActive
                            ? null
                            : Border.all(
                                color: const Color(
                                  0xFF444654,
                                ).withValues(alpha: 0.15),
                              ),
                        boxShadow: isActive
                            ? <BoxShadow>[
                                BoxShadow(
                                  color: const Color(
                                    0xFFB9C3FF,
                                  ).withValues(alpha: 0.3),
                                  blurRadius: 15,
                                  offset: const Offset(0, 0),
                                ),
                              ]
                            : null,
                      ),
                      child: Center(
                        child: Text(
                          filter,
                          style: TextStyle(
                            color: isActive
                                ? const Color(0xFF001D79)
                                : Colors.white,
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),

            // Results Count + Sort
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
              child: Row(
                children: <Widget>[
                  RichText(
                    text: TextSpan(
                      children: <TextSpan>[
                        TextSpan(
                          text: '${elections.length}',
                          style: const TextStyle(
                            fontSize: 14,
                            color: Colors.white,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        TextSpan(
                          text: ' elections found',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.white.withValues(alpha: 0.5),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Spacer(),
                  GestureDetector(
                    onTap: () {
                      showModalBottomSheet(
                        context: context,
                        backgroundColor: const Color(0xFF1A1D28),
                        shape: const RoundedRectangleBorder(
                          borderRadius: BorderRadius.vertical(
                            top: Radius.circular(20),
                          ),
                        ),
                        builder: (context) => _buildSortSheet(),
                      );
                    },
                    child: Row(
                      children: <Widget>[
                        Text(
                          'Sort by $_sortBy',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.white.withValues(alpha: 0.7),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(width: 4),
                        Icon(
                          Icons.keyboard_arrow_down,
                          size: 18,
                          color: Colors.white.withValues(alpha: 0.7),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // Elections List
            Expanded(
              child: elections.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          Icon(
                            Icons.search_off,
                            size: 64,
                            color: Colors.white.withValues(alpha: 0.2),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'No elections found',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                              color: Colors.white.withValues(alpha: 0.4),
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Try adjusting your filters',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.white.withValues(alpha: 0.3),
                            ),
                          ),
                        ],
                      ),
                    )
                  : ListView.separated(
                      padding: const EdgeInsets.all(16),
                      itemCount: elections.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 24),
                      itemBuilder: (context, index) {
                        return _buildElectionCard(elections[index]);
                      },
                    ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: const PremiumBottomNav(currentIndex: 1),
    );
  }

  Widget _buildSortSheet() {
    return Container(
      padding: const EdgeInsets.all(20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          const Text(
            'Sort by',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 16),
          ..._sortOptions.map((option) {
            final bool isSelected = _sortBy == option;
            return InkWell(
              onTap: () {
                setState(() {
                  _sortBy = option;
                });
                Navigator.pop(context);
              },
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 14),
                child: Row(
                  children: <Widget>[
                    Icon(
                      isSelected
                          ? Icons.radio_button_checked
                          : Icons.radio_button_off,
                      color: isSelected
                          ? const Color(0xFFB9C3FF)
                          : Colors.white.withValues(alpha: 0.3),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      option,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: isSelected
                            ? FontWeight.w600
                            : FontWeight.w500,
                        color: isSelected
                            ? Colors.white
                            : Colors.white.withValues(alpha: 0.7),
                      ),
                    ),
                  ],
                ),
              ),
            );
          }),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildElectionCard(Map<String, dynamic> election) {
    final Color statusColor = election['status'] == 'Active'
        ? const Color(0xFF2ADEC0)
        : election['status'] == 'Upcoming'
        ? const Color(0xFFB9C3FF)
        : const Color(0xFF8E90A0);

    final int participants = election['participants'] as int;
    final String participantsText = participants >= 1000
        ? '${(participants / 1000).toStringAsFixed(1)}k'
        : participants.toString();

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        color: const Color(0xFF1A1B21),
        border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            Navigator.pushNamed(context, AppRouter.electionDetails);
          },
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                // Top Row: Status + Icon
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    // Left: Status + Title + Org
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          // Status Badge + Meta
                          Row(
                            children: <Widget>[
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 2,
                                ),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(4),
                                  color: statusColor.withValues(alpha: 0.1),
                                ),
                                child: Text(
                                  election['status'] as String,
                                  style: TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.w800,
                                    color: statusColor,
                                    letterSpacing: 0.5,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              if (election['status'] == 'Active') ...<Widget>[
                                Container(
                                  width: 6,
                                  height: 6,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: const Color(0xFFFFB4AB),
                                    boxShadow: <BoxShadow>[
                                      BoxShadow(
                                        color: const Color(
                                          0xFFFFB4AB,
                                        ).withValues(alpha: 0.5),
                                        blurRadius: 4,
                                        spreadRadius: 1,
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(width: 6),
                              ],
                              Text(
                                election['meta'] as String,
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.white.withValues(alpha: 0.5),
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),

                          // Title
                          Text(
                            election['title'] as String,
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
                              letterSpacing: -0.5,
                              height: 1.2,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 4),

                          // Organization
                          Text(
                            election['organization'] as String,
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.white.withValues(alpha: 0.6),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 12),

                    // Right: Icon
                    Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(24),
                        color: const Color(0xFF292A2F),
                      ),
                      child: Icon(
                        election['icon'] as IconData,
                        color: statusColor,
                        size: 24,
                      ),
                    ),
                  ],
                ),

                // Bottom Row: Participants + Action
                Padding(
                  padding: const EdgeInsets.only(top: 16),
                  child: Container(
                    decoration: BoxDecoration(
                      border: Border(
                        top: BorderSide(
                          color: const Color(0xFF34343A).withValues(alpha: 0.5),
                        ),
                      ),
                    ),
                    padding: const EdgeInsets.only(top: 16),
                    child: Row(
                      children: <Widget>[
                        // Participant Avatars (placeholder circles)
                        Row(
                          children: <Widget>[
                            ...List.generate(3, (i) {
                              return Container(
                                margin: EdgeInsets.only(left: i == 0 ? 0 : 0),
                                child: Container(
                                  width: 32,
                                  height: 32,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                      color: const Color(0xFF1A1B21),
                                      width: 2,
                                    ),
                                    color: const Color(0xFF292A2F),
                                  ),
                                ),
                              );
                            }),
                            Container(
                              margin: const EdgeInsets.only(left: 0),
                              width: 32,
                              height: 32,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: const Color(0xFF1A1B21),
                                  width: 2,
                                ),
                                color: const Color(0xFF1E1F25),
                              ),
                              child: Center(
                                child: Text(
                                  '+${participantsText}',
                                  style: TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.w700,
                                    color: Colors.white.withValues(alpha: 0.6),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                        const Spacer(),

                        // View Details Button
                        Row(
                          children: <Widget>[
                            ShaderMask(
                              shaderCallback: (bounds) => const LinearGradient(
                                colors: <Color>[
                                  Color(0xFFB9C3FF),
                                  Color(0xFFD2BBFF),
                                ],
                              ).createShader(bounds),
                              child: const Text(
                                'View Details',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w700,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                            const SizedBox(width: 4),
                            const Icon(
                              Icons.arrow_forward,
                              size: 16,
                              color: Color(0xFFB9C3FF),
                            ),
                          ],
                        ),
                      ],
                    ),
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
