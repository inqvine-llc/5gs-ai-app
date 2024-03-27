import 'package:flutter/material.dart';
import 'package:whatsapp_ai/main.dart';

class HomePersonaPage extends StatelessWidget with AppServicesMixin {
  const HomePersonaPage({
    required this.personaTextController,
    required this.personaSuggestions,
    required this.onPersonaStatementSubmitted,
    required this.onPersonaSuggestionSelected,
    this.isLoadingSuggestions = false,
    super.key,
  });

  final TextEditingController personaTextController;
  final List<String> personaSuggestions;
  final void Function(String) onPersonaStatementSubmitted;
  final void Function(String) onPersonaSuggestionSelected;

  final bool isLoadingSuggestions;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              'Enter a persona statement, and AI will help generate system messages to match.',
              style: Theme.of(context).textTheme.titleSmall,
            ),
            const SizedBox(height: 16.0),
            TextField(
              controller: personaTextController,
              maxLines: 3,
              enabled: !isLoadingSuggestions,
              decoration: const InputDecoration(
                hintText: 'Enter a persona statement',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16.0),
            IgnorePointer(
              ignoring: isLoadingSuggestions,
              child: ElevatedButton(
                onPressed: () => onPersonaStatementSubmitted(personaTextController.text),
                child: const Text('Generate System Messages'),
              ),
            ),
            if (isLoadingSuggestions) ...<Widget>[
              const Padding(
                padding: EdgeInsets.all(16.0),
                child: CircularProgressIndicator(),
              ),
            ],
            if (!isLoadingSuggestions && personaSuggestions.isNotEmpty) ...<Widget>[
              const SizedBox(height: 16.0),
              Text(
                'Persona Suggestions',
                style: Theme.of(context).textTheme.titleSmall,
              ),
              const SizedBox(height: 16.0),
              Wrap(
                spacing: 8.0,
                runSpacing: 8.0,
                children: personaSuggestions
                    .map(
                      (String suggestion) => ActionChip(
                        label: Text(suggestion),
                        onPressed: () => onPersonaSuggestionSelected(suggestion),
                      ),
                    )
                    .toList(),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
