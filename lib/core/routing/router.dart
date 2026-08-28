import 'package:flutter/foundation.dart';
import 'package:go_router/go_router.dart';

import 'routes.dart';
import 'routes/main_routes.dart';

GoRouter createRouter({MainRouteDependencies? dependencies}) => GoRouter(
      initialLocation: MainRoutes.stopwatch.routePath,
      debugLogDiagnostics: kDebugMode,
      routes: mainRoutes(
        dependencies ?? MainRouteDependencies.production(),
      ),
    );
