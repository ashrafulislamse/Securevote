import 'package:flutter/material.dart';

import '../../../../shared/widgets/glass_card.dart';
import '../../../../shared/widgets/obsidian_scaffold.dart';

class HomePlaceholderScreen extends StatelessWidget {
  const HomePlaceholderScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ObsidianScaffold(
      title: 'Home',
      child: const Center(
        child: GlassCard(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Icon(Icons.home_rounded, size: 36),
              SizedBox(height: 12),
              Text('Core starter is ready.'),
              SizedBox(height: 6),
              Text('Next screens will continue from this architecture.'),
            ],
          ),
        ),
      ),
    );
  }
}
