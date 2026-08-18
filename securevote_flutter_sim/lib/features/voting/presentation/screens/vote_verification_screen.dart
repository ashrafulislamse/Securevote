import 'package:flutter/material.dart';

import '../../../../core/models/receipt_verification.dart';
import '../../../../features/voting/data/voting_repository.dart';

class VoteVerificationScreen extends StatefulWidget {
  const VoteVerificationScreen({super.key});

  @override
  State<VoteVerificationScreen> createState() => _VoteVerificationScreenState();
}

class _VoteVerificationScreenState extends State<VoteVerificationScreen> {
  String? _receiptId;
  bool _loading = true;
  String? _error;
  ReceiptVerification? _result;

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
      final verification = await VotingRepository().verifyReceipt(receiptId);
      if (!mounted) return;
      setState(() {
        _result = verification;
        _loading = false;
      });
    } on Exception catch (e) {
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
              const Icon(
                Icons.error_outline,
                color: Color(0xFFFF8A80),
                size: 56,
              ),
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
                  side: BorderSide(color: Colors.white.withValues(alpha: 0.2)),
                ),
              ),
            ],
          ),
        ),
      );
    }

    final ReceiptVerification result = _result!;
    final bool valid = result.valid;
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
              result.receiptId.isNotEmpty
                  ? result.receiptId
                  : (_receiptId ?? 'N/A'),
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
            result.electionTitle ?? 'Election',
            true,
          ),
          _buildVerificationStep(
            valid ? Icons.check_circle : Icons.cancel,
            'Merkle Proof Value',
            result.voteHash ?? 'N/A',
            valid,
          ),
          _buildVerificationStep(
            valid ? Icons.check_circle : Icons.cancel,
            'Transaction Hash',
            result.txHash ?? 'N/A',
            valid,
          ),
          _buildVerificationStep(
            valid ? Icons.check_circle : Icons.cancel,
            'Block Number',
            result.blockNumber != null ? '#${result.blockNumber}' : 'N/A',
            valid,
          ),
          _buildVerificationStep(
            valid ? Icons.check_circle : Icons.cancel,
            'Verified At',
            _formatVerifiedAt(result.verifiedAt),
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
            child: result.merkleProof.isEmpty
                ? _buildNoProofAvailable()
                : _buildMerklePath(result),
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

  Widget _buildMerklePath(ReceiptVerification result) {
    final List<Widget> nodes = <Widget>[];
    // Merkle Root at the top of the path.
    nodes.add(
      _buildMerkleNode('Merkle Root', result.merkleRoot ?? 'N/A', true),
    );
    // Each proof hash as an intermediate step.
    for (int i = 0; i < result.merkleProof.length; i++) {
      nodes.add(_buildMerkleLine());
      nodes.add(
        _buildMerkleNode('Proof Step ${i + 1}', result.merkleProof[i], false),
      );
    }
    // Your vote hash as the leaf at the bottom.
    nodes.add(_buildMerkleLine());
    nodes.add(_buildMerkleNode('Your Hash', result.voteHash ?? 'N/A', true));
    return Column(children: nodes);
  }

  Widget _buildNoProofAvailable() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 24),
      child: Column(
        children: <Widget>[
          const Icon(Icons.info_outline, color: Color(0xFF8E90A0), size: 32),
          const SizedBox(height: 12),
          const Text(
            'No proof available',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Color(0xFFC4C5D7),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Proof data will be available after the election closes.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 12,
              color: Colors.white.withValues(alpha: 0.5),
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }

  String _formatVerifiedAt(dynamic value) {
    if (value == null) return 'N/A';
    if (value is int) {
      final DateTime dt = DateTime.fromMillisecondsSinceEpoch(value).toLocal();
      return dt.toIso8601String();
    }
    return value.toString();
  }
}
