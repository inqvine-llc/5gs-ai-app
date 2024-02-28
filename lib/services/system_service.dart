import 'package:flutter/material.dart';
import 'package:whatsapp_ai/events/theme_updated_event.dart';
import 'package:whatsapp_ai/extensions/yaru_extensions.dart';
import 'package:whatsapp_ai/main.dart';
import 'package:yaru/yaru.dart';

abstract class AbstractSystemService with AppServicesMixin {
  String get yaruVariant;
  bool get isDarkMode;

  Future<void> showInformationToast(String message);
  Future<void> showWarningToast(String message);
  Future<void> showErrorToast(String message);
  Future<void> showSuccessToast(String message);

  Future<bool> showConfirmationDialog(String title, String body);

  Future<void> saveYaruVariant(String variant);
  Future<void> removeYaruVariant();

  Future<void> setDarkMode(bool value);
}

class SystemService extends AbstractSystemService with AppServicesMixin {
  static const String kYaruVariantKey = 'yaruVariant';
  static const String kDarkModeKey = 'darkMode';

  @override
  bool get isDarkMode => sharedPreferences.getBool(kDarkModeKey) ?? false;

  @override
  String get yaruVariant => sharedPreferences.getString(kYaruVariantKey) ?? YaruVariant.xubuntuBlue.toYaruString();

  @override
  Future<void> showInformationToast(String message) async {
    await showToast(message, YaruColors.light.link, YaruColors.porcelain);
  }

  @override
  Future<void> showWarningToast(String message) async {
    await showToast(message, YaruColors.light.warning, YaruColors.porcelain);
  }

  @override
  Future<void> showErrorToast(String message) async {
    await showToast(message, YaruColors.light.error, YaruColors.porcelain);
  }

  @override
  Future<void> showSuccessToast(String message) async {
    await showToast(message, YaruColors.light.success, YaruColors.porcelain);
  }

  Future<void> showToast(String message, Color color, Color textColor) async {
    final BuildContext? context = App.navigatorKey.currentContext;
    if (context == null) {
      return;
    }

    final ScaffoldMessengerState scaffoldMessenger = ScaffoldMessenger.of(context);

    final SnackBar snackBar = SnackBar(
      backgroundColor: color,
      duration: const Duration(seconds: 2),
      content: Align(
        alignment: Alignment.center,
        child: Text(
          message,
          style: TextStyle(color: textColor),
        ),
      ),
    );

    scaffoldMessenger.showSnackBar(snackBar);
  }

  @override
  Future<bool> showConfirmationDialog(String title, String body) async {
    final BuildContext? context = App.navigatorKey.currentContext;
    if (context == null) {
      return false;
    }

    return await showDialog<bool>(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: Text(title),
              content: Text(body),
              actions: <Widget>[
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop(false);
                  },
                  child: const Text('No'),
                ),
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop(true);
                  },
                  child: const Text('Yes'),
                ),
              ],
            );
          },
        ) ??
        false;
  }

  @override
  Future<void> saveYaruVariant(String variant) async {
    await sharedPreferences.setString(kYaruVariantKey, variant);
    eventBus.fire(ThemeUpdatedEvent());
  }

  @override
  Future<void> removeYaruVariant() async {
    await sharedPreferences.remove(kYaruVariantKey);
    eventBus.fire(ThemeUpdatedEvent());
  }

  @override
  Future<void> setDarkMode(bool value) async {
    await sharedPreferences.setBool(kDarkModeKey, value);
    eventBus.fire(ThemeUpdatedEvent());
  }
}
