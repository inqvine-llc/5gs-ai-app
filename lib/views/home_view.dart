import 'dart:async';

import 'package:flutter/material.dart';
import 'package:whatsapp_ai/events/default_prompt_updated_event.dart';
import 'package:whatsapp_ai/events/messages_updated_event.dart';
import 'package:whatsapp_ai/events/saved_prompts_updated_event.dart';
import 'package:whatsapp_ai/events/whatsapp_polling_interval_updated_event.dart';
import 'package:whatsapp_ai/events/whatsapp_status_updated_event.dart';
import 'package:whatsapp_ai/main.dart';
import 'package:whatsapp_ai/models/models.dart';
import 'package:whatsapp_ai/services/whatsapp_service.dart';

class HomeView extends StatefulWidget {
  const HomeView({super.key});

  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> with AppServicesMixin {
  WhatsappServiceStatus? whatsappStatus;
  int whatsappPollingInterval = 5000;

  StreamSubscription<MessagesUpdatedEvent>? _messagesUpdatedSubscription;
  StreamSubscription<WhatsappStatusUpdatedEvent>? _whatsappStatusSubscription;
  StreamSubscription<WhatsppPollingIntervalUpdatedEvent>? _whatsappPollingIntervalUpdatedSubscription;
  StreamSubscription<SavedPromptsUpdatedEvent>? _savedPromptsUpdatedSubscription;
  StreamSubscription<DefaultPromptUpdatedEvent>? _defaultPromptUpdatedSubscription;

  final PageController pageController = PageController();
  final Set<String> savedPrompts = {};

  String defaultPrompt = '';
  String apiToken = '';

  int _currentPage = 0;
  int get currentPage => _currentPage;
  set currentPage(int value) {
    _currentPage = value;
    if (mounted) {
      pageController.jumpToPage(value);
      setState(() {});
    }
  }

  bool _isBusy = false;
  bool get isBusy => _isBusy;
  set isBusy(bool value) {
    _isBusy = value;
    if (mounted) {
      setState(() {});
    }
  }

  final TextEditingController promptController = TextEditingController();
  final TextEditingController apiTokenController = TextEditingController();
  final TextEditingController whatsappIntervalTextController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback(onFirstRender);
  }

  Future<void> onFirstRender(Duration timeStamp) async {
    whatsappStatus = whatsappService.status;
    whatsappPollingInterval = whatsappService.pollingInterval;
    if (whatsappPollingInterval > 0) {
      whatsappIntervalTextController.text = whatsappPollingInterval.toString();
    }

    apiToken = whatsappService.clientToken;
    if (apiToken.isNotEmpty) {
      apiTokenController.text = apiToken;
    }

    savedPrompts.clear();
    savedPrompts.addAll(geminiService.savedPrompts);
    defaultPrompt = await geminiService.getDefaultPrompt() ?? '';

    setState(() {});

    await _messagesUpdatedSubscription?.cancel();
    _messagesUpdatedSubscription = eventBus.on<MessagesUpdatedEvent>().listen(onMessagesUpdated);

    await _whatsappPollingIntervalUpdatedSubscription?.cancel();
    _whatsappPollingIntervalUpdatedSubscription = eventBus.on<WhatsppPollingIntervalUpdatedEvent>().listen(onWhatsappPollingIntervalUpdated);

    await _whatsappStatusSubscription?.cancel();
    _whatsappStatusSubscription = eventBus.on<WhatsappStatusUpdatedEvent>().listen(onWhatsappStatusUpdated);

    await _savedPromptsUpdatedSubscription?.cancel();
    _savedPromptsUpdatedSubscription = eventBus.on<SavedPromptsUpdatedEvent>().listen(onSavedPromptsUpdated);

    _defaultPromptUpdatedSubscription?.cancel();
    _defaultPromptUpdatedSubscription = eventBus.on<DefaultPromptUpdatedEvent>().listen(onDefaultPromptUpdated);
  }

  void onDefaultPromptSubmitted(String prompt) async {
    await geminiService.setDefaultPrompt(prompt);
  }

  Future<void> onWhatsAppTokenSubmitted(String token) async {
    isBusy = true;

    try {
      if (whatsappService.isLoggedIn) {
        await whatsappService.logout();
      }

      await whatsappService.login(token);
      currentPage = 0;
    } finally {
      isBusy = false;
    }
  }

  Future<void> onWhatsAppIntervalSubmitted(String interval) async {
    final int? newInterval = int.tryParse(interval);
    if (newInterval == null) return;

    await whatsappService.updatePollingInterval(newInterval);
    if (mounted) {
      setState(() {});
    }
  }

  void onMessagesUpdated(MessagesUpdatedEvent event) {
    if (!mounted) return;
    systemService.showSuccessToast('New messages loaded');
    setState(() {});
  }

