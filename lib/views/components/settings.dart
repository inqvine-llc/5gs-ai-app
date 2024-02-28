import 'package:flutter/material.dart';
import 'package:simple_icons/simple_icons.dart';
import 'package:whatsapp_ai/extensions/yaru_extensions.dart';
import 'package:whatsapp_ai/main.dart';
import 'package:whatsapp_ai/services/generative_ai_service.dart';
import 'package:whatsapp_ai/services/whatsapp_service.dart';
import 'package:yaru/yaru.dart';
import 'package:yaru_icons/yaru_icons.dart';
import 'package:yaru_widgets/widgets.dart';

class HomeSettingsPage extends StatelessWidget with AppServicesMixin {
  const HomeSettingsPage({
    required this.whatApiToken,
    required this.openaiApiToken,
    required this.defaultModel,
    required this.yaruVariant,
    required this.isDarkMode,
    required this.whatsappTypingTime,
    required this.openaiApiTokenTextController,
    required this.whapiApiTokenTextController,
    required this.onWhapiApiTokenSubmitted,
    required this.onOpenaiApiTokenSubmitted,
    required this.whatsappIntervalTextController,
    required this.onWhatsappIntervalSubmitted,
    required this.onModelChangeRequested,
    required this.onThemeChangeRequested,
    required this.onDarkModeChangeRequested,
    required this.whatsappAutoReplyEnabled,
    required this.whatsappTypingTimeTextController,
    required this.onWhatsappTypingTimeChangeRequested,
    required this.onWhatsappAutoReplyChangeRequested,
    this.parentalPaddingApplied = false,
    super.key,
  });

  final String whatApiToken;
  final String openaiApiToken;
  final String defaultModel;
  final YaruVariant yaruVariant;
  final bool isDarkMode;
  final int whatsappTypingTime;
  final bool whatsappAutoReplyEnabled;

  final TextEditingController openaiApiTokenTextController;
  final TextEditingController whapiApiTokenTextController;
  final TextEditingController whatsappIntervalTextController;
  final TextEditingController whatsappTypingTimeTextController;

  final Future<void> Function(String) onOpenaiApiTokenSubmitted;
  final Future<void> Function(String) onWhapiApiTokenSubmitted;
  final Future<void> Function(String) onWhatsappIntervalSubmitted;
  final Future<void> Function(int) onWhatsappTypingTimeChangeRequested;
  final Future<void> Function(bool) onWhatsappAutoReplyChangeRequested;
  final Future<void> Function(SupportedModel? model) onModelChangeRequested;
  final Future<void> Function(YaruVariant varient) onThemeChangeRequested;
  final Future<void> Function(bool) onDarkModeChangeRequested;

  final bool parentalPaddingApplied;

