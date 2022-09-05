import 'package:logger/logger.dart';

class TaskService {
  final log = Logger();

  void addTask() {
    log.i('addTask');
  }

  void removeTask() {
    log.i('removeTask');
  }

  void completeTask() {
    log.i('completeTask');
  }

  void updateTask() {
    log.i('updateTask');
  }

  Future<void> findEmoji() async {
    log.i('findEmoji');
  }
}
