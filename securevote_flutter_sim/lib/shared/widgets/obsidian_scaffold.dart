import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import 'glass_top_bar.dart';

class ObsidianScaffold extends StatelessWidget {
  const ObsidianScaffold({
    super.key,
    required this.child,
    this.title,
    this.showBack = false,
    this.onBack,
    this.bottomNavigationBar,
  });

  final Widget child;
  final String? title;
  final bool showBack;
  final VoidCallback? onBack;
  final Widget? bottomNavigationBar;

  @override
  Widget build(BuildContext context) {
    final double width = MediaQuery.sizeOf(context).width;
    final double bodyWidth = width > 560 ? 460 : width;

    return Scaffold(
      extendBody: true,
      bottomNavigationBar: bottomNavigationBar,
      body: Container(
        decoration: const BoxDecoration(
          gradient: RadialGradient(
            center: Alignment(-0.9, -1.0),
            radius: 1.9,
            colors: <Color>[
              Color(0xFF2A2F45),
              Color(0xFF121318),
              AppColors.surfaceBase,
            ],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: SizedBox(
              width: bodyWidth,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    if (title != null)
                      GlassTopBar(
                        title: title!,
                        showBack: showBack,
                        onBack: onBack,
                      ),
                    const SizedBox(height: 12),
                    Expanded(
                      child: TweenAnimationBuilder<double>(
                        tween: Tween<double>(begin: 0.96, end: 1),
                        duration: const Duration(milliseconds: 260),
                        curve: Curves.easeOutCubic,
                        builder:
                            (BuildContext context, double value, Widget? _) {
                              return Opacity(
                                opacity: value,
                                child: Transform.scale(
                                  scale: value,
                                  child: child,
                                ),
                              );
                            },
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
