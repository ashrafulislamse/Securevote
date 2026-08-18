import 'package:flutter/material.dart';

class StepMeter extends StatelessWidget {
  const StepMeter({
    super.key,
    required this.total,
    required this.active,
    this.segmentWidth = 44,
    this.segmentHeight = 6,
  });

  final int total;
  final int active;
  final double segmentWidth;
  final double segmentHeight;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List<Widget>.generate(total * 2 - 1, (int index) {
        if (index.isOdd) {
          return const SizedBox(width: 8);
        }
        final int meterIndex = index ~/ 2;
        final bool isActive = meterIndex <= active;
        return Container(
          width: segmentWidth,
          height: segmentHeight,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(999),
            gradient: isActive
                ? const LinearGradient(
                    colors: <Color>[Color(0xFFB9C3FF), Color(0xFFD2BBFF)],
                  )
                : null,
            border: isActive
                ? null
                : Border.all(color: Colors.white.withValues(alpha: 0.16)),
          ),
        );
      }),
    );
  }
}
