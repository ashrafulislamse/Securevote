import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../core/navigation/app_router.dart';
import '../../../../core/services/storage_service.dart';
import '../../../../shared/widgets/premium_bottom_nav.dart';
import '../widgets/vote_detail_modal.dart';

class MyVotesScreen extends StatefulWidget {
  const MyVotesScreen({super.key});

  @override
  State<MyVotesScreen> createState() => _MyVotesScreenState();
}

class _MyVotesScreenState extends State<MyVotesScreen> {
  String _selectedFilter = 'All';
  final List<String> _filters = <String>['All', 'Completed', 'Pending'];

  List<Map<String, dynamic>> get _allVotes {
    final storedVotes = StorageService.getVotes();

    // If no votes in storage, return demo votes
    if (storedVotes.isEmpty) {
      return <Map<String, dynamic>>[
        <String, dynamic>{
          'title': 'Student Council Election 2025',
          'organization': 'City University Malaysia',
          'date': 'Oct 24, 2024',
          'status': 'Completed',
          'statusColor': const Color(0xFF2ADEC0),
          'receipt': 'REC_8829...4X11',
          'icon': Icons.how_to_vote,
          'verified': true,
        },
        <String, dynamic>{
          'title': 'Board of Directors Election',
          'organization': 'Global Tech Corp',
          'date': 'Oct 12, 2024',
          'status': 'Completed',
          'statusColor': const Color(0xFF2ADEC0),
          'receipt': 'REC_3310...9L00',
          'icon': Icons.business,
          'verified': true,
        },
        <String, dynamic>{
          'title': 'Community Garden Proposal',
          'organization': 'Oakwood HOA',
          'date': 'Nov 02, 2024',
          'status': 'Pending',
          'statusColor': const Color(0xFFD2BBFF),
          'receipt': 'REC_0125...7Z88',
          'icon': Icons.park,
          'verified': false,
        },
      ];
    }

    // Convert stored votes to display format
    return storedVotes.map((vote) {
      return <String, dynamic>{
        'title': vote['title'] ?? vote['electionTitle'] ?? 'Unknown Election',
        'organization': vote['organization'] ?? 'Unknown Organization',
        'date':
            vote['date'] ??
            DateTime.parse(
              vote['votedAt'] ?? DateTime.now().toIso8601String(),
            ).toString().split(' ')[0],
        'status': vote['status'] ?? 'Completed',
        'statusColor': const Color(0xFF2ADEC0),
        'receipt': vote['receipt'] ?? vote['receiptId'] ?? 'REC_UNKNOWN',
        'icon': Icons.how_to_vote,
        'verified': vote['verified'] ?? true,
      };
    }).toList();
  }

  List<Map<String, dynamic>> get _filteredVotes {
    if (_selectedFilter == 'All') return _allVotes;
    return _allVotes.where((v) => v['status'] == _selectedFilter).toList();
  }

