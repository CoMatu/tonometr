class AppConfig {
  static const String configType = String.fromEnvironment('CONFIG_TYPE');
  static const String configVersion = String.fromEnvironment('CONFIG_VERSION');
  static const String yandexAdId = String.fromEnvironment('YANDEX_AD_ID');
  static const String yandexBannerAdId = String.fromEnvironment(
    'YANDEX_BANNER_AD_ID',
  );
}
