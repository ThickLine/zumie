import 'package:flutter/material.dart';
import 'package:super_editor/super_editor.dart';
import 'package:zumie/core/common/app_colors.dart';
import 'package:zumie/core/extensions/node_title.dart';
import 'package:zumie/features/task/domain/task/task_model.dart';

class ListCard extends StatelessWidget {
  final TaskModel? task;
  final Function()? onTap;
  const ListCard({Key? key, this.task, this.onTap}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    var doc = task?.document as Document;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.fromLTRB(5, 8, 5, 8),
        decoration: BoxDecoration(
            border: Border.all(
          width: 3,
          color: kcDarkPrimaryColor,
        )),
        child: Row(
          children: [Text(doc.nodeTitle ?? "")],
        ),
      ),
    );
  }
}
