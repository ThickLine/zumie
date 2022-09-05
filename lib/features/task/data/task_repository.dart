import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:super_editor/super_editor.dart';
import 'package:uuid/uuid.dart';

import 'package:zumie/features/task/domain/task/task_model.dart';
import 'package:zumie/features/task/presentation/task_list/task_list_controller.dart';
import 'package:logger/logger.dart' as l;
import 'package:zumie/features/task/presentation/widgets/task/task.dart';

class TaskRepository {
  TaskRepository(this.ref) : super();
  final log = l.Logger();
  final Ref ref;

  final List<TaskModel> _list = [];
  List<TaskModel> get list => _list;

  Future<void> updateDocument(String id, Document data) async {
    list.map((e) => e.id == id ? e.copyWith(document: data) : e).toList();
    ref.refresh(tasksListProvider);
  }

  Stream<TaskModel?> getTask(String id) async* {
    yield _getTaskById(list, id);
  }

  /// Creates new document and returns its [id]
  Future<String?> createDocument() async {
    final data = TaskModel(
        id: const Uuid().v1(),
        document: MutableDocument(nodes: [
          ParagraphNode(
            id: DocumentEditor.createNodeId(),
            text: AttributedText(
              text: 'Welcome  💙 🚀',
            ),
            metadata: {
              'blockType': header1Attribution,
            },
          ),
          TaskNode(
            id: DocumentEditor.createNodeId(),
            isComplete: false,
            text: AttributedText(
              text: 'Create and configure your document',
            ),
          ),
        ]));
    _list.add(data);

    return data.id;
  }

  // Delete document
  Future<void> deleteDocument(TaskModel data) async {
    _list.remove(data);
  }

  Future<void> addTaskSection(String id) async {
    getTask(id).listen((event) {
      event?.document.nodes.add(TaskNode(
        id: DocumentEditor.createNodeId(),
        isComplete: false,
        text: AttributedText(
          text: 'Potato',
        ),
      ));
    });
  }

  static TaskModel? _getTaskById(List<TaskModel> tasks, String id) {
    try {
      return tasks.firstWhere((el) => el.id == id);
    } catch (e) {
      return null;
    }
  }
}

final taskRepositoryProvider = Provider<TaskRepository>((ref) {
  return TaskRepository(ref);
});

final taskProvider =
    StreamProvider.autoDispose.family<TaskModel?, String>((ref, id) {
  final productsRepository = ref.watch(taskRepositoryProvider);
  return productsRepository.getTask(id);
});
