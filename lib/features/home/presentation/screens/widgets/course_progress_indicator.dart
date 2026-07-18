import 'package:flutter/material.dart';

class CourseProgressIndicator extends StatelessWidget {
  final double percent; // 0.0 -> 100.0

  const CourseProgressIndicator({super.key, required this.percent});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final clamped = percent.clamp(0, 100) / 100;
    final isCompleted = percent >= 95;

    return Row(
      children: [
        Expanded(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: LinearProgressIndicator(
              value: clamped.toDouble(),
              minHeight: 6,
              backgroundColor: theme.colorScheme.surfaceContainerHighest,
              valueColor: AlwaysStoppedAnimation(
                isCompleted ? Colors.green : theme.colorScheme.primary,
              ),
            ),
          ),
        ),
        const SizedBox(width: 8),
        Text(
          isCompleted ? 'مكتمل' : '${percent.toStringAsFixed(0)}%',
          style: theme.textTheme.bodySmall?.copyWith(
            fontWeight: FontWeight.w600,
            color: isCompleted ? Colors.green : theme.colorScheme.outline,
          ),
        ),
      ],
    );
  }
}
