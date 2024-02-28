import 'dart:async';

import 'package:flutter/material.dart';
import 'package:inqvine_core_ui/inqvine_core_ui.dart';
import 'package:paginated_list/paginated_list.dart';
import 'package:whatsapp_ai/events/messages_updated_event.dart';
import 'package:whatsapp_ai/events/whatsapp_chat_selected_event.dart';
import 'package:whatsapp_ai/main.dart';
import 'package:whatsapp_ai/models/models.dart';
import 'package:whatsapp_ai/services/whatsapp_service.dart';
import 'package:whatsapp_ai/views/components/message.dart';
import 'package:yaru_widgets/yaru_widgets.dart';

class HomeWhatsappConfiguration extends StatefulWidget {
  const HomeWhatsappConfiguration({
    super.key,
    required WhatsappServiceStatus? whatsappStatus,
    required this.whatsappService,
    required this.onMessageResponseRequested,
    this.parentalPaddingApplied = false,
  }) : _whatsappStatus = whatsappStatus;

  final WhatsappServiceStatus? _whatsappStatus;
  final AbstractWhatsappService whatsappService;
  final void Function(Message) onMessageResponseRequested;
  final bool parentalPaddingApplied;

  @override
  State<HomeWhatsappConfiguration> createState() => HomeWhatsappConfigurationState();
}

class HomeWhatsappConfigurationState extends State<HomeWhatsappConfiguration> with TickerProviderStateMixin, AppServicesMixin {
  static const double kTabBarAvatarSize = 52.0;

  StreamSubscription<MessagesUpdatedEvent>? _messagesUpdatedEventSubscription;
  StreamSubscription<WhatsappChatSelectedEvent>? _whatsappChatSelectedEventSubscription;

  @override
  void initState() {
    super.initState();
    setupListeners();
  }

  @override
  void dispose() {
    disposeListeners();
    super.dispose();
  }

  void setupListeners() {
    _messagesUpdatedEventSubscription = eventBus.on<MessagesUpdatedEvent>().listen(onMessagesUpdated);
    _whatsappChatSelectedEventSubscription = eventBus.on<WhatsappChatSelectedEvent>().listen(onTabSelected);
  }

  void disposeListeners() {
    _messagesUpdatedEventSubscription?.cancel();
    _whatsappChatSelectedEventSubscription?.cancel();
  }

  void onMessagesUpdated(MessagesUpdatedEvent event) {
    if (mounted) {
      setState(() {});
    }
  }

  void onTabSelected(WhatsappChatSelectedEvent index) {
    if (mounted) {
      setState(() {});
    }
  }

  void onTabChangeRequested(int index) {
    final Chat chat = widget.whatsappService.messages.keys.elementAt(index);
    whatsappService.selectedChatId = chat.id ?? '';
    if (mounted) {
      setState(() {});
    }
  }

  Widget buildChatConversationTile(Chat chat, int index) {
    final ThemeData theme = Theme.of(context);

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
                    backgroundImage: NetworkImage(chat.chatPicFull ?? ''),
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
                    chat.name ?? '',
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
                          text: chat.lastMessage?.text?.body ?? '',
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

  @override
  Widget build(BuildContext context) {
    final MediaQueryData mediaQuery = MediaQuery.of(context);

    final bool hasSelectedChat = whatsappService.selectedChatId.isNotEmpty;
    final List<Message> currentMessages = [];

    Chat? selectedChat;
    if (hasSelectedChat) {
      selectedChat = widget.whatsappService.messages.keys.firstWhere((chat) => chat.id == whatsappService.selectedChatId);
      currentMessages.addAll(whatsappService.messages[selectedChat] ?? []);
    }

    final Widget child = whatsappService.selectedChatId.isEmpty
        ? _ConversationsList(whatsappService: whatsappService, widget: widget, onBuildConversationTile: buildChatConversationTile)
        : _MessagesList(currentMessages: currentMessages, whatsappService: whatsappService, selectedChat: selectedChat, widget: widget);

    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      children: <Widget>[
        if (widget._whatsappStatus == WhatsappServiceStatus.loggedOut) ...<Widget>[
          const Align(
            alignment: Alignment.center,
            child: Text(
              'Please enter your WhatsApp API token to get started...',
              textAlign: TextAlign.center,
            ),
          ),
        ] else if (widget._whatsappStatus == WhatsappServiceStatus.loggedInLoadingInitialMessages) ...<Widget>[
          const Align(alignment: Alignment.center, child: YaruCircularProgressIndicator()),
        ] else ...<Widget>[
          if (!widget.parentalPaddingApplied) ...<Widget>[
            SizedBox(height: mediaQuery.padding.top),
          ],
          Expanded(
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 300),
              child: child,
            ),
          ),
        ],
      ],
    );
  }
}

class _ConversationsList extends StatelessWidget {
  const _ConversationsList({
    required this.whatsappService,
    required this.widget,
    required this.onBuildConversationTile,
  });

  final AbstractWhatsappService whatsappService;
  final HomeWhatsappConfiguration widget;
  final Widget Function(Chat chat, int index) onBuildConversationTile;

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      padding: const EdgeInsets.all(12),
      physics: const BouncingScrollPhysics(),
      separatorBuilder: (context, index) => const SizedBox(width: 12),
      itemCount: widget.whatsappService.messages.length,
      itemBuilder: (context, index) {
        final chat = widget.whatsappService.messages.keys.elementAt(index);
        return onBuildConversationTile(chat, index);
      },
    );
  }
}

class _MessagesList extends StatelessWidget {
  const _MessagesList({
    required this.currentMessages,
    required this.whatsappService,
    required this.selectedChat,
    required this.widget,
  });

  final List<Message> currentMessages;
  final AbstractWhatsappService whatsappService;
  final Chat? selectedChat;
  final HomeWhatsappConfiguration widget;

  @override
  Widget build(BuildContext context) {
    return PaginatedList(
      isRecentSearch: false,
      items: currentMessages,
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.all(12),
      loadingIndicator: const Align(alignment: Alignment.center, child: YaruCircularProgressIndicator()),
      isLastPage: whatsappService.messageEndReached[selectedChat] ?? false,
      onLoadMore: (int index) => whatsappService.loadMessagesForChat(selectedChat!, offset: index),
      builder: (context, index) {
        final message = currentMessages.elementAt(index);
        return MessageTile(
          message: message,
          onMessageResponseRequested: widget.onMessageResponseRequested,
        );
      },
    );
  }
}
