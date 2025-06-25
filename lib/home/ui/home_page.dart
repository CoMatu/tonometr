import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:tonometr/blood_pressure/ui/blood_pressure_page.dart';
import 'package:tonometr/charts/ui/chart_page.dart';
import 'package:tonometr/settings/ui/settings_page.dart';
import 'package:tonometr/themes/theme_provider.dart';

@RoutePage()
class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _currentIndex = 0;

  final List<Widget> _pages = [
    const BloodPressurePage(),
    const ChartPage(),
    const SettingsPage(),
  ];

  void _onTabTapped(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Тонометр'),
        actions: [
          IconButton(
            icon: const Icon(Icons.brightness_6),
            onPressed: () {
              ThemeProvider.of(context).toggleTheme();
            },
          ),
        ],
      ),
      body: IndexedStack(index: _currentIndex, children: _pages),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: _onTabTapped,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.water_drop_outlined),
            label: 'Давление',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.bar_chart),
            label: 'Графики',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings),
            label: 'Настройки',
          ),
        ],
      ),
    );
  }
}
