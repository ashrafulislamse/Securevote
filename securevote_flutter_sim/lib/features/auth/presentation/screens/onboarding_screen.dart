import 'package:flutter/material.dart';

import '../../../../core/navigation/app_router.dart';
import '../../../../core/services/storage_service.dart';
import '../../../../shared/widgets/gradient_button.dart';
import '../../../../shared/widgets/obsidian_scaffold.dart';
import '../../../../shared/widgets/step_meter.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  final List<OnboardingData> _pages = [
    OnboardingData(
      icon: Icons.ballot_rounded,
      title: 'Vote From',
      titleHighlight: 'Anywhere.',
      description:
          'Cast your encrypted vote securely from your phone. No queues. No paper.',
      badge1: BadgeData(
        icon: Icons.verified_user_rounded,
        text: '256-bit Encrypted',
      ),
      badge2: BadgeData(icon: Icons.bolt_rounded, text: 'Live Results'),
    ),
    OnboardingData(
      icon: Icons.verified_rounded,
      title: 'Blockchain',
      titleHighlight: 'Verified.',
      description:
          'Every vote is recorded on an immutable blockchain. Transparent and tamper-proof.',
      badge1: BadgeData(icon: Icons.lock_rounded, text: 'Immutable'),
      badge2: BadgeData(icon: Icons.visibility_rounded, text: 'Transparent'),
    ),
    OnboardingData(
      icon: Icons.how_to_vote_rounded,
      title: 'Results in',
      titleHighlight: 'Real-Time.',
      description:
          'Watch election results update live as votes are counted. Democracy at the speed of light.',
      badge1: BadgeData(icon: Icons.speed_rounded, text: 'Instant Count'),
      badge2: BadgeData(icon: Icons.bar_chart_rounded, text: 'Live Stats'),
    ),
  ];

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _nextPage() {
    if (_currentPage < _pages.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      // Mark onboarding as completed
      StorageService.setOnboardingCompleted(true);
      // Navigate to welcome screen
      Navigator.pushReplacementNamed(context, AppRouter.welcome);
    }
  }

  void _skipOnboarding() {
    // Mark onboarding as completed
    StorageService.setOnboardingCompleted(true);
    // Navigate to welcome screen
    Navigator.pushReplacementNamed(context, AppRouter.welcome);
  }

  @override
  Widget build(BuildContext context) {
    return ObsidianScaffold(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          Align(
            alignment: Alignment.centerLeft,
            child: IconButton(
              onPressed: () => Navigator.maybePop(context),
              icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 18),
            ),
          ),
          Expanded(
            child: PageView.builder(
              controller: _pageController,
              onPageChanged: (index) {
                setState(() {
                  _currentPage = index;
                });
              },
              itemCount: _pages.length,
              itemBuilder: (context, index) {
                return _buildPage(_pages[index]);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPage(OnboardingData data) {
    return Column(
      children: <Widget>[
        const Spacer(),
        SizedBox(
          height: 340,
          child: Stack(
            alignment: Alignment.center,
            children: <Widget>[
              Positioned(
                left: 24,
                top: 40,
                child: _MiniBadge(
                  icon: data.badge1.icon,
                  text: data.badge1.text,
                ),
              ),
              Positioned(
                right: 18,
                top: 110,
                child: _MiniBadge(
                  icon: data.badge2.icon,
                  text: data.badge2.text,
                ),
              ),
              Container(
                width: 190,
                height: 320,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(36),
                  color: Colors.white.withValues(alpha: 0.03),
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.10),
                  ),
                ),
                child: Center(
                  child: Container(
                    width: 90,
                    height: 90,
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.05),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      data.icon,
                      color: const Color(0xFFB9C3FF),
                      size: 46,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        const Spacer(),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 18),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(30),
            color: Colors.white.withValues(alpha: 0.05),
            border: Border.all(color: Colors.white.withValues(alpha: 0.10)),
          ),
          child: Column(
            children: <Widget>[
              Text(
                '0${_currentPage + 1} / 03',
                style: Theme.of(context).textTheme.labelMedium,
              ),
              const SizedBox(height: 12),
              Text(
                data.title,
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              Text(
                data.titleHighlight,
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  color: const Color(0xFFD2BBFF),
                  fontStyle: FontStyle.italic,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                data.description,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              const SizedBox(height: 16),
              StepMeter(
                total: 3,
                active: _currentPage,
                segmentWidth: 30,
                segmentHeight: 6,
              ),
              const SizedBox(height: 16),
              GradientButton(
                label: _currentPage == _pages.length - 1
                    ? 'Get Started'
                    : 'Continue',
                onPressed: _nextPage,
                icon: Icons.arrow_forward_rounded,
              ),
              TextButton(
                onPressed: _skipOnboarding,
                child: const Text('Skip for now'),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class OnboardingData {
  final IconData icon;
  final String title;
  final String titleHighlight;
  final String description;
  final BadgeData badge1;
  final BadgeData badge2;

  OnboardingData({
    required this.icon,
    required this.title,
    required this.titleHighlight,
    required this.description,
    required this.badge1,
    required this.badge2,
  });
}

class BadgeData {
  final IconData icon;
  final String text;

  BadgeData({required this.icon, required this.text});
}

class _MiniBadge extends StatelessWidget {
  const _MiniBadge({required this.icon, required this.text});

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.06),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.white.withValues(alpha: 0.10)),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Icon(icon, size: 16, color: const Color(0xFFB9C3FF)),
              const SizedBox(width: 6),
              Text(text, style: Theme.of(context).textTheme.labelMedium),
            ],
          ),
        ),
      ],
    );
  }
}
