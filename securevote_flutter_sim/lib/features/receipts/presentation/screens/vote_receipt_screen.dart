import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../core/models/vote.dart';

class VoteReceiptScreen extends StatefulWidget {
  const VoteReceiptScreen({super.key});

  @override
  State<VoteReceiptScreen> createState() => _VoteReceiptScreenState();
}

class _VoteReceiptScreenState extends State<VoteReceiptScreen> {
  Vote? _vote;

  @override
  void initState() {
    super.initState();
    final args = ModalRoute.of(context)?.settings.arguments;
    if (args is Map) {
      final vote = args['vote'];
      if (vote is Vote) {
        _vote = vote;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF08090E),
      appBar: AppBar(
        backgroundColor: const Color(0xFF08090E).withValues(alpha: 0.6),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'SecureVote',
          style: TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 20),
            child: Row(
              children: [
                Icon(Icons.verified, color: Color(0xFF00D2B4), size: 20),
                const SizedBox(width: 8),
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: Colors.white.withValues(alpha: 0.2),
                    ),
                    color: Colors.white.withValues(alpha: 0.05),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      body: _vote == null ? _buildEmptyState() : _buildReceipt(_vote!),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.receipt_long, color: Color(0xFF8B93B0), size: 56),
            const SizedBox(height: 16),
            const Text(
              'No receipt data available.',
              style: TextStyle(color: Color(0xFF8B93B0), fontSize: 16),
            ),
            const SizedBox(height: 24),
            OutlinedButton.icon(
              onPressed: () => Navigator.pop(context),
              icon: const Icon(Icons.arrow_back, size: 18),
              label: const Text('Go Back'),
              style: OutlinedButton.styleFrom(
                foregroundColor: Colors.white,
                side: BorderSide(color: Colors.white.withValues(alpha: 0.2)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildReceipt(Vote vote) {
    final String electionTitle = vote.electionTitle ?? 'Election';
    final String voteHash = vote.voteHash ?? 'Pending on-chain confirmation';
    final String txHash = vote.txHash ?? 'Pending';
    final String blockNumber = vote.blockNumber != null
        ? '#${vote.blockNumber}'
        : 'Pending';

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          // Verified Hero Banner
          Container(
            padding: const EdgeInsets.all(32),
            decoration: BoxDecoration(
              color: const Color(0xFF161A24),
              border: Border.all(color: Colors.white.withValues(alpha: 0.07)),
              borderRadius: BorderRadius.circular(24),
            ),
            child: Column(
              children: [
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    color: const Color(0xFF00D2B4).withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: const Color(0xFF00D2B4).withValues(alpha: 0.2),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF00D2B4).withValues(alpha: 0.2),
                        blurRadius: 25,
                        spreadRadius: 5,
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.check_circle,
                    color: Color(0xFF00D2B4),
                    size: 40,
                  ),
                ),
                const SizedBox(height: 24),
                const Text(
                  'Vote Authenticated',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Your digital signature is verified and secured on the distributed ledger.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Color(0xFF8B93B0),
                    fontSize: 14,
                    height: 1.5,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // Election Card
          _buildDetailCard(
            context,
            'Election Identity',
            Icons.ballot,
            const Color(0xFF4F6EF7),
            [
              _buildDetailRow('Title', electionTitle),
              _buildDetailRow(
                'Reference',
                vote.electionId,
                isMonospace: true,
                color: const Color(0xFF4F6EF7),
              ),
              _buildDetailRowWithBadge(
                'Status',
                vote.txHash != null
                    ? 'Finalized on Blockchain'
                    : 'Recorded — pending finalization',
                badgeColor: vote.txHash != null
                    ? const Color(0xFF00D2B4)
                    : const Color(0xFFFBBF24),
              ),
            ],
          ),

          const SizedBox(height: 16),

          // Receipt Card
          _buildDetailCard(
            context,
            'Receipt Artifact',
            Icons.token,
            const Color(0xFF4F6EF7),
            [
              _buildReceiptField('Receipt ID', vote.receiptId),
              const SizedBox(height: 16),
              _buildReceiptField('Transaction Hash', txHash, isLong: true),
              const SizedBox(height: 16),
              _buildReceiptField('Block Number', blockNumber, isLong: true),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Recorded At',
                    style: TextStyle(color: Color(0xFF8B93B0), fontSize: 11),
                  ),
                  Text(
                    _formatTimestamp(vote.createdAt),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 11,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ],
          ),

          const SizedBox(height: 16),

          // Merkle Proof Card
          Container(
            padding: const EdgeInsets.all(32),
            decoration: BoxDecoration(
              color: const Color(0xFF161A24),
              border: Border.all(color: Colors.white.withValues(alpha: 0.07)),
              borderRadius: BorderRadius.circular(32),
            ),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: const [
                        Icon(
                          Icons.verified_user,
                          color: Color(0xFF00D2B4),
                          size: 20,
                        ),
                        SizedBox(width: 12),
                        Text(
                          'INTEGRITY PATH',
                          style: TextStyle(
                            color: Color(0xFF8B93B0),
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1.5,
                          ),
                        ),
                      ],
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.05),
                        border: Border.all(
                          color: Colors.white.withValues(alpha: 0.1),
                        ),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: const Text(
                        'LAYER-2 PROOF',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 9,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1.2,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 40),
                _buildMerkleNode(
                  'Your Hash',
                  voteHash,
                  const Color(0xFF4F6EF7),
                  true,
                  isUser: true,
                ),
                const SizedBox(height: 24),
                const Text(
                  'Proof data will be available after election closes.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Color(0xFF8B93B0),
                    fontSize: 12,
                    height: 1.5,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 48),

          // Action Buttons
          SizedBox(
            width: double.infinity,
            height: 56,
            child: ElevatedButton(
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Receipt saved to device'),
                    duration: Duration(seconds: 2),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF4F6EF7),
                foregroundColor: Colors.white,
                elevation: 10,
                shadowColor: const Color(0xFF4F6EF7).withValues(alpha: 0.4),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text(
                'Download Official Receipt',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
              ),
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            height: 56,
            child: OutlinedButton.icon(
              onPressed: () {
                final String receipt = vote.receiptId;
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      'Verify my vote: receipt ID $receipt',
                      style: const TextStyle(
                        fontFamily: 'monospace',
                        fontSize: 12,
                      ),
                    ),
                    duration: const Duration(seconds: 5),
                    action: SnackBarAction(
                      label: 'Copy',
                      textColor: const Color(0xFFB9C3FF),
                      onPressed: () {
                        Clipboard.setData(
                          ClipboardData(
                            text: 'Verify my vote: receipt ID $receipt',
                          ),
                        );
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Proof link copied to clipboard'),
                            duration: Duration(seconds: 2),
                          ),
                        );
                      },
                    ),
                  ),
                );
              },
              icon: const Icon(Icons.share, size: 18),
              label: const Text('Share Proof Link'),
              style: OutlinedButton.styleFrom(
                foregroundColor: Colors.white,
                side: BorderSide(color: Colors.white.withValues(alpha: 0.1)),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),

          const SizedBox(height: 40),
        ],
      ),
    );
  }

