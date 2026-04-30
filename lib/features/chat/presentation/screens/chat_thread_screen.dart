import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

import 'package:merokotha/core/constants/app_colors.dart';
import 'package:merokotha/core/constants/app_sizes.dart';
import 'package:merokotha/core/utils/formatters.dart';
import 'package:merokotha/shared/widgets/mk_widgets.dart';
import 'package:merokotha/features/auth/providers/auth_provider.dart';
import 'package:merokotha/features/chat/data/chat_model.dart';
import 'package:merokotha/features/chat/data/chat_repository.dart';
import 'package:merokotha/features/chat/providers/chat_providers.dart';

class ChatThreadScreen extends ConsumerStatefulWidget {
  final String chatId;
  const ChatThreadScreen({super.key, required this.chatId});

  @override
  ConsumerState<ChatThreadScreen> createState() => _ChatThreadScreenState();
}

class _ChatThreadScreenState extends ConsumerState<ChatThreadScreen> {
  final _textCtrl = TextEditingController();
  final _scrollCtrl = ScrollController();
  final _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    // Mark as read when screen opens
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _markRead();
    });
  }

  @override
  void dispose() {
    _textCtrl.dispose();
    _scrollCtrl.dispose();
    super.dispose();
  }

  void _markRead() {
    final user = ref.read(currentUserProvider).asData?.value;
    if (user == null) return;
    ref
        .read(chatRepositoryProvider)
        .markAsRead(chatId: widget.chatId, readerIsOwner: user.isOwner);
  }

  void _scrollToBottom() {
    SchedulerBinding.instance.addPostFrameCallback((_) {
      if (_scrollCtrl.hasClients) {
        _scrollCtrl.animateTo(
          _scrollCtrl.position.maxScrollExtent,
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOut,
        );
      }
    });
  }

  Future<void> _sendText() async {
    final text = _textCtrl.text.trim();
    if (text.isEmpty) return;
    _textCtrl.clear();

    final user = ref.read(currentUserProvider).asData?.value;
    if (user == null) return;

    await ref
        .read(sendMessageProvider.notifier)
        .send(
          chatId: widget.chatId,
          senderId: user.id,
          text: text,
          senderIsOwner: user.isOwner,
        );
    _scrollToBottom();
  }

  Future<void> _sendImage() async {
    final picked = await _picker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 1080,
      imageQuality: 80,
    );
    if (picked == null || !mounted) return;

    final user = ref.read(currentUserProvider).asData?.value;
    if (user == null) return;

    // Show sending indicator
    await ref
        .read(sendMessageProvider.notifier)
        .send(
          chatId: widget.chatId,
          senderId: user.id,
          text: '',
          imageUrl:
              picked.path, // local path — will be real URL after Storage wired
          senderIsOwner: user.isOwner,
        );
    _scrollToBottom();
  }

  @override
  Widget build(BuildContext context) {
    final chatAsync = ref.watch(chatThreadProvider(widget.chatId));
    final messagesAsync = ref.watch(chatMessagesProvider(widget.chatId));
    final user = ref.watch(currentUserProvider).asData?.value;

    // Scroll to bottom when new messages arrive
    ref.listen(chatMessagesProvider(widget.chatId), (_, _) {
      _scrollToBottom();
    });

    return Scaffold(
      backgroundColor: AppColors.backgroundSecondary,
      appBar: chatAsync.when(
        data: (chat) => _ChatAppBar(chat: chat, myUid: user?.id ?? ''),
        loading: () => AppBar(
          backgroundColor: Colors.white,
          leading: BackButton(onPressed: () => context.pop()),
        ),
        error: (_, _) => AppBar(
          backgroundColor: Colors.white,
          leading: BackButton(onPressed: () => context.pop()),
        ),
      ),
      body: Column(
        children: [
          // ── Messages list ──
          Expanded(
            child: messagesAsync.when(
              loading: () => const MkLoading(),
              error: (e, _) => MkErrorWidget(message: e.toString()),
              data: (messages) {
                if (messages.isEmpty) {
                  return const Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.chat_bubble_outline_rounded,
                          size: 48,
                          color: AppColors.grey100,
                        ),
                        SizedBox(height: 12),
                        Text(
                          'Say hello!',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: AppColors.grey400,
                          ),
                        ),
                        SizedBox(height: 4),
                        Text(
                          'Start the conversation',
                          style: TextStyle(
                            fontSize: 13,
                            color: AppColors.grey400,
                          ),
                        ),
                      ],
                    ),
                  );
                }

                return ListView.builder(
                  controller: _scrollCtrl,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  itemCount: messages.length,
                  itemBuilder: (_, i) {
                    final msg = messages[i];
                    final isMe = msg.senderId == user?.id;
                    final showDate =
                        i == 0 ||
                        !_sameDay(messages[i - 1].createdAt, msg.createdAt);

                    return Column(
                      children: [
                        if (showDate) _DateDivider(msg.createdAt),
                        _MessageBubble(message: msg, isMe: isMe),
                      ],
                    );
                  },
                );
              },
            ),
          ),

          // ── Input bar ──
          _InputBar(
            controller: _textCtrl,
            onSend: _sendText,
            onImage: _sendImage,
          ),
        ],
      ),
    );
  }

  bool _sameDay(DateTime a, DateTime b) =>
      a.day == b.day && a.month == b.month && a.year == b.year;
}

