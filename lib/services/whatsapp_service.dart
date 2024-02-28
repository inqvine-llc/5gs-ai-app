import 'dart:async';

import 'package:cron/cron.dart';
import 'package:dart_openai/dart_openai.dart';
import 'package:dio/dio.dart';
import 'package:whatsapp_ai/events/messages_updated_event.dart';
import 'package:whatsapp_ai/events/whatsapp_auto_reply_changed_event.dart';
import 'package:whatsapp_ai/events/whatsapp_chat_selected_event.dart';
import 'package:whatsapp_ai/events/whatsapp_polling_interval_updated_event.dart';
import 'package:whatsapp_ai/events/whatsapp_status_updated_event.dart';
import 'package:whatsapp_ai/events/whatsapp_typing_time_changed_event.dart';
import 'package:whatsapp_ai/main.dart';
import 'package:whatsapp_ai/models/models.dart';
import 'package:whatsapp_ai/services/system_service.dart';

enum WhatsappServiceStatus {
  loggedOut,
  loggedInIdle,
  loggedInLoadingInitialMessages,
  loggedInLoadingPreviousMessages,
  loggedInLoadingFirstMessages,
  loggedInLoadingNextMessages,
  loggedInBusy,
}

abstract class AbstractWhatsappService with AppServicesMixin {
  Map<Chat, List<Message>> get messages;
  Map<Chat, DateTime> get lastFetchTimes;
  Map<Chat, bool> get messageEndReached;
  DateTime? lastFetchTime;

  String get selectedChatId;
  set selectedChatId(String value);

  String get clientToken;
  bool get isLoggedIn => clientToken.isNotEmpty;

  WhatsappServiceStatus get status;

  ScheduledTask? pollingTask;
  int get pollingInterval;

  int get typingTime;
  bool get autoReplyEnabled;

  Future<void> initialize();

  Future<void> login(String newToken);
  Future<void> logout();
  Future<void> replyMessage(Message message, String body);

  Future<void> clearMessages() async {
    messages.clear();
    eventBus.fire(MessagesUpdatedEvent());
  }

  Future<void> loadConversations();
  Future<void> lookForNewMessagesFromAllConversations();
  Future<void> loadMessagesForChat(Chat chat, {int offset = 0, int limit = 20});

  Future<void> appendMessages(List<Message> newMessages, {bool notifyOnNewMessages = true, bool autoReplyOnNewMessages = true});
  Future<void> updatePollingInterval(int newInterval);

  Future<void> updateTypingTime(int newTypingTime);

  Future<void> setAutoReplyEnabled(bool enabled);
}

class WhatsappService extends AbstractWhatsappService with AppServicesMixin {
  static const String kWhatsappIntervalKey = 'whatsapp_interval';
  static const String kWhatsappTokenKey = 'whatsapp_token';
  static const String kWhatsappAutoReplyEnabledKey = 'whatsapp_auto_reply_enabled';
  static const String kWhatsappTypingTimeKey = 'whatsapp_typing_time';

  static const int kWindowLength = 20;

  StreamSubscription<WhatsppPollingIntervalUpdatedEvent>? _pollingIntervalUpdatedEventSubscription;

  @override
  Map<Chat, List<Message>> messages = {};

  @override
  Map<Chat, DateTime> lastFetchTimes = {};

  @override
  Map<Chat, bool> messageEndReached = {};

  DateTime? _lastFetchTime;

  @override
  DateTime? get lastFetchTime => _lastFetchTime;

  Map<String, String> get apiHeaders => {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        'Authorization': 'Bearer $clientToken',
      };

  String _clientToken = '';

  @override
  String get clientToken => _clientToken;
  set clientToken(String value) {
    _clientToken = value;
  }

  int _typingTime = 3;

  @override
  int get typingTime => _typingTime;

  int _pollingInterval = 5000;

  @override
  int get pollingInterval => _pollingInterval;

  String _selectedChatId = '';

  @override
  String get selectedChatId => _selectedChatId;

  set selectedChatId(String value) {
    if (value == _selectedChatId) {
      return;
    }

    _selectedChatId = value;
    eventBus.fire(WhatsappChatSelectedEvent());
  }

  ScheduledTask? _pollingTask;

  @override
  ScheduledTask? get pollingTask => _pollingTask;

