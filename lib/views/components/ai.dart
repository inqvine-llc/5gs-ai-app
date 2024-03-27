import 'package:flutter/material.dart';
import 'package:whatsapp_ai/main.dart';
import 'package:yaru_icons/yaru_icons.dart';
import 'package:yaru_widgets/yaru_widgets.dart';

class HomeAIConfigurationPage extends StatefulWidget {
  const HomeAIConfigurationPage({
    required this.allPromptGuidance,
    required this.defaultPromptGuidance,
    required this.allPromptContent,
    required this.defaultPromptContent,
    required this.openAiPromptGuidanceController,
    required this.openAiPromptContentController,
    required this.onDefaultPromptGuidanceSubmitted,
    required this.onDefaultPromptContentSubmitted,
    required this.onNewPromptGuidanceSubmitted,
    required this.onNewPromptContentSubmitted,
    required this.onRemovePromptGuidanceRequested,
    required this.onRemovePromptContentRequested,
    this.parentalPaddingApplied = false,
    super.key,
  });

  final Set<String> allPromptGuidance;
  final Set<String> defaultPromptGuidance;

  final Set<String> allPromptContent;
  final Set<String> defaultPromptContent;

  final TextEditingController openAiPromptGuidanceController;
  final TextEditingController openAiPromptContentController;

  final Future<void> Function(Iterable<String>) onDefaultPromptGuidanceSubmitted;
  final Future<void> Function(Iterable<String>) onDefaultPromptContentSubmitted;
  final Future<void> Function(String) onNewPromptGuidanceSubmitted;
  final Future<void> Function(String) onNewPromptContentSubmitted;
  final Future<void> Function(String) onRemovePromptGuidanceRequested;
  final Future<void> Function(String) onRemovePromptContentRequested;

  final bool parentalPaddingApplied;

  @override
  State<HomeAIConfigurationPage> createState() => _HomeAIConfigurationPageState();
}

enum AIContentMode {
  promptGuidance,
  promptContent;
}

class _HomeAIConfigurationPageState extends State<HomeAIConfigurationPage> with AppServicesMixin, TickerProviderStateMixin {
  int _selectedTabIndex = 0;
  int get selectedTabIndex => _selectedTabIndex;
  set selectedTabIndex(int value) {
    _selectedTabIndex = value;
    if (mounted) {
      setState(() {});
    }
  }

  AIContentMode get selectedMode => selectedTabIndex == 0 ? AIContentMode.promptGuidance : AIContentMode.promptContent;

  Future<void> _onInternalFormSubmitted(String value) async {
    if (selectedTabIndex == 0) {
      await widget.onNewPromptGuidanceSubmitted(value);
    } else {
      await widget.onNewPromptContentSubmitted(value);
    }
  }

  @override
  Widget build(BuildContext context) {
    final MediaQueryData mediaQuery = MediaQuery.of(context);
    final double bottomPadding = mediaQuery.padding.bottom;

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        if (!widget.parentalPaddingApplied) ...<Widget>[
          SizedBox(height: MediaQuery.of(context).padding.top),
        ],
        YaruTabBar(
          tabController: TabController(length: 2, vsync: this),
          tabs: <Widget>[
            YaruTab(label: selectedTabIndex == 0 ? '* Guidance *' : 'Guidance'),
            YaruTab(label: selectedTabIndex == 1 ? '* Content *' : 'Content'),
          ],
          onTap: (index) => selectedTabIndex = index,
        ),
        Expanded(
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 300),
            child: selectedMode == AIContentMode.promptGuidance ? PromptGuidanceMultiselect(widget: widget) : PromptContentMultiselect(widget: widget),
          ),
        ),
        const Divider(),
        const SizedBox(height: 8),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: TextField(
            controller: selectedMode == AIContentMode.promptGuidance ? widget.openAiPromptGuidanceController : widget.openAiPromptGuidanceController,
            onSubmitted: _onInternalFormSubmitted,
            decoration: InputDecoration(
              border: const OutlineInputBorder(),
              labelText: selectedMode == AIContentMode.promptGuidance ? 'Enter some prompt guidance here...' : 'Enter some prompt content here...',
              suffix: YaruIconButton(
                icon: const Icon(YaruIcons.send),
                onPressed: () => _onInternalFormSubmitted(selectedMode == AIContentMode.promptGuidance ? widget.openAiPromptContentController.text : widget.openAiPromptContentController.text),
              ),
            ),
          ),
        ),
        SizedBox(height: 8 + bottomPadding),
      ],
    );
  }
}

class PromptGuidanceMultiselect extends StatelessWidget {
  const PromptGuidanceMultiselect({
    super.key,
    required this.widget,
  });

  final HomeAIConfigurationPage widget;

  Future<void> _onInternalSwitchToggled(String prompt, bool value) async {
    final allDefaultPrompts = widget.defaultPromptGuidance;
    if (value) {
      allDefaultPrompts.add(prompt);
    } else {
      allDefaultPrompts.remove(prompt);
    }

    await widget.onDefaultPromptGuidanceSubmitted(allDefaultPrompts);
  }

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.only(top: 8, left: 8, right: 8),
      itemCount: widget.allPromptGuidance.length,
      itemBuilder: (context, index) {
        final prompt = widget.allPromptGuidance.elementAt(index);
        final bool isSelected = widget.defaultPromptGuidance.contains(prompt);

        return YaruCheckboxListTile(
          value: isSelected,
          onChanged: (value) => _onInternalSwitchToggled(prompt, value ?? false),
          title: SelectableText(prompt),
          dense: true,
          secondary: YaruIconButton(
            icon: const Icon(YaruIcons.trash),
            onPressed: () => widget.onRemovePromptGuidanceRequested(prompt),
          ),
        );
      },
    );
  }
}

class PromptContentMultiselect extends StatelessWidget {
  const PromptContentMultiselect({
    super.key,
    required this.widget,
  });

  final HomeAIConfigurationPage widget;

  Future<void> _onInternalSwitchToggled(String prompt, bool value) async {
    final allDefaultPrompts = widget.defaultPromptContent;
    if (value) {
      allDefaultPrompts.add(prompt);
    } else {
      allDefaultPrompts.remove(prompt);
    }

    await widget.onDefaultPromptContentSubmitted(allDefaultPrompts);
  }

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.only(top: 8, left: 8, right: 8),
      itemCount: widget.allPromptContent.length,
      itemBuilder: (context, index) {
        final prompt = widget.allPromptContent.elementAt(index);
        final bool isSelected = widget.defaultPromptContent.contains(prompt);

        return YaruCheckboxListTile(
          value: isSelected,
          onChanged: (value) => _onInternalSwitchToggled(prompt, value ?? false),
          title: SelectableText(prompt),
          dense: true,
          secondary: YaruIconButton(
            icon: const Icon(YaruIcons.trash),
            onPressed: () => widget.onRemovePromptContentRequested(prompt),
          ),
        );
      },
    );
  }
}
