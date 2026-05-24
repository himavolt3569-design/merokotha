import 'package:flutter/material.dart';
import 'package:merokotha/core/constants/app_colors.dart';

class FacilitiesSelector extends StatefulWidget {
  final List<String> selected;
  final ValueChanged<List<String>> onChanged;

  const FacilitiesSelector({
    super.key,
    required this.selected,
    required this.onChanged,
  });

  @override
  State<FacilitiesSelector> createState() => _FacilitiesSelectorState();
}

class _FacilitiesSelectorState extends State<FacilitiesSelector> {
  static const _options = [
    'WiFi',
    'Parking',
    'Water',
    'Electricity',
    'Kitchen',
    'Laundry',
    'Security',
    'Lift',
    'CCTV',
    'Generator',
  ];

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: _options.map((f) {
        final selected = widget.selected.contains(f);
        return FilterChip(
          label: Text(f),
          selected: selected,
          onSelected: (_) {
            final updated = [...widget.selected];
            selected ? updated.remove(f) : updated.add(f);
            widget.onChanged(updated);
          },
          selectedColor: AppColors.primaryLight,
          checkmarkColor: AppColors.primary,
          labelStyle: TextStyle(
            fontSize: 12,
            color: selected ? AppColors.primary : AppColors.grey600,
            fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
          ),
          side: BorderSide(
            color: selected ? AppColors.primary : AppColors.grey100,
          ),
          backgroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: 4),
        );
      }).toList(),
    );
  }
}
