import 'package:flutter/material.dart';

class VoteReceiptScreen extends StatelessWidget {
  const VoteReceiptScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF08090E),
      appBar: AppBar(
        backgroundColor: const Color(0xFF08090E).withOpacity(0.6),
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
                    border: Border.all(color: Colors.white.withOpacity(0.2)),
                    color: Colors.white.withOpacity(0.05),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            // Verified Hero Banner
            Container(
              padding: const EdgeInsets.all(32),
              decoration: BoxDecoration(
                color: const Color(0xFF161A24),
                border: Border.all(color: Colors.white.withOpacity(0.07)),
                borderRadius: BorderRadius.circular(24),
              ),
              child: Column(
                children: [
                  Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      color: const Color(0xFF00D2B4).withOpacity(0.1),
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: const Color(0xFF00D2B4).withOpacity(0.2),
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF00D2B4).withOpacity(0.2),
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
                _buildDetailRow('Title', '2024 General Council Vote'),
                _buildDetailRow(
                  'Reference',
                  'EV-2024-QX-99',
                  isMonospace: true,
                  color: const Color(0xFF4F6EF7),
                ),
                _buildDetailRowWithBadge('Status', 'Finalized'),
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
                _buildReceiptField('Receipt ID', 'RC-8821-X99-L0'),
                const SizedBox(height: 16),
                _buildReceiptField(
                  'Transaction Hash',
                  '0x71C7656EC7ab88b098defB751B7401B5f6d8976F...5d8976F',
                  isLong: true,
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: const [
                    Text(
                      'Recorded At',
                      style: TextStyle(color: Color(0xFF8B93B0), fontSize: 11),
                    ),
                    Text(
                      'Oct 24, 2024 • 14:32:01 UTC',
                      style: TextStyle(
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
                border: Border.all(color: Colors.white.withOpacity(0.07)),
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
                          color: Colors.white.withOpacity(0.05),
                          border: Border.all(
                            color: Colors.white.withOpacity(0.1),
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
                    'Merkle Root',
                    '0x9f2...3e1',
                    const Color(0xFF00D2B4),
                    true,
                  ),
                  _buildConnector(),
                  _buildMerkleNode(
                    'Internal Node',
                    '0x4a1...d82',
                    const Color(0xFF4F6EF7),
                    false,
                  ),
                  _buildConnector(),
                  _buildMerkleNode(
                    'Your Hash',
                    '0x882...L0X',
                    const Color(0xFF4F6EF7),
                    true,
                    isUser: true,
                  ),
                  const SizedBox(height: 24),
                  const Text(
                    '"SecureVote uses zero-knowledge proofs to ensure your choice remains private while mathematically proving its inclusion."',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Color(0xFF8B93B0),
                      fontSize: 10,
                      fontStyle: FontStyle.italic,
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
                onPressed: () {},
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF4F6EF7),
                  foregroundColor: Colors.white,
                  elevation: 10,
                  shadowColor: const Color(0xFF4F6EF7).withOpacity(0.4),
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
                onPressed: () {},
                icon: const Icon(Icons.share, size: 18),
                label: const Text('Share Proof Link'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.white,
                  side: BorderSide(color: Colors.white.withOpacity(0.1)),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 40),
          ],
        ),
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
        border: Border.all(color: Colors.white.withOpacity(0.07)),
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
          Text(
            value,
            style: TextStyle(
              color: color ?? Colors.white,
              fontSize: 14,
              fontWeight: FontWeight.bold,
              fontFamily: isMonospace ? 'monospace' : null,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRowWithBadge(String label, String value) {
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
              color: const Color(0xFF00D2B4).withOpacity(0.2),
              border: Border.all(
                color: const Color(0xFF00D2B4).withOpacity(0.2),
              ),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              children: [
                Container(
                  width: 6,
                  height: 6,
                  decoration: const BoxDecoration(
                    color: Color(0xFF00D2B4),
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 6),
                Text(
                  value.toUpperCase(),
                  style: const TextStyle(
                    color: Color(0xFF00D2B4),
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
            color: Colors.black.withOpacity(0.2),
            border: Border.all(color: Colors.white.withOpacity(0.1)),
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
                  color: const Color(0xFF8B93B0).withOpacity(0.5),
                  size: 18,
                ),
              ] else ...[
                const SizedBox(width: 8),
                Icon(
                  Icons.open_in_new,
                  color: const Color(0xFF8B93B0).withOpacity(0.5),
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
            color: isUser ? color : color.withOpacity(0.1),
            border: Border.all(
              color: color.withOpacity(0.3),
              width: isUser ? 4 : 1,
            ),
            borderRadius: BorderRadius.circular(isLarge ? 16 : 12),
            boxShadow: isUser
                ? [
                    BoxShadow(
                      color: color.withOpacity(0.3),
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
        Text(
          hash,
          style: TextStyle(
            color: isUser
                ? Colors.white
                : const Color(0xFF8B93B0).withOpacity(0.5),
            fontSize: 10,
            fontFamily: 'monospace',
          ),
        ),
      ],
    );
  }

  Widget _buildConnector() {
    return Container(
      width: 1,
      height: 48,
      margin: const EdgeInsets.symmetric(vertical: 16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            const Color(0xFF4F6EF7).withOpacity(0),
            const Color(0xFF4F6EF7),
            const Color(0xFF4F6EF7).withOpacity(0),
          ],
        ),
      ),
    );
  }
}
