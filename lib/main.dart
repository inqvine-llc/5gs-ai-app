import 'package:cron/cron.dart';
import 'package:dio/dio.dart';
import 'package:event_bus/event_bus.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:whatsapp_ai/services/gemini_service.dart';
import 'package:whatsapp_ai/services/system_service.dart';
import 'package:whatsapp_ai/services/whatsapp_service.dart';
import 'package:whatsapp_ai/themes/themes.dart';

import 'views/home_view.dart';

final GetIt di = GetIt.instance;

Future<void> main() async {
  await registerThirdPartyServices();
  await registerInternalServices();
  runApp(const App());
}

Future<void> registerThirdPartyServices() async {
  di.registerSingleton<Dio>(Dio(BaseOptions(
    baseUrl: 'https://gate.whapi.cloud/',
  )));

  di.registerSingleton<Cron>(Cron());
  di.registerSingleton<EventBus>(EventBus());
  di.registerSingleton<SharedPreferences>(await SharedPreferences.getInstance());
}

Future<void> registerInternalServices() async {
  final AbstractGeminiService geminiService = GeminiService();
  final AbstractWhatsappService whatsappService = WhatsappService();
  final AbstractSystemService systemService = SystemService();

  await geminiService.initialize();
  await whatsappService.initialize();

  di.registerSingleton<AbstractGeminiService>(geminiService);
  di.registerSingleton<AbstractWhatsappService>(whatsappService);
  di.registerSingleton<AbstractSystemService>(systemService);
}

mixin AppServicesMixin {
  Dio get whapiClient => di<Dio>();
  Cron get cron => di<Cron>();
  EventBus get eventBus => di<EventBus>();
  SharedPreferences get sharedPreferences => di<SharedPreferences>();

  AbstractWhatsappService get whatsappService => di<AbstractWhatsappService>();
  AbstractGeminiService get geminiService => di<AbstractGeminiService>();
  AbstractSystemService get systemService => di<AbstractSystemService>();
}

class App extends StatelessWidget {
  const App({super.key});

  static GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: const HomeView(),
      debugShowCheckedModeBanner: false,
      themeMode: ThemeMode.system,
      theme: Themes.lightTheme,
      darkTheme: Themes.darkTheme,
      navigatorKey: navigatorKey,
    );
  }
}
