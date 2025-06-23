import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

/// {@template system_bar_service}
/// Сервис устанавливает цвет статус бара и нижнего системного бара.
/// Требует обязательное наличие `Scaffold` в корневой странице приложения
/// {@endtemplate}
class SystemBarService {
  const SystemBarService._();

  /// {@macro system_bar_service}
  static void init(Color color) {
    if (!kIsWeb) {
      if (Platform.isAndroid || Platform.isIOS) {
        SystemChrome.setSystemUIOverlayStyle(
          SystemUiOverlayStyle(
            statusBarColor: color, // Цвет статус бара
            statusBarIconBrightness:
                Brightness.dark, // Темные иконки на статус баре (черный текст)
            systemNavigationBarColor: color, // Цвет навигационного бара
            systemNavigationBarIconBrightness: Brightness
                .dark, // Темные иконки на навигационном баре (черный текст)
          ),
        );
      }
    }
  }
}
