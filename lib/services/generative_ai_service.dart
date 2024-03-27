import 'package:dio/dio.dart';

import 'package:whatsapp_ai/events/events.dart';
import 'package:whatsapp_ai/main.dart';
import 'package:whatsapp_ai/models/models.dart';
import 'package:dart_openai/dart_openai.dart';
import 'package:whatsapp_ai/services/system_service.dart';

abstract class AbstractGenerativeAIService {
  String get apiKey;
  String get defaultModel;

  String get langchainServerUrl;

  Set<String> get defaultPromptGuidance;
  Set<String> get defaultPromptContent;

  Set<String> get allPromptGuidance;
  Set<String> get allPromptContent;

  bool get isLoggedIn => apiKey.isNotEmpty;

  Future<void> initialize();
  Future<void> dispose();

  Future<void> savePromptGuidance(String prompt);
  Future<void> reloadDefaultGuidance();
  Future<void> reloadAllGuidance();
  Future<void> removePromptGuidance(String prompt);

  Future<void> savePromptContent(String prompt);
  Future<void> reloadDefaultContent();
  Future<void> reloadAllContent();
  Future<void> removePromptContent(String prompt);

  Future<String> generateReply(Message messageContainingPrompt, Map<OpenAIChatMessageRole, Set<String>> params);

  Future<void> setApiKey(String apiKey);

  Future<void> setDefaultPromptGuidance(Iterable<String> prompts);
  Future<Iterable<String>> getDefaultPromptGuidance();
  Future<void> removeDefaultPromptGuidance();

  Future<void> setDefaultPromptContent(Iterable<String> prompts);
  Future<Iterable<String>> getDefaultPromptContent();
  Future<void> removeDefaultPromptContent();

  Future<void> saveDefaultModel(String model);
  Future<void> removeDefaultModel();

  Future<void> reloadLangchainServerUrl();
  Future<void> setLangchainServerUrl(String url);

  Future<String> performOpenAICompletion(Iterable<OpenAIChatCompletionChoiceMessageModel> requestMessages);
}

enum SupportedModel {
  gpt3,
  gpt35Turbo,
  gpt4,
  customLangchainServer;

  String get name {
    switch (this) {
      case SupportedModel.gpt3:
        return 'gpt-3';
      case SupportedModel.gpt35Turbo:
        return 'gpt-3.5-turbo';
      case SupportedModel.gpt4:
        return 'gpt-4';
      case SupportedModel.customLangchainServer:
        return 'custom-langchain-server';
    }
  }
}

class GenerativeAIService extends AbstractGenerativeAIService with AppServicesMixin {
  static const String kOpenaiApiKey = 'openaiApiKey';
  static const String kDefaultModel = 'defaultModel';

  static const String kAllGuidanceKey = 'responseGuidance';
  static const String kAllContentKey = 'responseContent';

  static const String kDefaultGuidanceKey = 'defaultResponseGuidance';
  static const String kDefaultContentKey = 'defaultResponseContent';

  static const String kLangchainServerUrlKey = 'langchainServerUrl';

  String _apiKey = '';

  @override
  String get apiKey => _apiKey;

  String _langchainServerUrl = '';

  @override
  String get langchainServerUrl => _langchainServerUrl;

  @override
  String get defaultModel => sharedPreferences.getString(kDefaultModel) ?? 'gpt-3.5-turbo';

  @override
  Set<String> defaultPromptGuidance = {};

  @override
  Set<String> defaultPromptContent = {};

  @override
  Set<String> allPromptGuidance = {};

  @override
  Set<String> allPromptContent = {};

  @override
  Future<void> initialize() async {
    await Future.wait([
      reloadDefaultGuidance(),
      reloadDefaultContent(),
      reloadAllGuidance(),
      reloadAllContent(),
      reloadLangchainServerUrl(),
    ]);

    _apiKey = sharedPreferences.getString(kOpenaiApiKey) ?? '';
    if (_apiKey.isNotEmpty) {
      OpenAI.apiKey = _apiKey;
      eventBus.fire(OpenAIApiKeyUpdatedEvent());
    }
  }

