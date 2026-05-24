import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:merokotha/core/constants/app_colors.dart';
import 'package:merokotha/features/chat/data/chat_model.dart';
import 'package:merokotha/shared/widgets/mk_widgets.dart';

class ChatAppBar extends StatelessWidget implements PreferredSizeWidget {
  final ChatModel? chat;
  final String myUid;

  const ChatAppBar({super.key, required this.chat, required this.myUid});

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
