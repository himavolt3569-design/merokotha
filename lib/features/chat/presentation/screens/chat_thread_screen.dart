import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

import 'package:merokotha/core/constants/app_colors.dart';
import 'package:merokotha/shared/widgets/mk_widgets.dart';
import 'package:merokotha/features/auth/providers/auth_provider.dart';
import 'package:merokotha/features/chat/data/chat_repository.dart';
import 'package:merokotha/features/chat/providers/chat_providers.dart';
import 'package:merokotha/features/chat/presentation/widgets/chat_app_bar.dart';
import 'package:merokotha/features/chat/presentation/widgets/chat_message_bubble.dart';
import 'package:merokotha/features/chat/presentation/widgets/chat_date_divider.dart';
import 'package:merokotha/features/chat/presentation/widgets/chat_input_bar.dart';

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

    try {
      final fileName = '${DateTime.now().millisecondsSinceEpoch}.jpg';
      final storageRef = FirebaseStorage.instance
          .ref()
          .child('chats/${widget.chatId}/$fileName');
      final task = await storageRef.putFile(
        File(picked.path),
        SettableMetadata(contentType: 'image/jpeg'),
      );
      final imageUrl = await task.ref.getDownloadURL();

      if (!mounted) return;

      await ref.read(sendMessageProvider.notifier).send(
        chatId: widget.chatId,
        senderId: user.id,
        text: '',
        imageUrl: imageUrl,
        senderIsOwner: user.isOwner,
      );
      _scrollToBottom();
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to send image. Try again.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final chatAsync = ref.watch(chatThreadProvider(widget.chatId));
    final messagesAsync = ref.watch(chatMessagesProvider(widget.chatId));
    final user = ref.watch(currentUserProvider).asData?.value;

    ref.listen(chatMessagesProvider(widget.chatId), (_, _) {
      _scrollToBottom();
    });

    return Scaffold(
      backgroundColor: AppColors.backgroundSecondary,
      appBar: chatAsync.when(
        data: (chat) => ChatAppBar(chat: chat, myUid: user?.id ?? ''),
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
                        if (showDate) ChatDateDivider(msg.createdAt),
                        ChatMessageBubble(message: msg, isMe: isMe),
                      ],
                    );
                  },
                );
              },
            ),
          ),

          ChatInputBar(
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
