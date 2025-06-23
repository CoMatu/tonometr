// ignore_for_file: public_member_api_docs, sort_constructors_first

class AppMetadata {
  AppMetadata({
    required this.deviceId,
    required this.appName,
    required this.packageName,
    required this.version,
    required this.buildNumber,
    required this.operatingSystem,
    required this.model,
  });

  final String deviceId;
  final String appName;
  final String packageName;
  final String version;
  final String buildNumber;
  final String operatingSystem;
  final String model;

  /// Полная версия приложения (собирается из [version] и [buildNumber]).
  String get appVersion => '$version+$buildNumber';

  @override
  String toString() {
    return 'appName: $appName, packageName: $packageName, '
        'version: $version, buildNumber: $buildNumber, '
        'operatingSystem: $operatingSystem, model: $model, '
        'appVersion: $appVersion), deviceId: $deviceId';
  }
}
