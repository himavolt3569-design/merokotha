import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:merokotha/core/constants/app_colors.dart';
import 'package:merokotha/core/constants/app_sizes.dart';
import 'package:merokotha/shared/models/category_model.dart';
import 'package:merokotha/shared/widgets/mk_widgets.dart';
import 'package:merokotha/features/admin/providers/category_providers.dart';
import 'package:merokotha/features/admin/presentation/widgets/admin_widgets.dart';

class AdminCategoriesScreen extends ConsumerStatefulWidget {
  const AdminCategoriesScreen({super.key});

  @override
  ConsumerState<AdminCategoriesScreen> createState() =>
      _AdminCategoriesScreenState();
}

class _AdminCategoriesScreenState extends ConsumerState<AdminCategoriesScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tab;

  @override
  void initState() {
    super.initState();
    _tab = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tab.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final catAsync = ref.watch(allCategoriesAdminProvider);

    return Scaffold(
      backgroundColor: AppColors.backgroundSecondary,
      appBar: AdminAppBar(
        showBack: false,

        title: 'Categories',
        actions: [
          // Seed defaults button
          TextButton.icon(
            onPressed: () => _confirmSeed(context, ref),
            icon: const Icon(
              Icons.auto_awesome_rounded,
              size: 16,
              color: Colors.white,
            ),
            label: const Text(
              'Seed defaults',
              style: TextStyle(color: Colors.white, fontSize: 12),
            ),
          ),
        ],
      ),
      body: catAsync.when(
        skipLoadingOnReload: true,
        loading: () => const MkLoading(),
        error: (e, _) => MkErrorWidget(message: e.toString()),
        data: (allCats) {
          final l1 = allCats.where((c) => c.isLevel1).toList();
          final l2 = allCats.where((c) => c.isLevel2).toList();
          final l3 = allCats.where((c) => c.isLevel3).toList();

          return Column(
            children: [
              Container(
                color: AdminColors.primary,
                child: TabBar(
                  controller: _tab,
                  labelColor: Colors.white,
                  unselectedLabelColor: AppColors.grey400,
                  indicatorColor: AdminColors.accent,
                  indicatorWeight: 2,
                  tabs: [
                    Tab(text: 'Level 1 (${l1.length})'),
                    Tab(text: 'Level 2 (${l2.length})'),
                    Tab(text: 'Level 3 (${l3.length})'),
                  ],
                ),
              ),
              Expanded(
                child: TabBarView(
                  controller: _tab,
                  children: [
                    _CategoryList(
                      cats: l1,
                      level: CategoryLevel.level1,
                      allCats: allCats,
                    ),
                    _CategoryList(
                      cats: l2,
                      level: CategoryLevel.level2,
                      allCats: allCats,
                    ),
                    _CategoryList(
                      cats: l3,
                      level: CategoryLevel.level3,
                      allCats: allCats,
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () =>
            _showAddDialog(context, ref, CategoryLevel.values[_tab.index], []),
        backgroundColor: AdminColors.accent,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add_rounded),
        label: const Text(
          'Add category',
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
      ),
    );
  }

  void _confirmSeed(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Seed default categories?'),
        content: const Text(
          'This adds Residential, Commercial, and Land as Level 1 categories. Run this only once.',
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSizes.radiusLg),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              ref.read(categoryActionProvider.notifier).seedDefaults();
            },
            child: const Text(
              'Seed',
              style: TextStyle(color: AdminColors.accent),
            ),
          ),
        ],
      ),
    );
  }

  void _showAddDialog(
    BuildContext context,
    WidgetRef ref,
    CategoryLevel level,
    List<CategoryModel> allCats,
  ) {
    showDialog(
      context: context,
      builder: (_) => _AddCategoryDialog(level: level, allCats: allCats),
    );
  }
}

// ── Category list for one level ────────────────────────────────────

class _CategoryList extends ConsumerWidget {
  final List<CategoryModel> cats;
  final CategoryLevel level;
  final List<CategoryModel> allCats;

  const _CategoryList({
    required this.cats,
    required this.level,
    required this.allCats,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (cats.isEmpty) {
      return MkEmptyState(
        title: 'No ${_levelLabel(level)} categories',
        subtitle: 'Tap the + button to add one',
        icon: Icons.category_outlined,
        actionLabel: 'Add category',
        onAction: () => _showAddDialog(context, ref),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.all(AppSizes.pagePadding),
      itemCount: cats.length,
      separatorBuilder: (_, _) => const SizedBox(height: 8),
      itemBuilder: (_, i) => _CategoryTile(cat: cats[i], allCats: allCats),
    );
  }

  void _showAddDialog(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (_) => _AddCategoryDialog(level: level, allCats: allCats),
    );
  }

  String _levelLabel(CategoryLevel l) {
    switch (l) {
      case CategoryLevel.level1:
        return 'Level 1';
      case CategoryLevel.level2:
        return 'Level 2';
      case CategoryLevel.level3:
        return 'Level 3';
    }
  }
}

// ── Single category tile ───────────────────────────────────────────

class _CategoryTile extends ConsumerWidget {
  final CategoryModel cat;
  final List<CategoryModel> allCats;

  const _CategoryTile({required this.cat, required this.allCats});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Find parent name for level2 and level3
    final parent = cat.parentId != null
        ? allCats.firstWhere(
            (c) => c.id == cat.parentId,
            orElse: () => CategoryModel(
              id: '',
              name: '?',
              level: CategoryLevel.level1,
              createdAt: DateTime.now(),
            ),
          )
        : null;

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSizes.md,
        vertical: 12,
      ),
      decoration: BoxDecoration(
        color: cat.isActive ? Colors.white : AppColors.grey50,
        borderRadius: BorderRadius.circular(AppSizes.radiusLg),
        border: Border.all(
          color: cat.isActive ? AppColors.grey50 : AppColors.grey100,
        ),
      ),
      child: Row(
        children: [
          // Level color dot
          Container(
            width: 10,
            height: 10,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: cat.isActive ? _levelColor(cat.level) : AppColors.grey400,
            ),
          ),
          const SizedBox(width: 12),

          // Name + parent breadcrumb
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  cat.name,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: cat.isActive ? AppColors.grey900 : AppColors.grey400,
                  ),
                ),
                if (cat.nameNp.isNotEmpty)
                  Text(
                    cat.nameNp,
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppColors.grey400,
                    ),
                  ),
                if (parent != null)
                  Text(
                    'Under: ${parent.name}',
                    style: const TextStyle(
                      fontSize: 11,
                      color: AppColors.grey400,
                    ),
                  ),
              ],
            ),
          ),

          // Active toggle
          Switch(
            value: cat.isActive,
            onChanged: (v) => ref
                .read(categoryActionProvider.notifier)
                .toggleActive(cat.id, v),
            activeThumbColor: AppColors.success,
            materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
          ),

          // Edit
          IconButton(
            icon: const Icon(
              Icons.edit_outlined,
              size: 18,
              color: AppColors.grey400,
            ),
            onPressed: () => _showEditDialog(context, ref),
            visualDensity: VisualDensity.compact,
          ),

          // Delete
          IconButton(
            icon: const Icon(
              Icons.delete_outline_rounded,
              size: 18,
              color: AppColors.error,
            ),
            onPressed: () => _confirmDelete(context, ref),
            visualDensity: VisualDensity.compact,
          ),
        ],
      ),
    );
  }

  Color _levelColor(CategoryLevel l) {
    switch (l) {
      case CategoryLevel.level1:
        return AppColors.ownerPrimary;
      case CategoryLevel.level2:
        return AppColors.info;
      case CategoryLevel.level3:
        return AppColors.customerPrimary;
    }
  }

  void _showEditDialog(BuildContext context, WidgetRef ref) {
    final nameCtrl = TextEditingController(text: cat.name);
    final nameNpCtrl = TextEditingController(text: cat.nameNp);
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Edit category'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameCtrl,
              decoration: const InputDecoration(labelText: 'Name (English)'),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: nameNpCtrl,
              decoration: const InputDecoration(labelText: 'Name (Nepali)'),
            ),
          ],
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSizes.radiusLg),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              ref
                  .read(categoryActionProvider.notifier)
                  .update(cat.id, nameCtrl.text.trim(), nameNpCtrl.text.trim());
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  void _confirmDelete(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Delete category?'),
        content: Text(
          'Delete "${cat.name}"? This may affect existing listings using this category.',
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSizes.radiusLg),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              ref.read(categoryActionProvider.notifier).delete(cat.id);
            },
            child: const Text(
              'Delete',
              style: TextStyle(color: AppColors.error),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Add Category Dialog ─────────────────────────────────────────────

class _AddCategoryDialog extends ConsumerStatefulWidget {
  final CategoryLevel level;
  final List<CategoryModel> allCats;

  const _AddCategoryDialog({required this.level, required this.allCats});

  @override
  ConsumerState<_AddCategoryDialog> createState() => _AddCategoryDialogState();
}

class _AddCategoryDialogState extends ConsumerState<_AddCategoryDialog> {
  final _nameCtrl = TextEditingController();
  final _nameNpCtrl = TextEditingController();
  String? _selectedParentId;

  @override
  void dispose() {
    _nameCtrl.dispose();
    _nameNpCtrl.dispose();
    super.dispose();
  }

  List<CategoryModel> get _parents {
    if (widget.level == CategoryLevel.level2) {
      return widget.allCats.where((c) => c.isLevel1).toList();
    } else if (widget.level == CategoryLevel.level3) {
      return widget.allCats.where((c) => c.isLevel2).toList();
    }
    return [];
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Add ${_levelLabel(widget.level)} category'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Parent selector for level2 and level3
            if (widget.level != CategoryLevel.level1) ...[
              Text(
                widget.level == CategoryLevel.level2
                    ? 'Select Level 1 parent:'
                    : 'Select Level 2 parent:',
                style: const TextStyle(fontSize: 13, color: AppColors.grey600),
              ),
              const SizedBox(height: 8),
              DropdownButtonFormField<String>(
                initialValue: _selectedParentId,
                hint: const Text('Select parent'),
                decoration: const InputDecoration(
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 10,
                  ),
                ),
                items: _parents
                    .map(
                      (p) => DropdownMenuItem(value: p.id, child: Text(p.name)),
                    )
                    .toList(),
                onChanged: (v) => setState(() => _selectedParentId = v),
              ),
              const SizedBox(height: 14),
            ],

            // Name fields
            TextField(
              controller: _nameCtrl,
              textCapitalization: TextCapitalization.words,
              decoration: const InputDecoration(labelText: 'Name (English) *'),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _nameNpCtrl,
              decoration: const InputDecoration(
                labelText: 'Name (Nepali) — optional',
              ),
            ),
          ],
        ),
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppSizes.radiusLg),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: () {
            if (_nameCtrl.text.trim().isEmpty) return;
            if (widget.level != CategoryLevel.level1 &&
                _selectedParentId == null) {
              return;
            }

            // For level3, find grandParentId from selected parent
            String? grandParentId;
            if (widget.level == CategoryLevel.level3 &&
                _selectedParentId != null) {
              grandParentId = widget.allCats
                  .firstWhere(
                    (c) => c.id == _selectedParentId,
                    orElse: () => CategoryModel(
                      id: '',
                      name: '',
                      level: CategoryLevel.level2,
                      createdAt: DateTime.now(),
                    ),
                  )
                  .parentId;
            }

            ref
                .read(categoryActionProvider.notifier)
                .create(
                  name: _nameCtrl.text.trim(),
                  nameNp: _nameNpCtrl.text.trim(),
                  level: widget.level,
                  parentId: _selectedParentId,
                  grandParentId: grandParentId,
                  sortOrder: widget.allCats
                      .where((c) => c.level == widget.level)
                      .length,
                );
            Navigator.pop(context);
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: AdminColors.accent,
            foregroundColor: Colors.white,
            elevation: 0,
          ),
          child: const Text('Add'),
        ),
      ],
    );
  }

  String _levelLabel(CategoryLevel l) {
    switch (l) {
      case CategoryLevel.level1:
        return 'Level 1';
      case CategoryLevel.level2:
        return 'Level 2';
      case CategoryLevel.level3:
        return 'Level 3';
    }
  }
}
