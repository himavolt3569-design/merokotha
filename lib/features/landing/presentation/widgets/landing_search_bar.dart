import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:merokotha/features/landing/presentation/widgets/landing_theme.dart';

class LandingSearchBar extends StatelessWidget {
  final ValueChanged<String> onChanged;
  const LandingSearchBar({super.key, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 50,
      decoration: BoxDecoration(
        color: LandingTheme.surface,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: LandingTheme.hairline, width: 1),
      ),
      child: Row(
        children: [
          const SizedBox(width: 16),
          Icon(Icons.search_rounded, color: LandingTheme.stone, size: 18),
          const SizedBox(width: 10),
          Expanded(
            child: TextField(
              onChanged: onChanged,
              style: GoogleFonts.dmSans(fontSize: 14, color: LandingTheme.ink),
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
          Container(
            margin: const EdgeInsets.all(6),
            padding: const EdgeInsets.symmetric(horizontal: 14),
            decoration: BoxDecoration(
              color: LandingTheme.accent,
              borderRadius: BorderRadius.circular(7),
            ),
            height: 38,
            alignment: Alignment.center,
            child: Text(
              'Search',
              style: GoogleFonts.dmSans(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: Colors.white,
                letterSpacing: 0.2,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
