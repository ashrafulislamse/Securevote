import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../core/navigation/app_router.dart';

class VoteDetailModal extends StatelessWidget {
  final Map<String, dynamic> vote;

  const VoteDetailModal({super.key, required this.vote});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.85,
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
                  'Vote Details',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
                const Spacer(),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
          ),

          // Content
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Status Badge
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                      color: (vote['statusColor'] as Color).withValues(
                        alpha: 0.1,
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (vote['verified'] as bool)
                          Icon(
                            Icons.verified,
                            size: 14,
                            color: vote['statusColor'] as Color,
                          ),
                        if (vote['verified'] as bool) const SizedBox(width: 4),
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
                  const SizedBox(height: 16),

                  // Title
                  Text(
                    vote['title'] as String,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    vote['organization'] as String,
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.white.withValues(alpha: 0.6),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Info Cards
                  _buildInfoCard(
                    'Date Cast',
                    vote['date'] as String,
                    Icons.calendar_today,
                  ),
                  const SizedBox(height: 12),
                  _buildInfoCard(
                    'Receipt ID',
                    vote['receipt'] as String,
                    Icons.receipt_long,
                    isCopyable: true,
                  ),
                  const SizedBox(height: 12),
                  _buildInfoCard(
                    'Verification',
                    (vote['verified'] as bool)
                        ? 'Blockchain Confirmed'
                        : 'Pending Confirmation',
                    Icons.verified,
                  ),
                  const SizedBox(height: 24),

                  // Actions
                  const Text(
                    'Actions',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 16),

                  _buildActionButton(
                    'View Full Receipt',
                    Icons.receipt_long,
                    () {
                      Navigator.pop(context);
                      final dynamic voteModel = vote['voteModel'];
                      Navigator.pushNamed(
                        context,
                        AppRouter.voteReceipt,
                        arguments: voteModel != null
                            ? <String, dynamic>{'vote': voteModel}
                            : <String, dynamic>{
                                'receiptId': vote['receipt'] as String,
                              },
                      );
                    },
                  ),
                  const SizedBox(height: 12),
                  _buildActionButton(
                    'Verify on Blockchain',
                    Icons.verified,
                    () {
                      Navigator.pop(context);
                      Navigator.pushNamed(
                        context,
                        AppRouter.voteVerification,
                        arguments: <String, dynamic>{
                          'receiptId': vote['receipt'] as String,
                        },
                      );
                    },
                  ),
                  const SizedBox(height: 12),
                  _buildActionButton(
                    'View Election Results',
                    Icons.bar_chart,
                    () {
                      Navigator.pop(context);
                      final Object? electionId = vote['electionId'];
                      Navigator.pushNamed(
                        context,
                        AppRouter.electionResults,
                        arguments: electionId != null
                            ? <String, dynamic>{'electionId': electionId}
                            : null,
                      );
                    },
                  ),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoCard(
    String label,
    String value,
    IconData icon, {
    bool isCopyable = false,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: const Color(0xFF1A1B21),
        border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
      ),
      child: Row(
        children: [
          Icon(icon, color: const Color(0xFFB9C3FF), size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.white.withValues(alpha: 0.5),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
          if (isCopyable)
            Builder(
              builder: (context) => IconButton(
                icon: const Icon(Icons.copy, size: 18),
                color: Colors.white.withValues(alpha: 0.5),
                onPressed: () {
                  Clipboard.setData(ClipboardData(text: value));
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Copied to clipboard'),
                      duration: Duration(seconds: 2),
                    ),
                  );
                },
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildActionButton(String label, IconData icon, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          color: const Color(0xFF1A1B21),
          border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
        ),
        child: Row(
          children: [
            Icon(icon, color: const Color(0xFFB9C3FF), size: 20),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                label,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
            ),
            Icon(
              Icons.chevron_right,
              color: Colors.white.withValues(alpha: 0.3),
            ),
          ],
        ),
      ),
    );
  }
}
