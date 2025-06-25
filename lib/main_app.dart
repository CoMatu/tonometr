import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:talker_flutter/talker_flutter.dart';
import 'package:tonometr/core/initialization/data/dependencies_ext.dart';
import 'package:tonometr/home/ui/scopes/global_scope.dart';
import 'package:tonometr/router/app_router.dart';
import 'package:tonometr/themes/theme_provider.dart';

class MainApp extends StatelessWidget {
  MainApp({super.key});

  final _router = AppRouter();

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      localizationsDelegates: const [
        // S.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      // supportedLocales: S.delegate.supportedLocales,
      theme: ThemeProvider.of(context).themeData,
      debugShowCheckedModeBanner: false,
      routerConfig: _router.config(
        navigatorObservers: () => [TalkerRouteObserver(context.talker)],
      ),
      builder: (context, child) {
        return GlobalScope(child: child!);
      },
    );
  }
}
