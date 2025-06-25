import 'package:flutter/material.dart';
import 'package:storage/storage.dart';
import 'package:tonometr/themes/dark_theme.dart';
import 'package:tonometr/themes/light_theme.dart';

class ThemeProvider extends StatefulWidget {
  const ThemeProvider({
    super.key,
    required this.child,
    required this.storage,
    required this.initialTheme,
  });

  final Widget child;
  final Storage storage;
  final ThemeData initialTheme;

  @override
  State<ThemeProvider> createState() => ThemeProviderState();

  static ThemeProviderState of(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<_InheritedTheme>()!.data;
  }
}

class ThemeProviderState extends State<ThemeProvider> {
  late ThemeData _themeData;
  static const String _themeKey = 'app_theme';

  @override
  void initState() {
    super.initState();
    _themeData = widget.initialTheme;
  }

  ThemeData get themeData => _themeData;

  Future<void> toggleTheme() async {
    final newTheme = _themeData == lightTheme ? darkTheme : lightTheme;
    setState(() {
      _themeData = newTheme;
    });
    await widget.storage.write(
      key: _themeKey,
      value: newTheme == darkTheme ? 'dark' : 'light',
    );
  }

  @override
  Widget build(BuildContext context) {
    return _InheritedTheme(data: this, child: widget.child);
  }
}

class _InheritedTheme extends InheritedWidget {
  const _InheritedTheme({required this.data, required super.child});

  final ThemeProviderState data;

  @override
  bool updateShouldNotify(_InheritedTheme oldWidget) {
    return true;
  }
}
