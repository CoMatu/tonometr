import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:tonometr/themes/theme_provider.dart';

@RoutePage()
class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Text('Settings'),
          Placeholder(color: Colors.amber),
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
    );
  }
}
