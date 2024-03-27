import 'dart:async';

import 'package:flutter/material.dart';
import 'package:paginated_list/paginated_list.dart';
import 'package:whatsapp_ai/events/events.dart';
import 'package:whatsapp_ai/main.dart';
import 'package:whatsapp_ai/models/models.dart';
import 'package:whatsapp_ai/services/whatsapp_service.dart';
import 'package:whatsapp_ai/views/components/message.dart';
import 'package:whatsapp_ai/views/components/whatsapp_conversation_tile.dart';
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
    return WhatsappConversationTile(
      chat: chat,
      index: index,
      onTabChangeRequested: onTabChangeRequested,
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
        ] else if (widget._whatsappStatus == WhatsappServiceStatus.loggedInLoadingConversations) ...<Widget>[
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
