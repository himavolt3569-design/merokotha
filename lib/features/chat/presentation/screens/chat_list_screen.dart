import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:merokotha/shared/widgets/owner_botton_nav.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_sizes.dart';
import '../../../../core/router/app_routes.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../shared/widgets/mk_app_bar.dart';
import '../../../../shared/widgets/mk_widgets.dart';
import '../../../auth/providers/auth_provider.dart';
import '../../../customer/presentation/widgets/customer_widgets.dart';
import '../../data/chat_model.dart';
import '../../providers/chat_providers.dart';

class ChatListScreen extends ConsumerWidget {
  const ChatListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final chatsAsync = ref.watch(myChatsProvider);
    final user = ref.watch(currentUserProvider).asData?.value;
    final isOwner = user?.isOwner ?? true;

    return Scaffold(
      backgroundColor: AppColors.backgroundSecondary,
      appBar: const MkAppBar(title: 'Messages', showBack: false),
      body: chatsAsync.when(
        loading: () => const MkLoading(),
        error: (e, _) => MkErrorWidget(message: e.toString()),
        data: (chats) {
          if (chats.isEmpty) {
            return MkEmptyState(
              icon: Icons.chat_bubble_outline_rounded,
              title: 'No messages yet',
              subtitle: isOwner
                  ? 'When you accept an inquiry, a chat thread will open here'
                  : 'When an owner accepts your inquiry, you can chat here',
            );
          }

          return ListView.separated(
            padding: const EdgeInsets.all(AppSizes.pagePadding),
            itemCount: chats.length,
            separatorBuilder: (_, _) => const SizedBox(height: 8),
            itemBuilder: (_, i) => _ChatTile(
              chat: chats[i],
              myUid: user?.id ?? '',
              onTap: () => context.push(
                AppRoutes.chatThread.replaceAll(':chatId', chats[i].id),
              ),
            ),
          );
        },
      ),
      bottomNavigationBar: isOwner
          ? const OwnerBottomNav(currentIndex: 3)
          : const CustomerBottomNav(currentIndex: 2),
    );
  }
}

// ── Chat tile ─────────────────────────────────────────────────────

class _ChatTile extends StatelessWidget {
  final ChatModel chat;
  final String myUid;
  final VoidCallback onTap;

  const _ChatTile({
    required this.chat,
    required this.myUid,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final unread = chat.unreadFor(myUid);
    final hasUnread = unread > 0;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(AppSizes.md),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(AppSizes.radiusLg),
          border: Border.all(
            color: hasUnread ? AppColors.primary : AppColors.grey50,
            width: hasUnread ? 1.5 : 1,
          ),
        ),
        child: Row(
          children: [
            // Avatar
            UserAvatar(
              name: chat.otherName(myUid),
              photoUrl: chat.otherPhoto(myUid),
              size: 50,
            ),
            const SizedBox(width: 12),

            // Info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Name + time
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          chat.otherName(myUid),
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: hasUnread
                                ? FontWeight.w700
                                : FontWeight.w600,
                            color: AppColors.grey900,
                          ),
                        ),
                      ),
                      if (chat.lastMessageAt != null)
                        Text(
                          Formatters.timeAgo(chat.lastMessageAt!),
                          style: TextStyle(
                            fontSize: 11,
                            color: hasUnread
                                ? AppColors.primary
                                : AppColors.grey400,
                            fontWeight: hasUnread
                                ? FontWeight.w600
                                : FontWeight.w400,
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 3),

                  // Listing name
                  Text(
                    chat.listingTitle,
                    style: const TextStyle(
                      fontSize: 11,
                      color: AppColors.primary,
                      fontWeight: FontWeight.w500,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),

                  // Last message + unread badge
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          chat.lastMessage ?? 'Start chatting...',
                          style: TextStyle(
                            fontSize: 13,
                            color: hasUnread
                                ? AppColors.grey800
                                : AppColors.grey400,
                            fontWeight: hasUnread
                                ? FontWeight.w500
                                : FontWeight.w400,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (hasUnread) ...[
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 7,
                            vertical: 3,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.primary,
                            borderRadius: BorderRadius.circular(
                              AppSizes.radiusFull,
                            ),
                          ),
                          child: Text(
                            '$unread',
                            style: const TextStyle(
                              fontSize: 10,
                              color: Colors.white,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