// ── App bar ───────────────────────────────────────────────────────

class _ChatAppBar extends StatelessWidget implements PreferredSizeWidget {
  final ChatModel? chat;
  final String myUid;

  const _ChatAppBar({required this.chat, required this.myUid});

  @override
  Size get preferredSize => const Size.fromHeight(64);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 0,
      leading: IconButton(
        icon: const Icon(
          Icons.arrow_back_ios_new_rounded,
          size: 20,
          color: AppColors.grey800,
        ),
        onPressed: () => context.pop(),
      ),
      title: chat == null
          ? const SizedBox.shrink()
          : Row(
              children: [
                UserAvatar(
                  name: chat!.otherName(myUid),
                  photoUrl: chat!.otherPhoto(myUid),
                  size: 38,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        chat!.otherName(myUid),
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: AppColors.grey900,
                        ),
                      ),
                      Text(
                        chat!.listingTitle,
                        style: const TextStyle(
                          fontSize: 11,
                          color: AppColors.grey400,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ],
            ),
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(1),
        child: Container(height: 1, color: AppColors.grey50),
      ),
    );
  }
}

// ── Message bubble ────────────────────────────────────────────────

class _MessageBubble extends StatelessWidget {
  final MessageModel message;
  final bool isMe;

  const _MessageBubble({required this.message, required this.isMe});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        mainAxisAlignment: isMe
            ? MainAxisAlignment.end
            : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (!isMe) const SizedBox(width: 4),

