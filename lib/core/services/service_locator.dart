import 'package:get_it/get_it.dart';

import 'package:zumie/core/services/app/translator_service.dart';

import 'package:zumie/core/services/utils/event_bus_service.dart';
import 'package:zumie/core/services/utils/navigation_service.dart';
import 'package:zumie/features/task/application/task_service.dart';

final locator = GetIt.instance;

Future<void> setupLocator() async {
  //--REPOSITORIES--//

  locator.registerLazySingleton(() => NavigationService());
  locator.registerLazySingleton(() => EventBusService());
  locator.registerLazySingleton(() => TaskService());
  locator.registerLazySingleton(() => TranslatorService());
}