  @override
  Future<void> dispose() async {
    allPromptContent.clear();
    allPromptGuidance.clear();
    defaultPromptGuidance.clear();
    defaultPromptContent.clear();
  }

  @override
  Future<void> savePromptGuidance(String prompt) async {
    allPromptGuidance.add(prompt);
    await sharedPreferences.setStringList(
      kDefaultGuidanceKey,
      allPromptGuidance.toList(),
    );

    eventBus.fire(ResponseGuidanceUpdatedEvent());
  }

  @override
  Future<void> reloadDefaultGuidance() async {
    defaultPromptGuidance = (sharedPreferences.getStringList(kDefaultGuidanceKey) ?? []).toSet();
    eventBus.fire(ResponseGuidanceUpdatedEvent());
  }

  @override
  Future<void> reloadDefaultContent() async {
    defaultPromptContent = (sharedPreferences.getStringList(kDefaultContentKey) ?? []).toSet();
    eventBus.fire(ResponseContentUpdatedEvent());
  }

  @override
  Future<void> reloadAllGuidance() async {
    allPromptGuidance = (sharedPreferences.getStringList(kAllGuidanceKey) ?? []).toSet();
    eventBus.fire(ResponseGuidanceUpdatedEvent());
  }

  @override
  Future<void> reloadAllContent() async {
    allPromptContent = (sharedPreferences.getStringList(kAllContentKey) ?? []).toSet();
    eventBus.fire(ResponseContentUpdatedEvent());
  }

  @override
  Future<void> removePromptGuidance(String prompt) async {
    allPromptGuidance.remove(prompt);
    await sharedPreferences.setStringList(
      kDefaultGuidanceKey,
      allPromptGuidance.toList(),
    );

    eventBus.fire(ResponseGuidanceUpdatedEvent());
  }

  @override
  Future<void> savePromptContent(String prompt) async {
    allPromptContent.add(prompt);
    await sharedPreferences.setStringList(
      kDefaultContentKey,
      allPromptContent.toList(),
    );

    eventBus.fire(ResponseContentUpdatedEvent());
  }

  @override
  Future<void> removePromptContent(String prompt) async {
    allPromptContent.remove(prompt);
    await sharedPreferences.setStringList(
      kDefaultContentKey,
      allPromptContent.toList(),
    );

    eventBus.fire(ResponseContentUpdatedEvent());
  }

  @override
  Future<void> setApiKey(String apiKey) async {
    if (apiKey.isEmpty) {
      throw Exception('API key cannot be empty');
    }

    _apiKey = apiKey;
    OpenAI.apiKey = apiKey;

    await sharedPreferences.setString(kOpenaiApiKey, apiKey);
    eventBus.fire(OpenAIApiKeyUpdatedEvent());
  }

  @override
  Future<String> generateReply(Message messageContainingPrompt, Map<OpenAIChatMessageRole, Set<String>> params) async {
    try {
      final String messageText = messageContainingPrompt.text.body;
      if (messageText.isEmpty) {
        systemService.showErrorToast('Message cannot be empty');
        return '';
      }

      if (!isLoggedIn) {
        systemService.showErrorToast('OpenAI API key is not set');
        return '';
      }

      final requestMessages = params.entries.map((entry) {
        return OpenAIChatCompletionChoiceMessageModel(
          role: entry.key,
          content: entry.value.map((e) => OpenAIChatCompletionChoiceMessageContentItemModel.text(e)).toList(),
        );
      });

      if (defaultModel == SupportedModel.customLangchainServer.name) {
        return await performLangchainServerCompletion(messageText, requestMessages);
      }

      return await performOpenAICompletion(requestMessages);
    } catch (e) {
      systemService.showErrorToast('Failed to generate reply');
      rethrow;
    }
  }