  void onWhatsappPollingIntervalUpdated(WhatsppPollingIntervalUpdatedEvent event) {
    if (!mounted) return;

    whatsappPollingInterval = whatsappService.pollingInterval;
    systemService.showSuccessToast('Polling interval updated to $whatsappPollingInterval ms');
    setState(() {});
  }

  void onWhatsappStatusUpdated(WhatsappStatusUpdatedEvent status) {
    if (!mounted) return;

    whatsappStatus = whatsappService.status;
    apiToken = whatsappService.clientToken;
    systemService.showSuccessToast('WhatsApp status updated to $whatsappStatus');
    setState(() {});
  }

  void onSavedPromptsUpdated(SavedPromptsUpdatedEvent event) {
    if (!mounted) return;

    savedPrompts.clear();
    savedPrompts.addAll(geminiService.savedPrompts);

    systemService.showSuccessToast('Saved prompts updated');
    setState(() {});
  }

  Future<void> onDefaultPromptUpdated(DefaultPromptUpdatedEvent event) async {
    if (!mounted) return;

    defaultPrompt = await geminiService.getDefaultPrompt() ?? '';
    systemService.showSuccessToast('Default prompt updated');
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    String lastFetchTime = '';
    if (whatsappService.lastFetchTime != null) {
      lastFetchTime = 'Last fetch: ${whatsappService.lastFetchTime!.toIso8601String()}';
    } else {
      lastFetchTime = 'Last fetch: Never';
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('WhatsApp AI'),
        actions: <Widget>[
          if (whatsappStatus == WhatsappServiceStatus.loggedInIdle) ...<Widget>[
            Text(
              lastFetchTime,
              style: const TextStyle(fontSize: 12, color: Colors.white),
            ),
          ],
          if (whatsappStatus == WhatsappServiceStatus.loggedInIdle) ...<Widget>[
            IconButton(
              icon: const Icon(Icons.refresh),
              onPressed: () async {
                await whatsappService.loadNextMessageWindow();
              },
            ),
          ],
        ],
      ),
      body: Stack(
        children: <Widget>[
          PageView(
            controller: pageController,
            physics: const NeverScrollableScrollPhysics(),
            children: [
              HomeWhatsappConfiguration(
                whatsappStatus: whatsappStatus,
                whatsappService: whatsappService,
              ),
              HomeAIConfigurationPage(
                savedPrompts: savedPrompts,
                defaultPrompt: defaultPrompt,
                textEditingController: promptController,
                onPromptSubmitted: (prompt) async {
                  await geminiService.savePrompt(prompt);
                  promptController.clear();
                },
              ),
              HomeSettingsPage(
                apiToken: apiToken,
                apiTokenController: apiTokenController,
                onApiTokenSubmitted: onWhatsAppTokenSubmitted,
                whatsappIntervalTextController: whatsappIntervalTextController,
                onWhatsappIntervalSubmitted: onWhatsAppIntervalSubmitted,
              ),
            ],
          ),
          if (whatsappStatus == WhatsappServiceStatus.loggedInBusy) ...<Widget>[
            Container(
              width: double.infinity,
              height: double.infinity,
              decoration: const BoxDecoration(color: Colors.black26),
              child: const Center(
                child: CircularProgressIndicator(color: Colors.white),
              ),
            ),
          ],
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: currentPage,
        selectedItemColor: Theme.of(context).primaryColor,
        type: BottomNavigationBarType.shifting,
        items: <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: const Icon(Icons.chat),
            backgroundColor: Theme.of(context).colorScheme.primary,
            label: 'WhatsApp',
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.sentiment_very_satisfied_sharp),
            backgroundColor: Theme.of(context).colorScheme.secondary,
            label: 'AI',
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.settings),
            backgroundColor: Theme.of(context).colorScheme.tertiary,
            label: 'Settings',
          ),
        ],
        onTap: (index) => currentPage = index,
      ),
    );
  }
}

class HomeAIConfigurationPage extends StatelessWidget with AppServicesMixin {
  const HomeAIConfigurationPage({
    required this.savedPrompts,
    required this.defaultPrompt,
    required this.textEditingController,
    required this.onPromptSubmitted,
    super.key,
  });

