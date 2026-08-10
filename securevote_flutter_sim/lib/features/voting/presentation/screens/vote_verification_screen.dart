import 'package:flutter/material.dart';

class VoteVerificationScreen extends StatelessWidget {
  const VoteVerificationScreen({super.key});

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
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Status Banner
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                gradient: const LinearGradient(
                  colors: [Color(0xFF2ADEC0), Color(0xFF1AB89F)],
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
                    child: const Icon(
                      Icons.verified,
                      color: Colors.white,
                      size: 28,
                    ),
                  ),
                  const SizedBox(width: 16),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Vote Verified',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w800,
                            color: Colors.white,
                          ),
                        ),
                        SizedBox(height: 4),
                        Text(
                          'Your vote is recorded on the blockchain',
                          style: TextStyle(fontSize: 13, color: Colors.white),
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
              child: const Text(
                'SV-2024-X99-442-B018-K4L',
                style: TextStyle(
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
              'Block Confirmed',
              'Block #847392',
              true,
            ),
            _buildVerificationStep(
              Icons.check_circle,
              'Merkle Proof Valid',
              '0x8f3c...f92a',
              true,
            ),
            _buildVerificationStep(
              Icons.check_circle,
              'Timestamp Verified',
              'Nov 05, 2024 14:32:01 UTC',
              true,
            ),
            _buildVerificationStep(
              Icons.check_circle,
              'Network Consensus',
              '1,247 confirmations',
              true,
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
                  _buildMerkleNode('Root Hash', '0xa7f2...3d9e', true),
                  _buildMerkleLine(),
                  Row(
                    children: [
                      Expanded(
                        child: _buildMerkleNode(
                          'Branch',
                          '0x4b8c...1f2a',
                          false,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: _buildMerkleNode(
                          'Branch',
                          '0x9e3d...7c5b',
                          false,
                        ),
                      ),
                    ],
                  ),
                  _buildMerkleLine(),
                  Row(
                    children: [
                      Expanded(
                        child: _buildMerkleNode('Leaf', '0x2f1a...8d4c', false),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: _buildMerkleNode(
                          'Your Vote',
                          '0x8f3c...f92a',
                          true,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: _buildMerkleNode('Leaf', '0x6c9b...3e7f', false),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: _buildMerkleNode('Leaf', '0x1d5e...9a2b', false),
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
                      'This cryptographic proof ensures your vote was counted without revealing your identity or choice.',
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
              fontSize: 9,
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
}
