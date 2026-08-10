import 'package:flutter/material.dart';

import '../../../../core/models/candidate.dart';

class CandidateManifestoScreen extends StatelessWidget {
  const CandidateManifestoScreen({super.key});

  Candidate? _candidate(BuildContext context) {
    final Object? args = ModalRoute.of(context)?.settings.arguments;
    return args is Candidate ? args : null;
  }

  @override
  Widget build(BuildContext context) {
    final Candidate? candidate = _candidate(context);
    final String name = candidate?.name ?? 'Candidate';
    final String party = candidate?.party ?? 'Independent';
    final String manifesto = candidate?.manifesto?.isNotEmpty == true
        ? candidate!.manifesto!
        : candidate?.bio?.isNotEmpty == true
        ? candidate!.bio!
        : 'This candidate has not published a manifesto yet. Review their profile for more details.';

    return Scaffold(
      backgroundColor: const Color(0xFF08090E),
      body: CustomScrollView(
        slivers: [
          // Reading Progress Bar
          SliverAppBar(
            pinned: true,
            backgroundColor: const Color(0xFF0F1117).withOpacity(0.5),
            elevation: 0,
            leading: Container(
              margin: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.05),
                borderRadius: BorderRadius.circular(12),
              ),
              child: IconButton(
                icon: const Icon(Icons.arrow_back, color: Color(0xFFE3E1E9)),
                onPressed: () => Navigator.pop(context),
              ),
            ),
            title: Text(
              name,
              style: const TextStyle(
                color: Color(0xFFE3E1E9),
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            actions: [
              Container(
                margin: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.05),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: IconButton(
                  icon: const Icon(Icons.bookmark, color: Color(0xFFE3E1E9)),
                  onPressed: () {},
                ),
              ),
            ],
            bottom: PreferredSize(
              preferredSize: const Size.fromHeight(3),
              child: Container(
                height: 3,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.05),
                ),
                child: FractionallySizedBox(
                  widthFactor: 0.65,
                  alignment: Alignment.centerLeft,
                  child: Container(
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        colors: [Color(0xFFB9C3FF), Color(0xFFD2BBFF)],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),

          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Mini Author Bar
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: const Color(0xFF1A1B21).withOpacity(0.5),
                      border: Border.all(color: Colors.white.withOpacity(0.05)),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 48,
                          height: 48,
                          decoration: BoxDecoration(
                            color: const Color(0xFF292A2F),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: Colors.white.withOpacity(0.1),
                            ),
                          ),
                          child: const Icon(
                            Icons.person,
                            color: Color(0xFF8E90A0),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                name,
                                style: const TextStyle(
                                  color: Color(0xFFE3E1E9),
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Row(
                                children: [
                                  const Icon(
                                    Icons.verified,
                                    color: Color(0xFF2ADEC0),
                                    size: 14,
                                  ),
                                  const SizedBox(width: 4),
                                  Expanded(
                                    child: Text(
                                      party.toUpperCase(),
                                      style: const TextStyle(
                                        color: Color(0xFF2ADEC0),
                                        fontSize: 12,
                                        fontWeight: FontWeight.w500,
                                        letterSpacing: 1.0,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFF34343A).withOpacity(0.5),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            children: const [
                              Icon(
                                Icons.schedule,
                                color: Color(0xFFC4C5D7),
                                size: 14,
                              ),
                              SizedBox(width: 4),
                              Text(
                                '5 min read',
                                style: TextStyle(
                                  color: Color(0xFFC4C5D7),
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 32),

                  // Article Header
                  ShaderMask(
                    shaderCallback: (bounds) => const LinearGradient(
                      colors: [Color(0xFFE3E1E9), Color(0xFFC4C5D7)],
                    ).createShader(bounds),
                    child: Text(
                      '$name — Manifesto',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 36,
                        fontWeight: FontWeight.w800,
                        height: 1.2,
                      ),
                    ),
                  ),

                  const SizedBox(height: 16),

                  Row(
                    children: [
                      const Text(
                        'Published Sept 12, 2024',
                        style: TextStyle(
                          color: Color(0xFFC4C5D7),
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      Container(
                        width: 4,
                        height: 4,
                        margin: const EdgeInsets.symmetric(horizontal: 8),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          shape: BoxShape.circle,
                        ),
                      ),
                      const Text(
                        'Policy Paper #16',
                        style: TextStyle(
                          color: Color(0xFFC4C5D7),
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 32),

                  // Section 1
                  Row(
                    children: [
                      Container(
                        width: 6,
                        height: 32,
                        decoration: const BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [Color(0xFFB9C3FF), Color(0xFFD2BBFF)],
                          ),
                          borderRadius: BorderRadius.all(Radius.circular(3)),
                        ),
                      ),
                      const SizedBox(width: 16),
                      const Text(
                    'Manifesto',
                    style: TextStyle(
                      color: Color(0xFFE3E1E9),
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),

                  const SizedBox(height: 24),

                  Text(
                    manifesto,
                    style: const TextStyle(
                      color: Color(0xFFC4C5D7),
                      fontSize: 18,
                      height: 1.6,
                    ),
                  ),

                  const SizedBox(height: 24),

                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      border: Border(
                        left: BorderSide(color: Color(0xFF4F6EF7), width: 4),
                      ),
                    ),
                    child: const Text(
                      '"True digital sovereignty is not merely the right to speak, but the guaranteed right to be heard without fear of surveillance or manipulation."',
                      style: TextStyle(
                        color: Color(0xFFB9C3FF),
                        fontSize: 20,
                        fontStyle: FontStyle.italic,
                        fontWeight: FontWeight.w500,
                        height: 1.5,
                      ),
                    ),
                  ),

                  const SizedBox(height: 32),

                  // Key Promises
                  Row(
                    children: [
                      Expanded(
                        child: _buildPromiseCard(
                          'Immutable Ledger',
                          'Publicly auditable voting records using decentralized consensus protocols.',
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: _buildPromiseCard(
                          'Identity Privacy',
                          'Decoupled voter identity from ballot content using homomorphic encryption.',
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 32),

                  // Section 2
                  Row(
                    children: [
                      Container(
                        width: 6,
                        height: 32,
                        decoration: const BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [Color(0xFFB9C3FF), Color(0xFFD2BBFF)],
                          ),
                          borderRadius: BorderRadius.all(Radius.circular(3)),
                        ),
                      ),
                      const SizedBox(width: 16),
                      const Text(
                        'Economic Reconfiguration',
                        style: TextStyle(
                          color: Color(0xFFE3E1E9),
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 24),

                  const Text(
                    'The governance of our data should yield dividends to the citizen, not just the corporation. I propose a Universal Data Dividend (UDD), where every verified SecureVote participant receives a micro-percentage of national tech growth.',
                    style: TextStyle(
                      color: Color(0xFFC4C5D7),
                      fontSize: 18,
                      height: 1.6,
                    ),
                  ),

                  const SizedBox(height: 24),

                  Container(
                    height: 200,
                    decoration: BoxDecoration(
                      color: const Color(0xFF1A1B21),
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(color: Colors.white.withOpacity(0.05)),
                    ),
                    child: Stack(
                      children: [
                        Positioned(
                          bottom: 24,
                          left: 24,
                          child: Row(
                            children: const [
                              Icon(
                                Icons.bolt,
                                color: Color(0xFF2ADEC0),
                                size: 16,
                              ),
                              SizedBox(width: 8),
                              Text(
                                'LIVE GROWTH PROJECTION',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 1.2,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),

                  const Text(
                    'By aligning economic incentives with civic participation, we create a self-sustaining loop of engagement. This isn\'t just a policy; it\'s a protocol for national resilience.',
                    style: TextStyle(
                      color: Color(0xFFC4C5D7),
                      fontSize: 18,
                      height: 1.6,
                    ),
                  ),

                  const SizedBox(height: 80),
                ],
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: const Color(0xFF0D0E13).withOpacity(0.8),
          border: Border.all(color: Colors.white.withOpacity(0.1)),
          borderRadius: BorderRadius.circular(24),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextButton(
              onPressed: () {},
              child: const Text(
                'A-',
                style: TextStyle(
                  color: Color(0xFFC4C5D7),
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            Container(
              width: 1,
              height: 24,
              color: Colors.white.withOpacity(0.1),
            ),
            TextButton(
              onPressed: () {},
              child: const Text(
                'A+',
                style: TextStyle(
                  color: Color(0xFFE3E1E9),
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPromiseCard(String title, String description) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: const Color(0xFF292A2F),
        border: Border.all(color: Colors.white.withOpacity(0.05)),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: const Color(0xFF2ADEC0).withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.check_circle,
              color: Color(0xFF2ADEC0),
              size: 20,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            title,
            style: const TextStyle(
              color: Color(0xFFE3E1E9),
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            description,
            style: const TextStyle(
              color: Color(0xFFC4C5D7),
              fontSize: 14,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }
}
