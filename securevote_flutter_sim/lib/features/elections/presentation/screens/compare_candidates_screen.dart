import 'package:flutter/material.dart';

import '../../../../core/models/candidate.dart';
import '../widgets/candidate_picker_modal.dart';

class CompareCandidatesScreen extends StatefulWidget {
  const CompareCandidatesScreen({super.key});

  @override
  State<CompareCandidatesScreen> createState() =>
      _CompareCandidatesScreenState();
}

class _CompareCandidatesScreenState extends State<CompareCandidatesScreen> {
  static const List<Color> _candidateColors = <Color>[
    Color(0xFFB9C3FF),
    Color(0xFFD2BBFF),
    Color(0xFF2ADEC0),
    Color(0xFFFF7B5A),
  ];

  List<Map<String, dynamic>> _selectedCandidates = <Map<String, dynamic>>[];

  List<Candidate>? get _passedCandidates {
    final Object? args = ModalRoute.of(context)?.settings.arguments;
    return _extractCandidates(args);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_selectedCandidates.isEmpty) {
      final List<Candidate>? candidates = _passedCandidates;
      if (candidates != null && candidates.isNotEmpty) {
        _selectedCandidates = candidates
            .take(2)
            .map((Candidate c) => _toMap(c))
            .toList();
      } else {
        _selectedCandidates = _defaultCandidates();
      }
    }
  }

  List<Candidate>? _extractCandidates(Object? args) {
    if (args is List<Candidate>) {
      return args;
    }
    if (args is Map) {
      final Object? v = args['candidates'];
      if (v is List<Candidate>) {
        return v;
      }
    }
    return null;
  }

  Map<String, dynamic> _toMap(Candidate c) => <String, dynamic>{
    'name': c.name,
    'party': c.party ?? 'Independent',
    'color': _candidateColors[c.ballotOrder % _candidateColors.length],
    'bio': c.bio ?? '',
    'manifesto': c.manifesto ?? '',
  };

  List<Map<String, dynamic>> _defaultCandidates() {
    final List<Candidate>? candidates = _passedCandidates;
    if (candidates != null && candidates.isNotEmpty) {
      return candidates.map((Candidate c) => _toMap(c)).toList();
    }
    return <Map<String, dynamic>>[
      <String, dynamic>{
        'name': 'No candidates available',
        'party': '—',
        'color': const Color(0xFFB9C3FF),
        'bio': '',
        'manifesto': '',
      },
    ];
  }

  void _showCandidatePicker() {
    final List<Candidate>? candidates = _passedCandidates;
    if (candidates == null || candidates.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('No candidates to pick from. Open an election first.'),
        ),
      );
      return;
    }
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => CandidatePicker(
        selectedCandidates: _selectedCandidates,
        onCandidateSelected: (candidate) {
          setState(() {
            if (_selectedCandidates.length < 4) {
              _selectedCandidates.add(candidate);
            }
          });
        },
        candidates: candidates,
      ),
    );
  }

  void _removeCandidate(int index) {
    setState(() {
      _selectedCandidates.removeAt(index);
    });
  }

  void _resetComparison() {
    setState(() {
      _selectedCandidates = _defaultCandidates();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF08090E),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFFE3E1E9)),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Compare Candidates',
          style: TextStyle(
            color: Color(0xFFE3E1E9),
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        actions: <Widget>[
          TextButton(
            onPressed: _resetComparison,
            child: const Text(
              'Reset',
              style: TextStyle(
                color: Color(0xFFFFB4AB),
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
      body: Column(
        children: <Widget>[
          // Selector Row
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            child: Row(
              children: <Widget>[
                ..._selectedCandidates.asMap().entries.map((entry) {
                  final int index = entry.key;
                  final Map<String, dynamic> candidate = entry.value;
                  return Padding(
                    padding: const EdgeInsets.only(right: 12),
                    child: _buildCandidateChip(
                      candidate['name'] as String,
                      candidate['color'] as Color,
                      true,
                      () => _removeCandidate(index),
                    ),
                  );
                }),
                if (_selectedCandidates.length < 4) _buildAddChip(),
              ],
            ),
          ),

          // Comparison Table
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: const Color(0xFF1A1B21),
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(24),
                ),
                border: Border(
                  top: BorderSide(color: Colors.white.withValues(alpha: 0.1)),
                ),
              ),
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: <Widget>[
                    // Sticky Header: Avatars
                    Container(
                      padding: const EdgeInsets.only(bottom: 24),
                      decoration: const BoxDecoration(
                        border: Border(
                          bottom: BorderSide(color: Color(0xFF34343A)),
                        ),
                      ),
                      child: Row(
                        children: _selectedCandidates.asMap().entries.map((
                          entry,
                        ) {
                          final Map<String, dynamic> candidate = entry.value;
                          return Expanded(
                            child: Padding(
                              padding: EdgeInsets.only(
                                right:
                                    entry.key < _selectedCandidates.length - 1
                                    ? 16
                                    : 0,
                              ),
                              child: _buildCandidateHeader(
                                candidate['name'] as String,
                                candidate['party'] as String,
                                candidate['color'] as Color,
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    ),

                    const SizedBox(height: 32),

                    // Bio row
                    _buildCriteriaSection('Biography', <Widget>[
                      _buildTextRow(
                        _selectedCandidates
                            .map((c) => _truncate(c['bio'] as String, 160))
                            .toList(),
                      ),
                    ]),

                    const SizedBox(height: 32),

                    // Manifesto row
                    _buildCriteriaSection('Manifesto', <Widget>[
                      _buildTextRow(
                        _selectedCandidates
                            .map(
                              (c) => _truncate(c['manifesto'] as String, 200),
                            )
                            .toList(),
                      ),
                    ]),

                    const SizedBox(height: 100),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.fromLTRB(20, 24, 20, 40),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.05),
          border: Border(
            top: BorderSide(color: Colors.white.withValues(alpha: 0.2)),
          ),
        ),
        child: SizedBox(
          height: 56,
          child: ElevatedButton(
            onPressed: () => Navigator.pop(context),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFB9C3FF),
              foregroundColor: const Color(0xFF001D79),
              elevation: 8,
              shadowColor: const Color(0xFFB9C3FF).withValues(alpha: 0.3),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: const <Widget>[
                Icon(Icons.how_to_vote, size: 20),
                SizedBox(width: 8),
                Text(
                  'Done Comparing',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String _truncate(String text, int max) {
    if (text.isEmpty) return '—';
    if (text.length <= max) return text;
    return '${text.substring(0, max)}…';
  }

  Widget _buildCandidateChip(
    String name,
    Color color,
    bool hasClose,
    VoidCallback? onRemove,
  ) {
    return Container(
      height: 40,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: const Color(0xFF34343A),
        border: Border.all(color: Colors.white.withValues(alpha: 0.15)),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: <Widget>[
          Icon(Icons.person, color: color, size: 18),
          const SizedBox(width: 8),
          Text(
            name,
            style: const TextStyle(
              color: Color(0xFFE3E1E9),
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
          if (hasClose && onRemove != null) ...<Widget>[
            const SizedBox(width: 8),
            GestureDetector(
              onTap: onRemove,
              child: const Icon(
                Icons.close,
                color: Color(0xFFC4C5D7),
                size: 16,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildAddChip() {
    return GestureDetector(
      onTap: _showCandidatePicker,
      child: Container(
        height: 40,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        decoration: BoxDecoration(
          border: Border.all(
            color: const Color(0xFF444654),
            style: BorderStyle.solid,
          ),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          children: const <Widget>[
            Icon(Icons.add, color: Color(0xFFC4C5D7), size: 18),
            SizedBox(width: 8),
            Text(
              'Add Candidate',
              style: TextStyle(
                color: Color(0xFFC4C5D7),
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCandidateHeader(String name, String party, Color color) {
    return Column(
      children: <Widget>[
        Container(
          width: 80,
          height: 80,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: color, width: 2),
          ),
          child: const Icon(Icons.person, color: Color(0xFFE3E1E9), size: 40),
        ),
        const SizedBox(height: 16),
        Text(
          name,
          textAlign: TextAlign.center,
          style: const TextStyle(
            color: Color(0xFFE3E1E9),
            fontSize: 18,
            fontWeight: FontWeight.bold,
            height: 1.2,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          party.toUpperCase(),
          style: TextStyle(
            color: color,
            fontSize: 12,
            fontWeight: FontWeight.w500,
            letterSpacing: 1.2,
          ),
        ),
      ],
    );
  }

  Widget _buildCriteriaSection(String title, List<Widget> children) {
    return Column(
      children: <Widget>[
        Container(
          padding: const EdgeInsets.only(bottom: 8),
          decoration: const BoxDecoration(
            border: Border(bottom: BorderSide(color: Color(0xFF34343A))),
          ),
          child: Text(
            title.toUpperCase(),
            style: const TextStyle(
              color: Color(0xFFC4C5D7),
              fontSize: 14,
              fontWeight: FontWeight.w600,
              letterSpacing: 1.5,
            ),
          ),
        ),
        const SizedBox(height: 24),
        ...children,
      ],
    );
  }

  /// Renders one text cell per selected candidate side by side.
  Widget _buildTextRow(List<String> values) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: values.asMap().entries.map((entry) {
        final int i = entry.key;
        return Expanded(
          child: Padding(
            padding: EdgeInsets.only(right: i < values.length - 1 ? 24 : 0),
            child: Text(
              entry.value,
              style: const TextStyle(
                color: Color(0xFFE3E1E9),
                fontSize: 14,
                height: 1.5,
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}
