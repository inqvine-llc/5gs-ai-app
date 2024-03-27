import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:inqvine_core_ui/widgets/handlers/inqvine_tap_handler.dart';
import 'package:whatsapp_ai/main.dart';
import 'package:whatsapp_ai/models/models.dart';

class WhatsappConversationTile extends StatelessWidget with AppServicesMixin {
  const WhatsappConversationTile({
    required this.chat,
    required this.index,
    required this.onTabChangeRequested,
    super.key,
  });

  static const double kTabBarAvatarSize = 52.0;

  final Chat chat;
  final int index;
  final void Function(int index) onTabChangeRequested;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);

    String title = chat.name ?? '';
    String lastMessage = chat.lastMessage?.text?.body ?? '';

    if (title.isEmpty) {
      title = 'New ${chat.type} chat';
    }

    if (lastMessage.isEmpty) {
      lastMessage = 'No messages yet';
    }

    return InqvineTapHandler(
      onTap: () => onTabChangeRequested(index),
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: whatsappService.selectedChatId == chat.id ? theme.primaryColor.withOpacity(0.1) : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: <Widget>[
            if (chat.chatPicFull?.isNotEmpty ?? false) ...<Widget>[
              DecoratedBox(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(kTabBarAvatarSize / 2),
                  border: Border.all(color: theme.primaryColor, width: 2),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(2),
                  child: CircleAvatar(
                    radius: kTabBarAvatarSize / 2,
                    backgroundImage: CachedNetworkImageProvider(chat.chatPicFull ?? ''),
                  ),
                ),
              ),
            ] else ...<Widget>[
              DecoratedBox(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(kTabBarAvatarSize / 2),
                  border: Border.all(color: theme.primaryColor, width: 2),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(2),
                  child: CircleAvatar(
                    radius: kTabBarAvatarSize / 2,
                    child: Text(
                      chat.name?.substring(0, 1) ?? '',
                      style: theme.textTheme.titleLarge?.copyWith(color: theme.primaryColor),
                    ),
                  ),
                ),
              ),
            ],
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    title,
                    style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w500),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  RichText(
                    text: TextSpan(
                      children: <TextSpan>[
                        if (chat.lastMessage?.fromMe ?? false) ...<TextSpan>[
                          TextSpan(
                            text: 'You: ',
                            style: TextStyle(
                              color: theme.hintColor,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                        TextSpan(
                          text: lastMessage,
                          style: theme.textTheme.bodyMedium,
                        ),
                      ],
                    ),
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
