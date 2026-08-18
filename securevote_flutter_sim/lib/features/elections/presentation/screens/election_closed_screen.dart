import 'package:flutter/material.dart';

import '../../../../core/models/election.dart';
import '../../../../core/navigation/app_router.dart';

class ElectionClosedScreen extends StatelessWidget {
  const ElectionClosedScreen({super.key});

  Election? _election(BuildContext context) {
    final Object? args = ModalRoute.of(context)?.settings.arguments;
    if (args is Election) return args;
    if (args is Map) {
      final Object? e = args['election'];
      if (e is Election) return e;
    }
    return null;
  }

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

  static String _formatDate(DateTime d) {
    final List<String> months = _months;
    return '${months[d.month - 1]} ${d.day}, ${d.year}';
  }

  @override
  Widget build(BuildContext context) {
    final Election? election = _election(context);
    final String title = election?.title ?? 'Election Closed';
    final String organization = election?.organization ?? 'SecureVote Election';
    final String endDate = election != null
        ? _formatDate(election.endsAt)
        : 'the scheduled end date';

    return Scaffold(
      backgroundColor: const Color(0xFF08090E),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                const SizedBox(height: 40),
                // Icon
                Container(
                  width: 120,
                  height: 120,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: const Color(0xFF8E90A0).withValues(alpha: 0.1),
                    border: Border.all(
                      color: const Color(0xFF8E90A0).withValues(alpha: 0.3),
                      width: 2,
                    ),
                  ),
                  child: const Icon(
                    Icons.event_busy,
                    size: 60,
                    color: Color(0xFF8E90A0),
                  ),
                ),
                const SizedBox(height: 32),

                // Title
                Text(
                  title,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 12),

                // Message
                Text(
                  'This election has ended and is no longer accepting votes. The voting period closed on $endDate.',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.white.withValues(alpha: 0.7),
                    height: 1.6,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 32),

                // Info Card
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    color: const Color(0xFF1A1B21),
                    border: Border.all(
                      color: Colors.white.withValues(alpha: 0.05),
                    ),
                  ),
                  child: Column(
                    children: <Widget>[
                      _buildInfoRow('Organization', organization),
                      const SizedBox(height: 12),
                      _buildInfoRow('End Date', endDate),
                      const SizedBox(height: 12),
                      _buildInfoRow('Status', 'Results Available'),
                    ],
                  ),
                ),
                const SizedBox(height: 32),

                // View Results Button
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton.icon(
                    onPressed: () {
                      Navigator.pushNamed(
                        context,
                        AppRouter.electionResults,
                        arguments: election,
                      );
                    },
                    icon: const Icon(Icons.bar_chart, size: 20),
                    label: const Text(
                      'View Results',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFB9C3FF),
                      foregroundColor: const Color(0xFF001257),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 12),

                // Browse Elections Button
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: OutlinedButton.icon(
                    onPressed: () {
                      Navigator.pushNamed(context, AppRouter.electionSearch);
                    },
                    icon: const Icon(Icons.search, size: 20),
                    label: const Text(
                      'Browse Active Elections',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.white,
                      side: BorderSide(
                        color: Colors.white.withValues(alpha: 0.2),
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
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

  Widget _buildInfoRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: <Widget>[
        Flexible(
          child: Text(
            label,
            style: TextStyle(
              fontSize: 14,
              color: Colors.white.withValues(alpha: 0.6),
            ),
          ),
        ),
        const SizedBox(width: 16),
        Flexible(
          child: Text(
            value,
            textAlign: TextAlign.right,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
        ),
      ],
    );
  }
}
