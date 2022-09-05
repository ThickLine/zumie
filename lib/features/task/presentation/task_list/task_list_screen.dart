import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:zumie/core/common/ui_helpers.dart';
import 'package:zumie/core/common/widgets/async_value_widget.dart';
import 'package:zumie/core/extensions/string_hardcoded.dart';
import 'package:zumie/core/router/router.dart';
import 'package:zumie/features/task/domain/task/task_model.dart';
import 'package:zumie/features/task/presentation/task_list/task_list_controller.dart';
import 'package:zumie/features/task/presentation/widgets/list_card.dart';

class TaskListScreen extends ConsumerWidget {
  const TaskListScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final goRouter = ref.watch(goRouterProvider);
    final tasks = ref.watch(tasksListProvider);
    final controller = ref.watch(tasksListProvider.notifier);

    return Scaffold(
        appBar: AppBar(
          automaticallyImplyLeading: false,
          centerTitle: false,
          elevation: 0,
          title: GestureDetector(
              onTap: () {
                FocusScope.of(context).requestFocus(FocusNode());
              },
              child: Container(
                  margin: const EdgeInsets.only(left: 6),
                  child: Text(
                    'Whats\'s up for today?'.hardcoded,
                  ))),
          actions: [
            IconButton(
                onPressed: () async {
                  var id = await controller.add();
                  goRouter.goNamed(
                    AppRoute.newTask.name,
                    params: {'id': id ?? ""},
                  );
                },
                icon: const Icon(
                  Icons.add,
                )),
          ],
        ),
        bottomNavigationBar: BottomNavigationBar(
          elevation: 0,
          onTap: (value) {},
          items: <BottomNavigationBarItem>[
            BottomNavigationBarItem(icon: Container(), label: ""),
            BottomNavigationBarItem(icon: Container(), label: ""),
            BottomNavigationBarItem(
              label: "Settings".hardcoded,
              icon: const Icon(Icons.settings),
            ),
          ],
        ),
        body: Padding(
          padding: kPagePadding,
          child: Column(
            children: [
              Expanded(
                child: AsyncValueWidget<List<TaskModel>>(
                    value: tasks,
                    data: (task) => task.isEmpty
                        ? Center(
                            child: Text(
                              "No tasks yet".hardcoded,
                              style: Theme.of(context).textTheme.headline3,
                              textAlign: TextAlign.center,
                            ),
                          )
                        : ListView.builder(
                            itemCount: task.length,
                            itemBuilder: (context, index) {
                              return Column(
                                children: [
                                  ListCard(
                                    task: task[index],
                                    onTap: () => context.goNamed(
                                      AppRoute.newTask.name,
                                      params: {'id': task[index].id ?? ""},
                                    ),
                                  ),
                                  verticalSpaceSmall,
                                ],
                              );
                            },
                          )),
              ),
            ],
          ),
        ));
  }
}
