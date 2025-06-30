import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tonometr/blood_pressure/ui/blood_pressure_page.dart';
import 'package:tonometr/charts/ui/chart_page.dart';
import 'package:tonometr/home/domain/bottom_bar_bloc.dart/bottom_bar_bloc.dart';
import 'package:tonometr/settings/ui/settings_page.dart';

@RoutePage()
class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final List<Widget> _pages = [
    const BloodPressurePage(),
    const ChartPage(),
    const SettingsPage(),
  ];

  void _onTabTapped(int index) {
    context.read<BottomBarBloc>().add(BottomBarEvent.update(index));
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<BottomBarBloc, BottomBarState>(
      builder: (context, state) {
        return Scaffold(
          body: IndexedStack(index: state.index, children: _pages),
          bottomNavigationBar: BottomNavigationBar(
            currentIndex: state.index,
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
      },
    );
  }
}
