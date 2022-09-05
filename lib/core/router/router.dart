import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:zumie/core/router/not_found_screen.dart';

import 'package:zumie/features/task/presentation/task/create_task_screen.dart';
import 'package:zumie/features/task/presentation/task_list/task_list_screen.dart';

enum AppRoute { home, newTask, task }

final goRouterProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: '/',
    debugLogDiagnostics: false,
    redirect: (state) {
      return null;
    },
    routes: [
      GoRoute(
        path: '/',
        name: AppRoute.home.name,
        builder: (_, __) => const TaskListScreen(),
        routes: [
          GoRoute(
            path: 'task/:id',
            name: AppRoute.newTask.name,
            builder: (_, state) {
              final taskId = state.params['id']!;
              return CreateTaskScreen(taskId: taskId);
            },
          ),
        ],
      ),
    ],
    errorBuilder: (_, __) => const NotFoundScreen(),
  );
});
