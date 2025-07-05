import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:tonometr/themes/theme_provider.dart';
import 'package:tonometr/settings/ui/widgets/import_button.dart';
import 'package:tonometr/settings/ui/widgets/export_button.dart';

@RoutePage()
class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

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
          const ImportButton(),
          const ExportButton(),
        ],
      ),
    );
  }
}
