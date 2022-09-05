import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:super_editor/super_editor.dart';

import 'package:zumie/core/common/widgets/async_value_widget.dart';
import 'package:zumie/core/extensions/node_title.dart';
import 'package:zumie/core/extensions/string_hardcoded.dart';
import 'package:zumie/features/task/data/task_repository.dart';
import 'package:zumie/features/task/domain/task/task_model.dart';

import 'package:zumie/features/task/presentation/widgets/input/input.dart';

class CreateTaskScreen extends HookConsumerWidget {
  final String taskId;
  const CreateTaskScreen({Key? key, required this.taskId}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final document = ref.watch(taskProvider(taskId));

// With a MutableDocument, create a DocumentEditor, which knows how
// to apply changes to the MutableDocument.
    final title = document.value != null
        ? (document.value?.document as Document).nodeTitle
        : "";

    return Scaffold(
        appBar: AppBar(
          automaticallyImplyLeading: false,
          title: Text(title ?? ""),
          elevation: 0,
          actions: [
            InkWell(
              onTap: () => Navigator.of(context).pop(),
              child: Padding(
                padding: const EdgeInsets.all(5.0),
                child: Row(
                  children: [
                    Text(
                      "Cancel".hardcoded,
                    ),
                  ],
                ),
              ),
            ),
            InkWell(
              onTap: () {},
              child: const Padding(
                padding: EdgeInsets.all(5.0),
                child: Icon(Icons.share),
              ),
            ),
            InkWell(
              onTap: () {},
              child: const Padding(
                  padding: EdgeInsets.all(5.0), child: Icon(Icons.more_vert)),
            ),
          ],
        ),
        body: AsyncValueWidget<TaskModel?>(
          value: document,
          data: (TaskModel? doc) {
            return Column(
              children: [
                Expanded(
                  child: Input(
                    onChange: (d) => ref
                        .read(taskRepositoryProvider)
                        .updateDocument(taskId, d),
                    onOption: () async => await ref
                        .read(taskRepositoryProvider)
                        .addTaskSection(taskId),
                    initialDocument: doc?.document,
                  ),
                ),
              ],
            );
          },
        ));
  }
}
