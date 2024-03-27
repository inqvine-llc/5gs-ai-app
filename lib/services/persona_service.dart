import 'package:dart_openai/dart_openai.dart';
import 'package:whatsapp_ai/main.dart';

abstract class AbstractPersonaService {
  Future<List<String>> generatePersonaFromStatement(String personaStatement);
}

class PersonaService with AppServicesMixin implements AbstractPersonaService {
  @override
  Future<List<String>> generatePersonaFromStatement(String personaStatement) async {
    if (personaStatement.isEmpty) {
      return <String>[];
    }

    final List<String> suggestionModelPrompts = [
      'Using the persona statement "$personaStatement", generate system messages that match the persona.',
      'Provide the suggested system messages only, with new lines separating each message.',
    ];

    final Iterable<OpenAIChatCompletionChoiceMessageModel> personaExtractionMessages = <OpenAIChatCompletionChoiceMessageModel>[
      OpenAIChatCompletionChoiceMessageModel(
        role: OpenAIChatMessageRole.system,
        content: suggestionModelPrompts.map((prompt) => OpenAIChatCompletionChoiceMessageContentItemModel.text(prompt)).toList(),
      ),
    ];

    final String aiSuggestion = await generativeAIService.performOpenAICompletion(personaExtractionMessages);
    if (aiSuggestion.isEmpty) {
      return <String>[];
    }

    return <String>[aiSuggestion];
  }
}
