import 'package:flutter/material.dart';
import 'dart:math' as math;

import '../../../../core/errors/api_exception.dart';
import '../../../../core/models/election.dart';
import '../../../../core/models/vote.dart';
import '../../../../core/navigation/app_router.dart';
import '../../../../features/voting/data/voting_repository.dart';

class VoteSuccessScreen extends StatefulWidget {
  const VoteSuccessScreen({super.key});

  @override
  State<VoteSuccessScreen> createState() => _VoteSuccessScreenState();
}

class _VoteSuccessScreenState extends State<VoteSuccessScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  Election? _election;
  List<Map<String, String>> _selections = <Map<String, String>>[];

  Vote? _vote;
  bool _casting = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 10),
      vsync: this,
    )..repeat();

    final args = ModalRoute.of(context)?.settings.arguments;
    if (args is Map) {
      _election = args['election'] as Election?;
      final selections = args['selections'];
      if (selections is List<Map<String, String>>) {
        _selections = selections;
      }
    }

    WidgetsBinding.instance.addPostFrameCallback((_) => _castVote());
  }

  Future<void> _castVote() async {
    final String electionId = _election?.id ?? '';
    final List<Map<String, String>> selections = _selections;
    try {
      final vote = await VotingRepository().castVote(
            electionId: electionId,
            selections: selections,
          );
      if (!mounted) return;
      setState(() {
        _vote = vote;
        _casting = false;
      });
    } on ApiException catch (e) {
      if (!mounted) return;
      if (e.statusCode == 409) {
        Navigator.pushReplacementNamed(context, AppRouter.alreadyVoted);
        return;
      }
      if (e.statusCode == 403) {
        setState(() {
          _error =
              'KYC verification is required before casting your vote. Please complete KYC first.';
          _casting = false;
        });
        return;
      }
      setState(() {
        _error = e.message;
        _casting = false;
      });
    } on Exception catch (e) {
      if (!mounted) return;
      setState(() {
        _error = e.toString();
        _casting = false;
      });
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF08090E),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: Row(
          children: [
            const SizedBox(width: 20),
            Icon(Icons.shield, color: Color(0xFF2ADEC0), size: 24),
            const SizedBox(width: 8),
          ],
        ),
        leadingWidth: 60,
        title: ShaderMask(
          shaderCallback: (bounds) => const LinearGradient(
            colors: [Color(0xFFB9C3FF), Color(0xFFD2BBFF)],
          ).createShader(bounds),
          child: const Text(
            'SecureVote',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w800,
              color: Colors.white,
            ),
          ),
        ),
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 20),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.05),
              border: Border.all(color: Colors.white.withOpacity(0.1)),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              children: const [
                Icon(Icons.verified_user, color: Color(0xFF2ADEC0), size: 14),
                SizedBox(width: 6),
                Text(
                  'SYSTEM SECURED',
                  style: TextStyle(
                    color: Color(0xFFC4C5D7),
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
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_casting) {
      return const Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircularProgressIndicator(color: Color(0xFF2ADEC0)),
            SizedBox(height: 16),
            Text(
              'Sealing your ballot on the ledger...',
              style: TextStyle(color: Color(0xFFC4C5D7), fontSize: 14),
            ),
          ],
        ),
      );
    }

    if (_error != null) {
      return SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            const SizedBox(height: 48),
            const Icon(Icons.error_outline, color: Color(0xFFFF8A80), size: 72),
            const SizedBox(height: 24),
            Text(
              _error!,
              textAlign: TextAlign.center,
              style: const TextStyle(color: Color(0xFFE3E1E9), fontSize: 16),
            ),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: () => Navigator.of(context).pop(),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFB9C3FF),
                  foregroundColor: const Color(0xFF001D79),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  'Go Back',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ],
        ),
      );
    }

    final Vote vote = _vote!;
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          const SizedBox(height: 40),

          // Animated Success Icon
          _buildSuccessAnimation(),

          const SizedBox(height: 48),

          // Heading
          const Text(
            'Vote Submitted!',
            style: TextStyle(
              color: Color(0xFFE3E1E9),
              fontSize: 36,
              fontWeight: FontWeight.w800,
              height: 1.2,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            _election?.title ?? 'Your ballot has been securely recorded.',
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Color(0xFFC4C5D7),
              fontSize: 18,
              fontWeight: FontWeight.w500,
            ),
          ),

          const SizedBox(height: 48),

          // Receipt Card
          Container(
            padding: const EdgeInsets.all(32),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.03),
              borderRadius: BorderRadius.circular(32),
              border: Border(
                top: BorderSide(color: Colors.white.withOpacity(0.1)),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.6),
                  blurRadius: 80,
                  offset: const Offset(0, 40),
                ),
              ],
            ),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'VOTE RECEIPT',
                          style: TextStyle(
                            color: Color(0xFFC4C5D7),
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1.5,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            const Text(
                              'Verified',
                              style: TextStyle(
                                color: Color(0xFFE3E1E9),
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: const Color(
                                  0xFF2ADEC0,
                                ).withOpacity(0.1),
                                border: Border.all(
                                  color: const Color(
                                    0xFF2ADEC0,
                                  ).withOpacity(0.2),
                                ),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Row(
                                children: [
                                  Container(
                                    width: 6,
                                    height: 6,
                                    decoration: const BoxDecoration(
                                      color: Color(0xFF2ADEC0),
                                      shape: BoxShape.circle,
                                    ),
                                  ),
                                  const SizedBox(width: 4),
                                  const Text(
                                    'LIVE VERIFICATION',
                                    style: TextStyle(
                                      color: Color(0xFF2ADEC0),
                                      fontSize: 10,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(
                        Icons.qr_code,
                        size: 64,
                        color: Colors.black,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 32),
                _buildReceiptField('Receipt ID', vote.receiptId, false),
                const SizedBox(height: 24),
                _buildReceiptField(
                  'Merkle Hash',
                  vote.voteHash ?? 'Pending on-chain confirmation',
                  true,
                ),
                const SizedBox(height: 24),
                Container(
                  padding: const EdgeInsets.only(top: 16),
                  decoration: BoxDecoration(
                    border: Border(
                      top: BorderSide(color: Colors.white.withOpacity(0.05)),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'TIMESTAMP',
                            style: TextStyle(
                              color: Color(0xFF8E90A0),
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 1.2,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            _formatTimestamp(vote.createdAt),
                            style: const TextStyle(
                              color: Color(0xFFE3E1E9),
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: const [
                          Text(
                            'NETWORK',
                            style: TextStyle(
                              color: Color(0xFF8E90A0),
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 1.2,
                            ),
                          ),
                          SizedBox(height: 4),
                          Text(
                            'SecureVote Mainnet',
                            style: TextStyle(
                              color: Color(0xFFE3E1E9),
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ],
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
                Navigator.of(context).popUntil((route) => route.isFirst);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFB9C3FF),
                foregroundColor: const Color(0xFF001D79),
                elevation: 8,
                shadowColor: const Color(0xFFB9C3FF).withOpacity(0.3),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text(
                'Done',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: SizedBox(
                  height: 56,
                  child: OutlinedButton.icon(
                    onPressed: () {
                      Navigator.pushNamed(
                        context,
                        AppRouter.voteReceipt,
                        arguments: <String, dynamic>{'vote': vote},
                      );
                    },
                    icon: const Icon(Icons.receipt_long, size: 18),
                    label: const Text('View Full Receipt'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: const Color(0xFF2ADEC0),
                      side: BorderSide(
                        color: const Color(0xFF2ADEC0).withOpacity(0.4),
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: SizedBox(
                  height: 56,
                  child: ElevatedButton.icon(
                    onPressed: () {},
                    icon: const Icon(Icons.share, size: 18),
                    label: const Text('Share Receipt'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF34343A),
                      foregroundColor: const Color(0xFFE3E1E9),
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 32),

          // Footer Notice
          const Text(
            'This receipt serves as mathematical proof of your vote submission. Keep this ID private to maintain ballot secrecy.',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Color(0xFF8E90A0),
              fontSize: 11,
              fontWeight: FontWeight.w500,
              height: 1.5,
            ),
          ),

          const SizedBox(height: 40),
        ],
      ),
    );
  }

  Widget _buildSuccessAnimation() {
    return SizedBox(
      width: 200,
      height: 200,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Rotating rings
          AnimatedBuilder(
            animation: _controller,
            builder: (context, child) {
              return Transform.rotate(
                angle: _controller.value * 2 * math.pi,
                child: Container(
                  width: 200,
                  height: 200,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: const Color(0xFF2ADEC0).withOpacity(0.2),
                      width: 1.5,
                    ),
                  ),
                ),
              );
            },
          ),
          AnimatedBuilder(
            animation: _controller,
            builder: (context, child) {
              return Transform.rotate(
                angle: -_controller.value * 1.5 * math.pi,
                child: Container(
                  width: 180,
                  height: 180,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: const Color(0xFF2ADEC0).withOpacity(0.4),
                      width: 0.5,
                      style: BorderStyle.solid,
                    ),
                  ),
                ),
              );
            },
          ),
          // Center glow
          Container(
            width: 128,
            height: 128,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: const Color(0xFF2ADEC0).withOpacity(0.1),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF2ADEC0).withOpacity(0.2),
                  blurRadius: 80,
                  spreadRadius: 10,
                ),
              ],
            ),
            child: Container(
              margin: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: const Color(0xFF2ADEC0).withOpacity(0.2),
              ),
              child: const Icon(
                Icons.check,
                color: Color(0xFF2ADEC0),
                size: 60,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReceiptField(String label, String value, bool isTertiary) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label.toUpperCase(),
          style: const TextStyle(
            color: Color(0xFF8E90A0),
            fontSize: 10,
            fontWeight: FontWeight.bold,
            letterSpacing: 1.2,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: isTertiary
                ? const Color(0xFF2ADEC0).withOpacity(0.05)
                : const Color(0xFF34343A).withOpacity(0.5),
            border: Border.all(
              color: isTertiary
                  ? const Color(0xFF2ADEC0).withOpacity(0.1)
                  : Colors.white.withOpacity(0.05),
            ),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            value,
            style: TextStyle(
              color: isTertiary
                  ? const Color(0xFF2ADEC0)
                  : const Color(0xFFE3E1E9),
              fontSize: isTertiary ? 11 : 14,
              fontFamily: 'monospace',
              height: 1.5,
            ),
          ),
        ),
      ],
    );
  }

  String _formatTimestamp(DateTime dt) {
    const List<String> months = <String>[
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
    ];
    final DateTime local = dt.toLocal();
    String two(int v) => v.toString().padLeft(2, '0');
    return '${months[local.month - 1]} ${two(local.day)}, ${local.year} '
        '• ${two(local.hour)}:${two(local.minute)}:${two(local.second)} UTC';
  }
}