import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../../core/constants/firebase_collections.dart';
import '../../../../core/exceptions/app_exceptions.dart';
import '../data/models/task_model.dart';

class FirebaseTaskService {
  final FirebaseFirestore _firestore;

  FirebaseTaskService(this._firestore);

  CollectionReference _getTasksCollection(String userId) {
    return _firestore
        .collection(FirebaseCollections.users)
        .doc(userId)
        .collection(FirebaseCollections.tasks);
  }

  Stream<List<TaskModel>> getTasksStream(String userId) {
    try {
      return _getTasksCollection(userId)
          .orderBy('createdAt', descending: true)
          .snapshots()
          .map((snapshot) {
        return snapshot.docs
            .map((doc) => TaskModel.fromFirestore(doc))
            .toList();
      });
    } on FirebaseException catch (e) {
      throw AppException(e.message ?? 'Failed to fetch tasks.');
    }
  }

  Future<void> addTask(String userId, TaskModel task) async {
    try {
      await _getTasksCollection(userId).add(task.toFirestore());
    } on FirebaseException catch (e) {
      throw AppException(e.message ?? 'Failed to add task.');
    }
  }

  Future<void> updateTask(String userId, TaskModel task) async {
    try {
      await _getTasksCollection(userId)
          .doc(task.id)
          .update(task.toFirestore());
    } on FirebaseException catch (e) {
      throw AppException(e.message ?? 'Failed to update task.');
    }
  }

  Future<void> deleteTask(String userId, String taskId) async {
    try {
      await _getTasksCollection(userId).doc(taskId).delete();
    } on FirebaseException catch (e) {
      throw AppException(e.message ?? 'Failed to delete task.');
    }
  }
}