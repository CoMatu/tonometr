// ignore_for_file: provide_deprecation_message

import 'package:flutter/material.dart';
import 'package:persistent_storage/persistent_storage.dart';
import 'package:talker/talker.dart';
import 'package:tonometr/auth/data/auth_client.dart';
import 'package:tonometr/auth/domain/auth_repository.dart';
import 'package:tonometr/core/initialization/data/models/app_metadata.dart';
import 'package:tonometr/core/initialization/ui/inherited_dependencies.dart';

/// Dependencies
abstract interface class Dependencies {
  /// The state from the closest instance of this class.
  factory Dependencies.of(BuildContext context) =>
      InheritedDependencies.of(context);

  /// App metadata
  abstract final AppMetadata appMetadata;

  /// Theme
  abstract final ThemeData theme;

  /// Storage
  abstract final PersistentStorage storage;

  /// Auth repository
  abstract final AuthRepository authRepository;

  /// Auth client
  abstract final AuthClient authClient;

  /// Logger
  abstract final Talker talker;
}

/// {@template dependencies}
/// Dependencies
/// {@endtemplate}
final class $MutableDependencies implements Dependencies {
  /// {@macro dependencies}
  $MutableDependencies() : context = <String, Object?>{};

  /// Initialization context
  final Map<Object?, Object?> context;

  @override
  late AppMetadata appMetadata;

  @override
  late ThemeData theme;

  @override
  late PersistentStorage storage;

  @override
  late AuthRepository authRepository;

  @override
  late AuthClient authClient;

  @override
  late Talker talker;

  /// {@macro dependencies}
  Dependencies freeze() => _$ImmutableDependencies(
    appMetadata: appMetadata,
    storage: storage,
    authRepository: authRepository,
    authClient: authClient,
    talker: talker,
    theme: theme,
  );
}

final class _$ImmutableDependencies implements Dependencies {
  _$ImmutableDependencies({
    required this.appMetadata,
    required this.storage,
    required this.authRepository,
    required this.authClient,
    required this.talker,
    required this.theme,
  });

  @override
  final AppMetadata appMetadata;

  @override
  final ThemeData theme;

  @override
  final PersistentStorage storage;

  @override
  late AuthRepository authRepository;

  @override
  late AuthClient authClient;

  @override
  late Talker talker;
}
