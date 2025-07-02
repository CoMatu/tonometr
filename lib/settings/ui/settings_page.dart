import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:tonometr/themes/theme_provider.dart';

@RoutePage()
class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(title: const Text('Settings')),
        body: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: OutlinedButton(
                onPressed: () {
                  ThemeProvider.of(context).toggleTheme();
                },
                child: const Text('Switch theme'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
