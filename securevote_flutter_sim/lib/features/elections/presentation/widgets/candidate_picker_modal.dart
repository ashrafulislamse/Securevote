import 'package:flutter/material.dart';

class CandidatePicker extends StatefulWidget {
  final List<Map<String, dynamic>> selectedCandidates;
  final Function(Map<String, dynamic>) onCandidateSelected;

  const CandidatePicker({
    super.key,
    required this.selectedCandidates,
    required this.onCandidateSelected,
  });

  @override
  State<CandidatePicker> createState() => _CandidatePickerState();
}

class _CandidatePickerState extends State<CandidatePicker> {
  String _searchQuery = '';

  final List<Map<String, dynamic>> _allCandidates = [
    {
      'name': 'Alice Johnson',
      'party': 'Democrat',
      'color': const Color(0xFFB9C3FF),
      'position': 'Mayor District 4',
    },
    {
      'name': 'Bob Smith',
      'party': 'Republican',
      'color': const Color(0xFFD2BBFF),
      'position': 'Mayor District 4',
    },
    {
      'name': 'Carol Williams',
      'party': 'Independent',
      'color': const Color(0xFF2ADEC0),
      'position': 'Mayor District 4',
    },
    {
      'name': 'David Brown',
      'party': 'Green Party',
      'color': const Color(0xFF7FD8BE),
      'position': 'Mayor District 4',
    },
  ];

  List<Map<String, dynamic>> get _filteredCandidates {
    if (_searchQuery.isEmpty) return _allCandidates;
    return _allCandidates.where((candidate) {
      final name = (candidate['name'] as String).toLowerCase();
      final party = (candidate['party'] as String).toLowerCase();
      final query = _searchQuery.toLowerCase();
      return name.contains(query) || party.contains(query);
    }).toList();
  }

  bool _isSelected(Map<String, dynamic> candidate) {
    return widget.selectedCandidates.any((c) => c['name'] == candidate['name']);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.75,
      decoration: const BoxDecoration(
        color: Color(0xFF08090E),
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        children: [
          // Handle
          Container(
            margin: const EdgeInsets.only(top: 12),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(2),
            ),
          ),

          // Header
          Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                const Text(
                  'Select Candidate',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
                const Spacer(),
                IconButton(
                  icon: const Icon(Icons.close, color: Colors.white),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
          ),

          // Search Bar
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Container(
              decoration: BoxDecoration(
                color: const Color(0xFF1A1B21),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
              ),
              child: TextField(
                onChanged: (value) {
                  setState(() {
                    _searchQuery = value;
                  });
                },
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  hintText: 'Search candidates...',
                  hintStyle: TextStyle(
                    color: Colors.white.withValues(alpha: 0.4),
                  ),
                  prefixIcon: Icon(
                    Icons.search,
                    color: Colors.white.withValues(alpha: 0.4),
                  ),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.all(16),
                ),
              ),
            ),
          ),

          const SizedBox(height: 16),

          // Candidate List
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              itemCount: _filteredCandidates.length,
              itemBuilder: (context, index) {
                final candidate = _filteredCandidates[index];
                final isSelected = _isSelected(candidate);

                return Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: InkWell(
                    onTap: isSelected
                        ? null
                        : () {
                            widget.onCandidateSelected(candidate);
                            Navigator.pop(context);
                          },
                    borderRadius: BorderRadius.circular(16),
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: const Color(0xFF1A1B21),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: isSelected
                              ? Colors.white.withValues(alpha: 0.2)
                              : Colors.white.withValues(alpha: 0.05),
                        ),
                      ),
                      child: Row(
                        children: [
                          // Avatar
                          Container(
                            width: 48,
                            height: 48,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: candidate['color'] as Color,
                                width: 2,
                              ),
                            ),
                            child: Icon(
                              Icons.person,
                              color: candidate['color'] as Color,
                              size: 24,
                            ),
                          ),
                          const SizedBox(width: 12),

                          // Info
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  candidate['name'] as String,
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                    color: isSelected
                                        ? Colors.white.withValues(alpha: 0.4)
                                        : Colors.white,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  candidate['party'] as String,
                                  style: TextStyle(
                                    fontSize: 13,
                                    color: isSelected
                                        ? (candidate['color'] as Color)
                                              .withValues(alpha: 0.4)
                                        : candidate['color'] as Color,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          ),

                          // Status
                          if (isSelected)
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 6,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                'Selected',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.white.withValues(alpha: 0.5),
                                ),
                              ),
                            )
                          else
                            Icon(
                              Icons.add_circle_outline,
                              color: candidate['color'] as Color,
                            ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
