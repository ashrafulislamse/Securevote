import 'package:flutter/material.dart';

import '../../../../core/navigation/app_router.dart';

/// Lightweight landing route that immediately forwards to the real home
/// screen. Kept as a route target so legacy deep-links still resolve.
class HomePlaceholderScreen extends StatefulWidget {
  const HomePlaceholderScreen({super.key});

  @override
  State<HomePlaceholderScreen> createState() => _HomePlaceholderScreenState();
}

class _HomePlaceholderScreenState extends State<HomePlaceholderScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      Navigator.pushReplacementNamed(context, AppRouter.homeScreen);
    });
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: Color(0xFF0D0E13),
      body: SafeArea(
        child: Center(
          child: CircularProgressIndicator(color: Color(0xFFB9C3FF)),
        ),
      ),
    );
  }
}
