import 'dart:async';
import 'dart:ui';

import 'package:cron/cron.dart';
import 'package:dio/dio.dart';
import 'package:event_bus/event_bus.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get_it/get_it.dart';
import 'package:redis/redis.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:universal_io/io.dart';
import 'package:whatsapp_ai/events/events.dart';
import 'package:whatsapp_ai/extensions/yaru_extensions.dart';
import 'package:whatsapp_ai/services/generative_ai_service.dart';
import 'package:whatsapp_ai/services/persona_service.dart';
import 'package:whatsapp_ai/services/redis_service.dart';
import 'package:whatsapp_ai/services/system_service.dart';
import 'package:whatsapp_ai/services/whatsapp_service.dart';
import 'package:window_manager/window_manager.dart';
import 'package:yaru/yaru.dart';

import 'views/home.dart';

final GetIt di = GetIt.instance;

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await registerThirdPartyServices();
  await registerInternalServices();
  await configureWindowManager();

  runApp(const App());
}

Future<void> configureWindowManager() async {
  final bool isDesktop = Platform.isWindows || Platform.isLinux || Platform.isMacOS;

  if (isDesktop) {
    await windowManager.ensureInitialized();
    const WindowOptions windowOptions = WindowOptions(
      backgroundColor: Color(0xFF1E1E1E),
      title: '\${INSERT_APP_NAME} - AI Bot Prototype',
      center: true,
      titleBarStyle: TitleBarStyle.hidden,
      windowButtonVisibility: true,
    );

    windowManager.waitUntilReadyToShow(windowOptions, () async {
      await windowManager.show();
      await windowManager.focus();
    });
  }

  SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    statusBarIconBrightness: Brightness.light,
    systemNavigationBarColor: Colors.transparent,
    systemNavigationBarIconBrightness: Brightness.light,
  ));
}

Future<void> registerThirdPartyServices() async {
  di.registerSingleton<Dio>(Dio(BaseOptions(baseUrl: 'https://gate.whapi.cloud/')), instanceName: 'whatsapp');
  di.registerSingleton<Cron>(Cron());
  di.registerSingleton<EventBus>(EventBus());
  di.registerSingleton<SharedPreferences>(await SharedPreferences.getInstance());
}

Future<void> registerInternalServices() async {
  final AbstractGenerativeAIService generativeAIService = GenerativeAIService();
  final AbstractWhatsappService whatsappService = WhatsappService();
  final AbstractSystemService systemService = SystemService();
  final AbstractRedisService redisService = RedisService();
  final AbstractPersonaService personaService = PersonaService();

  await generativeAIService.initialize();
  await whatsappService.initialize();
  await redisService.initialize();

  di.registerSingleton<AbstractGenerativeAIService>(generativeAIService);
  di.registerSingleton<AbstractWhatsappService>(whatsappService);
  di.registerSingleton<AbstractSystemService>(systemService);
  di.registerSingleton<AbstractRedisService>(redisService);
  di.registerSingleton<AbstractPersonaService>(personaService);
}

mixin AppServicesMixin {
  Dio get whatsappDio => di<Dio>(instanceName: 'whatsapp');
  Dio get langchainDio => di<Dio>(instanceName: 'langchainServer');

  Cron get cron => di<Cron>();
  EventBus get eventBus => di<EventBus>();
  SharedPreferences get sharedPreferences => di<SharedPreferences>();

  RedisConnection get redisConnection => di<RedisConnection>();

  AbstractWhatsappService get whatsappService => di<AbstractWhatsappService>();
  AbstractGenerativeAIService get generativeAIService => di<AbstractGenerativeAIService>();
  AbstractSystemService get systemService => di<AbstractSystemService>();
  AbstractRedisService get redisService => di<AbstractRedisService>();
  AbstractPersonaService get personaService => di<AbstractPersonaService>();
}

class App extends StatefulWidget {
  const App({super.key});

  static GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

  @override
  State<App> createState() => _AppState();
}

class _AppState extends State<App> with AppServicesMixin {
  StreamSubscription<ThemeUpdatedEvent>? _themeUpdatedSubscription;

  YaruVariant _yaruVariant = YaruVariant.xubuntuBlue;
  YaruVariant get yaruVariant => _yaruVariant;
  set yaruVariant(YaruVariant value) {
    _yaruVariant = value;
    if (mounted) {
      setState(() {});
    }
  }

  bool _isDarkMode = false;
  bool get isDarkMode => _isDarkMode;
  set isDarkMode(bool value) {
    _isDarkMode = value;
    if (mounted) {
      setState(() {});
    }
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback(onFirstFrameRendered);
    setupListeners();
  }

  void setupListeners() {
    _themeUpdatedSubscription = eventBus.on<ThemeUpdatedEvent>().listen(onThemeUpdated);
  }

  @override
  void dispose() {
    _themeUpdatedSubscription?.cancel();
    super.dispose();
  }

  void onFirstFrameRendered(Duration timeStamp) {
    _isDarkMode = systemService.isDarkMode;
    _yaruVariant = systemService.yaruVariant.toYaruVariant();
    setState(() {});
  }

  void onThemeUpdated(ThemeUpdatedEvent event) {
    if (!mounted) return;

    _isDarkMode = systemService.isDarkMode;
    _yaruVariant = systemService.yaruVariant.toYaruVariant();
    setState(() {});

    systemService.showInformationToast('Theme updated to ${_yaruVariant.toYaruString()}');
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '\${INSERT_APP_NAME} - AI Bot Prototype',
      home: const HomeView(),
      debugShowCheckedModeBanner: false,
      themeMode: ThemeMode.system,
      navigatorKey: App.navigatorKey,
      builder: (context, child) {
        return YaruTheme(
          data: YaruThemeData(
            useMaterial3: true,
            variant: _yaruVariant,
            themeMode: _isDarkMode ? ThemeMode.dark : ThemeMode.light,
          ),
          child: child!,
        );
      },
      scrollBehavior: const MaterialScrollBehavior().copyWith(
        dragDevices: {PointerDeviceKind.mouse, PointerDeviceKind.touch, PointerDeviceKind.stylus, PointerDeviceKind.unknown},
      ),
    );
  }
}
