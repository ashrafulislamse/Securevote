import 'package:flutter/material.dart';

import '../../../../core/navigation/app_router.dart';

class HelpSupportScreen extends StatefulWidget {
  const HelpSupportScreen({super.key});

  @override
  State<HelpSupportScreen> createState() => _HelpSupportScreenState();
}

class _HelpArticleData {
  const _HelpArticleData({
    required this.title,
    required this.category,
    required this.readTime,
    required this.content,
  });

  final String title;
  final String category;
  final String readTime;
  final String content;

  Map<String, String> toMap() => <String, String>{
    'title': title,
    'category': category,
    'readTime': readTime,
    'content': content,
  };
}

class _FaqItem {
  const _FaqItem({required this.question, required this.answer});

  final String question;
  final String answer;
}

class _HelpSupportScreenState extends State<HelpSupportScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  late final List<_HelpArticleData> _articles;
  late final List<_FaqItem> _allFaqs;
  List<_FaqItem> get _filteredFaqs {
    if (_searchQuery.isEmpty) return _allFaqs;
    final q = _searchQuery.toLowerCase();
    return _allFaqs
        .where(
          (f) =>
              f.question.toLowerCase().contains(q) ||
              f.answer.toLowerCase().contains(q),
        )
        .toList();
  }

  @override
  void initState() {
    super.initState();
    _articles = <_HelpArticleData>[
      _HelpArticleData(
        title: 'How to Vote',
        category: 'GETTING STARTED',
        readTime: '5 min read',
        content:
            'SecureVote makes it easy to participate in elections securely and anonymously.\n\n'
            'Step 1: Find an Active Election — Navigate to the Home screen and look for elections marked as "Active". You can also use the Search tab to find specific elections.\n\n'
            'Step 2: Review Candidates — Tap on an election to view details. Switch to the "Candidates" tab to see all running candidates. Tap on any candidate to view their full profile and manifesto.\n\n'
            'Step 3: Cast Your Vote — Once you\'re ready, tap "Vote Now". Select your preferred candidate and tap "Review & Continue". Carefully review your selection and confirm.\n\n'
            'Step 4: Verify Your Vote — After submission, you\'ll receive a cryptographic receipt. Save this receipt ID to verify your vote was counted on the blockchain.\n\n'
            'Important: Votes are irreversible. Once submitted, you cannot change or withdraw your vote.',
      ),
      _HelpArticleData(
        title: 'KYC Guide',
        category: 'IDENTITY',
        readTime: '4 min read',
        content:
            'Know Your Customer (KYC) verification confirms your identity so you can vote in verified elections.\n\n'
            'To complete KYC: Open your profile, tap "Security & Privacy", and follow the verification steps. You will need to upload a government-issued ID and complete a liveness check.\n\n'
            'Verification typically takes a few minutes to a few hours. You will receive a notification once your status changes.',
      ),
      _HelpArticleData(
        title: 'Verify Receipt',
        category: 'SECURITY',
        readTime: '3 min read',
        content:
            'Every vote you cast generates a cryptographic receipt with a unique receipt ID.\n\n'
            'To verify your vote: Open the "My Votes" tab, tap any vote to view its receipt, then tap "Verify". '
            'SecureVote checks the blockchain and confirms your vote was recorded and counted correctly.\n\n'
            'Your receipt never reveals who you voted for — only that your ballot was included in the tally.',
      ),
      _HelpArticleData(
        title: 'Account Issues',
        category: 'ACCOUNT',
        readTime: '3 min read',
        content:
            'Common account issues and how to resolve them:\n\n'
            'Forgot password: Use the "Forgot Password" link on the login screen to receive a reset link by email.\n\n'
            'Account suspended: If your account is suspended, you will see a notice on login. Contact support@securevote.io for help.\n\n'
            'Cannot log in: Ensure your email and password are correct and that you have verified your account via the OTP sent to your email.',
      ),
      _HelpArticleData(
        title: 'Security FAQ',
        category: 'SECURITY',
        readTime: '6 min read',
        content:
            'SecureVote uses end-to-end encryption and blockchain technology to protect your votes.\n\n'
            'Your identity is verified via KYC, but your vote is separated from your identity using cryptographic mixing. '
            'This means no one — not even SecureVote administrators — can link your identity to your vote.\n\n'
            'All data in transit is encrypted with TLS. Tokens are stored securely on your device using platform secure storage.',
      ),
      _HelpArticleData(
        title: 'Contact Us',
        category: 'SUPPORT',
        readTime: '1 min read',
        content:
            'Need to talk to a human? Our support team is available 24/7.\n\n'
            'Email: support@securevote.io\n\n'
            'Live chat is coming soon. Until then, email is the fastest way to reach us.',
      ),
    ];

    _allFaqs = <_FaqItem>[
      _FaqItem(
        question: 'Is my vote truly anonymous on the blockchain?',
        answer:
            'Yes. SecureVote separates your identity from your vote using cryptographic proofs. '
            'Your ballot is recorded on-chain, but it cannot be linked back to you personally.',
      ),
      _FaqItem(
        question: 'What happens if I lose my private key?',
        answer:
            'You do not need to manage a private key to use SecureVote. '
            'Your authentication is handled securely by the app. If you lose access to your account, '
            'use the password reset flow or contact support@securevote.io.',
      ),
      _FaqItem(
        question: 'How long does the KYC verification take?',
        answer:
            'KYC verification typically takes anywhere from a few minutes to a few hours. '
            'You will receive a notification as soon as your status is updated.',
      ),
    ];
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF08090E),
      appBar: AppBar(
        backgroundColor: const Color(0xFF08090E).withValues(alpha: 0.8),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Help & Support',
          style: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Hero & Search
            RichText(
              text: const TextSpan(
                style: TextStyle(
                  fontSize: 30,
                  fontWeight: FontWeight.bold,
                  height: 1.2,
                ),
                children: [
                  TextSpan(
                    text: 'How can we ',
                    style: TextStyle(color: Colors.white),
                  ),
                  TextSpan(
                    text: 'help you?',
                    style: TextStyle(color: Color(0xFF4F6EF7)),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Search our knowledge base or browse common topics below to secure your digital sovereignty.',
              style: TextStyle(
                color: Color(0xFF8B93B0),
                fontSize: 14,
                height: 1.5,
              ),
            ),

            const SizedBox(height: 24),

            // Search Bar
            Container(
              height: 50,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: const Color(0xFF161A24),
                border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
                borderRadius: BorderRadius.circular(24),
              ),
              child: Row(
                children: [
                  const Icon(Icons.search, color: Color(0xFF8B93B0)),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextField(
                      controller: _searchController,
                      style: const TextStyle(color: Colors.white),
                      decoration: InputDecoration(
                        hintText: 'Search for answers...',
                        hintStyle: TextStyle(
                          color: const Color(0xFF8B93B0).withValues(alpha: 0.5),
                        ),
                        border: InputBorder.none,
                      ),
                      onChanged: (value) =>
                          setState(() => _searchQuery = value),
                    ),
                  ),
                  if (_searchQuery.isNotEmpty)
                    IconButton(
                      icon: const Icon(Icons.clear, size: 18),
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                      color: const Color(0xFF8B93B0),
                      onPressed: () {
                        _searchController.clear();
                        setState(() => _searchQuery = '');
                      },
                    ),
                ],
              ),
            ),

            const SizedBox(height: 32),

            // Quick Topics
            const Text(
              'Quick Topics',
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            GridView.count(
              crossAxisCount: 2,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              mainAxisSpacing: 12,
              crossAxisSpacing: 12,
              childAspectRatio: 1.2,
              children: List<Widget>.generate(_articles.length, (i) {
                final article = _articles[i];
                return _buildTopicCard(
                  context,
                  article.title,
                  _iconForTopic(i),
                  _colorForTopic(i),
                  article,
                );
              }),
            ),

            const SizedBox(height: 32),

            // FAQ
            const Text(
              'Frequently Asked Questions',
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            if (_filteredFaqs.isEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 24),
                child: Center(
                  child: Text(
                    'No results for "$_searchQuery".',
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.4),
                      fontSize: 14,
                    ),
                  ),
                ),
              )
            else
              ..._filteredFaqs.map(
                (faq) => Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: _buildFAQItem(faq),
                ),
              ),

            const SizedBox(height: 32),

            // Contact Support Card
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: const Color(0xFF161A24),
                border: Border.all(color: Colors.white.withValues(alpha: 0.07)),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFF10B981).withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 6,
                          height: 6,
                          decoration: const BoxDecoration(
                            color: Color(0xFF10B981),
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 6),
                        const Text(
                          'LIVE NOW',
                          style: TextStyle(
                            color: Color(0xFF10B981),
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1.2,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Still need support?',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Our high-priority concierge team is available 24/7 to assist with your technical inquiries.',
                    style: TextStyle(
                      color: Color(0xFF8B93B0),
                      fontSize: 14,
                      height: 1.5,
                    ),
                  ),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: ElevatedButton(
                      onPressed: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text(
                              'Live chat coming soon. Email support@securevote.io.',
                            ),
                            duration: Duration(seconds: 3),
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF4F6EF7),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.forum, size: 18),
                          SizedBox(width: 8),
                          Text(
                            'Chat with Support',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: OutlinedButton(
                      onPressed: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text(
                              'Email us at support@securevote.io for assistance.',
                            ),
                            duration: Duration(seconds: 3),
                          ),
                        );
                      },
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.white,
                        side: BorderSide(
                          color: Colors.white.withValues(alpha: 0.1),
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.mail, size: 18),
                          SizedBox(width: 8),
                          Text(
                            'Send an Email',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  IconData _iconForTopic(int index) {
    const icons = <IconData>[
      Icons.ballot,
      Icons.shield,
      Icons.card_membership,
      Icons.person,
      Icons.lock,
      Icons.chat,
    ];
    return icons[index % icons.length];
  }

  Color _colorForTopic(int index) {
    const colors = <Color>[
      Color(0xFF4F6EF7),
      Color(0xFF10B981),
      Color(0xFFF59E0B),
      Color(0xFFEF4444),
      Color(0xFF8B5CF6),
      Color(0xFF06B6D4),
    ];
    return colors[index % colors.length];
  }

  Widget _buildTopicCard(
    BuildContext context,
    String title,
    IconData icon,
    Color color,
    _HelpArticleData article,
  ) {
    return InkWell(
      onTap: () {
        Navigator.pushNamed(
          context,
          AppRouter.helpArticle,
          arguments: article.toMap(),
        );
      },
      borderRadius: BorderRadius.circular(14),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xFF161A24),
          border: Border.all(color: Colors.white.withValues(alpha: 0.07)),
          borderRadius: BorderRadius.circular(14),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: color, size: 20),
            ),
            Text(
              title,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFAQItem(_FaqItem faq) {
    return ExpansionTile(
      tilePadding: const EdgeInsets.symmetric(horizontal: 16),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
        side: BorderSide(color: Colors.white.withValues(alpha: 0.07)),
      ),
      collapsedShape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
        side: BorderSide(color: Colors.white.withValues(alpha: 0.07)),
      ),
      backgroundColor: const Color(0xFF161A24),
      collapsedBackgroundColor: const Color(0xFF161A24),
      collapsedIconColor: const Color(0xFF8B93B0),
      iconColor: const Color(0xFF4F6EF7),
      title: Row(
        children: [
          Container(
            width: 24,
            height: 24,
            decoration: BoxDecoration(
              color: const Color(0xFF4F6EF7).withValues(alpha: 0.12),
              shape: BoxShape.circle,
            ),
            child: const Center(
              child: Text(
                'Q',
                style: TextStyle(
                  color: Color(0xFF4F6EF7),
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              faq.question,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 14,
                fontWeight: FontWeight.w500,
                height: 1.2,
              ),
            ),
          ),
        ],
      ),
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(52, 0, 16, 16),
          child: Text(
            faq.answer,
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.7),
              fontSize: 13,
              height: 1.5,
            ),
          ),
        ),
      ],
    );
  }
}
