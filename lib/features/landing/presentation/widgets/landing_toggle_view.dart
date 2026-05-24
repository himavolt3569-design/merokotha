import 'package:flutter/material.dart';
import 'package:merokotha/features/landing/presentation/widgets/landing_theme.dart';

class LandingToggleView extends StatelessWidget {
  final bool isGrid;
  final VoidCallback onToggle;

  const LandingToggleView({
    super.key,
    required this.isGrid,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onToggle,
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: LandingTheme.surface,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: LandingTheme.hairline, width: 1),
        ),
        child: Icon(
          isGrid ? Icons.format_list_bulleted_rounded : Icons.grid_view_rounded,
          color: LandingTheme.accent,
          size: 16,
        ),
      ),
    );
  }
}
