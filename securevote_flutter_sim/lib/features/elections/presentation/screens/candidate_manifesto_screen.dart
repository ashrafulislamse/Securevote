import 'package:flutter/material.dart';

import '../../../../core/models/candidate.dart';

class CandidateManifestoScreen extends StatefulWidget {
  const CandidateManifestoScreen({super.key});

  @override
  State<CandidateManifestoScreen> createState() =>
      _CandidateManifestoScreenState();
}

class _CandidateManifestoScreenState extends State<CandidateManifestoScreen> {
  // Font size for the manifesto body, adjustable via the A-/A+ controls.
  double _fontSize = 18.0;
  static const double _minFontSize = 14.0;
  static const double _maxFontSize = 26.0;

  Candidate? _candidate;

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
    }
  }

  @override
  Widget build(BuildContext context) {
    final Candidate? candidate = _candidate;
    final String name = candidate?.name ?? 'Candidate';
    final String party = candidate?.party ?? 'Independent';
    final String body = candidate?.manifesto?.isNotEmpty == true
        ? candidate!.manifesto!
        : candidate?.bio?.isNotEmpty == true
        ? candidate!.bio!
        : 'This candidate has not published a manifesto yet. Review their profile for more details.';

    return Scaffold(
      backgroundColor: const Color(0xFF08090E),
      body: CustomScrollView(
        slivers: <Widget>[
          // Reading Progress Bar
          SliverAppBar(
            pinned: true,
            backgroundColor: const Color(0xFF0F1117).withValues(alpha: 0.5),
            elevation: 0,
            leading: Container(
              margin: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.05),
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
            actions: <Widget>[
              Container(
                margin: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.05),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: IconButton(
                  icon: const Icon(Icons.bookmark, color: Color(0xFFE3E1E9)),
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Bookmarked'),
                        duration: Duration(seconds: 2),
                      ),
                    );
                  },
                ),
              ),
            ],
            bottom: PreferredSize(
              preferredSize: const Size.fromHeight(3),
              child: Container(
                height: 3,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.05),
                ),
                child: FractionallySizedBox(
                  widthFactor: 0.65,
                  alignment: Alignment.centerLeft,
                  child: Container(
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        colors: <Color>[Color(0xFFB9C3FF), Color(0xFFD2BBFF)],
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
                children: <Widget>[
                  // Mini Author Bar
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: const Color(0xFF1A1B21).withValues(alpha: 0.5),
                      border: Border.all(
                        color: Colors.white.withValues(alpha: 0.05),
                      ),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Row(
                      children: <Widget>[
                        Container(
                          width: 48,
                          height: 48,
                          decoration: BoxDecoration(
                            color: const Color(0xFF292A2F),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: Colors.white.withValues(alpha: 0.1),
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
                            children: <Widget>[
                              Text(
                                name,
                                style: const TextStyle(
                                  color: Color(0xFFE3E1E9),
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Row(
                                children: <Widget>[
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
                      ],
                    ),
                  ),

                  const SizedBox(height: 32),

                  // Article Header
                  ShaderMask(
                    shaderCallback: (bounds) => const LinearGradient(
                      colors: <Color>[Color(0xFFE3E1E9), Color(0xFFC4C5D7)],
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

                  const SizedBox(height: 32),

                  // Section header
                  Row(
                    children: <Widget>[
                      Container(
                        width: 6,
                        height: 32,
                        decoration: const BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: <Color>[
                              Color(0xFFB9C3FF),
                              Color(0xFFD2BBFF),
                            ],
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

                  // Manifesto body (font size adjustable).
                  AnimatedDefaultTextStyle(
                    duration: const Duration(milliseconds: 150),
                    style: TextStyle(
                      color: const Color(0xFFC4C5D7),
                      fontSize: _fontSize,
                      height: 1.6,
                    ),
                    child: Text(body),
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
          color: const Color(0xFF0D0E13).withValues(alpha: 0.8),
          border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
          borderRadius: BorderRadius.circular(24),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            TextButton(
              onPressed: _fontSize <= _minFontSize
                  ? null
                  : () => setState(
                      () => _fontSize = (_fontSize - 2).clamp(
                        _minFontSize,
                        _maxFontSize,
                      ),
                    ),
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
              color: Colors.white.withValues(alpha: 0.1),
            ),
            TextButton(
              onPressed: _fontSize >= _maxFontSize
                  ? null
                  : () => setState(
                      () => _fontSize = (_fontSize + 2).clamp(
                        _minFontSize,
                        _maxFontSize,
                      ),
                    ),
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
}