  bool _autoReplyEnabled = false;

  @override
  bool get autoReplyEnabled => _autoReplyEnabled;

  WhatsappServiceStatus _status = WhatsappServiceStatus.loggedOut;
  set status(WhatsappServiceStatus value) {
    _status = value;
    eventBus.fire(WhatsappStatusUpdatedEvent());
  }

  @override
  WhatsappServiceStatus get status => _status;

  @override
  Future<void> initialize() async {
    if (isLoggedIn) {
      status = WhatsappServiceStatus.loggedInIdle;
    } else {
      status = WhatsappServiceStatus.loggedOut;
    }

    final int? savedTypingTime = sharedPreferences.getInt(kWhatsappTypingTimeKey);
    if (savedTypingTime != null) {
      _typingTime = savedTypingTime;
    }

    final int? savedInterval = sharedPreferences.getInt(kWhatsappIntervalKey);
    if (savedInterval != null) {
      _pollingInterval = savedInterval;
    }

    final bool? savedAutoReplyEnabled = sharedPreferences.getBool(kWhatsappAutoReplyEnabledKey);
    if (savedAutoReplyEnabled != null) {
      _autoReplyEnabled = savedAutoReplyEnabled;
    }

    final String savedToken = sharedPreferences.getString(kWhatsappTokenKey) ?? '';
    if (!isLoggedIn && savedToken.isNotEmpty) {
      await login(savedToken);
    }

    setupListeners();
    setupCronSchedule();
  }

  Future<void> setupListeners() async {
    await _pollingIntervalUpdatedEventSubscription?.cancel();
    _pollingIntervalUpdatedEventSubscription = eventBus.on<WhatsppPollingIntervalUpdatedEvent>().listen((_) => setupCronSchedule());
  }

  Future<void> setupCronSchedule() async {
    await _pollingTask?.cancel();

    // Convert polling interval to seconds from milliseconds
    final int seconds = pollingInterval ~/ 1000;
    final Schedule schedule = Schedule.parse('*/$seconds * * * * *');
    _pollingTask = cron.schedule(schedule, onPollingIntervalTick);
  }

  void onPollingIntervalTick() async {
    if (status != WhatsappServiceStatus.loggedInIdle) {
      return;
    }

    if (DateTime.now().difference(lastFetchTime ?? DateTime.now()).inMilliseconds < pollingInterval) {
      return;
    }

    await lookForNewMessagesFromAllConversations();
  }

  @override
  Future<void> login(String newToken) async {
    if (newToken.isEmpty) {
      throw Exception('Invalid token');
    }

    if (isLoggedIn) {
      throw Exception('Already logged in');
    }

    clientToken = newToken;
    status = WhatsappServiceStatus.loggedInIdle;
    await sharedPreferences.setString(kWhatsappTokenKey, newToken);

    await clearMessages();
    await loadConversations();
  }

  @override
  Future<void> logout() async {
    if (!isLoggedIn) {
      throw Exception('Not logged in');
    }

    clientToken = '';
    status = WhatsappServiceStatus.loggedOut;
  }

  @override
  Future<void> loadConversations() async {
    if (!isLoggedIn) {
      throw Exception('Not logged in');
    }

    final bool isInitialLoad = messages.isEmpty;
    status = isInitialLoad ? WhatsappServiceStatus.loggedInLoadingInitialMessages : WhatsappServiceStatus.loggedInLoadingFirstMessages;

    if (di.isRegistered<AbstractSystemService>()) {
      systemService.showInformationToast('Refreshing messages from WhatsApp...');
    }

    try {
      final Response chatResponse = await whapiClient.get(
        'chats',
        options: Options(headers: apiHeaders),
      );

      if (chatResponse.statusCode != 200) {
        throw Exception('Failed to load messages');
      }

      final List<dynamic> chatsJson = (chatResponse.data as Map<String, Object?>).containsKey('chats') ? (chatResponse.data as Map<String, Object?>)['chats'] as List<dynamic> : [];
      final List<Chat> newChats = chatsJson.map((chatJson) => Chat.fromJson(chatJson)).toList();
      for (final chat in newChats) {
        if (!messages.containsKey(chat)) {
          messages[chat] = [];
        }
      }
    } finally {
      status = WhatsappServiceStatus.loggedInIdle;
    }
  }

