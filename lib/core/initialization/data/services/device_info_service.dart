import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/foundation.dart';

/// {@template device_info_service}
/// Сервис предоставляет информацию об устройстве
/// {@endtemplate}
class DeviceInfoService {
  /// {@macro device_info_service}
  DeviceInfoService();

  static final DeviceInfoPlugin _deviceInfoPlugin = DeviceInfoPlugin();

  /// {@macro device_info_service}
  Future<Map<String, dynamic>> getDeviceData() async {
    var deviceData = <String, dynamic>{};

    try {
      deviceData = switch (defaultTargetPlatform) {
        TargetPlatform.android =>
          _readAndroidBuildData(await _deviceInfoPlugin.androidInfo),
        TargetPlatform.iOS =>
          _readIosDeviceInfo(await _deviceInfoPlugin.iosInfo),
        TargetPlatform.linux => <String, dynamic>{
            'Error:': "LINUX platform isn't supported",
          },
        TargetPlatform.windows => <String, dynamic>{
            'Error:': "WINDOWS platform isn't supported",
          },
        TargetPlatform.macOS => <String, dynamic>{
            'Error:': "MAC OS platform isn't supported",
          },
        TargetPlatform.fuchsia => <String, dynamic>{
            'Error:': "Fuchsia platform isn't supported",
          },
      };
    } on Exception catch (e) {
      deviceData = <String, dynamic>{
        'Error:': 'Failed to get platform version. Error: $e',
      };
    }

    return deviceData;
  }

  Map<String, dynamic> _readAndroidBuildData(AndroidDeviceInfo build) {
    return <String, dynamic>{
      'operationVersion': 'android',
      'version.securityPatch': build.version.securityPatch,
      'version.sdkInt': build.version.sdkInt,
      'version.release': build.version.release,
      'version.previewSdkInt': build.version.previewSdkInt,
      'version.incremental': build.version.incremental,
      'version.codename': build.version.codename,
      'version.baseOS': build.version.baseOS,
      'board': build.board,
      'bootloader': build.bootloader,
      'brand': build.brand,
      'device': build.device,
      'display': build.display,
      'fingerprint': build.fingerprint,
      'hardware': build.hardware,
      'host': build.host,
      'id': build.id,
      'manufacturer': build.manufacturer,
      'model': build.model,
      'product': build.product,
      'supported32BitAbis': build.supported32BitAbis,
      'supported64BitAbis': build.supported64BitAbis,
      'supportedAbis': build.supportedAbis,
      'tags': build.tags,
      'type': build.type,
      'isPhysicalDevice': build.isPhysicalDevice,
      'systemFeatures': build.systemFeatures,
      'serialNumber': build.serialNumber,
    };
  }

  Map<String, dynamic> _readIosDeviceInfo(IosDeviceInfo data) {
    return <String, dynamic>{
      'operationVersion': 'ios',
      'name': data.name,
      'systemName': data.systemName,
      'systemVersion': data.systemVersion,
      'model': data.model,
      'localizedModel': data.localizedModel,
      'identifierForVendor': data.identifierForVendor,
      'isPhysicalDevice': data.isPhysicalDevice,
      'utsname.sysname:': data.utsname.sysname,
      'utsname.nodename:': data.utsname.nodename,
      'utsname.release:': data.utsname.release,
      'utsname.version:': data.utsname.version,
      'utsname.machine:': data.utsname.machine,
    };
  }
}