  Widget _buildDetailCard(
    BuildContext context,
    String title,
    IconData icon,
    Color iconColor,
    List<Widget> children,
  ) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: const Color(0xFF161A24),
        border: Border.all(color: Colors.white.withValues(alpha: 0.07)),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: iconColor, size: 20),
              const SizedBox(width: 12),
              Text(
                title.toUpperCase(),
                style: const TextStyle(
                  color: Color(0xFF8B93B0),
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.5,
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          ...children,
        ],
      ),
    );
  }

  Widget _buildDetailRow(
    String label,
    String value, {
    bool isMonospace = false,
    Color? color,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(color: Color(0xFF8B93B0), fontSize: 12),
          ),
          Flexible(
            child: Text(
              value,
              textAlign: TextAlign.end,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: color ?? Colors.white,
                fontSize: 14,
                fontWeight: FontWeight.bold,
                fontFamily: isMonospace ? 'monospace' : null,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRowWithBadge(
    String label,
    String value, {
    Color? badgeColor,
  }) {
    final Color color = badgeColor ?? const Color(0xFF00D2B4);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(color: Color(0xFF8B93B0), fontSize: 12),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.2),
              border: Border.all(color: color.withValues(alpha: 0.2)),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              children: [
                Container(
                  width: 6,
                  height: 6,
                  decoration: BoxDecoration(
                    color: color,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 6),
                Text(
                  value.toUpperCase(),
                  style: TextStyle(
                    color: color,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.2,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReceiptField(String label, String value, {bool isLong = false}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label.toUpperCase(),
          style: const TextStyle(
            color: Color(0xFF8B93B0),
            fontSize: 10,
            fontWeight: FontWeight.bold,
            letterSpacing: 1.2,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.black.withValues(alpha: 0.2),
            border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  value,
                  style: TextStyle(
                    color: isLong
                        ? const Color(0xFF8B93B0)
                        : const Color(0xFF4F6EF7),
                    fontSize: isLong ? 10 : 14,
                    fontFamily: 'monospace',
                    height: 1.5,
                  ),
                ),
              ),
              if (!isLong) ...[
                const SizedBox(width: 8),
                Icon(
                  Icons.content_copy,
                  color: const Color(0xFF8B93B0).withValues(alpha: 0.5),
                  size: 18,
                ),
              ] else ...[
                const SizedBox(width: 8),
                Icon(
                  Icons.open_in_new,
                  color: const Color(0xFF8B93B0).withValues(alpha: 0.5),
                  size: 18,
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildMerkleNode(
    String label,
    String hash,
    Color color,
    bool isLarge, {
    bool isUser = false,
  }) {
    return Column(
      children: [
        Container(
          width: isLarge ? 64 : 40,
          height: isLarge ? 64 : 40,
          decoration: BoxDecoration(
            color: isUser ? color : color.withValues(alpha: 0.1),
            border: Border.all(
              color: color.withValues(alpha: 0.3),
              width: isUser ? 4 : 1,
            ),
            borderRadius: BorderRadius.circular(isLarge ? 16 : 12),
            boxShadow: isUser
                ? [
                    BoxShadow(
                      color: color.withValues(alpha: 0.3),
                      blurRadius: 20,
                      spreadRadius: 2,
                    ),
                  ]
                : null,
          ),
          child: Icon(
            isUser
                ? Icons.how_to_reg
                : isLarge
                ? Icons.workspace_premium
                : Icons.mediation,
            color: isUser ? Colors.white : color,
            size: isLarge ? 32 : 18,
          ),
        ),
        const SizedBox(height: 12),
        Text(
          label.toUpperCase(),
          style: TextStyle(
            color: isUser ? color : const Color(0xFF8B93B0),
            fontSize: 9,
            fontWeight: FontWeight.bold,
            letterSpacing: 1.5,
          ),
        ),
        const SizedBox(height: 4),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: Text(
            hash,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: isUser
                  ? Colors.white
                  : const Color(0xFF8B93B0).withValues(alpha: 0.5),
              fontSize: 10,
              fontFamily: 'monospace',
            ),
          ),
        ),
      ],
    );
  }

  String _formatTimestamp(DateTime dt) {
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
        '• ${two(local.hour)}:${two(local.minute)}:${two(local.second)} UTC';
  }
}