  Future<String> performLangchainServerCompletion(String messageText, Iterable<OpenAIChatCompletionChoiceMessageModel> requestMessages) async {
    final List<Map<String, dynamic>> choices = [];
    for (final OpenAIChatCompletionChoiceMessageModel message in requestMessages) {
      final choice = {
        'role': message.role.name,
        'content': message.content?.map((e) => e.text).join(' ') ?? '',
      };

      choices.add(choice);
    }

    if (!di.isRegistered<Dio>(instanceName: 'langchainServer')) {
      throw Exception('Langchain server is not registered');
    }

    final Response response = await langchainDio.post(
      '/answer_prompt',
      data: {
        'prompt': messageText,
        'choices': choices,
      },
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to complete the request');
    }

    final Map<String, dynamic> data = response.data;
    return data.containsKey('response') ? data['response'] : '';
  }

  @override
  Future<String> performOpenAICompletion(Iterable<OpenAIChatCompletionChoiceMessageModel> requestMessages) async {
    final OpenAIChatCompletionModel completion = await OpenAI.instance.chat.create(
      model: 'gpt-3.5-turbo',
      messages: requestMessages.toList(),
      maxTokens: 100,
      temperature: 0.5,
      topP: 1,
      frequencyPenalty: 0,
      presencePenalty: 0,
      stop: ['\n'],
    );

    if (completion.choices.isEmpty) {
      throw Exception('No completion choices');
    }

    return completion.choices.first.message.content?.firstOrNull?.text ?? '';
  }

  @override
  Future<void> setDefaultPromptGuidance(Iterable<String> prompts) async {
    await sharedPreferences.setStringList(kDefaultGuidanceKey, prompts.toList());
    defaultPromptGuidance = prompts.toSet();
    eventBus.fire(ResponseGuidanceUpdatedEvent());
  }

  @override
  Future<Iterable<String>> getDefaultPromptGuidance() async {
    return sharedPreferences.getStringList(kDefaultGuidanceKey) ?? [];
  }

  @override
  Future<void> removeDefaultPromptGuidance() async {
    await sharedPreferences.remove(kDefaultGuidanceKey);
    defaultPromptGuidance.clear();
    eventBus.fire(ResponseGuidanceUpdatedEvent());
  }

  @override
  Future<void> setDefaultPromptContent(Iterable<String> prompts) async {
    await sharedPreferences.setStringList(kDefaultContentKey, prompts.toList());
    defaultPromptContent = prompts.toSet();
    eventBus.fire(ResponseContentUpdatedEvent());
  }

  @override
  Future<Iterable<String>> getDefaultPromptContent() async {
    return sharedPreferences.getStringList(kDefaultContentKey) ?? [];
  }

  @override
  Future<void> removeDefaultPromptContent() async {
    await sharedPreferences.remove(kDefaultContentKey);
    defaultPromptContent.clear();
    eventBus.fire(ResponseContentUpdatedEvent());
  }

  @override
  Future<void> saveDefaultModel(String model) async {
    await sharedPreferences.setString(kDefaultModel, model);
    eventBus.fire(ModelUpdatedEvent());
  }

  @override
  Future<void> removeDefaultModel() async {
    await sharedPreferences.remove(kDefaultModel);
    eventBus.fire(ModelUpdatedEvent());
  }

  @override
  Future<void> reloadLangchainServerUrl() async {
    _langchainServerUrl = sharedPreferences.getString(kLangchainServerUrlKey) ?? '';

    await _reloadLangchainDio();

    eventBus.fire(LangchainServerUrlUpdatedEvent());
  }

  @override
  Future<void> setLangchainServerUrl(String url) async {
    _langchainServerUrl = url;

    await sharedPreferences.setString(kLangchainServerUrlKey, url);
    await _reloadLangchainDio();

    if (di.isRegistered<AbstractSystemService>()) {
      systemService.showInformationToast('Langchain server URL updated to $url');
    }

    eventBus.fire(LangchainServerUrlUpdatedEvent());
  }

  Future<void> _reloadLangchainDio() async {
    if (di.isRegistered<Dio>(instanceName: 'langchainServer')) {
      await di.unregister<Dio>(instanceName: 'langchainServer');
    }

    if (_langchainServerUrl.isEmpty) {
      return;
    }

    di.registerSingleton<Dio>(Dio(BaseOptions(baseUrl: _langchainServerUrl)), instanceName: 'langchainServer');
    eventBus.fire(LangchainServerUrlUpdatedEvent());
  }
}
