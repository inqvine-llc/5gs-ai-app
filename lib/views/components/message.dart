import 'package:flutter/material.dart';
import 'package:inqvine_core_ui/inqvine_core_ui.dart';
import 'package:simple_icons/simple_icons.dart';
import 'package:whatsapp_ai/main.dart';
import 'package:whatsapp_ai/models/models.dart';
import 'package:yaru/yaru.dart';
import 'package:yaru_icons/yaru_icons.dart';

class MessageTile extends StatelessWidget with AppServicesMixin {
  const MessageTile({
    required this.message,
    required this.onMessageResponseRequested,
    super.key,
  });

  final Message message;
  final void Function(Message message) onMessageResponseRequested;

  @override
  Widget build(BuildContext context) {
    String title = message.fromName.isEmpty ? message.from : message.fromName;
    if (message.fromMe) {
      title = 'You';
    }

    final MessageQuotationData? quotationData = MessageQuotationData.fromMessageContext(message.context);
    final bool isQuoted = quotationData != null;
    final List<TextSpan> titleTextSpans = <TextSpan>[
      TextSpan(
        text: title,
        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
      ),
    ];

    if (isQuoted) {
      titleTextSpans.add(
        TextSpan(
          text: ' (Quoted - ${quotationData.quotedAuthor})',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: YaruTheme.of(context).theme?.colorScheme.link),
        ),
      );
    }

    Chat? selectedChat;
    if (whatsappService.selectedChatId.isNotEmpty) {
      selectedChat = whatsappService.messages.keys.firstWhere((chat) => chat.id == whatsappService.selectedChatId);
    }

    final ThemeData theme = Theme.of(context);

    return InqvineTapHandler(
      onTap: () => onMessageResponseRequested(message),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(100),
        ),
        child: Row(
          children: <Widget>[
            if (message.fromMe) ...<Widget>[
              const Icon(
                YaruIcons.user,
                size: 24,
              ),
            ] else if (selectedChat?.chatPic?.isNotEmpty ?? false) ...<Widget>[
              SizedBox(
                width: 24,
                height: 24,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(100),
                  child: Image.network(
                    selectedChat?.chatPic ?? '',
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            ] else ...<Widget>[
              const Icon(
                SimpleIcons.whatsapp,
                size: 24,
              ),
            ],
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  RichText(
                    text: TextSpan(
                      children: titleTextSpans,
                      style: theme.textTheme.labelSmall,
                    ),
                  ),
                  Text(
                    message.text.body,
                    maxLines: 2,
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: <Widget>[
                Text(DateTime.fromMillisecondsSinceEpoch(message.timestamp * 1000).toIso8601String()),
                if (isQuoted) ...<Widget>[
                  const Icon(
                    YaruIcons.reply,
                    size: 24,
                  ),
                ],
                if (!message.fromMe) ...<Widget>[
                  const Text(
                    'Tap to reply',
                    style: TextStyle(fontSize: 9, fontWeight: FontWeight.w900),
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }
}
