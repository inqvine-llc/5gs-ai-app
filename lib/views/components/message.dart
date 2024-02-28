import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:simple_icons/simple_icons.dart';
import 'package:whatsapp_ai/models/models.dart';
import 'package:whatsapp_ai/views/home.dart';
import 'package:yaru/yaru.dart';
import 'package:yaru_icons/yaru_icons.dart';
import 'package:yaru_widgets/yaru_widgets.dart';

class MessageTile extends StatelessWidget {
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

    final MediaQueryData mediaQuery = MediaQuery.of(context);
    final bool isLargeScreen = mediaQuery.size.width > HomeViewState.kWidthBreakpoint;

    final Widget trailing = Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: <Widget>[
        Text(DateTime.fromMillisecondsSinceEpoch(message.timestamp * 1000).toIso8601String()),
        if (!message.fromMe) ...<Widget>[
          const Text(
            'Tap to reply',
            style: TextStyle(fontSize: 9, fontWeight: FontWeight.w900),
          ),
        ],
      ],
    );

    return YaruMasterTile(
      selected: message.fromMe,
      onTap: () => onMessageResponseRequested(message),
      leading: CircleAvatar(
        child: message.fromMe
            ? const Icon(
                YaruIcons.user,
                size: 24,
              )
            : const Icon(
                SimpleIcons.whatsapp,
                size: 24,
              ),
      ),
      title: RichText(
        text: TextSpan(
          children: titleTextSpans,
        ),
      ),
      subtitle: Text(
        message.text.body,
        maxLines: 2,
      ),
      trailing: isLargeScreen ? trailing : null,
    );
  }
}
