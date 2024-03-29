import 'dart:async';

import 'package:dart_openai/dart_openai.dart';
import 'package:flutter/material.dart';
import 'package:simple_icons/simple_icons.dart';

import 'package:whatsapp_ai/events/events.dart';
import 'package:whatsapp_ai/extensions/yaru_extensions.dart';
import 'package:whatsapp_ai/main.dart';
import 'package:whatsapp_ai/models/models.dart';
import 'package:whatsapp_ai/services/generative_ai_service.dart';
import 'package:whatsapp_ai/services/whatsapp_service.dart';
import 'package:whatsapp_ai/views/components/ai.dart';
import 'package:whatsapp_ai/views/components/persona.dart';
import 'package:whatsapp_ai/views/components/settings.dart';
import 'package:whatsapp_ai/views/components/whatsapp.dart';
import 'package:yaru/yaru.dart';
import 'package:yaru_icons/yaru_icons.dart';
import 'package:yaru_widgets/yaru_widgets.dart';

class HomeView extends StatefulWidget {
  const HomeView({super.key});

  @override
  State<HomeView> createState() => HomeViewState();
}

class HomeViewState extends State<HomeView> with AppServicesMixin {
  WhatsappServiceStatus? whatsappStatus;

  StreamSubscription<MessagesUpdatedEvent>? _messagesUpdatedSubscription;
  StreamSubscription<WhatsappStatusUpdatedEvent>? _whatsappStatusSubscription;
  StreamSubscription<WhatsppPollingIntervalUpdatedEvent>? _whatsappPollingIntervalUpdatedSubscription;
  StreamSubscription<WhatsappAutoReplyChangedEvent>? _whatsappAutoReplyChangedSubscription;
  StreamSubscription<WhatsappTypingTimeChangedEvent>? _whatsappTypingTimeChangedSubscription;
  StreamSubscription<WhatsappChatSelectedEvent>? _whatsappChatSelectedSubscription;

  StreamSubscription<RedisConnectionUpdatedEvent>? _redisConnectionUpdatedSubscription;

  StreamSubscription<ResponseGuidanceUpdatedEvent>? _responseGuidanceUpdatedSubscription;
  StreamSubscription<ResponseContentUpdatedEvent>? _responseContentUpdatedSubscription;

  StreamSubscription<ModelUpdatedEvent>? _modelUpdatedSubscription;
  StreamSubscription<LangchainServerUrlUpdatedEvent>? _langchainServerUrlUpdatedSubscription;

  final int kPageCount = 5;
  late final YaruPageController pageController;

  final TextEditingController openAiLangchainServerTextController = TextEditingController();
  final TextEditingController openAiTokenTextController = TextEditingController();
  final TextEditingController openAiPromptGuidanceController = TextEditingController();
  final TextEditingController openAiPromptContentController = TextEditingController();

  final TextEditingController whapiApiTokenTextController = TextEditingController();
  final TextEditingController whatsappIntervalTextController = TextEditingController();
  final TextEditingController whatsappTypingTimeTextController = TextEditingController();

  final TextEditingController redisAddressTextController = TextEditingController();
  final TextEditingController redisPortTextController = TextEditingController();

  final TextEditingController personaTextController = TextEditingController();
  final List<String> personaSuggestions = <String>[];

