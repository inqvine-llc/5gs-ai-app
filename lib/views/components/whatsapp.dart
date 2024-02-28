import 'dart:async';

import 'package:flutter/material.dart';
import 'package:whatsapp_ai/events/messages_updated_event.dart';
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
  State<HomeWhatsappConfiguration> createState() => _HomeWhatsappConfigurationState();
}

class _HomeWhatsappConfigurationState extends State<HomeWhatsappConfiguration> with TickerProviderStateMixin, AppServicesMixin {
  String _selectedChatId = '';
  String get selectedChatId => _selectedChatId;
  set selectedChatId(String value) {
    _selectedChatId = value;
    if (mounted) {
      setState(() {});
    }
  }

  StreamSubscription<MessagesUpdatedEvent>? _messagesUpdatedEventSubscription;

  TabController? _tabController;
  TabController? get tabController => _tabController;

  @override
  void initState() {
    super.initState();
    setupListeners();
    checkTabIntegrity();
  }

  @override
  void dispose() {
    disposeListeners();
    super.dispose();
  }

  void setupListeners() {
    _tabController = TabController(length: widget.whatsappService.messages.length, vsync: this);
    _messagesUpdatedEventSubscription = eventBus.on<MessagesUpdatedEvent>().listen(onMessagesUpdated);
  }

  void disposeListeners() {
    _tabController?.dispose();
    _messagesUpdatedEventSubscription?.cancel();
  }

  void onMessagesUpdated(MessagesUpdatedEvent event) {
    refreshTabController();
    checkTabIntegrity();
  }

  // If the selected chat was deleted or null, and there are still chats available, select the first one
  void checkTabIntegrity() {
    if (widget.whatsappService.messages[selectedChatId] == null && widget.whatsappService.messages.isNotEmpty) {
      selectedChatId = widget.whatsappService.messages.keys.first;
    }

    if (mounted) {
      setState(() {});
    }
  }

  void refreshTabController() {
    _tabController = TabController(length: widget.whatsappService.messages.length, vsync: this);
    if (mounted) {
      setState(() {});
    }
  }

  void onTabSelected(int index) {
    selectedChatId = widget.whatsappService.messages.keys.elementAt(index);
    if (mounted) {
      setState(() {});
    }
  }

  Widget buildYaruTab(String key) {
    final List<Message> messages = widget.whatsappService.messages[key] ?? [];
    final String label = messages.firstWhere((element) => !element.fromMe && element.fromName.isNotEmpty, orElse: () => Message.empty()).fromName;

    final bool isSelected = key == selectedChatId;
    return YaruTab(label: isSelected ? '* $label *' : label);
  }

  @override
  Widget build(BuildContext context) {
    List<Message> currentMessages = widget.whatsappService.messages[selectedChatId]?.toList() ?? [];
    currentMessages.sort((a, b) => b.timestamp.compareTo(a.timestamp));

    final MediaQueryData mediaQuery = MediaQuery.of(context);
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
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
          YaruTabBar(
            tabController: TabController(length: widget.whatsappService.messages.length, vsync: this),
            tabs: widget.whatsappService.messages.keys.map(buildYaruTab).toList(),
            onTap: onTabSelected,
          ),
          Expanded(
            child: ListView.separated(
              padding: EdgeInsets.only(
                bottom: 8 + mediaQuery.padding.bottom,
                left: 8,
                right: 8,
                top: 8,
              ),
              itemCount: currentMessages.length,
              physics: const BouncingScrollPhysics(),
              separatorBuilder: (context, index) => const SizedBox(height: 8),
              itemBuilder: (context, index) {
                final message = currentMessages.elementAt(index);
                return MessageTile(
                  message: message,
                  onMessageResponseRequested: widget.onMessageResponseRequested,
                );
              },
            ),
          ),
        ],
      ],
    );
  }
}
