import 'package:flutter/material.dart';

class AnimatedTile extends StatelessWidget {
  final Duration delay;
  final String name;
  final int score;
  final double height;

  const AnimatedTile({
    Key? key,
    required this.delay,
    required this.name,
    required this.score,
    required this.height,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: height),
      duration: const Duration(milliseconds: 800),
      curve: Curves.easeOutBack,
      builder: (context, value, child) {
        return Container(
          width: 80,
          height: value,
          margin: const EdgeInsets.symmetric(horizontal: 8),
          decoration: BoxDecoration(
            color: const Color(0xFF212A6B), // New background color
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start, // Move to the top
            children: [
              const SizedBox(height: 8),
              Text(
                score.toString(),
                style: const TextStyle(
                  fontSize: 16,
                  color: Colors.amber, // Score color
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                name,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 12,
                  color: Colors.green, // Name color
                  fontWeight: FontWeight.w600,
                ),
              ),
              const Spacer(), // Push everything else down
            ],
          ),
        );
      },
    );
  }
}
