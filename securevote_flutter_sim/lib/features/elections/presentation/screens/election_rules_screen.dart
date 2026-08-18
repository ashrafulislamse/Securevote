import 'package:flutter/material.dart';

import '../../../../core/models/election.dart';
import '../../../../core/navigation/app_router.dart';
import '../../../../shared/widgets/gradient_button.dart';

class ElectionRulesScreen extends StatefulWidget {
  const ElectionRulesScreen({super.key});

  @override
  State<ElectionRulesScreen> createState() => _ElectionRulesScreenState();
}

class _ElectionRulesScreenState extends State<ElectionRulesScreen> {
  final List<bool> _expanded = <bool>[true, false, false, false];

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

  Election? get _election {
    final Object? args = ModalRoute.of(context)?.settings.arguments;
    if (args is Election) return args;
    if (args is Map) {
      final Object? e = args['election'];
      if (e is Election) return e;
    }
    return null;
  }

  static String _formatDate(DateTime d) {
    final List<String> months = _months;
    return '${months[d.month - 1]} ${d.day}, ${d.year}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF08090E),
      body: SafeArea(
        child: Column(
          children: <Widget>[
            // Custom AppBar
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: const Color(0xFF0D0E13).withValues(alpha: 0.5),
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
                      borderRadius: BorderRadius.circular(20),
                      color: Colors.white.withValues(alpha: 0.1),
                    ),
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        onTap: () => Navigator.pop(context),
                        borderRadius: BorderRadius.circular(20),
                        child: const Icon(Icons.arrow_back, size: 20),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: ShaderMask(
                      shaderCallback: (bounds) => const LinearGradient(
                        colors: <Color>[Color(0xFFB9C3FF), Color(0xFFD2BBFF)],
                      ).createShader(bounds),
                      child: const Text(
                        'Rules & Guidelines',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w800,
                          color: Colors.white,
                          letterSpacing: -0.5,
                        ),
                      ),
                    ),
                  ),
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                      color: Colors.white.withValues(alpha: 0.1),
                    ),
                    child: const Icon(
                      Icons.shield,
                      size: 20,
                      color: Color(0xFFB9C3FF),
                    ),
                  ),
                ],
              ),
            ),

            // Content
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: <Widget>[
                    _infoBanner(context),
                    const SizedBox(height: 24),
                    _buildRuleCard(
                      0,
                      '01',
                      'One Vote Per Person',
                      'Each verified voter may cast a single ballot in this election. Once your vote is submitted it cannot be changed.',
                      <String>[],
                    ),
                    const SizedBox(height: 16),
                    _buildRuleCard(
                      1,
                      '02',
                      'KYC Verification Required',
                      'You must complete identity (KYC) verification before you can vote. Votes from unverified accounts are not accepted.',
                      <String>[],
                    ),
                    const SizedBox(height: 16),
                    _buildRuleCard(
                      2,
                      '03',
                      'Voting Period',
                      _election != null
                          ? 'Voting is open from ${_formatDate(_election!.startsAt)} to ${_formatDate(_election!.endsAt)}. Ballots submitted outside this window are not counted.'
                          : 'Ballots may only be submitted during the official voting window for this election.',
                      <String>[],
                    ),
                    const SizedBox(height: 16),
                    _buildRuleCard(
                      3,
                      '04',
                      'Results & Verification',
                      'Results are published after the voting period closes. Every ballot is recorded on an immutable ledger and can be independently verified without revealing your choice.',
                      <String>[],
                    ),
                    const SizedBox(height: 32),
                    _helpSection(),
                    const SizedBox(height: 80),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      // Fixed Bottom Button
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xFF0D0E13).withValues(alpha: 0.8),
          border: Border(
            top: BorderSide(color: Colors.white.withValues(alpha: 0.05)),
          ),
        ),
        child: SafeArea(
          child: GradientButton(
            label: 'I Understand, Continue',
            icon: Icons.check_circle,
            onPressed: () => Navigator.pop(context),
          ),
        ),
      ),
    );
  }

  Widget _infoBanner(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        color: Colors.white.withValues(alpha: 0.03),
        border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              color: const Color(0xFFB9C3FF).withValues(alpha: 0.1),
            ),
            child: const Icon(Icons.info, color: Color(0xFFB9C3FF), size: 24),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                if (_election != null) ...<Widget>[
                  Text(
                    _election!.title,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFFB9C3FF),
                    ),
                  ),
                  const SizedBox(height: 6),
                ],
                const Text(
                  'Election Integrity Protocol',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'These rules ensure that every vote is weighted equally and protected by end-to-end encryption. Any violation of these terms may result in vote disqualification.',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.white.withValues(alpha: 0.7),
                    height: 1.5,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRuleCard(
    int index,
    String number,
    String title,
    String? description,
    List<String> items, {
    bool numbered = false,
  }) {
    final bool isExpanded = _expanded[index];

    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        color: const Color(0xFF161A24),
        border: Border.all(
          color: isExpanded
              ? Colors.white.withValues(alpha: 0.1)
              : Colors.white.withValues(alpha: 0.05),
        ),
      ),
      child: Column(
        children: <Widget>[
          Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: () {
                setState(() {
                  _expanded[index] = !_expanded[index];
                });
              },
              borderRadius: BorderRadius.circular(16),
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Row(
                  children: <Widget>[
                    Container(
                      width: 40,
                      height: 40,
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: LinearGradient(
                          colors: <Color>[Color(0xFFB9C3FF), Color(0xFFD2BBFF)],
                        ),
                        boxShadow: <BoxShadow>[
                          BoxShadow(
                            color: Color(0xFFB9C3FF),
                            blurRadius: 15,
                            offset: Offset(0, 0),
                            spreadRadius: -5,
                          ),
                        ],
                      ),
                      child: Center(
                        child: Text(
                          number,
                          style: const TextStyle(
                            color: Color(0xFF001D79),
                            fontWeight: FontWeight.w800,
                            fontSize: 14,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 20),
                    Expanded(
                      child: Text(
                        title,
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          color: isExpanded
                              ? const Color(0xFFB9C3FF)
                              : Colors.white,
                        ),
                      ),
                    ),
                    AnimatedRotation(
                      turns: isExpanded ? 0.5 : 0,
                      duration: const Duration(milliseconds: 300),
                      child: Icon(
                        Icons.expand_more,
                        color: isExpanded
                            ? Colors.white
                            : Colors.white.withValues(alpha: 0.5),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          if (isExpanded)
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  if (description != null) ...<Widget>[
                    Text(
                      description,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.white.withValues(alpha: 0.7),
                        height: 1.5,
                      ),
                    ),
                    if (items.isNotEmpty) const SizedBox(height: 16),
                  ],
                  ...items.asMap().entries.map((entry) {
                    final int idx = entry.key;
                    final String item = entry.value;
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: numbered
                          ? Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(12),
                                color: const Color(
                                  0xFF34343A,
                                ).withValues(alpha: 0.5),
                                border: Border.all(
                                  color: Colors.white.withValues(alpha: 0.05),
                                ),
                              ),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: <Widget>[
                                  Text(
                                    '${idx + 1}.',
                                    style: const TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w700,
                                      color: Color(0xFFB9C3FF),
                                    ),
                                  ),
                                  const SizedBox(width: 16),
                                  Expanded(
                                    child: Text(
                                      item,
                                      style: TextStyle(
                                        fontSize: 14,
                                        color: Colors.white.withValues(
                                          alpha: 0.7,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            )
                          : Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: <Widget>[
                                const Padding(
                                  padding: EdgeInsets.only(top: 2),
                                  child: Icon(
                                    Icons.check_circle,
                                    size: 18,
                                    color: Color(0xFF2ADEC0),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Text(
                                    item,
                                    style: const TextStyle(
                                      fontSize: 14,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                    );
                  }),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _helpSection() {
    return Center(
      child: Column(
        children: <Widget>[
          InkWell(
            borderRadius: BorderRadius.circular(20),
            onTap: () => Navigator.pushNamed(context, AppRouter.helpSupport),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                color: const Color(0xFF292A2F).withValues(alpha: 0.5),
                border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  const Icon(
                    Icons.support_agent,
                    size: 16,
                    color: Color(0xFF2ADEC0),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Still have questions?',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.white.withValues(alpha: 0.7),
                    ),
                  ),
                  const SizedBox(width: 8),
                  const Text(
                    'Contact Support',
                    style: TextStyle(
                      fontSize: 14,
                      color: Color(0xFFB9C3FF),
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 48),
          Opacity(
            opacity: 0.3,
            child: Column(
              children: <Widget>[
                const Icon(
                  Icons.shield_outlined,
                  size: 36,
                  color: Colors.white,
                ),
                const SizedBox(height: 8),
                Text(
                  'SECUREVOTE OBSIDIAN PROTOCOL',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 2,
                    color: Colors.white.withValues(alpha: 0.5),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
