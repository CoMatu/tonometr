import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

/// {@template initialization_splash_screen}
/// Экран загрузки приложения
/// {@endtemplate}
class InitializationSplashScreen extends StatelessWidget {
  /// {@macro initialization_splash_screen}
  const InitializationSplashScreen({this.progress, super.key});

  /// Progress
  final ValueListenable<({int progress, String message})>? progress;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      child: DecoratedBox(
        decoration: const BoxDecoration(),
        child: Directionality(
          textDirection: TextDirection.ltr,
          child: Center(
            child: progress != null
                ? ListView(
                    shrinkWrap: true,
                    children: <Widget>[
                      const FlutterLogo(),
                      const SizedBox(height: 16),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 40),
                        child: Opacity(
                          opacity: .25,
                          child: ValueListenableBuilder<
                              ({String message, int progress})>(
                            valueListenable: progress!,
                            builder: (context, value, _) => SizedBox(
                              height: 70,
                              child: Text(
                                value.message,
                                overflow: TextOverflow.ellipsis,
                                maxLines: 3,
                                textAlign: TextAlign.center,
                                style: Theme.of(context)
                                    .textTheme
                                    .labelSmall
                                    ?.copyWith(height: 1, color: Colors.white),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  )
                : const FlutterLogo(),
          ),
        ),
      ),
    );
  }
}
