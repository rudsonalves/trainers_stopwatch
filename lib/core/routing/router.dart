import 'package:flutter/foundation.dart';
import 'package:go_router/go_router.dart';

import 'route_observer.dart';
import 'routes.dart';
import 'routes/main_routes.dart';

GoRouter createRouter(MainRouteDependencies dependencies) => GoRouter(
      initialLocation: MainRoutes.stopwatch.routePath,
      debugLogDiagnostics: kDebugMode,
      observers: [routeObserver],
      routes: mainRoutes(dependencies),
    );
