import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:merokotha/features/owner/presentation/widgets/owner_widgets.dart';
import 'package:merokotha/shared/widgets/owner_botton_nav.dart';

import 'package:merokotha/core/constants/app_colors.dart';
import 'package:merokotha/core/constants/app_sizes.dart';
import 'package:merokotha/core/router/app_routes.dart';
import 'package:merokotha/shared/models/inquiry_model.dart';
import 'package:merokotha/shared/widgets/mk_app_bar.dart';
import 'package:merokotha/shared/widgets/mk_widgets.dart';
import 'package:merokotha/features/auth/providers/auth_provider.dart';
import 'package:merokotha/features/owner/data/inquiry_repository.dart';

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
                        : status == InquiryStatus.accepted
                        ? 'Accepted inquiries open a chat — check Messages tab'
                        : 'No inquiries have been declined yet',
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
                          ? () => _acceptAndChat(context, ref, user, inq)
                          : null,
                      onDecline: status == InquiryStatus.pending
                          ? () => _showDeclineDialog(context, ref, inq.id)
                          : null,
                      // Show "Open chat" button for accepted inquiries
                      onOpenChat: status == InquiryStatus.accepted
                          ? () => _openChat(context, ref, user, inq)
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

  // ── Accept inquiry → create chat → open thread ──
  Future<void> _acceptAndChat(
    BuildContext context,
    WidgetRef ref,
    dynamic user,
    InquiryModel inq,
  ) async {
    try {
      final chatId = await ref
          .read(inquiryRepositoryProvider)
          .acceptInquiry(
            inquiryId: inq.id,
            inquiry: inq,
            ownerName: user.name,
            ownerPhotoUrl: user.photoUrl,
          );

      if (context.mounted) {
        // Show success snackbar
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(
                  Icons.check_circle_rounded,
                  color: Colors.white,
                  size: 18,
                ),
                const SizedBox(width: 8),
                Text('Accepted! Chat opened with ${inq.customerName}'),
              ],
            ),
            backgroundColor: AppColors.success,
            duration: const Duration(seconds: 3),
          ),
        );

        // Navigate to chat thread
        context.push(AppRoutes.chatThread.replaceAll(':chatId', chatId));
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to accept: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  // ── Open existing chat for accepted inquiry ──
  Future<void> _openChat(
    BuildContext context,
    WidgetRef ref,
    dynamic user,
    InquiryModel inq,
  ) async {
    try {
      // Find or create the chat (idempotent)
      final chatId = await ref
          .read(inquiryRepositoryProvider)
          .acceptInquiry(
            inquiryId: inq.id,
            inquiry: inq,
            ownerName: user.name,
            ownerPhotoUrl: user.photoUrl,
          );

      if (context.mounted) {
        context.push(AppRoutes.chatThread.replaceAll(':chatId', chatId));
      }
    } catch (_) {
      if (context.mounted) {
        context.push(AppRoutes.chatList);
      }
    }
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
