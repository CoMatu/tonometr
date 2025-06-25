import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:tonometr/core/initialization/data/dependencies_ext.dart';
import 'package:tonometr/core/initialization/data/initialization.dart';
import 'package:tonometr/core/initialization/ui/inherited_dependencies.dart';
import 'package:tonometr/main_app.dart';
import 'package:tonometr/themes/theme_provider.dart';

void main() async {
  /// Инициализация и затем - запуск приложения
  await $initializeApp(
    onProgress: (int progress, String message) {
      //...
    },
    onSuccess: (dependencies) async {
      runApp(
        InheritedDependencies(
          dependencies: dependencies,
          child: Builder(
            builder: (context) {
              final deps = context.dependencies;
              return ThemeProvider(
                storage: deps.storage,
                initialTheme: deps.theme,
                child: MainApp(),
              );
            },
          ),
        ),
      );
    },
    onError: (error, stackTrace) {
      log(
        'Initialization error: $error',
        error: error,
        stackTrace: stackTrace,
        name: 'Runner',
      );
    },
  );
}
