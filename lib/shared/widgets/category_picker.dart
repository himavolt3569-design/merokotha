import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:merokotha/features/admin/providers/category_providers.dart';

import 'package:merokotha/core/constants/app_colors.dart';
import 'package:merokotha/core/constants/app_sizes.dart';
import 'package:merokotha/shared/models/category_model.dart';

class CategoryPicker extends ConsumerWidget {
  final CategorySelection selection;
  final void Function(CategorySelection) onChanged;
  final bool required;

  const CategoryPicker({
    super.key,
    required this.selection,
    required this.onChanged,
    this.required = false,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ── Level 1 ──
        _LevelSelector(
          label: 'Property type',
          hint: 'Select type (e.g. Residential)',
          selectedId: selection.level1?.id,
          itemsAsync: ref.watch(level1CategoriesProvider),
          onSelected: (cat) {
            onChanged(CategorySelection(level1: cat));
          },
          color: AppColors.ownerPrimary,
          lightColor: AppColors.ownerLight,
        ),

        // ── Level 2 (shown after level 1 selected) ──
        AnimatedSize(
          duration: const Duration(milliseconds: 200),
          child: selection.level1 != null
              ? Padding(
                  padding: const EdgeInsets.only(top: AppSizes.md),
                  child: _LevelSelector(
                    label: 'Sub-type',
                    hint: 'Select sub-type (e.g. Apartment)',
                    selectedId: selection.level2?.id,
                    itemsAsync: ref.watch(
                      level2CategoriesProvider(selection.level1!.id),
                    ),
                    onSelected: (cat) {
                      onChanged(
                        selection.copyWith(level2: cat, clearLevel3: true),
                      );
                    },
                    color: AppColors.info,
                    lightColor: AppColors.infoLight,
                  ),
                )
              : const SizedBox.shrink(),
        ),

        // ── Level 3 (shown after level 2 selected) ──
        AnimatedSize(
          duration: const Duration(milliseconds: 200),
          child: selection.level2 != null
              ? Padding(
                  padding: const EdgeInsets.only(top: AppSizes.md),
                  child: _LevelSelector(
                    label: 'Specific type',
                    hint: 'Select specific type (e.g. 2BHK)',
                    selectedId: selection.level3?.id,
                    itemsAsync: ref.watch(
                      level3CategoriesProvider(selection.level2!.id),
                    ),
                    onSelected: (cat) {
                      onChanged(selection.copyWith(level3: cat));
                    },
                    color: AppColors.customerPrimary,
                    lightColor: AppColors.customerLight,
                  ),
                )
              : const SizedBox.shrink(),
        ),

        // ── Selected path display ──
        if (selection.hasLevel1) ...[
          const SizedBox(height: AppSizes.md),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: AppColors.primaryLight,
              borderRadius: BorderRadius.circular(AppSizes.radiusFull),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.category_rounded,
                  size: 14,
                  color: AppColors.primary,
                ),
                const SizedBox(width: 6),
                Text(
                  selection.displayPath,
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.primary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(width: 8),
                GestureDetector(
                  onTap: () => onChanged(const CategorySelection()),
                  child: const Icon(
                    Icons.close_rounded,
                    size: 14,
                    color: AppColors.primary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }
}

// ── Single level dropdown ─────────────────────────────────────────

class _LevelSelector extends StatelessWidget {
  final String label;
  final String hint;
  final String? selectedId;
  final AsyncValue<List<CategoryModel>> itemsAsync;
  final void Function(CategoryModel) onSelected;
  final Color color;
  final Color lightColor;

  const _LevelSelector({
    required this.label,
    required this.hint,
    this.selectedId,
    required this.itemsAsync,
    required this.onSelected,
    required this.color,
    required this.lightColor,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w500,
            color: AppColors.grey800,
          ),
        ),
        const SizedBox(height: 6),
        itemsAsync.when(
          loading: () => Container(
            height: 50,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(AppSizes.radiusMd),
              border: Border.all(color: AppColors.grey100),
            ),
            child: const Center(
              child: SizedBox(
                width: 18,
                height: 18,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: AppColors.primary,
                ),
              ),
            ),
          ),
          error: (e, _) => Container(
            height: 50,
            padding: const EdgeInsets.symmetric(horizontal: 14),
            decoration: BoxDecoration(
              color: AppColors.errorLight,
              borderRadius: BorderRadius.circular(AppSizes.radiusMd),
              border: Border.all(color: AppColors.error),
            ),
            child: const Row(
              children: [
                Icon(
                  Icons.error_outline_rounded,
                  size: 16,
                  color: AppColors.error,
                ),
                SizedBox(width: 8),
                Text(
                  'Failed to load categories',
                  style: TextStyle(fontSize: 13, color: AppColors.error),
                ),
              ],
            ),
          ),
          data: (items) {
            if (items.isEmpty) {
              return Container(
                height: 50,
                padding: const EdgeInsets.symmetric(horizontal: 14),
                decoration: BoxDecoration(
                  color: AppColors.grey50,
                  borderRadius: BorderRadius.circular(AppSizes.radiusMd),
                  border: Border.all(color: AppColors.grey100),
                ),
                child: const Row(
                  children: [
                    Icon(
                      Icons.info_outline_rounded,
                      size: 16,
                      color: AppColors.grey400,
                    ),
                    SizedBox(width: 8),
                    Text(
                      'No categories yet — add from admin panel',
                      style: TextStyle(fontSize: 12, color: AppColors.grey400),
                    ),
                  ],
                ),
              );
            }

            final selected = selectedId != null
                ? items.firstWhere(
                    (c) => c.id == selectedId,
                    orElse: () => items.first,
                  )
                : null;

            return DropdownButtonFormField<String>(
              value: selectedId,
              hint: Text(
                hint,
                style: const TextStyle(fontSize: 14, color: AppColors.grey400),
              ),
              decoration: InputDecoration(
                filled: true,
                fillColor: selected != null ? lightColor : Colors.white,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 14,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppSizes.radiusMd),
                  borderSide: BorderSide(
                    color: selected != null ? color : AppColors.grey100,
                  ),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppSizes.radiusMd),
                  borderSide: BorderSide(
                    color: selected != null ? color : AppColors.grey100,
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppSizes.radiusMd),
                  borderSide: BorderSide(color: color, width: 1.5),
                ),
              ),
              items: items
                  .map(
                    (c) => DropdownMenuItem(
                      value: c.id,
                      child: Text(
                        c.name,
                        style: const TextStyle(
                          fontSize: 14,
                          color: AppColors.grey900,
                        ),
                      ),
                    ),
                  )
                  .toList(),
              onChanged: (id) {
                if (id == null) return;
                final cat = items.firstWhere((c) => c.id == id);
                onSelected(cat);
              },
            );
          },
        ),
      ],
    );
  }
}
