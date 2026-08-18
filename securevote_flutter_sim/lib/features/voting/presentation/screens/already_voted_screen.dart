import 'package:flutter/material.dart';

import '../../../../core/models/vote.dart';
import '../../../../core/navigation/app_router.dart';

class AlreadyVotedScreen extends StatelessWidget {
  const AlreadyVotedScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final Object? args = ModalRoute.of(context)?.settings.arguments;
    Vote? vote;
    String? receiptId;
    if (args is Map) {
      final v = args['vote'];
      if (v is Vote) {
        vote = v;
      }
      final r = args['receiptId'];
      if (r is String) {
        receiptId = r;
      }
    }

    final String displayReceipt = vote?.receiptId ?? receiptId ?? '';

    return Scaffold(
      backgroundColor: const Color(0xFF08090E),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Icon
              Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: const Color(0xFFFBBF24).withValues(alpha: 0.1),
                  border: Border.all(
                    color: const Color(0xFFFBBF24).withValues(alpha: 0.3),
                    width: 2,
                  ),
                ),
                child: const Icon(
                  Icons.how_to_vote,
                  size: 60,
                  color: Color(0xFFFBBF24),
                ),
              ),
              const SizedBox(height: 32),

              // Title
              const Text(
                'Already Voted',
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.w800,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 12),

              // Message
              Text(
                'You have already cast your vote in this election. Each voter can only vote once per election.',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.white.withValues(alpha: 0.7),
                  height: 1.6,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),

              // Info Card (only when real data is available)
              if (vote != null || receiptId != null) ...[
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
                    children: [
                      if (vote != null)
                        _buildInfoRow('Vote Cast', _formatDate(vote.createdAt)),
                      if (vote != null) const SizedBox(height: 12),
                      if (displayReceipt.isNotEmpty)
                        _buildInfoRow('Receipt ID', displayReceipt),
                      if (displayReceipt.isNotEmpty) const SizedBox(height: 12),
                      if (vote != null)
                        _buildInfoRow(
                          'Status',
                          (vote.txHash != null && vote.blockNumber != null)
                              ? 'Verified on Blockchain (Block #${vote.blockNumber})'
                              : 'Vote recorded — pending blockchain confirmation',
                        ),
                    ],
                  ),
                ),
                const SizedBox(height: 32),
              ],

              // View Receipt Button
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton.icon(
                  onPressed: () {
                    if (vote != null) {
                      Navigator.pushNamed(
                        context,
                        AppRouter.voteReceipt,
                        arguments: <String, dynamic>{'vote': vote},
                      );
                    } else if (receiptId != null) {
                      Navigator.pushNamed(
                        context,
                        AppRouter.voteVerification,
                        arguments: <String, dynamic>{'receiptId': receiptId},
                      );
                    } else {
                      Navigator.pushNamed(context, AppRouter.voteReceipt);
                    }
                  },
                  icon: const Icon(Icons.receipt_long, size: 20),
                  label: Text(
                    displayReceipt.isNotEmpty
                        ? 'View Receipt'
                        : 'Verify Receipt',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
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

              // View Results Button
              SizedBox(
                width: double.infinity,
                height: 56,
                child: OutlinedButton.icon(
                  onPressed: () {
                    Navigator.pushNamed(
                      context,
                      AppRouter.electionResults,
                      arguments: <String, dynamic>{
                        if (vote != null) 'electionId': vote.electionId,
                      },
                    );
                  },
                  icon: const Icon(Icons.bar_chart, size: 20),
                  label: const Text(
                    'View Results',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
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
              const SizedBox(height: 12),

              // Go Back
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text(
                  'Go Back',
                  style: TextStyle(fontSize: 16, color: Color(0xFF8E90A0)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 14,
            color: Colors.white.withValues(alpha: 0.6),
          ),
        ),
        Flexible(
          child: Text(
            value,
            textAlign: TextAlign.end,
            overflow: TextOverflow.ellipsis,
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

  String _formatDate(DateTime dt) {
    const List<String> months = <String>[
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
    final DateTime local = dt.toLocal();
    String two(int v) => v.toString().padLeft(2, '0');
    return '${months[local.month - 1]} ${two(local.day)}, ${local.year} '
        '${two(local.hour)}:${two(local.minute)} UTC';
  }
}
