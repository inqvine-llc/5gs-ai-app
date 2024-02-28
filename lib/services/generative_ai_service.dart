import 'package:whatsapp_ai/events/model_updated_event.dart';
import 'package:whatsapp_ai/events/response_content_updated_event.dart';
import 'package:whatsapp_ai/events/response_guidance_updated_event.dart';
import 'package:whatsapp_ai/events/open_ai_api_key_updated_event.dart';
import 'package:whatsapp_ai/main.dart';
import 'package:whatsapp_ai/models/models.dart';
import 'package:dart_openai/dart_openai.dart';

abstract class AbstractGenerativeAIService {
  String get apiKey;
  String get defaultModel;

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
}

enum SupportedModel {
  gpt3,
  gpt35Turbo,
  gpt4;

  String get name {
    switch (this) {
      case SupportedModel.gpt3:
        return 'gpt-3';
      case SupportedModel.gpt35Turbo:
        return 'gpt-3.5-turbo';
      case SupportedModel.gpt4:
        return 'gpt-4';
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

  String _apiKey = '';

  @override
  String get apiKey => _apiKey;

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
}