  @override
  Widget build(BuildContext context) {
    final int totalVotes = _allVotes.length;
    final int completedVotes = _allVotes
        .where((v) => v['status'] == 'Completed')
        .length;
    final int pendingVotes = _allVotes
        .where((v) => v['status'] == 'Pending')
        .length;

    return Scaffold(
      backgroundColor: const Color(0xFF0B0D12),
      body: SafeArea(
        child: Column(
          children: <Widget>[
            // AppBar (consistent with profile/alerts - no back button)
            Container(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 12),
              color: const Color(0xFF0B0D12),
              child: const Row(
                children: <Widget>[
                  Text(
                    'My Votes',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                      letterSpacing: -0.3,
                    ),
                  ),
                ],
              ),
            ),

            // Content
            Expanded(
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: <Widget>[
                  // Stats Cards
                  Row(
                    children: <Widget>[
                      Expanded(
                        child: _buildStatCard(
                          icon: Icons.how_to_vote,
                          label: 'Total',
                          value: totalVotes.toString(),
                          color: const Color(0xFFB9C3FF),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildStatCard(
                          icon: Icons.check_circle,
                          label: 'Verified',
                          value: completedVotes.toString(),
                          color: const Color(0xFF2ADEC0),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildStatCard(
                          icon: Icons.pending,
                          label: 'Pending',
                          value: pendingVotes.toString(),
                          color: const Color(0xFFD2BBFF),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // Filter Tabs
                  Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      color: const Color(0xFF1A1D28),
                    ),
                    child: Row(
                      children: _filters.map((filter) {
                        final bool isActive = _selectedFilter == filter;
                        return Expanded(
                          child: GestureDetector(
                            onTap: () {
                              setState(() {
                                _selectedFilter = filter;
                              });
                            },
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 200),
                              height: 36,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(10),
                                gradient: isActive
                                    ? const LinearGradient(
                                        colors: <Color>[
                                          Color(0xFFB9C3FF),
                                          Color(0xFFD2BBFF),
                                        ],
                                      )
                                    : null,
                              ),
                              child: Center(
                                child: Text(
                                  filter,
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                    color: isActive
                                        ? Colors.black
                                        : Colors.white.withValues(alpha: 0.6),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Vote History Cards
                  if (_filteredVotes.isEmpty)
                    Center(
                      child: Padding(
                        padding: const EdgeInsets.all(40),
                        child: Column(
                          children: <Widget>[
                            Icon(
                              Icons.inbox_outlined,
                              size: 64,
                              color: Colors.white.withValues(alpha: 0.2),
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'No votes found',
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.white.withValues(alpha: 0.4),
                              ),
                            ),
                          ],
                        ),
                      ),
                    )
                  else
                    ..._filteredVotes.map((vote) {
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 16),
                        child: _buildVoteCard(vote),
                      );
                    }),
                  const SizedBox(height: 100),
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: const PremiumBottomNav(currentIndex: 2),
    );
  }

  Widget _buildStatCard({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        color: const Color(0xFF1A1D28),
      ),
      child: Column(
        children: <Widget>[
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              color: color.withValues(alpha: 0.15),
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(height: 12),
          Text(
            value,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w700,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: Colors.white.withValues(alpha: 0.5),
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildVoteCard(Map<String, dynamic> vote) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: <Color>[Color(0xFF1E2332), Color(0xFF181C28)],
        ),
        border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            showModalBottomSheet(
              context: context,
              isScrollControlled: true,
              backgroundColor: Colors.transparent,
              builder: (context) => VoteDetailModal(vote: vote),
            );
          },
          borderRadius: BorderRadius.circular(20),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Row(
                  children: <Widget>[
                    Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(14),
                        gradient: LinearGradient(
                          colors: <Color>[
                            (vote['statusColor'] as Color).withValues(
                              alpha: 0.2,
                            ),
                            (vote['statusColor'] as Color).withValues(
                              alpha: 0.1,
                            ),
                          ],
                        ),
                      ),
                      child: Icon(
                        vote['icon'] as IconData,
                        color: vote['statusColor'] as Color,
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Text(
                            vote['title'] as String,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 2),
                          Text(
                            vote['organization'] as String,
                            style: TextStyle(
                              fontSize: 13,
                              color: Colors.white.withValues(alpha: 0.6),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8),
                        color: (vote['statusColor'] as Color).withValues(
                          alpha: 0.15,
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: <Widget>[
                          if (vote['verified'] as bool)
                            Icon(
                              Icons.verified,
                              size: 14,
                              color: vote['statusColor'] as Color,
                            ),
                          if (vote['verified'] as bool)
                            const SizedBox(width: 4),
                          Text(
                            vote['status'] as String,
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              color: vote['statusColor'] as Color,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: <Widget>[
                    Icon(
                      Icons.calendar_today,
                      size: 14,
                      color: Colors.white.withValues(alpha: 0.4),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      vote['date'] as String,
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.white.withValues(alpha: 0.5),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    color: Colors.black.withValues(alpha: 0.3),
                  ),
                  child: Row(
                    children: <Widget>[
                      Icon(
                        Icons.receipt_long,
                        size: 16,
                        color: Colors.white.withValues(alpha: 0.5),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          vote['receipt'] as String,
                          style: TextStyle(
                            fontSize: 13,
                            fontFamily: 'monospace',
                            color: Colors.white.withValues(alpha: 0.7),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                      InkWell(
                        onTap: () {
                          Clipboard.setData(
                            ClipboardData(text: vote['receipt'] as String),
                          );
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Receipt ID copied'),
                              duration: Duration(seconds: 2),
                            ),
                          );
                        },
                        child: Container(
                          padding: const EdgeInsets.all(6),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(6),
                            color: Colors.white.withValues(alpha: 0.1),
                          ),
                          child: Icon(
                            Icons.copy,
                            size: 14,
                            color: Colors.white.withValues(alpha: 0.7),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  children: <Widget>[
                    Expanded(
                      child: InkWell(
                        onTap: () {
                          Navigator.pushNamed(context, AppRouter.voteReceipt);
                        },
                        borderRadius: BorderRadius.circular(10),
                        child: Container(
                          height: 40,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10),
                            color: Colors.white.withValues(alpha: 0.08),
                          ),
                          child: const Center(
                            child: Text(
                              'View Details',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: InkWell(
                        onTap: () {
                          Navigator.pushNamed(context, AppRouter.voteReceipt);
                        },
                        borderRadius: BorderRadius.circular(10),
                        child: Container(
                          height: 40,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10),
                            gradient: const LinearGradient(
                              colors: <Color>[
                                Color(0xFFB9C3FF),
                                Color(0xFFD2BBFF),
                              ],
                            ),
                          ),
                          child: const Center(
                            child: Text(
                              'Verify Receipt',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w700,
                                color: Colors.black,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
