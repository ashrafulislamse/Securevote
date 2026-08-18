import 'package:flutter/material.dart';

class HelpArticleScreen extends StatefulWidget {
  const HelpArticleScreen({super.key});

  @override
  State<HelpArticleScreen> createState() => _HelpArticleScreenState();
}

class _HelpArticleScreenState extends State<HelpArticleScreen> {
  bool _feedbackGiven = false;
  bool _feedbackPositive = false;
  bool _bookmarked = false;

  Map<String, String>? _article;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final args = ModalRoute.of(context)?.settings.arguments;
    if (args is Map<String, String>) {
      _article = args;
    }
  }

  void _giveFeedback(bool positive) {
    if (_feedbackGiven) return;
    setState(() {
      _feedbackGiven = true;
      _feedbackPositive = positive;
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Thanks for your feedback!'),
        duration: Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final article = _article;
    final hasArticle =
        article != null &&
        article['title'] != null &&
        article['title']!.isNotEmpty;

    return Scaffold(
      backgroundColor: const Color(0xFF08090E),
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            backgroundColor: const Color(0xFF08090E),
            elevation: 0,
            pinned: true,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back),
              onPressed: () => Navigator.pop(context),
            ),
            actions: [
              IconButton(
                icon: Icon(
                  _bookmarked ? Icons.bookmark : Icons.bookmark_border,
                ),
                onPressed: () {
                  setState(() => _bookmarked = !_bookmarked);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        _bookmarked
                            ? 'Article saved to bookmarks.'
                            : 'Bookmark removed.',
                      ),
                      duration: const Duration(seconds: 2),
                    ),
                  );
                },
              ),
              IconButton(
                icon: const Icon(Icons.share),
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text(
                        'Sharing is not available in this version.',
                      ),
                      duration: Duration(seconds: 2),
                    ),
                  );
                },
              ),
            ],
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: hasArticle
                  ? _buildArticle(article)
                  : const _MissingArticle(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildArticle(Map<String, String> article) {
    final title = article['title'] ?? 'Article';
    final category = article['category'] ?? 'HELP';
    final readTime = article['readTime'] ?? '';
    final content = article['content'] ?? '';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Category Badge
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            color: const Color(0xFFB9C3FF).withValues(alpha: 0.1),
          ),
          child: Text(
            category.toUpperCase(),
            style: const TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w700,
              color: Color(0xFFB9C3FF),
              letterSpacing: 1,
            ),
          ),
        ),
        const SizedBox(height: 16),

        // Title
        Text(
          title,
          style: const TextStyle(
            fontSize: 32,
            fontWeight: FontWeight.w800,
            color: Colors.white,
            letterSpacing: -0.5,
            height: 1.2,
          ),
        ),
        const SizedBox(height: 16),

        // Meta Info
        if (readTime.isNotEmpty)
          Row(
            children: [
              Icon(
                Icons.access_time,
                size: 16,
                color: Colors.white.withValues(alpha: 0.5),
              ),
              const SizedBox(width: 6),
              Text(
                readTime,
                style: TextStyle(
                  fontSize: 13,
                  color: Colors.white.withValues(alpha: 0.5),
                ),
              ),
            ],
          ),
        const SizedBox(height: 32),

        // Content
        ...content
            .split('\n\n')
            .map(
              (paragraph) => Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: Text(
                  paragraph,
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.white.withValues(alpha: 0.8),
                    height: 1.6,
                  ),
                ),
              ),
            ),

        const SizedBox(height: 32),

        // Helpful Section
        Center(
          child: Column(
            children: [
              Text(
                'Was this article helpful?',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.white.withValues(alpha: 0.7),
                ),
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _buildFeedbackButton(
                    Icons.thumb_up_outlined,
                    'Yes',
                    _feedbackGiven && _feedbackPositive,
                    () => _giveFeedback(true),
                  ),
                  const SizedBox(width: 12),
                  _buildFeedbackButton(
                    Icons.thumb_down_outlined,
                    'No',
                    _feedbackGiven && !_feedbackPositive,
                    () => _giveFeedback(false),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 40),
      ],
    );
  }

  Widget _buildFeedbackButton(
    IconData icon,
    String label,
    bool highlighted,
    VoidCallback onTap,
  ) {
    return InkWell(
      onTap: _feedbackGiven ? null : onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          color: const Color(0xFF1A1B21),
          border: Border.all(
            color: highlighted
                ? const Color(0xFFB9C3FF).withValues(alpha: 0.5)
                : Colors.white.withValues(alpha: 0.1),
          ),
        ),
        child: Row(
          children: [
            Icon(
              icon,
              size: 18,
              color: highlighted
                  ? const Color(0xFFB9C3FF)
                  : Colors.white.withValues(alpha: 0.7),
            ),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: highlighted
                    ? const Color(0xFFB9C3FF)
                    : Colors.white.withValues(alpha: 0.7),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MissingArticle extends StatelessWidget {
  const _MissingArticle();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 120),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.article_outlined, size: 64, color: Colors.white24),
            const SizedBox(height: 16),
            Text(
              'Article not found',
              style: TextStyle(
                fontSize: 16,
                color: Colors.white.withValues(alpha: 0.6),
              ),
            ),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Back'),
            ),
          ],
        ),
      ),
    );
  }
}
