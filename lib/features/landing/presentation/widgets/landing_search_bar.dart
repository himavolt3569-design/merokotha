import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:merokotha/features/landing/presentation/widgets/landing_theme.dart';

class LandingSearchBar extends StatelessWidget {
  final ValueChanged<String> onChanged;
  const LandingSearchBar({super.key, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 56,
      decoration: BoxDecoration(
        color: LandingTheme.surface,
        borderRadius: BorderRadius.circular(LandingTheme.rSm),
        boxShadow: LandingTheme.shadow,
      ),
      child: Row(
        children: [
          const SizedBox(width: 18),
          Icon(Icons.search_rounded, color: LandingTheme.stone, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: TextField(
              onChanged: onChanged,
              style: GoogleFonts.dmSans(
                fontSize: 14.5,
                color: LandingTheme.ink,
              ),
              decoration: InputDecoration(
                hintText: 'Search by location or name…',
                hintStyle: GoogleFonts.dmSans(
                  fontSize: 14,
                  color: LandingTheme.stone,
                ),
                border: InputBorder.none,
                isDense: true,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8),
            child: Material(
              color: LandingTheme.accent,
              borderRadius: BorderRadius.circular(LandingTheme.rSm - 2),
              child: InkWell(
                borderRadius: BorderRadius.circular(LandingTheme.rSm - 2),
                onTap: () => FocusScope.of(context).unfocus(),
                child: const Padding(
                  padding: EdgeInsets.all(10),
                  child: Icon(
                    Icons.tune_rounded,
                    color: Colors.white,
                    size: 18,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
