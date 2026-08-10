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

  List<Map<String, dynamic>> _selectedCandidates = [];

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_selectedCandidates.isEmpty) {
      final Object? args = ModalRoute.of(context)?.settings.arguments;
      final List<Candidate>? candidates = _extractCandidates(args);
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
        'color': _candidateColors[(c.ballotOrder) % _candidateColors.length],
        'position': 'Candidate',
      };

  List<Map<String, dynamic>> _defaultCandidates() => <Map<String, dynamic>>[
        <String, dynamic>{
          'name': 'Alice Johnson',
          'party': 'Democrat',
          'color': const Color(0xFFB9C3FF),
          'position': 'Candidate',
        },
        <String, dynamic>{
          'name': 'Bob Smith',
          'party': 'Republican',
          'color': const Color(0xFFD2BBFF),
          'position': 'Candidate',
        },
      ];

  void _showCandidatePicker() {
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
        actions: [
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
        children: [
          // Selector Row
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            child: Row(
              children: [
                ..._selectedCandidates.asMap().entries.map((entry) {
                  final index = entry.key;
                  final candidate = entry.value;
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
                  top: BorderSide(color: Colors.white.withOpacity(0.1)),
                ),
              ),
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    // Sticky Header: Avatars
                    Container(
                      padding: const EdgeInsets.only(bottom: 24),
                      decoration: BoxDecoration(
                        color: const Color(0xFF1A1B21),
                        border: Border(
                          bottom: BorderSide(color: const Color(0xFF34343A)),
                        ),
                      ),
                      child: Row(
                        children: _selectedCandidates.asMap().entries.map((
                          entry,
                        ) {
                          final candidate = entry.value;
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

                    // Criteria Rows
                    _buildCriteriaSection('Running For', [
                      _buildCriteriaRow(
                        'Mayor\nDistrict 4',
                        'Mayor\nDistrict 4',
                      ),
                    ]),

                    const SizedBox(height: 32),

                    _buildCriteriaSection('Experience', [
                      _buildExperienceRow(
                        Icons.account_balance,
                        'City Council',
                        '5 Years',
                        const Color(0xFFB9C3FF),
                        Icons.storefront,
                        'Business Owner',
                        '10 Years',
                        const Color(0xFFD2BBFF),
                      ),
                    ]),

                    const SizedBox(height: 32),

                    _buildCriteriaSection('Key Focus Areas', [
                      _buildFocusAreasRow(),
                    ]),

                    const SizedBox(height: 32),

                    _buildCriteriaSection('SecureVote Verified', [
                      _buildVerificationRow(),
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
          color: Colors.white.withOpacity(0.05),
          border: Border(top: BorderSide(color: Colors.white.withOpacity(0.2))),
        ),
        child: SizedBox(
          height: 56,
          child: ElevatedButton(
            onPressed: () {},
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFB9C3FF),
              foregroundColor: const Color(0xFF001D79),
              elevation: 8,
              shadowColor: const Color(0xFFB9C3FF).withOpacity(0.3),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: const [
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
        border: Border.all(color: Colors.white.withOpacity(0.15)),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
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
          if (hasClose && onRemove != null) ...[
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
          children: const [
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
      children: [
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
      children: [
        Container(
          padding: const EdgeInsets.only(bottom: 8),
          decoration: BoxDecoration(
            border: Border(bottom: BorderSide(color: const Color(0xFF34343A))),
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

  Widget _buildCriteriaRow(String left, String right) {
    return Row(
      children: [
        Expanded(
          child: Text(
            left,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Color(0xFFE3E1E9),
              fontSize: 16,
              fontWeight: FontWeight.w500,
              height: 1.4,
            ),
          ),
        ),
        const SizedBox(width: 24),
        Expanded(
          child: Text(
            right,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Color(0xFFE3E1E9),
              fontSize: 16,
              fontWeight: FontWeight.w500,
              height: 1.4,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildExperienceRow(
    IconData icon1,
    String title1,
    String years1,
    Color color1,
    IconData icon2,
    String title2,
    String years2,
    Color color2,
  ) {
    return Row(
      children: [
        Expanded(
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFF34343A).withOpacity(0.3),
              border: Border.all(color: Colors.white.withOpacity(0.1)),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              children: [
                Icon(icon1, color: color1, size: 24),
                const SizedBox(height: 8),
                Text(
                  title1,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: Color(0xFFE3E1E9),
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  years1,
                  style: TextStyle(
                    color: color1,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(width: 24),
        Expanded(
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFF34343A).withOpacity(0.3),
              border: Border.all(color: Colors.white.withOpacity(0.1)),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              children: [
                Icon(icon2, color: color2, size: 24),
                const SizedBox(height: 8),
                Text(
                  title2,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: Color(0xFFE3E1E9),
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  years2,
                  style: TextStyle(
                    color: color2,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildFocusAreasRow() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            children: [
              _buildFocusItem(
                'Public Transportation Expansion',
                const Color(0xFFB9C3FF),
              ),
              const SizedBox(height: 12),
              _buildFocusItem(
                'Affordable Housing Initiatives',
                const Color(0xFFB9C3FF),
              ),
              const SizedBox(height: 12),
              _buildFocusItem(
                'Green Energy Transition',
                const Color(0xFFB9C3FF),
              ),
            ],
          ),
        ),
        const SizedBox(width: 24),
        Expanded(
          child: Column(
            children: [
              _buildFocusItem(
                'Small Business Tax Cuts',
                const Color(0xFFD2BBFF),
              ),
              const SizedBox(height: 12),
              _buildFocusItem(
                'Law Enforcement Funding',
                const Color(0xFFD2BBFF),
              ),
              const SizedBox(height: 12),
              _buildFocusItem('Infrastructure Repair', const Color(0xFFD2BBFF)),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildFocusItem(String text, Color color) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(Icons.check_circle, color: color, size: 18),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            text,
            style: const TextStyle(color: Color(0xFFE3E1E9), fontSize: 14),
          ),
        ),
      ],
    );
  }

  Widget _buildVerificationRow() {
    return Row(
      children: [
        Expanded(
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: const Color(0xFF2ADEC0).withOpacity(0.2),
              border: Border.all(
                color: const Color(0xFF2ADEC0).withOpacity(0.3),
              ),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: const [
                Icon(Icons.verified_user, color: Color(0xFF2ADEC0), size: 16),
                SizedBox(width: 6),
                Text(
                  'Identity Confirmed',
                  style: TextStyle(
                    color: Color(0xFF2ADEC0),
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(width: 24),
        Expanded(
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: const Color(0xFF2ADEC0).withOpacity(0.2),
              border: Border.all(
                color: const Color(0xFF2ADEC0).withOpacity(0.3),
              ),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: const [
                Icon(Icons.verified_user, color: Color(0xFF2ADEC0), size: 16),
                SizedBox(width: 6),
                Text(
                  'Identity Confirmed',
                  style: TextStyle(
                    color: Color(0xFF2ADEC0),
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