  int _currentPage = 0;
  int get currentPage => _currentPage;
  set currentPage(int value) {
    if (value < 0 || value > kPageCount - 1 || value == _currentPage) {
      return;
    }

    _currentPage = value;
    if (pageController.index != value) {
      pageController.index = value;
    }

    if (mounted) {
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

  bool _isGeneratingPersona = false;
  bool get isGeneratingPersona => _isGeneratingPersona;
  set isGeneratingPersona(bool value) {
    _isGeneratingPersona = value;
    if (mounted) {
      setState(() {});
    }
  }

  @override
  void initState() {
    super.initState();
    pageController = YaruPageController(length: kPageCount);
    WidgetsBinding.instance.addPostFrameCallback(onFirstRender);
  }

  Future<void> onFirstRender(Duration timeStamp) async {
    whatsappStatus = whatsappService.status;
    pageController.index = currentPage;

    if (whatsappService.typingTime > 0) {
      whatsappTypingTimeTextController.text = whatsappService.typingTime.toString();
    }

    if (whatsappService.pollingInterval > 0) {
      whatsappIntervalTextController.text = whatsappService.pollingInterval.toString();
    }

    if (whatsappService.clientToken.isNotEmpty) {
      whapiApiTokenTextController.text = whatsappService.clientToken;
    }

    if (generativeAIService.apiKey.isNotEmpty) {
      openAiTokenTextController.text = generativeAIService.apiKey;
    }

    if (generativeAIService.langchainServerUrl.isNotEmpty) {
      openAiLangchainServerTextController.text = generativeAIService.langchainServerUrl;
    }

    setState(() {});

    await _messagesUpdatedSubscription?.cancel();
    _messagesUpdatedSubscription = eventBus.on<MessagesUpdatedEvent>().listen(onMessagesUpdated);

    await _whatsappPollingIntervalUpdatedSubscription?.cancel();
    _whatsappPollingIntervalUpdatedSubscription = eventBus.on<WhatsppPollingIntervalUpdatedEvent>().listen(onWhatsappPollingIntervalUpdated);

    await _whatsappTypingTimeChangedSubscription?.cancel();
    _whatsappTypingTimeChangedSubscription = eventBus.on<WhatsappTypingTimeChangedEvent>().listen(onWhatsappTypingTimeUpdated);

    await _whatsappChatSelectedSubscription?.cancel();
    _whatsappChatSelectedSubscription = eventBus.on<WhatsappChatSelectedEvent>().listen(onWhatsappChatSelected);

    await _whatsappAutoReplyChangedSubscription?.cancel();
    _whatsappAutoReplyChangedSubscription = eventBus.on<WhatsappAutoReplyChangedEvent>().listen(onWhatsappAutoReplyUpdated);

    await _whatsappStatusSubscription?.cancel();
    _whatsappStatusSubscription = eventBus.on<WhatsappStatusUpdatedEvent>().listen(onWhatsappStatusUpdated);

    await _responseGuidanceUpdatedSubscription?.cancel();
    _responseGuidanceUpdatedSubscription = eventBus.on<ResponseGuidanceUpdatedEvent>().listen(onResponseGuidanceUpdated);

    await _responseContentUpdatedSubscription?.cancel();
    _responseContentUpdatedSubscription = eventBus.on<ResponseContentUpdatedEvent>().listen(onResponseContentUpdated);

    await _modelUpdatedSubscription?.cancel();
    _modelUpdatedSubscription = eventBus.on<ModelUpdatedEvent>().listen(onModelUpdated);

    await _langchainServerUrlUpdatedSubscription?.cancel();
    _langchainServerUrlUpdatedSubscription = eventBus.on<LangchainServerUrlUpdatedEvent>().listen(onLangchainServerUrlUpdated);

    await _redisConnectionUpdatedSubscription?.cancel();
    _redisConnectionUpdatedSubscription = eventBus.on<RedisConnectionUpdatedEvent>().listen(onRedisConnectionUpdated);
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

  Future<void> onOpenaiApiTokenSubmitted(String token) async {
    isBusy = true;

    try {
      await generativeAIService.setApiKey(token);
      systemService.showSuccessToast('OpenAI API token updated');
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

  Future<void> onWhatsAppAutoReplyChangeRequested(bool value) async {
    await whatsappService.setAutoReplyEnabled(value);
    if (mounted) {
      setState(() {});
    }
  }

  Future<void> onWhatsappTypingTimeChangeRequested(int time) async {
    await whatsappService.updateTypingTime(time);
    if (mounted) {
      setState(() {});
    }
  }

  Future<void> onModelChangeRequested(SupportedModel? model) async {
    if (model == null) return;
    if (model.name == generativeAIService.defaultModel) return;

    await generativeAIService.saveDefaultModel(model.name);
    if (mounted) {
      setState(() {});
    }
  }

  Future<void> onThemeChangeRequested(YaruVariant variant) async {
    await systemService.saveYaruVariant(variant.name);
  }

  Future<void> onDarkModeChangeRequested(bool value) async {
    await systemService.setDarkMode(value);
  }

  Future<void> onRedisConnectionAddressUpdated(String address) async {
    if (!mounted) return;
    setState(() {});

    attemptToConnectRedis();
  }

  Future<void> onRedisConnectionPortUpdated(String port) async {
    if (!mounted) return;
    setState(() {});

    final int? newPort = int.tryParse(port);
    if (newPort == null) return;

    attemptToConnectRedis();
  }

  Future<void> attemptToConnectRedis() async {
    final String address = redisAddressTextController.text;
    final int port = int.tryParse(redisPortTextController.text) ?? 0;

    if (redisService.isConnectionOpen) {
      systemService.showSuccessToast('Disconnecting from old redis connection');
      await redisService.disconnect();
    }

    if (address.isEmpty || port == 0) {
      systemService.showErrorToast('Invalid address or port');
      return;
    }

    await redisService.connect(address, port);
  }

  void onMessagesUpdated(MessagesUpdatedEvent event) {
    if (!mounted) return;
    setState(() {});
  }

  void onWhatsappPollingIntervalUpdated(WhatsppPollingIntervalUpdatedEvent event) {
    if (!mounted) return;

    systemService.showSuccessToast('Polling interval updated to ${whatsappService.pollingInterval} ms');
    setState(() {});
  }

  void onWhatsappTypingTimeUpdated(WhatsappTypingTimeChangedEvent event) {
    if (!mounted) return;

    if (whatsappService.typingTime > 0) {
      whatsappTypingTimeTextController.text = whatsappService.typingTime.toString();
    }

    systemService.showSuccessToast('Typing time updated to ${whatsappService.typingTime} seconds');
    setState(() {});
  }

  void onWhatsappChatSelected(WhatsappChatSelectedEvent event) {
    if (!mounted) return;
    setState(() {});
  }

  void onWhatsappAutoReplyUpdated(WhatsappAutoReplyChangedEvent event) {
    if (!mounted) return;

    systemService.showSuccessToast('Auto reply enabled: ${whatsappService.autoReplyEnabled}');
    setState(() {});
  }

  void onWhatsappStatusUpdated(WhatsappStatusUpdatedEvent status) {
    if (!mounted) return;

    whatsappStatus = whatsappService.status;
    if (whatsappService.clientToken.isNotEmpty) {
      whapiApiTokenTextController.text = whatsappService.clientToken;
    }

    setState(() {});
  }

  Future<void> onResponseGuidanceUpdated(ResponseGuidanceUpdatedEvent event) async {
    if (!mounted) return;
    setState(() {});
  }

  Future<void> onResponseContentUpdated(ResponseContentUpdatedEvent event) async {
    if (!mounted) return;
    setState(() {});
  }

  Future<void> onModelUpdated(ModelUpdatedEvent event) async {
    if (!mounted) return;
    setState(() {});
  }

  Future<void> onLangchainServerUrlUpdated(LangchainServerUrlUpdatedEvent event) async {
    if (!mounted) return;
    setState(() {});
  }

  Future<void> onRedisConnectionUpdated(RedisConnectionUpdatedEvent event) async {
    if (!mounted) return;
    setState(() {});
  }

  Future<void> onMessageResponseRequested(Message message) async {
    isBusy = true;

    try {
      if (message.fromMe) {
        systemService.showErrorToast('Cannot reply to own message');
        return;
      }

      // Get acceptance from user to reply to message
      final bool shouldReply = await systemService.showConfirmationDialog(
        'Reply to message?',
        'Do you want to reply to this message with an AI generated response?',
      );

      if (!shouldReply) {
        return;
      }

      final Map<OpenAIChatMessageRole, Set<String>> content = <OpenAIChatMessageRole, Set<String>>{};
      content[OpenAIChatMessageRole.system] = generativeAIService.defaultPromptGuidance;
      content[OpenAIChatMessageRole.assistant] = generativeAIService.defaultPromptContent;

      final String response = await generativeAIService.generateReply(message, content);

      if (response.isEmpty) {
        systemService.showErrorToast('Failed to generate response');
        return;
      }

      await whatsappService.replyMessage(message, response);
    } finally {
      isBusy = false;
    }
  }

  Future<void> onNewPromptGuidanceSubmitted(String prompt) async {
    await generativeAIService.savePromptGuidance(prompt);
    openAiPromptGuidanceController.clear();
  }

  Future<void> onPromptContentSubmitted(String prompt) async {
    await generativeAIService.savePromptContent(prompt);
    openAiPromptContentController.clear();
  }

  Future<void> onRemovePromptGuidanceRequested(String prompt) async {
    await generativeAIService.removePromptGuidance(prompt);
  }

  Future<void> onRemovePromptContentRequested(String prompt) async {
    await generativeAIService.removePromptContent(prompt);
  }

  Future<void> onDefaultPromptGuidanceSubmitted(Iterable<String> prompts) async {
    await generativeAIService.setDefaultPromptGuidance(prompts);
    if (mounted) {
      setState(() {});
    }
  }

  Future<void> onDefaultPromptContentSubmitted(Iterable<String> prompts) async {
    await generativeAIService.setDefaultPromptContent(prompts);
    if (mounted) {
      setState(() {});
    }
  }

  Future<void> onPersonaStatementSubmitted(String personaStatement) async {
    isGeneratingPersona = true;

    try {
      final List<String> persona = await personaService.generatePersonaFromStatement(personaStatement);
      personaSuggestions.clear();
      personaSuggestions.addAll(persona);
      if (mounted) {
        setState(() {});
      }
    } catch (ex) {
      await systemService.showErrorToast('Failed to generate persona suggestions, please verify AI settings and try again.');
    } finally {
      isGeneratingPersona = false;
    }
  }

  Future<void> onPersonaSuggestionSelected(String suggestion) async {
    personaTextController.text = suggestion;
    personaSuggestions.clear();
    if (mounted) {
      setState(() {});
    }
  }

  static const double kWidthBreakpoint = 800.0;
  static const double kHeightBreakpoint = 600.0;

  Widget buildDetailPageTile(BuildContext context, int index) {
    final MediaQueryData mediaQuery = MediaQuery.of(context);
    final bool hasTopSafeArea = mediaQuery.padding.top > 0;
    final bool shouldApplyTopPadding = hasTopSafeArea && index == 0;

    late final IconData icon;
    late final String title;
    switch (index) {
      case 0:
        icon = SimpleIcons.whatsapp;
        title = 'WhatsApp';
        break;
      case 1:
        icon = SimpleIcons.openai;
        title = 'AI';
        break;
      case 2:
        icon = SimpleIcons.personio;
        title = 'Persona Generator';
        break;
      case 3:
        icon = SimpleIcons.redis;
        title = 'Redis';
        break;
      case 4:
        icon = YaruIcons.settings;
        title = 'Settings';
        break;
    }

    final Widget child = YaruMasterTile(
      leading: Icon(icon),
      title: Text(title),
      selected: index == currentPage,
      onTap: () {
        currentPage = index;
      },
    );

    return Padding(
      padding: shouldApplyTopPadding ? EdgeInsets.only(top: mediaQuery.padding.top) : EdgeInsets.zero,
      child: child,
    );
  }

  PreferredSizeWidget? buildAppBar(BuildContext context) {
    final MediaQueryData mediaQuery = MediaQuery.of(context);
    final bool hasExceededWidthBreakpoint = mediaQuery.size.width > kWidthBreakpoint;
    final bool hasExceededHeightBreakpoint = mediaQuery.size.height > kHeightBreakpoint;

    if (!hasExceededHeightBreakpoint && hasExceededWidthBreakpoint) {
      return null;
    }

    Widget? leading = hasExceededWidthBreakpoint
        ? null
        : YaruIconButton(
            icon: const Icon(YaruIcons.menu),
            onPressed: () => pageController.index = -1,
          );

    if (whatsappService.selectedChatId.isNotEmpty) {
      leading = YaruIconButton(
        icon: const Icon(YaruIcons.arrow_left),
        onPressed: () => whatsappService.selectedChatId = '',
      );
    }

    return YaruWindowTitleBar(
      leading: leading,
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            '{\$insertNameOfAppHere}',
            style: Theme.of(context).textTheme.titleSmall,
          ),
          Text(
            'Reply to any message with AI generated responses.',
            style: Theme.of(context).textTheme.labelSmall,
          ),
        ],
      ),
      border: BorderSide.none,
      backgroundColor: YaruMasterDetailTheme.of(context).sideBarColor,
    );
  }

  @override
  Widget build(BuildContext context) {
    final PreferredSizeWidget? appBar = buildAppBar(context);
    return YaruMasterDetailPage(
      controller: pageController,
      breakpoint: kWidthBreakpoint,
      tileBuilder: (context, index, __, ___) => buildDetailPageTile(context, index),
      pageBuilder: (context, index) => YaruDetailPage(
        appBar: appBar,
        body: buildChild(context, index, parentalPaddingApplied: appBar != null),
      ),
    );
  }

  Widget buildChild(BuildContext context, int index, {bool parentalPaddingApplied = false}) {
    return switch (index) {
      0 => HomeWhatsappConfiguration(
          whatsappStatus: whatsappStatus,
          whatsappService: whatsappService,
          onMessageResponseRequested: onMessageResponseRequested,
          parentalPaddingApplied: parentalPaddingApplied,
        ),
      1 => HomeAIConfigurationPage(
          allPromptGuidance: generativeAIService.allPromptGuidance,
          defaultPromptGuidance: generativeAIService.defaultPromptGuidance,
          allPromptContent: generativeAIService.allPromptContent,
          defaultPromptContent: generativeAIService.defaultPromptContent,
          openAiPromptGuidanceController: openAiPromptGuidanceController,
          openAiPromptContentController: openAiPromptContentController,
          onDefaultPromptContentSubmitted: onDefaultPromptContentSubmitted,
          onDefaultPromptGuidanceSubmitted: onDefaultPromptGuidanceSubmitted,
          onNewPromptContentSubmitted: onPromptContentSubmitted,
          onNewPromptGuidanceSubmitted: onNewPromptGuidanceSubmitted,
          onRemovePromptContentRequested: onRemovePromptContentRequested,
          onRemovePromptGuidanceRequested: onRemovePromptGuidanceRequested,
          parentalPaddingApplied: parentalPaddingApplied,
        ),
      2 => HomePersonaPage(
          personaTextController: personaTextController,
          personaSuggestions: personaSuggestions,
          onPersonaStatementSubmitted: onPersonaStatementSubmitted,
          onPersonaSuggestionSelected: onPersonaSuggestionSelected,
          isLoadingSuggestions: isGeneratingPersona,
        ),
      3 => Container(),
      4 => HomeSettingsPage(
          whatApiToken: whatsappService.clientToken,
          openaiApiToken: generativeAIService.apiKey,
          openAiLangchainServerTextController: openAiLangchainServerTextController,
          openAiLangchainServerUrl: generativeAIService.langchainServerUrl,
          onOpenAiLangchainServerUrlSubmitted: generativeAIService.setLangchainServerUrl,
          defaultModel: generativeAIService.defaultModel,
          whapiApiTokenTextController: whapiApiTokenTextController,
          onWhapiApiTokenSubmitted: onWhatsAppTokenSubmitted,
          whatsappIntervalTextController: whatsappIntervalTextController,
          openAiTokenTextController: openAiTokenTextController,
          onOpenAiTokenSubmitted: onOpenaiApiTokenSubmitted,
          onWhatsappIntervalSubmitted: onWhatsAppIntervalSubmitted,
          onModelChangeRequested: onModelChangeRequested,
          onThemeChangeRequested: onThemeChangeRequested,
          onDarkModeChangeRequested: onDarkModeChangeRequested,
          isDarkMode: systemService.isDarkMode,
          yaruVariant: systemService.yaruVariant.toYaruVariant(),
          whatsappAutoReplyEnabled: whatsappService.autoReplyEnabled,
          onWhatsappAutoReplyChangeRequested: onWhatsAppAutoReplyChangeRequested,
          onWhatsappTypingTimeChangeRequested: onWhatsappTypingTimeChangeRequested,
          whatsappTypingTime: whatsappService.typingTime,
          whatsappTypingTimeTextController: whatsappTypingTimeTextController,
          parentalPaddingApplied: parentalPaddingApplied,
          onRedisAddressChanged: onRedisConnectionAddressUpdated,
          onRedisPortChanged: onRedisConnectionPortUpdated,
          redisAddressTextController: redisAddressTextController,
          redisPortTextController: redisPortTextController,
        ),
      _ => const SizedBox.shrink(),
    };
  }
}
