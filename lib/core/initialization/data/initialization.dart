import 'dart:async';
import 'dart:developer';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:tonometr/core/initialization/data/initialize_dependencies.dart';
import 'package:tonometr/core/initialization/data/models/dependencies.dart';

/// Ephemerally initializes the app and prepares it for use.
Future<Dependencies>? _$initializeApp;

/// Initializes the app and prepares it for use.
Future<Dependencies> $initializeApp({
  void Function(int progress, String message)? onProgress,
  FutureOr<void> Function(Dependencies dependencies)? onSuccess,
  void Function(Object error, StackTrace stackTrace)? onError,
}) =>
    _$initializeApp ??= Future<Dependencies>(() async {
      late final WidgetsBinding binding;
      final stopwatch = Stopwatch()..start();
      try {
        binding = WidgetsFlutterBinding.ensureInitialized();
        FlutterNativeSplash.preserve(widgetsBinding: binding);

        SystemChrome.setSystemUIOverlayStyle(
          SystemUiOverlayStyle(
            // systemNavigationBarColor:
            //     RmsColors.darkIndigo3, // Цвет панели навигации
            systemNavigationBarIconBrightness:
                Brightness.light, // Светлые иконки
          ),
        );

        await _catchExceptions();

        final dependencies = await $initializeDependencies(
          onProgress: onProgress,
        ).timeout(const Duration(minutes: 5));
        await onSuccess?.call(dependencies);
        return dependencies;
      } on Object catch (error, stackTrace) {
        onError?.call(error, stackTrace);
        rethrow;
      } finally {
        stopwatch.stop();
        binding.addPostFrameCallback((_) {
          // Closes splash screen, and show the app layout.
          FlutterNativeSplash.remove();
        });
        _$initializeApp = null;
      }
    });

/// Resets the app's state to its initial state.
@visibleForTesting
Future<void> $resetApp(Dependencies dependencies) async {}

/// Disposes the app and releases all resources.
@visibleForTesting
Future<void> $disposeApp(Dependencies dependencies) async {}

Future<void> _catchExceptions() async {
  try {
    PlatformDispatcher.instance.onError = (error, stackTrace) {
      // TODO(CoMatu): Подключить аналитику для сбора ошибок
      // Matusevich Vyacheslav <Telegram: @CoMatu>, 16 December 2024
      return true;
    };

    final sourceFlutterError = FlutterError.onError;
    FlutterError.onError = (details) {
      // TODO(CoMatu): Подключить аналитику для сбора ошибок
      // Matusevich Vyacheslav <Telegram: @CoMatu>, 16 December 2024

      sourceFlutterError?.call(details);
    };
  } on Object catch (error, stackTrace) {
    log(error.toString(), stackTrace: stackTrace);
  }
}