  @override
  Future<void> loadMessagesForChat(Chat chat, {int offset = 0, int limit = 20}) async {
    if (!isLoggedIn) {
      throw Exception('Not logged in');
    }

    status = WhatsappServiceStatus.loggedInLoadingPreviousMessages;
    if (di.isRegistered<AbstractSystemService>()) {
      systemService.showInformationToast('Loading previous messages from WhatsApp...');
    }

    try {
      final Response messageResponse = await whapiClient.get(
        'messages/list/${chat.id}',
        options: Options(headers: apiHeaders),
        queryParameters: {
          'offset': offset,
          'limit': limit,
        },
      );

      if (messageResponse.statusCode != 200) {
        throw Exception('Failed to load messages');
      }

      final List<dynamic> messagesJson = (messageResponse.data as Map<String, Object?>).containsKey('messages') ? (messageResponse.data as Map<String, Object?>)['messages'] as List<dynamic> : [];
      final List<Message> newMessages = messagesJson.map((messageJson) => Message.fromWhapiJson(messageJson)).toList();

      // Check if we have reached the end of the messages
      final bool endReached = newMessages.length < kWindowLength;
      messageEndReached[chat] = endReached;

      await appendMessages(newMessages, notifyOnNewMessages: false, autoReplyOnNewMessages: false);
    } finally {
      status = WhatsappServiceStatus.loggedInIdle;
    }
  }

  @override
  Future<void> lookForNewMessagesFromAllConversations() async {
    if (!isLoggedIn) {
      throw Exception('Not logged in');
    }

    if (status != WhatsappServiceStatus.loggedInIdle) {
      throw Exception('Service is busy');
    }

    status = WhatsappServiceStatus.loggedInLoadingNextMessages;

    if (di.isRegistered<AbstractSystemService>()) {
      systemService.showInformationToast('Looking for new messages from WhatsApp...');
    }

    try {
      final response = await whapiClient.get(
        'messages/list',
        options: Options(headers: apiHeaders),
        data: {
          'time_from': lastFetchTime?.millisecondsSinceEpoch,
          'time_to': DateTime.now().millisecondsSinceEpoch,
        },
      );

      if (response.statusCode != 200) {
        throw Exception('Failed to load messages');
      }

      final List<dynamic> messagesJson = (response.data as Map<String, Object?>).containsKey('messages') ? (response.data as Map<String, Object?>)['messages'] as List<dynamic> : [];
      final List<Message> newMessages = [];
      for (final messageJson in messagesJson) {
        newMessages.add(Message.fromWhapiJson(messageJson));
      }

      await appendMessages(newMessages);
    } finally {
      status = WhatsappServiceStatus.loggedInIdle;
    }
  }

