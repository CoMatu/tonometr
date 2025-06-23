import 'package:package_info_plus/package_info_plus.dart';

/// {@template package_info_service}
/// Сервис предоставляет информацию о приложении
/// {@endtemplate}
class PackageInfoService {
  /// {@macro package_info_service}
  Future<
      ({
        String appName,
        String packageName,
        String version,
        String buildNumber,
      })> getPackageInfo() async {
    final info = await PackageInfo.fromPlatform();

    return (
      appName: info.appName,
      packageName: info.packageName,
      version: info.version,
      buildNumber: info.buildNumber,
    );
  }
}
