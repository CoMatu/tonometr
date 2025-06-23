import 'package:flutter/material.dart';
import 'package:talker/talker.dart';
import 'package:tonometr/core/initialization/data/models/dependencies.dart';

/// {@template dependencies_ext}
/// Extension to get dependencies from BuildContext
/// {@endtemplate}
extension DependenciesExt on BuildContext {
  /// {@macro dependencies_ext}
  Dependencies get dependencies => Dependencies.of(this);
}

/// {@template logger_ext}
/// Extension to get logger from BuildContext
/// {@endtemplate}
extension LoggerExt on BuildContext {
  /// {@macro logger_ext}
  Talker get talker => Dependencies.of(this).talker;
}