  final Set<String> savedPrompts;
  final String defaultPrompt;
  final TextEditingController textEditingController;
  final Future<void> Function(String) onPromptSubmitted;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.only(top: 8, left: 8, right: 8),
            itemCount: savedPrompts.length,
            itemBuilder: (context, index) {
              final prompt = savedPrompts.elementAt(index);
              return ListTile(
                title: Text(prompt),
                leading: Radio<String>(
                  value: prompt,
                  groupValue: defaultPrompt,
                  onChanged: (value) async {
                    await geminiService.setDefaultPrompt(value!);
                  },
                ),
                trailing: IconButton(
                  icon: const Icon(Icons.delete),
                  onPressed: () async {
                    await geminiService.removePrompt(prompt);
                  },
                ),
              );
            },
          ),
        ),
        const Divider(),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: TextField(
            controller: textEditingController,
            onSubmitted: onPromptSubmitted,
            decoration: InputDecoration(
              border: const OutlineInputBorder(),
              labelText: 'Enter some prompt guidance here...',
              suffixIcon: IconButton(
                icon: const Icon(Icons.send),
                onPressed: () => onPromptSubmitted(textEditingController.text),
              ),
            ),
          ),
        ),
        const SizedBox(height: 8),
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 8),
          child: Align(
            alignment: Alignment.centerLeft,
            child: Text(
              'Prompt guidance allows you to provide a set of prompts to guide the AI in generating a response. For example, you can provide a set of prompts for different types of customer queries. The AI will use these prompts to generate a response.',
              style: TextStyle(fontSize: 12, color: Colors.white),
            ),
          ),
        ),
        const SizedBox(height: 8),
      ],
    );
  }
}

class HomeWhatsappConfiguration extends StatelessWidget {
  const HomeWhatsappConfiguration({
    super.key,
    required WhatsappServiceStatus? whatsappStatus,
    required this.whatsappService,
  }) : _whatsappStatus = whatsappStatus;

  final WhatsappServiceStatus? _whatsappStatus;
  final AbstractWhatsappService whatsappService;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        if (_whatsappStatus == WhatsappServiceStatus.loggedOut) ...<Widget>[
          const Text(
            'Please enter your WhatsApp API token to get started...',
          ),
        ],
        if (_whatsappStatus == WhatsappServiceStatus.loggedInLoadingInitialMessages || _whatsappStatus == WhatsappServiceStatus.loggedInLoadingPreviousMessages || _whatsappStatus == WhatsappServiceStatus.loggedInLoadingNextMessages)
          const CircularProgressIndicator(),
        if (_whatsappStatus == WhatsappServiceStatus.loggedInIdle)
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(8),
              itemCount: whatsappService.messages.length,
              itemBuilder: (context, index) {
                final message = whatsappService.messages.elementAt(index);
                return MessageTile(
                  message: message,
                  onLongPress: () {
                    whatsappService.replyMessage(message);
                  },
                );
              },
            ),
          ),
      ],
    );
  }
}

class MessageTile extends StatelessWidget {
  const MessageTile({
    required this.message,
    this.onLongPress,
    super.key,
  });

  final Message message;
  final void Function()? onLongPress;

  @override
  Widget build(BuildContext context) {
    return Card(
      color: message.fromMe ? Theme.of(context).colorScheme.tertiary : Theme.of(context).colorScheme.primary,
      child: ListTile(
        isThreeLine: true,
        onLongPress: onLongPress,
        leading: Text(
          message.chatId,
          style: const TextStyle(fontSize: 12, color: Colors.black),
        ),
        title: Text(
          message.text.body,
          style: const TextStyle(fontSize: 16, color: Colors.black),
        ),
        subtitle: Text(
          message.fromName.isEmpty ? message.from : message.fromName,
          style: const TextStyle(fontSize: 12, color: Colors.black),
        ),
        trailing: Text(
          DateTime.fromMillisecondsSinceEpoch(message.timestamp * 1000).toIso8601String(),
          style: const TextStyle(fontSize: 12, color: Colors.black),
        ),
      ),
    );
  }
}

class HomeSettingsPage extends StatelessWidget {
  const HomeSettingsPage({
    required this.apiToken,
    required this.apiTokenController,
    required this.onApiTokenSubmitted,
    required this.whatsappIntervalTextController,
    required this.onWhatsappIntervalSubmitted,
    super.key,
  });

  final String apiToken;
  final TextEditingController apiTokenController;
  final TextEditingController whatsappIntervalTextController;

  final Future<void> Function(String) onApiTokenSubmitted;
  final Future<void> Function(String) onWhatsappIntervalSubmitted;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: <Widget>[
        TextField(
          controller: apiTokenController,
          onSubmitted: onApiTokenSubmitted,
          decoration: const InputDecoration(
            border: OutlineInputBorder(),
            labelText: 'WhatsApp API Token',
            suffixIcon: Icon(Icons.send),
          ),
        ),
        const SizedBox(height: 16),
        TextField(
          controller: whatsappIntervalTextController,
          onSubmitted: onWhatsappIntervalSubmitted,
          decoration: const InputDecoration(
            border: OutlineInputBorder(),
            labelText: 'New Message Polling Interval (ms)',
            suffixIcon: Icon(Icons.send),
          ),
        ),
      ],
    );
  }
}
