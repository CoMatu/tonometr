import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:tonometr/themes/theme_provider.dart';
import 'package:tonometr/settings/ui/widgets/import_button.dart';
import 'package:tonometr/settings/ui/widgets/export_button.dart';
import 'package:persistent_storage/persistent_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tonometr/core/ui_kit/yandex_banner_ad_widget.dart';

@RoutePage()
class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  bool _adsEnabled = true;
  final _adsKey = 'ads_enabled';
  late PersistentStorage _storage;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _initStorage();
  }

  Future<void> _initStorage() async {
    final prefs = await SharedPreferences.getInstance();
    _storage = PersistentStorage(sharedPreferences: prefs);
    final value = await _storage.read(key: _adsKey);
    setState(() {
      _adsEnabled = value != 'false';
      _loading = false;
    });
  }

  Future<void> _toggleAds(bool value) async {
    setState(() => _adsEnabled = value);
    await _storage.write(key: _adsKey, value: value.toString());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Настройки')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: SizedBox(
              width: double.infinity,
              height: 50,
              child: OutlinedButton(
                onPressed: () {
                  ThemeProvider.of(context).toggleTheme();
                },
                child: const Text('Сменить тему'),
              ),
            ),
          ),
          if (_loading)
            const Padding(
              padding: EdgeInsets.all(16),
              child: CircularProgressIndicator(),
            )
          else
            SwitchListTile(
              title: const Text('Показывать рекламу'),
              value: _adsEnabled,
              onChanged: _toggleAds,
            ),
          const ImportButton(),
          const ExportButton(),
          if (!_loading && _adsEnabled)
            const YandexBannerAdWidget(adUnitId: 'R-M-16235352-1'),
        ],
      ),
    );
  }
}
