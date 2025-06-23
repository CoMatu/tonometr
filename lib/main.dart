import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:tonometr/core/initialization/data/initialization.dart';
import 'package:tonometr/core/initialization/ui/inherited_dependencies.dart';
import 'package:tonometr/main_app.dart';

void main() async {
  /// Инициализация и затем - запуск приложения
  await $initializeApp(
    onProgress: (int progress, String message) {
      //...
    },
    onSuccess: (dependencies) async {
      runApp(
        InheritedDependencies(dependencies: dependencies, child: MainApp()),
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
