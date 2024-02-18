import 'package:dio/dio.dart';
import 'package:whatsapp_ai/events/messages_updated_event.dart';
import 'package:whatsapp_ai/events/whatsapp_polling_interval_updated_event.dart';
import 'package:whatsapp_ai/events/whatsapp_status_updated_event.dart';
import 'package:whatsapp_ai/main.dart';
import 'package:whatsapp_ai/models/models.dart';

enum WhatsappServiceStatus {
  loggedOut,
  loggedInIdle,
  loggedInLoadingInitialMessages,
  loggedInLoadingPreviousMessages,
  loggedInLoadingNextMessages,
  loggedInBusy,
}

abstract class AbstractWhatsappService with AppServicesMixin {
  Set<Message> get messages;

  String get clientToken;
  bool get isLoggedIn => clientToken.isNotEmpty;

  WhatsappServiceStatus get status;
  int get pollingInterval;
  DateTime? lastFetchTime;

  Future<void> initialize();

  Future<void> login(String newToken);
  Future<void> logout();
  Future<void> replyMessage(Message message);

  Future<void> clearMessages() async {
    messages.clear();
    eventBus.fire(MessagesUpdatedEvent());
  }

  Future<void> loadNextMessageWindow();
  Future<void> updatePollingInterval(int newInterval);
}

class WhatsappService extends AbstractWhatsappService with AppServicesMixin {
  static const String kWhatsappIntervalKey = 'whatsapp_interval';
  static const String kWhatsappTokenKey = 'whatsapp_token';

  @override
  Set<Message> messages = {};

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

  int _pollingInterval = 5000;

  @override
  int get pollingInterval => _pollingInterval;

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

    final int? savedInterval = sharedPreferences.getInt(kWhatsappIntervalKey);
    if (savedInterval != null) {
      _pollingInterval = savedInterval;
    }

    final String savedToken = sharedPreferences.getString(kWhatsappTokenKey) ?? '';
    if (!isLoggedIn && savedToken.isNotEmpty) {
      await login(savedToken);
    }
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

    messages.clear();
    await loadNextMessageWindow();
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
  Future<void> loadNextMessageWindow() async {
    if (!isLoggedIn) {
      throw Exception('Not logged in');
    }

    final bool isInitialLoad = messages.isEmpty;
    status = isInitialLoad ? WhatsappServiceStatus.loggedInLoadingInitialMessages : WhatsappServiceStatus.loggedInLoadingNextMessages;

    try {
      final response = await whapiClient.get(
        'messages/list',
        options: Options(headers: apiHeaders),
      );

      if (response.statusCode != 200) {
        throw Exception('Failed to load messages');
      }

      final List<dynamic> messagesJson = (response.data as Map<String, Object?>).containsKey('messages') ? (response.data as Map<String, Object?>)['messages'] as List<dynamic> : [];

      final List<Message> newMessages = [];
      for (final messageJson in messagesJson) {
        newMessages.add(Message.fromJson(messageJson));
      }

      lastFetchTime = DateTime.now();
      messages.addAll(newMessages);
      eventBus.fire(MessagesUpdatedEvent());
    } finally {
      status = WhatsappServiceStatus.loggedInIdle;
    }
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
  Future<void> replyMessage(Message message) async {
    if (!isLoggedIn) {
      throw Exception('Not logged in');
    }

    if (status != WhatsappServiceStatus.loggedInIdle) {
      throw Exception('Service is busy');
    }

    const String defaultPrompt = 'You are a helpful assistant!';
    final String defaultReply = await geminiService.getDefaultPrompt() ?? '';

    // final String replyPrompt = defaultPromptStyle.isEmpty
    //     ? defaultPrompt
    //     : '$defaultPrompt\n\n$defaultPromptStyle';

    status = WhatsappServiceStatus.loggedInBusy;

    try {
      final response = await whapiClient.post(
        'messages/text',
        options: Options(headers: apiHeaders),
        data: {
          'to': message.chatId,
          'body': defaultReply,
          'quotedMessageId': message.id,
        },
      );

      if (response.statusCode != 200) {
        throw Exception('Failed to send message');
      }

      messages.clear();
      await loadNextMessageWindow();
    } finally {
      status = WhatsappServiceStatus.loggedInIdle;
    }
  }
}
