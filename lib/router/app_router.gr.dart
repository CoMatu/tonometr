// dart format width=80
// GENERATED CODE - DO NOT MODIFY BY HAND

// **************************************************************************
// AutoRouterGenerator
// **************************************************************************

// ignore_for_file: type=lint
// coverage:ignore-file

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'package:auto_route/auto_route.dart' as _i5;
import 'package:tonometr/blood_pressure/ui/blood_pressure_page.dart' as _i1;
import 'package:tonometr/charts/ui/chart_page.dart' as _i2;
import 'package:tonometr/home/ui/home_page.dart' as _i3;
import 'package:tonometr/settings/ui/settings_page.dart' as _i4;

/// generated route for
/// [_i1.BloodPressurePage]
class BloodPressureRoute extends _i5.PageRouteInfo<void> {
  const BloodPressureRoute({List<_i5.PageRouteInfo>? children})
    : super(BloodPressureRoute.name, initialChildren: children);

  static const String name = 'BloodPressureRoute';

  static _i5.PageInfo page = _i5.PageInfo(
    name,
    builder: (data) {
      return const _i1.BloodPressurePage();
    },
  );
}

/// generated route for
/// [_i2.ChartPage]
class ChartRoute extends _i5.PageRouteInfo<void> {
  const ChartRoute({List<_i5.PageRouteInfo>? children})
    : super(ChartRoute.name, initialChildren: children);

  static const String name = 'ChartRoute';

  static _i5.PageInfo page = _i5.PageInfo(
    name,
    builder: (data) {
      return const _i2.ChartPage();
    },
  );
}

/// generated route for
/// [_i3.HomePage]
class HomeRoute extends _i5.PageRouteInfo<void> {
  const HomeRoute({List<_i5.PageRouteInfo>? children})
    : super(HomeRoute.name, initialChildren: children);

  static const String name = 'HomeRoute';

  static _i5.PageInfo page = _i5.PageInfo(
    name,
    builder: (data) {
      return const _i3.HomePage();
    },
  );
}

/// generated route for
/// [_i4.SettingsPage]
class SettingsRoute extends _i5.PageRouteInfo<void> {
  const SettingsRoute({List<_i5.PageRouteInfo>? children})
    : super(SettingsRoute.name, initialChildren: children);

  static const String name = 'SettingsRoute';

  static _i5.PageInfo page = _i5.PageInfo(
    name,
    builder: (data) {
      return const _i4.SettingsPage();
    },
  );
}