          // Bubble
          ConstrainedBox(
            constraints: BoxConstraints(
              maxWidth: MediaQuery.of(context).size.width * 0.70,
            ),
            child: Container(
              padding: message.hasImage
                  ? EdgeInsets.zero
                  : const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: isMe ? AppColors.primary : Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: const Radius.circular(18),
                  topRight: const Radius.circular(18),
                  bottomLeft: Radius.circular(isMe ? 18 : 4),
                  bottomRight: Radius.circular(isMe ? 4 : 18),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 4,
                    offset: const Offset(0, 1),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  // Image
                  if (message.hasImage)
                    ClipRRect(
                      borderRadius: BorderRadius.circular(14),
                      child: message.imageUrl!.startsWith('/')
                          ? Image.file(
                              File(message.imageUrl!),
                              width: double.infinity,
                              fit: BoxFit.cover,
                            )
                          : Image.network(
                              message.imageUrl!,
                              width: double.infinity,
                              fit: BoxFit.cover,
                              loadingBuilder: (_, child, prog) => prog == null
                                  ? child
                                  : Container(
                                      height: 160,
                                      color: AppColors.grey50,
                                      child: const Center(
                                        child: CircularProgressIndicator(),
                                      ),
                                    ),
                            ),
                    ),

                  // Text
                  if (message.text.isNotEmpty)
                    Padding(
                      padding: message.hasImage
                          ? const EdgeInsets.fromLTRB(10, 6, 10, 8)
                          : EdgeInsets.zero,
                      child: Text(
                        message.text,
                        style: TextStyle(
                          fontSize: 14,
                          color: isMe ? Colors.white : AppColors.grey900,
                          height: 1.4,
                        ),
                      ),
                    ),

                  // Time + read indicator
                  Padding(
                    padding: message.hasImage
                        ? const EdgeInsets.fromLTRB(10, 0, 10, 6)
                        : const EdgeInsets.only(top: 4),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          Formatters.time(message.createdAt),
                          style: TextStyle(
                            fontSize: 10,
                            color: isMe
                                ? Colors.white.withOpacity(0.7)
                                : AppColors.grey400,
                          ),
                        ),
                        if (isMe) ...[
                          const SizedBox(width: 4),
                          Icon(
                            message.isRead
                                ? Icons.done_all_rounded
                                : Icons.done_rounded,
                            size: 13,
                            color: message.isRead
                                ? Colors.white
                                : Colors.white.withOpacity(0.6),
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          if (isMe) const SizedBox(width: 4),
        ],
      ),
    );
  }
}

// ── Date divider ──────────────────────────────────────────────────

class _DateDivider extends StatelessWidget {
  final DateTime date;
  const _DateDivider(this.date);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        children: [
          const Expanded(child: Divider(color: AppColors.grey100, height: 1)),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Text(
              Formatters.date(date),
              style: const TextStyle(fontSize: 11, color: AppColors.grey400),
            ),
          ),
          const Expanded(child: Divider(color: AppColors.grey100, height: 1)),
        ],
      ),
    );
  }
}

// ── Input bar ─────────────────────────────────────────────────────

class _InputBar extends StatelessWidget {
  final TextEditingController controller;
  final VoidCallback onSend;
  final VoidCallback onImage;

  const _InputBar({
    required this.controller,
    required this.onSend,
    required this.onImage,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.fromLTRB(
        12,
        8,
        12,
        MediaQuery.of(context).padding.bottom + 8,
      ),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: AppColors.grey50)),
      ),
      child: Row(
        children: [
          // Image button
          GestureDetector(
            onTap: onImage,
            child: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: AppColors.grey50,
                borderRadius: BorderRadius.circular(AppSizes.radiusMd),
              ),
              child: const Icon(
                Icons.image_outlined,
                size: 20,
                color: AppColors.grey600,
              ),
            ),
          ),
          const SizedBox(width: 8),

          // Text input
          Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: BoxDecoration(
                color: AppColors.grey50,
                borderRadius: BorderRadius.circular(AppSizes.radiusFull),
              ),
              child: TextField(
                controller: controller,
                maxLines: 4,
                minLines: 1,
                textCapitalization: TextCapitalization.sentences,
                style: const TextStyle(fontSize: 14),
                decoration: const InputDecoration(
                  hintText: 'Type a message...',
                  hintStyle: TextStyle(fontSize: 14, color: AppColors.grey400),
                  border: InputBorder.none,
                  isDense: true,
                  contentPadding: EdgeInsets.zero,
                ),
                onSubmitted: (_) => onSend(),
              ),
            ),
          ),
          const SizedBox(width: 8),

          // Send button
          GestureDetector(
            onTap: onSend,
            child: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: AppColors.primary,
                borderRadius: BorderRadius.circular(AppSizes.radiusMd),
              ),
              child: const Icon(
                Icons.send_rounded,
                size: 18,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