  @override
  Widget build(BuildContext context) {
    TextEditingValue? initialModelValue;
    if (defaultModel.isNotEmpty) {
      initialModelValue = TextEditingValue(text: defaultModel);
    }

    final DateTime? lastFetchTime = whatsappService.lastFetchTime;
    final int pollRate = whatsappService.pollingInterval ~/ 1000;
    final DateTime nextPollingTime = lastFetchTime?.add(Duration(seconds: pollRate)) ?? DateTime.now().add(const Duration(seconds: 60));

    final TextEditingValue initialThemeValue = TextEditingValue(text: yaruVariant.toYaruString());
    final MediaQueryData mediaQuery = MediaQuery.of(context);

    return ListView(
      padding: EdgeInsets.only(
        left: 8,
        right: 8,
        top: !parentalPaddingApplied ? mediaQuery.padding.top + 8 : 8,
        bottom: 8 + mediaQuery.padding.bottom,
      ),
      children: <Widget>[
        YaruExpansionPanel(
          headers: const [
            Row(
              children: [
                Icon(SimpleIcons.openai, size: 24),
                SizedBox(width: 12),
                Text('OpenAI Settings'),
              ],
            ),
            Row(
              children: [
                Icon(SimpleIcons.whatsapp, size: 24),
                SizedBox(width: 12),
                Text('WhatsApp Settings'),
              ],
            ),
            Row(
              children: [
                Icon(SimpleIcons.ubuntu, size: 24),
                SizedBox(width: 12),
                Text('Theme Settings'),
              ],
            ),
            Row(
              children: [
                Icon(SimpleIcons.adminer, size: 24),
                SizedBox(width: 12),
                Text('Developer Settings'),
              ],
            ),
            Row(
              children: [
                Icon(SimpleIcons.adminer, size: 24),
                SizedBox(width: 12),
                Text('FAQs'),
              ],
            ),
          ],
          children: [
            Padding(
              padding: const EdgeInsets.only(left: 16, right: 16, bottom: 16),
              child: Column(children: buildOpenAIWidgets(initialModelValue: initialModelValue, onModelChangeRequested: onModelChangeRequested)),
            ),
            Padding(
              padding: const EdgeInsets.only(left: 16, right: 16, bottom: 16),
              child: Column(
                children: buildWhatsAppWidgets(
                  onWhapiApiTokenSubmitted: onWhapiApiTokenSubmitted,
                  onWhatsappIntervalSubmitted: onWhatsappIntervalSubmitted,
                  onWhatsappAutoReplyChangeRequested: onWhatsappAutoReplyChangeRequested,
                  whatsappAutoReplyEnabled: whatsappAutoReplyEnabled,
                  whatsappTypingTimeTextController: whatsappTypingTimeTextController,
                  onWhatsappTypingTimeChangeRequested: onWhatsappTypingTimeChangeRequested,
                  whatsappTypingTime: whatsappTypingTime,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(left: 16, right: 16, bottom: 16),
              child: Column(
                children: buildThemeWidgets(
                  initialThemeValue: initialThemeValue,
                  isDarkMode: isDarkMode,
                  onThemeChangeRequested: onThemeChangeRequested,
                  onDarkModeChangeRequested: onDarkModeChangeRequested,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(left: 16, right: 16, bottom: 16),
              child: Column(
                children: buildDeveloperWidgets(
                  context: context,
                  whatsappService: whatsappService,
                  nextPollingTime: nextPollingTime,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(left: 16, right: 16, bottom: 16),
              child: Column(
                children: buildFAQWidgets(
                  context: context,
                  whatsappService: whatsappService,
                  nextPollingTime: nextPollingTime,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  List<Widget> buildWhatsAppWidgets({
    required Future<void> Function(String) onWhapiApiTokenSubmitted,
    required Future<void> Function(String) onWhatsappIntervalSubmitted,
    required Future<void> Function(bool) onWhatsappAutoReplyChangeRequested,
    required Future<void> Function(int) onWhatsappTypingTimeChangeRequested,
    required TextEditingController whatsappTypingTimeTextController,
    required bool whatsappAutoReplyEnabled,
    required int whatsappTypingTime,
  }) {
    return [
      TextField(
        controller: whapiApiTokenTextController,
        onSubmitted: onWhapiApiTokenSubmitted,
        decoration: InputDecoration(
          labelText: 'WhatsApp API Token',
          suffix: YaruIconButton(onPressed: () => onWhapiApiTokenSubmitted(whapiApiTokenTextController.text), icon: const Icon(YaruIcons.send)),
        ),
      ),
      const SizedBox(height: 16),
      TextField(
        controller: whatsappIntervalTextController,
        onSubmitted: onWhatsappIntervalSubmitted,
        decoration: InputDecoration(
          labelText: 'New Message Polling Interval (ms)',
          suffix: YaruIconButton(onPressed: () => onWhatsappIntervalSubmitted(whatsappIntervalTextController.text), icon: const Icon(YaruIcons.send)),
        ),
      ),
      const SizedBox(height: 16),
      TextField(
        controller: whatsappTypingTimeTextController,
        onSubmitted: (String value) {
          final int? parsedValue = int.tryParse(value);
          if (parsedValue != null) {
            onWhatsappTypingTimeChangeRequested(parsedValue);
          }
        },
        decoration: InputDecoration(
          labelText: 'Faked typing time (seconds)',
          suffix: YaruIconButton(onPressed: () => onWhatsappTypingTimeChangeRequested(int.parse(whatsappTypingTimeTextController.text)), icon: const Icon(YaruIcons.send)),
        ),
      ),
      const SizedBox(height: 16),
      YaruCheckboxListTile(
        value: whatsappAutoReplyEnabled,
        contentPadding: const EdgeInsets.symmetric(horizontal: 8),
        title: const Text('Enable WhatsApp Auto-Reply', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
        dense: true,
        onChanged: (value) => onWhatsappAutoReplyChangeRequested(value ?? false),
      ),
    ];
  }

  List<Widget> buildOpenAIWidgets({
    required TextEditingValue? initialModelValue,
    required Future<void> Function(SupportedModel? model) onModelChangeRequested,
  }) {
    return [
      TextField(
        controller: openaiApiTokenTextController,
        onSubmitted: onOpenaiApiTokenSubmitted,
        decoration: InputDecoration(
          labelText: 'OpenAI API Token',
          suffix: YaruIconButton(onPressed: () => onOpenaiApiTokenSubmitted(openaiApiTokenTextController.text), icon: const Icon(YaruIcons.send)),
        ),
      ),
      const SizedBox(height: 16),
      Container(
        alignment: Alignment.centerLeft,
        padding: const EdgeInsets.only(left: 8, bottom: 2),
        child: const Text(
          'OpenAI Model',
          style: TextStyle(fontSize: 12, fontWeight: FontWeight.w300),
        ),
      ),
      YaruAutocomplete<SupportedModel>(
        onSelected: onModelChangeRequested,
        initialValue: initialModelValue,
        displayStringForOption: (model) => model.name,
        optionsBuilder: (textEditingValue) {
          const List<SupportedModel> supportedModels = SupportedModel.values;
          return supportedModels;
        },
      ),
    ];
  }

  List<Widget> buildThemeWidgets({
    required TextEditingValue initialThemeValue,
    required bool isDarkMode,
    required Future<void> Function(YaruVariant varient) onThemeChangeRequested,
    required Future<void> Function(bool) onDarkModeChangeRequested,
  }) {
    return [
      YaruCheckboxListTile(
        value: isDarkMode,
        contentPadding: const EdgeInsets.symmetric(horizontal: 8),
        title: const Text('Dark Mode', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
        dense: true,
        onChanged: (value) => onDarkModeChangeRequested(value ?? false),
      ),
      const SizedBox(height: 16),
      Container(
        alignment: Alignment.centerLeft,
        padding: const EdgeInsets.only(left: 8, bottom: 2),
        child: const Text(
          'Theme Variant',
          style: TextStyle(fontSize: 12, fontWeight: FontWeight.w300),
        ),
      ),
      YaruAutocomplete<YaruVariant>(
        onSelected: onThemeChangeRequested,
        initialValue: initialThemeValue,
        displayStringForOption: (variant) => variant.toYaruString(),
        optionsBuilder: (textEditingValue) {
          const List<YaruVariant> variants = YaruVariant.values;
          return variants;
        },
      ),
    ];
  }

  List<Widget> buildDeveloperWidgets({
    required BuildContext context,
    required DateTime? nextPollingTime,
    required AbstractWhatsappService whatsappService,
  }) {
    return [
      Align(
        alignment: Alignment.centerLeft,
        child: FilledButton(
          onPressed: () => whatsappService.refreshMessages(),
          child: const Text('Refresh WhatsApp Messages'),
        ),
      ),
      if (nextPollingTime != null) ...<Widget>[
        const SizedBox(height: 16),
        Container(
          alignment: Alignment.centerLeft,
          padding: const EdgeInsets.only(left: 8, bottom: 2),
          child: Text(
            'Next Fetch Time: ${nextPollingTime.toIso8601String()}',
            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w300),
          ),
        ),
      ],
    ];
  }

  List<Widget> buildFAQWidgets({
    required BuildContext context,
    required DateTime? nextPollingTime,
    required AbstractWhatsappService whatsappService,
  }) {
    return const [
      ListTile(
        title: Text('What is Prompt Guidance?'),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('This is the guidance that the AI will use to generate the response. It is the system\'s role.'),
            Text(
              'For example, if you want to ask the AI to generate a response to a question, you can provide the AI with some guidance on how to answer the question. Guidance instructs the AI on how to generate the response. This guidance can be in the form of a question, a statement, or a combination of both.',
              style: TextStyle(fontSize: 12, fontWeight: FontWeight.w300),
            ),
          ],
        ),
      ),
      ListTile(
        title: Text('What is Prompt Content?'),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('This is the content that the AI will use to generate the response. It is the assistant\'s role.'),
            Text(
              'For example, if you want to ask the AI to generate a response to a question, you can provide the AI with some content that it can use to generate the response. The content is not the guidance, but rather the information that the AI will use to generate the response. This content can be in the form of a question, a statement, or a combination of both. The AI will use this content to generate the response based on the guidance provided.',
              style: TextStyle(fontSize: 12, fontWeight: FontWeight.w300),
            ),
          ],
        ),
      ),
      ListTile(
        title: Text('How does Auto-Reply work?'),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('This is the feature that allows the system to automatically reply to incoming messages.'),
            Text(
              'The Auto-Reply feature allows the system to automatically reply to incoming messages. When this feature is enabled, the system will automatically generate a response to incoming messages and send the response to the sender. This feature is useful for automating the process of replying to messages and can be used to save time and effort when replying to messages.',
              style: TextStyle(fontSize: 12, fontWeight: FontWeight.w300),
            ),
            Text(
              'Note: This feature will only process future messages and will not process messages that have already been received.',
              style: TextStyle(fontSize: 11, fontWeight: FontWeight.w300, fontStyle: FontStyle.italic),
            ),
          ],
        ),
      ),
      ListTile(
        title: Text('What is the OpenAI API Token?'),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('This is the API token that is used to authenticate with the OpenAI API.'),
            Text(
              'The OpenAI API token is used to authenticate with the OpenAI API. This token is required to access the OpenAI API and use the services provided by the API. The token is used to authenticate the user and ensure that the user has the necessary permissions to access the API.',
              style: TextStyle(fontSize: 12, fontWeight: FontWeight.w300),
            ),
          ],
        ),
      ),
      ListTile(
        title: Text('What is the Whapi API Token?'),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('This is the API token that is used to authenticate with the Whapi API.'),
            Text(
              'The Whapi API token is used to authenticate with the Whapi API. This token is required to access the Whapi API and use the services provided by the API. The token is used to authenticate the user and ensure that the user has the necessary permissions to access the API.',
              style: TextStyle(fontSize: 12, fontWeight: FontWeight.w300),
            ),
          ],
        ),
      ),
    ];
  }
}
