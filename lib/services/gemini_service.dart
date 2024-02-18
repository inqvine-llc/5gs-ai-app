import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:whatsapp_ai/events/default_prompt_updated_event.dart';
import 'package:whatsapp_ai/events/saved_prompts_updated_event.dart';
import 'package:whatsapp_ai/main.dart';
import 'package:whatsapp_ai/models/models.dart';

abstract class AbstractGeminiService {
  Future<void> initialize();
  Future<void> dispose();

  Set<String> get savedPrompts;

  Future<void> savePrompt(String prompt);
  Future<void> reloadSavedPrompts();
  Future<void> removePrompt(String prompt);

  Future<String> generateReply(String requestStyle, Message message);

  Future<void> setDefaultPrompt(String prompt);
  Future<String?> getDefaultPrompt();
  Future<void> removeDefaultPrompt();
}

class GeminiService extends AbstractGeminiService with AppServicesMixin {
  @override
  Set<String> savedPrompts = {};

  @override
  Future<void> initialize() async {
    await reloadSavedPrompts();
  }

  @override
  Future<void> dispose() async {
    savedPrompts.clear();
  }

  @override
  Future<void> savePrompt(String prompt) async {
    savedPrompts.add(prompt);
    await sharedPreferences.setStringList(
      'savedPrompts',
      savedPrompts.toList(),
    );

    eventBus.fire(SavedPromptsUpdatedEvent());
  }

  @override
  Future<void> reloadSavedPrompts() async {
    savedPrompts =
        (sharedPreferences.getStringList('savedPrompts') ?? []).toSet();

    eventBus.fire(SavedPromptsUpdatedEvent());
  }

  @override
  Future<void> removePrompt(String prompt) async {
    savedPrompts.remove(prompt);
    await sharedPreferences.setStringList(
      'savedPrompts',
      savedPrompts.toList(),
    );

    eventBus.fire(SavedPromptsUpdatedEvent());
  }

  @override
  Future<String> generateReply(String requestStyle, Message message) async {
    final model = GenerativeModel(
      model: 'gemini-pro',
      apiKey: '',
    );

    final content = [
      Content.text(requestStyle),
      Content.text(message.text.body)
    ];

    final response = await model.generateContent(content);
    return response.text ?? '';
  }

  @override
  Future<void> setDefaultPrompt(String prompt) async {
    await sharedPreferences.setString('defaultPrompt', prompt);
    eventBus.fire(DefaultPromptUpdatedEvent());
  }

  @override
  Future<String?> getDefaultPrompt() async {
    return sharedPreferences.getString('defaultPrompt');
  }

  @override
  Future<void> removeDefaultPrompt() async {
    await sharedPreferences.remove('defaultPrompt');
    eventBus.fire(DefaultPromptUpdatedEvent());
  }
}
