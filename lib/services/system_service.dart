import 'package:flutter/material.dart';
import 'package:whatsapp_ai/main.dart';

abstract class AbstractSystemService with AppServicesMixin {
  Future<void> showInformationToast(String message);
  Future<void> showWarningToast(String message);
  Future<void> showErrorToast(String message);
  Future<void> showSuccessToast(String message);
}

class SystemService extends AbstractSystemService with AppServicesMixin {
  @override
  Future<void> showInformationToast(String message) async {
    await showToast(message, Colors.blue, Colors.white);
  }

  @override
  Future<void> showWarningToast(String message) async {
    await showToast(message, Colors.orange, Colors.white);
  }

  @override
  Future<void> showErrorToast(String message) async {
    await showToast(message, Colors.red, Colors.white);
  }

  @override
  Future<void> showSuccessToast(String message) async {
    await showToast(message, Colors.green, Colors.white);
  }

  Future<void> showToast(String message, Color color, Color textColor) async {
    final BuildContext? context = App.navigatorKey.currentContext;
    if (context == null) {
      return;
    }

    final ScaffoldMessengerState scaffoldMessenger = ScaffoldMessenger.of(context);

    final SnackBar snackBar = SnackBar(
      backgroundColor: color,
      content: Text(message, style: TextStyle(color: textColor)),
    );

    scaffoldMessenger.showSnackBar(snackBar);
  }
}
