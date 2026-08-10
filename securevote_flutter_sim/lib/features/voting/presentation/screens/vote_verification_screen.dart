import 'package:flutter/material.dart';

import '../../../../core/network/api_client.dart';

class VoteVerificationScreen extends StatefulWidget {
  const VoteVerificationScreen({super.key});

  @override
  State<VoteVerificationScreen> createState() => _VoteVerificationScreenState();
}

class _VoteVerificationScreenState extends State<VoteVerificationScreen> {
  String? _receiptId;
  bool _loading = true;
  String? _error;
  Map<String, dynamic>? _result;

  @override
  void initState() {
    super.initState();
    final args = ModalRoute.of(context)?.settings.arguments;
    if (args is Map) {
      _receiptId = args['receiptId'] as String?;
    }
    WidgetsBinding.instance.addPostFrameCallback((_) => _verify());
  }

  Future<void> _verify() async {
    final String receiptId = _receiptId ?? '';
    if (receiptId.isEmpty) {
      setState(() {
        _error = 'No receipt ID provided to verify.';
        _loading = false;
      });
      return;
    }
    try {
      final data = await ApiClient.instance.getApi(
        '/api/public/verify/$receiptId',
      ) as Map<String, dynamic>;
      if (!mounted) return;
      setState(() {
        _result = data;
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = e.toString();
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF08090E),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Verify Vote',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
        ),
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_loading) {
      return const Center(
        child: CircularProgressIndicator(color: Color(0xFF2ADEC0)),
      );
    }

    if (_error != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.error_outline, color: Color(0xFFFF8A80), size: 56),
              const SizedBox(height: 16),
              Text(
                _error!,
                textAlign: TextAlign.center,
                style: const TextStyle(color: Color(0xFFE3E1E9), fontSize: 15),
              ),
              const SizedBox(height: 24),
              OutlinedButton.icon(
                onPressed: _verify,
                icon: const Icon(Icons.refresh, size: 18),
                label: const Text('Retry'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.white,
                  side: BorderSide(color: Colors.white.withOpacity(0.2)),
                ),
              ),
            ],
          ),
        ),
      );
    }

    final bool valid = _result?['valid'] == true;
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Status Banner
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              gradient: LinearGradient(
                colors: valid
                    ? const [Color(0xFF2ADEC0), Color(0xFF1AB89F)]
                    : const [Color(0xFFDC2626), Color(0xFFB91C1C)],
              ),
            ),
            child: Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white.withValues(alpha: 0.2),
                  ),
                  child: Icon(
                    valid ? Icons.verified : Icons.cancel,
                    color: Colors.white,
                    size: 28,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        valid ? 'Vote Verified' : 'Verification Failed',
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w800,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        valid
                            ? 'Your vote is recorded on the blockchain'
                            : 'No valid record found for this receipt',
                        style: const TextStyle(
                          fontSize: 13,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 32),

          // Receipt ID
          const Text(
            'Receipt ID',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: Color(0xFF8E90A0),
              letterSpacing: 1,
            ),
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              color: const Color(0xFF1A1B21),
              border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
            ),
            child: Text(
              _result?['receiptId'] as String? ?? _receiptId ?? 'N/A',
              style: const TextStyle(
                fontSize: 16,
                fontFamily: 'monospace',
                color: Colors.white,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          const SizedBox(height: 32),

          // Blockchain Verification
          const Text(
            'Blockchain Verification',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 16),

          _buildVerificationStep(
            Icons.check_circle,
            'Election',
            _result?['electionTitle'] as String? ?? 'Election',
            true,
          ),
          _buildVerificationStep(
            valid ? Icons.check_circle : Icons.cancel,
            'Merkle Proof Value',
            _result?['voteHash'] as String? ?? 'N/A',
            valid,
          ),
          _buildVerificationStep(
            valid ? Icons.check_circle : Icons.cancel,
            'Transaction Hash',
            _result?['txHash'] as String? ?? 'N/A',
            valid,
          ),
          _buildVerificationStep(
            valid ? Icons.check_circle : Icons.cancel,
            'Block Number',
            _result?['blockNumber'] != null
                ? '#${_result!['blockNumber']}'
                : 'N/A',
            valid,
          ),
          _buildVerificationStep(
            valid ? Icons.check_circle : Icons.cancel,
            'Verified At',
            _formatVerifiedAt(_result?['verifiedAt']),
            valid,
          ),

          const SizedBox(height: 32),

          // Merkle Tree Visualization
          const Text(
            'Merkle Proof Path',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 16),

          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              color: const Color(0xFF1A1B21),
              border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
            ),
            child: Column(
              children: [
                _buildMerkleNode(
                  'Root Hash',
                  _result?['voteHash'] as String? ?? 'N/A',
                  true,
                ),
                _buildMerkleLine(),
                Row(
                  children: [
                    Expanded(
                      child: _buildMerkleNode(
                        'Branch',
                        _result?['voteHash'] as String? ?? 'N/A',
                        false,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: _buildMerkleNode(
                        'Branch',
                        _result?['voteHash'] as String? ?? 'N/A',
                        false,
                      ),
                    ),
                  ],
                ),
                _buildMerkleLine(),
                Row(
                  children: [
                    Expanded(
                      child: _buildMerkleNode('Leaf', '…', false),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: _buildMerkleNode(
                        'Your Vote',
                        _result?['voteHash'] as String? ?? 'N/A',
                        true,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: _buildMerkleNode('Leaf', '…', false),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: _buildMerkleNode('Leaf', '…', false),
                    ),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(height: 32),

          // Info Box
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              color: const Color(0xFFB9C3FF).withValues(alpha: 0.1),
              border: Border.all(
                color: const Color(0xFFB9C3FF).withValues(alpha: 0.2),
              ),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(
                  Icons.info_outline,
                  color: Color(0xFFB9C3FF),
                  size: 20,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    valid
                        ? 'This cryptographic proof ensures your vote was counted without revealing your identity or choice.'
                        : 'The receipt could not be verified on the ledger. Please double-check the receipt ID and try again.',
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.white.withValues(alpha: 0.8),
                      height: 1.5,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildVerificationStep(
    IconData icon,
    String title,
    String value,
    bool verified,
  ) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        children: [
          Icon(
            icon,
            color: verified ? const Color(0xFF2ADEC0) : const Color(0xFF8E90A0),
            size: 24,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.white.withValues(alpha: 0.6),
                    fontFamily: 'monospace',
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMerkleNode(String label, String hash, bool highlighted) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        color: highlighted
            ? const Color(0xFF2ADEC0).withValues(alpha: 0.1)
            : const Color(0xFF0D0E13),
        border: Border.all(
          color: highlighted
              ? const Color(0xFF2ADEC0).withValues(alpha: 0.3)
              : Colors.white.withValues(alpha: 0.05),
        ),
      ),
      child: Column(
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w700,
              color: highlighted
                  ? const Color(0xFF2ADEC0)
                  : Colors.white.withValues(alpha: 0.5),
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            hash,
            style: TextStyle(
              fontSize: 8,
              fontFamily: 'monospace',
              color: Colors.white.withValues(alpha: 0.7),
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _buildMerkleLine() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: List.generate(
          3,
          (index) => Container(
            width: 2,
            height: 16,
            margin: const EdgeInsets.symmetric(horizontal: 4),
            color: Colors.white.withValues(alpha: 0.2),
          ),
        ),
      ),
    );
  }

  String _formatVerifiedAt(dynamic value) {
    if (value == null) return 'N/A';
    if (value is int) {
      final DateTime dt =
          DateTime.fromMillisecondsSinceEpoch(value).toLocal();
      return dt.toIso8601String();
    }
    return value.toString();
  }
}