  @override
  Future<void> appendMessages(List<Message> newMessages, {bool notifyOnNewMessages = true, bool autoReplyOnNewMessages = true}) async {
    if (!isLoggedIn) {
      throw Exception('Not logged in');
    }

    try {
      final Set<Message> actualNewMessages = {};
      for (final message in newMessages) {
        final String chatId = message.chatId;
        if (chatId.isEmpty) {
          //! TODO - Load the conversation from the API
          continue;
        }

        final Chat? chat = messages.keys.any((element) => element.id == chatId) ? messages.keys.firstWhere((element) => element.id == chatId) : null;
        if (chat == null) {
          continue;
        }

        messages[chat] ??= [];
        final bool isNew = !(messages[chat]?.any((element) => element.id == message.id) ?? false);
        if (isNew) {
          actualNewMessages.add(message);
          messages[chat]!.add(message);
        } else {
          final int index = messages[chat]!.indexWhere((element) => element.id == message.id);
          messages[chat]![index] = message;
        }

        lastFetchTimes[chat] = DateTime.now();
      }

      // sort messages by timestamp
      for (final chatId in messages.keys) {
        messages[chatId]!.sort((a, b) => b.timestamp.compareTo(a.timestamp));
      }

      if (notifyOnNewMessages && actualNewMessages.isNotEmpty && di.isRegistered<AbstractSystemService>()) {
        systemService.showInformationToast('New messages found: ${actualNewMessages.length}');
      }

      // UNCOMMENT FOR AUTO REPLIES
      // if (autoReplyOnNewMessages && autoReplyEnabled) {
      //   for (final message in actualNewMessages) {
      //     if (message.fromMe) {
      //       continue;
      //     }

      //     // Check if we have a reply for the message
      //     final MessageQuotationData? replyData = MessageQuotationData.fromMessageContext(message.context);
      //     bool hasReply = false;
      //     if (replyData != null) {
      //       final Message? replyMessage = messages[message.chatId]?.firstWhere((m) => m.id == replyData.quotedId, orElse: () => Message.empty());
      //       final bool isReplyFromMe = replyMessage?.fromMe ?? false;
      //       if (isReplyFromMe) {
      //         hasReply = true;
      //       }
      //     }

      //     if (!isFirstLoad && !hasReply && di.isRegistered<AbstractGenerativeAIService>()) {
      //       final Map<OpenAIChatMessageRole, Set<String>> content = <OpenAIChatMessageRole, Set<String>>{};
      //       content[OpenAIChatMessageRole.system] = generativeAIService.defaultPromptGuidance;
      //       content[OpenAIChatMessageRole.assistant] = generativeAIService.defaultPromptContent;

      //       if (di.isRegistered<AbstractSystemService>()) {
      //         await systemService.showInformationToast('Generating reply for message from ${message.fromName}...');
      //       }

      //       final String reply = await generativeAIService.generateReply(message, content);
      //       if (reply.isNotEmpty) {
      //         if (di.isRegistered<AbstractSystemService>()) {
      //           await systemService.showSuccessToast('Sending reply ($reply) in $typingTime seconds...');
      //         }

      //         await replyMessage(message, reply);
      //       } else {
      //         if (di.isRegistered<AbstractSystemService>()) {
      //           await systemService.showErrorToast('Failed to generate reply for message from ${message.from}');
      //         }
      //       }
      //     }
      //   }
      // }

      lastFetchTime = DateTime.now();
      eventBus.fire(MessagesUpdatedEvent());
    } finally {
      status = WhatsappServiceStatus.loggedInIdle;
    }
  }

  @override
  Future<void> updateTypingTime(int newTypingTime) async {
    if (newTypingTime < 1) {
      throw Exception('Typing time too short');
    }

    _typingTime = newTypingTime;
    await sharedPreferences.setInt(kWhatsappTypingTimeKey, newTypingTime);
    eventBus.fire(WhatsappTypingTimeChangedEvent());
  }

  @override
  Future<void> updatePollingInterval(int newInterval) async {
    if (newInterval < 1000) {
      throw Exception('Interval too short');
    }

    _pollingInterval = newInterval;
    await sharedPreferences.setInt(kWhatsappIntervalKey, newInterval);

    eventBus.fire(WhatsppPollingIntervalUpdatedEvent());
  }

  @override
  Future<void> replyMessage(Message message, String body) async {
    if (!isLoggedIn) {
      throw Exception('Not logged in');
    }

    if (status != WhatsappServiceStatus.loggedInIdle && status != WhatsappServiceStatus.loggedInLoadingNextMessages) {
      throw Exception('Invalid service status');
    }

    status = WhatsappServiceStatus.loggedInBusy;

    try {
      final Response<Map<String, dynamic>> response = await whapiClient.post(
        'messages/text',
        options: Options(headers: apiHeaders),
        data: {
          'to': message.chatId,
          'body': body,
          'quoted': message.id,
          'typing_time': typingTime,
        },
      );

      if (response.statusCode != 200) {
        throw Exception('Failed to send message');
      }

      final Map<String, dynamic> messageResponse = response.data?.containsKey('message') ?? false ? response.data!['message'] as Map<String, dynamic> : {};
      final Message sentMessage = Message.fromWhapiJson(messageResponse);
      await appendMessages([sentMessage], notifyOnNewMessages: false, autoReplyOnNewMessages: false);
    } finally {
      status = WhatsappServiceStatus.loggedInIdle;
    }
  }

  @override
  Future<void> setAutoReplyEnabled(bool enabled) async {
    _autoReplyEnabled = enabled;
    await sharedPreferences.setBool(kWhatsappAutoReplyEnabledKey, enabled);
    eventBus.fire(WhatsappAutoReplyChangedEvent());
  }
}
