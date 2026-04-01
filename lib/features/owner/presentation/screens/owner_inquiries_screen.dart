import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:merokotha/shared/widgets/owner_botton_nav.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_sizes.dart';
import '../../../../shared/models/inquiry_model.dart';
import '../../../../shared/widgets/mk_app_bar.dart';
import '../../../../shared/widgets/mk_widgets.dart';
import '../../../auth/providers/auth_provider.dart';
import '../../data/inquiry_repository.dart';
import '../widgets/owner_widgets.dart';

class OwnerInquiriesScreen extends ConsumerStatefulWidget {
  const OwnerInquiriesScreen({super.key});

  @override
  ConsumerState<OwnerInquiriesScreen> createState() =>
      _OwnerInquiriesScreenState();
}

class _OwnerInquiriesScreenState extends ConsumerState<OwnerInquiriesScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundSecondary,
      appBar: MkAppBar(title: 'Inquiries', showBack: false, actions: const []),
      body: Column(
        children: [
          // Tab bar
          Container(
            color: Colors.white,
            child: TabBar(
              controller: _tabController,
              labelColor: AppColors.primary,
              unselectedLabelColor: AppColors.grey400,
              indicatorColor: AppColors.primary,
              indicatorWeight: 2,
              labelStyle: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
              tabs: const [
                Tab(text: 'Pending'),
                Tab(text: 'Accepted'),
                Tab(text: 'Declined'),
              ],
            ),
          ),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _InquiryTab(status: InquiryStatus.pending),
                _InquiryTab(status: InquiryStatus.accepted),
                _InquiryTab(status: InquiryStatus.declined),
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: const OwnerBottomNav(currentIndex: 3),
    );
  }
}

class _InquiryTab extends ConsumerWidget {
  final InquiryStatus status;
  const _InquiryTab({required this.status});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ref
        .watch(currentUserProvider)
        .when(
          data: (user) {
            if (user == null) return const SizedBox.shrink();

            return StreamBuilder<List<InquiryModel>>(
              stream: ref
                  .watch(inquiryRepositoryProvider)
                  .watchByStatus(user.id, status),
              builder: (context, snap) {
                if (snap.connectionState == ConnectionState.waiting) {
                  return const MkLoading(fullScreen: false);
                }
                final inquiries = snap.data ?? [];
                if (inquiries.isEmpty) {
                  return MkEmptyState(
                    title: 'No ${status.name} inquiries',
                    subtitle: status == InquiryStatus.pending
                        ? 'New inquiries from renters will appear here'
                        : 'No inquiries have been ${status.name} yet',
                    icon: Icons.inbox_outlined,
                  );
                }

                return ListView.separated(
                  padding: const EdgeInsets.all(AppSizes.pagePadding),
                  itemCount: inquiries.length,
                  separatorBuilder: (_, _) =>
                      const SizedBox(height: AppSizes.md),
                  itemBuilder: (_, i) {
                    final inq = inquiries[i];
                    return InquiryCard(
                      inquiry: inq,
                      onAccept: status == InquiryStatus.pending
                          ? () => ref
                                .read(inquiryRepositoryProvider)
                                .acceptInquiry(inq.id)
                          : null,
                      onDecline: status == InquiryStatus.pending
                          ? () => _showDeclineDialog(context, ref, inq.id)
                          : null,
                    );
                  },
                );
              },
            );
          },
          loading: () => const MkLoading(),
          error: (_, _) => const SizedBox.shrink(),
        );
  }

  void _showDeclineDialog(
    BuildContext context,
    WidgetRef ref,
    String inquiryId,
  ) {
    final reasonCtrl = TextEditingController();
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Decline inquiry'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Optionally add a reason for the renter:',
              style: TextStyle(fontSize: 13, color: AppColors.grey600),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: reasonCtrl,
              maxLines: 3,
              decoration: const InputDecoration(
                hintText: 'e.g. Room is no longer available',
              ),
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
                  .read(inquiryRepositoryProvider)
                  .declineInquiry(
                    inquiryId,
                    reason: reasonCtrl.text.trim().isEmpty
                        ? null
                        : reasonCtrl.text.trim(),
                  );
            },
            child: const Text(
              'Decline',
              style: TextStyle(color: AppColors.error),
            ),
          ),
        ],
      ),
    );
  }
}
