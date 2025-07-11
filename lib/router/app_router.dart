import 'package:auto_route/auto_route.dart';
import 'package:tonometr/router/app_router.gr.dart';

@AutoRouterConfig()
class AppRouter extends RootStackRouter {
  @override
  List<AutoRoute> get routes => [
    AutoRoute(page: HomeRoute.page, initial: true),
    AutoRoute(page: BloodPressureRoute.page),
    AutoRoute(page: CalendarRoute.page),
    AutoRoute(page: ChartRoute.page),
    AutoRoute(page: SettingsRoute.page),
  ];
}
