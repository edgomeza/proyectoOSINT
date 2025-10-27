import 'package:flutter/material.dart';

class ProgressIndicatorWidget extends StatelessWidget {
  final double progress;
  final double height;
  final Color? color;
  final bool showPercentage;

  const ProgressIndicatorWidget({
    super.key,
    required this.progress,
    this.height = 8,
    this.color,
    this.showPercentage = true,
  });

  Color _getProgressColor() {
    if (color != null) return color!;
    if (progress < 0.33) return Colors.red;
    if (progress < 0.66) return Colors.orange;
    return Colors.green;
  }

  @override
  Widget build(BuildContext context) {
    final progressColor = _getProgressColor();
    final percentage = (progress * 100).toInt();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (showPercentage)
          Padding(
            padding: const EdgeInsets.only(bottom: 4),
            child: Text(
              '$percentage%',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: progressColor,
              ),
            ),
          ),
        ClipRRect(
          borderRadius: BorderRadius.circular(height / 2),
          child: LinearProgressIndicator(
            value: progress,
            backgroundColor: progressColor.withOpacity(0.2),
            valueColor: AlwaysStoppedAnimation<Color>(progressColor),
            minHeight: height,
          ),
        ),
      ],
    );
  }
}
