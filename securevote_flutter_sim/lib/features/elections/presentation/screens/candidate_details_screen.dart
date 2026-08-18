import 'package:flutter/material.dart';

import '../../../../core/models/candidate.dart';
import '../../../../core/models/election.dart';
import '../../../../core/navigation/app_router.dart';

class CandidateDetailsScreen extends StatefulWidget {
  const CandidateDetailsScreen({super.key});

  @override
  State<CandidateDetailsScreen> createState() => _CandidateDetailsScreenState();
}

class _CandidateDetailsScreenState extends State<CandidateDetailsScreen> {
  int _selectedTab = 0;
  final List<String> _tabs = <String>['Manifesto', 'Profile', 'Media'];

  Candidate? _candidate;
  Election? _election;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final Object? args = ModalRoute.of(context)?.settings.arguments;
    if (args is Candidate) {
      _candidate = args;
    } else if (args is Map) {
      final Object? c = args['candidate'];
      if (c is Candidate) {
        _candidate = c;
      }
      final Object? e = args['election'];
      if (e is Election) {
        _election = e;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF08090E),
      body: SafeArea(
        child: Column(
          children: <Widget>[
            // AppBar
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: const Color(0xFF0F1117).withValues(alpha: 0.8),
                border: Border(
                  bottom: BorderSide(
                    color: Colors.white.withValues(alpha: 0.05),
                  ),
                ),
              ),
              child: Row(
                children: <Widget>[
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      color: Colors.white.withValues(alpha: 0.1),
                    ),
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        onTap: () => Navigator.pop(context),
                        borderRadius: BorderRadius.circular(12),
                        child: const Icon(Icons.arrow_back, size: 20),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  const Text(
                    'Candidate Detail',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                  const Spacer(),
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      color: Colors.white.withValues(alpha: 0.1),
                    ),
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        onTap: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(_candidate?.name ?? 'Candidate'),
                              duration: const Duration(seconds: 2),
                            ),
                          );
                        },
                        borderRadius: BorderRadius.circular(12),
                        child: const Icon(Icons.share, size: 20),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Content
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  children: <Widget>[
                    // Hero Section
                    _buildHeroSection(),

                    // Tabs
                    _buildTabs(),

                    // Content
                    _buildContent(),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      // Bottom Action Bar
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xFF0D0E13).withValues(alpha: 0.9),
          border: Border(
            top: BorderSide(color: Colors.white.withValues(alpha: 0.05)),
          ),
        ),
        child: SafeArea(
          child: Row(
            children: <Widget>[
              Expanded(
                child: InkWell(
                  onTap: () {
                    Navigator.pushNamed(
                      context,
                      AppRouter.compareCandidates,
                      arguments: <String, dynamic>{
                        if (_election != null) 'election': _election,
                        if (_candidate != null)
                          'candidates': <Candidate>[_candidate!],
                      },
                    );
                  },
                  borderRadius: BorderRadius.circular(16),
                  child: Container(
                    height: 56,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: const Color(0xFF8E90A0)),
                    ),
                    child: const Center(
                      child: Text(
                        'Compare',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                flex: 2,
                child: InkWell(
                  onTap: () {
                    final Candidate? candidate = _candidate;
                    if (candidate == null) return;
                    final String blockId =
                        _election?.id ?? candidate.electionId;
                    Navigator.pushNamed(
                      context,
                      AppRouter.reviewVote,
                      arguments: <String, dynamic>{
                        'election': _election,
                        'candidates': <Candidate>[candidate],
                        'selections': <Map<String, String>>[
                          <String, String>{
                            'blockId': blockId,
                            'candidateId': candidate.id,
                          },
                        ],
                      },
                    );
                  },
                  borderRadius: BorderRadius.circular(16),
                  child: Container(
                    height: 56,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16),
                      gradient: const LinearGradient(
                        colors: <Color>[Color(0xFFB9C3FF), Color(0xFFD2BBFF)],
                      ),
                      boxShadow: <BoxShadow>[
                        BoxShadow(
                          color: const Color(0xFFB9C3FF).withValues(alpha: 0.3),
                          blurRadius: 30,
                          offset: const Offset(0, 10),
                        ),
                      ],
                    ),
                    child: const Center(
                      child: Text(
                        'Select Candidate',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w800,
                          color: Color(0xFF001257),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeroSection() {
    return Container(
      padding: const EdgeInsets.fromLTRB(24, 32, 24, 32),
      decoration: const BoxDecoration(color: Color(0xFF0F1117)),
      child: Column(
        children: <Widget>[
          // Avatar with gradient border
          Container(
            width: 96,
            height: 96,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: const LinearGradient(
                colors: <Color>[Color(0xFFB9C3FF), Color(0xFFD2BBFF)],
              ),
            ),
            padding: const EdgeInsets.all(4),
            child: Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: const Color(0xFF0F1117),
              ),
              padding: const EdgeInsets.all(4),
              child: CircleAvatar(
                radius: 40,
                backgroundColor: const Color(0xFFB9C3FF).withValues(alpha: 0.2),
                child: const Icon(
                  Icons.person,
                  size: 40,
                  color: Color(0xFFB9C3FF),
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Badge
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              color: const Color(0xFFB9C3FF).withValues(alpha: 0.1),
            ),
            child: Text(
              'CANDIDATE',
              style: const TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w700,
                color: Color(0xFFB9C3FF),
                letterSpacing: 1,
              ),
            ),
          ),
          const SizedBox(height: 12),

          // Name
          Text(
            _candidate?.name ?? 'Candidate',
            style: const TextStyle(
              fontSize: 30,
              fontWeight: FontWeight.w800,
              color: Colors.white,
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(height: 4),

          // Party
          Text(
            _candidate?.party ?? 'Independent',
            style: TextStyle(
              fontSize: 16,
              color: Colors.white.withValues(alpha: 0.7),
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 12),

          // Ballot Number
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              color: const Color(0xFF34343A),
              border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
            ),
            child: Text(
              'BALLOT #${_candidate?.ballotOrder ?? 0}',
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: Color(0xFFD2BBFF),
              ),
            ),
          ),
          const SizedBox(height: 20),

          // Social Links
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              _buildSocialButton(Icons.public, 'Website'),
              const SizedBox(width: 12),
              _buildSocialButton(Icons.link, 'LinkedIn'),
              const SizedBox(width: 12),
              _buildSocialButton(Icons.tag, 'Twitter'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSocialButton(IconData icon, String label) {
    return InkWell(
      onTap: () {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Social links coming soon'),
            duration: Duration(seconds: 2),
          ),
        );
      },
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          color: Colors.white.withValues(alpha: 0.03),
          border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
        ),
        child: Row(
          children: <Widget>[
            Icon(icon, size: 14, color: Colors.white.withValues(alpha: 0.7)),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                color: Colors.white.withValues(alpha: 0.7),
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTabs() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      decoration: BoxDecoration(
        color: const Color(0xFF08090E).withValues(alpha: 0.9),
        border: Border(
          bottom: BorderSide(color: Colors.white.withValues(alpha: 0.05)),
        ),
      ),
      child: Row(
        children: List.generate(_tabs.length, (index) {
          final bool isSelected = _selectedTab == index;
          return GestureDetector(
            onTap: () {
              if (index == 0) {
                // Manifesto tab - navigate to full manifesto screen
                Navigator.pushNamed(
                  context,
                  AppRouter.candidateManifesto,
                  arguments: _candidate,
                );
              } else {
                setState(() {
                  _selectedTab = index;
                });
              }
            },
            child: Container(
              margin: const EdgeInsets.only(right: 32),
              padding: const EdgeInsets.only(bottom: 4),
              decoration: BoxDecoration(
                border: Border(
                  bottom: BorderSide(
                    color: isSelected
                        ? const Color(0xFFB9C3FF)
                        : Colors.transparent,
                    width: 2,
                  ),
                ),
              ),
              child: Text(
                _tabs[index],
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: isSelected
                      ? const Color(0xFFB9C3FF)
                      : Colors.white.withValues(alpha: 0.5),
                ),
              ),
            ),
          );
        }),
      ),
    );
  }

  Widget _buildContent() {
    final Candidate? candidate = _candidate;
    final String bio = candidate?.bio?.isNotEmpty == true
        ? candidate!.bio!
        : '';
    final String manifesto = candidate?.manifesto?.isNotEmpty == true
        ? candidate!.manifesto!
        : '';

    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          if (bio.isNotEmpty) ...<Widget>[
            _buildSection(
              'About',
              Icons.person_outline,
              const Color(0xFFB9C3FF),
              bio,
            ),
            const SizedBox(height: 20),
          ],
          if (manifesto.isNotEmpty) ...<Widget>[
            _buildSection(
              'Manifesto',
              Icons.article_outlined,
              const Color(0xFFD2BBFF),
              manifesto,
            ),
            const SizedBox(height: 20),
          ],
          if (bio.isEmpty && manifesto.isEmpty)
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                color: const Color(0xFF1A1B21),
                border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
              ),
              child: Row(
                children: <Widget>[
                  Icon(
                    Icons.info_outline,
                    color: Colors.white.withValues(alpha: 0.5),
                    size: 20,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'This candidate has not added a biography or manifesto yet.',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.white.withValues(alpha: 0.6),
                        height: 1.5,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          const SizedBox(height: 100),
        ],
      ),
    );
  }

  Widget _buildSection(String title, IconData icon, Color color, String body) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        color: const Color(0xFF1A1B21),
        border: Border(left: BorderSide(color: color, width: 4)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            children: <Widget>[
              Icon(icon, color: color, size: 24),
              const SizedBox(width: 12),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            body,
            style: TextStyle(
              fontSize: 14,
              color: Colors.white.withValues(alpha: 0.8),
              height: 1.6,
            ),
          ),
        ],
      ),
    );
  }
}
