import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:persistent_storage/persistent_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:talker_bloc_logger/talker_bloc_logger.dart';
import 'package:talker_flutter/talker_flutter.dart';
import 'package:tonometr/auth/data/auth_client.dart';
import 'package:tonometr/auth/domain/auth_repository.dart';
import 'package:tonometr/core/initialization/data/models/app_metadata.dart';
import 'package:tonometr/core/initialization/data/models/dependencies.dart';
import 'package:tonometr/core/initialization/data/services/device_info_service.dart';
import 'package:tonometr/core/initialization/data/services/package_info_service.dart';
import 'package:tonometr/themes/dark_theme.dart';
import 'package:tonometr/themes/light_theme.dart';

/// Initializes the app and returns a [Dependencies] object
Future<Dependencies> $initializeDependencies({
  void Function(int progress, String message)? onProgress,
}) async {
  final dependencies = $MutableDependencies();
  final totalSteps = _initializationSteps.length;
  var currentStep = 0;

  for (final step in _initializationSteps.entries) {
    currentStep++;
    final percent = (currentStep * 100 ~/ totalSteps).clamp(0, 100);
    onProgress?.call(percent, step.key);
    await step.value(dependencies);
  }
  return dependencies.freeze();
}

typedef _InitializationStep =
    FutureOr<void> Function($MutableDependencies dependencies);

final Map<String, _InitializationStep> _initializationSteps =
    <String, _InitializationStep>{
      '... Инициализируем логгер': (dependencies) async {
        final talker =
            TalkerFlutter.init()
              ..verbose('Приложение запускается в конфигурации: ___');

        dependencies.talker = talker;
      },
      '... Собираем системную информацию об устройстве и версии приложения': (
        dependencies,
      ) async {
        final packageInfo = await PackageInfoService().getPackageInfo();
        final deviceInfo = await DeviceInfoService().getDeviceData();

        dependencies.appMetadata = AppMetadata(
          deviceId: deviceInfo['id'] as String? ?? 'unknown device id',
          appName: packageInfo.appName,
          packageName: packageInfo.packageName,
          version: packageInfo.version,
          buildNumber: packageInfo.buildNumber,
          operatingSystem:
              deviceInfo['operationVersion'] as String? ?? 'unknown',
          model: deviceInfo['model'] as String? ?? 'unknown',
        );
      },
      '... Инициализируем AppBlocObserver': (dependencies) async {
        Bloc.observer = TalkerBlocObserver(
          talker: dependencies.talker,
          settings: const TalkerBlocLoggerSettings(printStateFullData: false),
        );
      },
      '... Инициализируем глобальные зависимости': (dependencies) async {
        final sharedPreferences = await SharedPreferences.getInstance();

        dependencies
          ..storage = PersistentStorage(sharedPreferences: sharedPreferences)
          ..authClient = AuthClient()
          ..authRepository = AuthRepository();

        final themeName = await dependencies.storage.read(key: 'app_theme');
        dependencies.theme = themeName == 'dark' ? darkTheme : lightTheme;
      },
    };
