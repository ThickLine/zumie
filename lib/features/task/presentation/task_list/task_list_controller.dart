import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:zumie/features/task/data/task_repository.dart';
import 'package:zumie/features/task/domain/task/task_model.dart';

class TasksList extends StateNotifier<AsyncValue<List<TaskModel>>> {
  TasksList({
    required this.productsRepositoryProvider,
  }) : super(AsyncValue.data(productsRepositoryProvider.list));

  final TaskRepository productsRepositoryProvider;

  Future<String?> add() async {
    state = AsyncValue.data(productsRepositoryProvider.list);
    return await productsRepositoryProvider.createDocument();
  }

  Future<void> updateList() async {
    state = AsyncValue.data(productsRepositoryProvider.list);
  }

  void removeTask(TaskModel todo) {
    //  Todo: implement
  }
}

final tasksListProvider =
    StateNotifierProvider<TasksList, AsyncValue<List<TaskModel>>>((ref) {
  return TasksList(
    productsRepositoryProvider: ref.watch(taskRepositoryProvider),
  );
});
