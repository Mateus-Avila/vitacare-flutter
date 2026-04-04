import 'package:flutter/material.dart';
import 'package:vitacare_flutter/theme/vitacare_colors.dart';

class VitacareFeatureTile extends StatelessWidget {
  const VitacareFeatureTile({
    super.key,
    required this.icon,
    required this.title,
    required this.description,
    this.light = false,
  });

  final IconData icon;
  final String title;
  final String description;
  final bool light;

  @override
  Widget build(BuildContext context) {
    final titleColor = light ? Colors.white : VitacareColors.textStrong;
    final bodyColor = light
        ? Colors.white.withValues(alpha: 0.78)
        : VitacareColors.textSoft;

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: light
            ? Colors.white.withValues(alpha: 0.08)
            : VitacareColors.surfaceTint,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: light
              ? Colors.white.withValues(alpha: 0.12)
              : VitacareColors.border,
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: light
                  ? VitacareColors.accent.withValues(alpha: 0.22)
                  : VitacareColors.accent.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(
              icon,
              color: light ? Colors.white : VitacareColors.primary,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: titleColor,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  description,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: bodyColor,
                    height: 1.45,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
