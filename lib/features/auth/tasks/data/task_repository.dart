import '../services/firebase_task_service.dart';
import 'models/task_model.dart';

class TaskRepository {
  final FirebaseTaskService _taskService;

  TaskRepository(this._taskService);

  Stream<List<TaskModel>> getTasksStream(String userId) {
    return _taskService.getTasksStream(userId);
  }

  Future<void> addTask(String userId, TaskModel task) {
    return _taskService.addTask(userId, task);
  }

  Future<void> updateTask(String userId, TaskModel task) {
    return _taskService.updateTask(userId, task);
  }

  Future<void> deleteTask(String userId, String taskId) {
    return _taskService.deleteTask(userId, taskId);
  }
}