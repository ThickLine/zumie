import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:zumie/core/common/themes.dart';
import 'package:zumie/core/extensions/string_hardcoded.dart';
import 'package:zumie/core/router/router.dart';
import 'package:zumie/core/services/service_locator.dart';
import 'package:zumie/core/services/utils/navigation_service.dart';

class ZumieApp extends ConsumerWidget {
  final navigator = locator<NavigationService>();
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final goRouter = ref.watch(goRouterProvider);
    return MaterialApp.router(
      onGenerateTitle: (BuildContext context) => 'Zumie'.hardcoded,
      restorationScopeId: 'app',
      theme: primaryMaterialTheme,
      themeMode: ThemeMode.light,
      debugShowCheckedModeBanner: false,
      routeInformationProvider: goRouter.routeInformationProvider,
      routeInformationParser: goRouter.routeInformationParser,
      routerDelegate: goRouter.routerDelegate,
    );
  }
}
