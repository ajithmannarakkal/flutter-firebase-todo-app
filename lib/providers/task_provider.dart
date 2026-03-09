import 'package:flutter/material.dart';
import '../models/task_model.dart';
import '../services/task_service.dart';

class TaskProvider with ChangeNotifier {
  final _taskService = TaskService();

  List<TaskModel> _tasks = [];
  bool _isLoading = false;
  String? _errorMsg;

  List<TaskModel> get tasks => [..._tasks];
  bool get isLoading => _isLoading;
  String? get error => _errorMsg;

  Future<void> fetchTasks(String userId, String token) async {
    _isLoading = true;
    _errorMsg = null;
    notifyListeners();

    try {
      _tasks = await _taskService.getTasks(userId, token);
    } catch (e) {
      _errorMsg = e.toString();
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<bool> addTask(String userId, String token, String title) async {
    try {
      final task = TaskModel(title: title);
      final saved = await _taskService.addTask(userId, token, task);
      _tasks.insert(0, saved);
      notifyListeners();
      return true;
    } catch (e) {
      _errorMsg = e.toString();
      notifyListeners();
      return false;
    }
  }

  Future<bool> updateTask(
      String userId, String token, TaskModel updated) async {
    try {
      await _taskService.updateTask(userId, token, updated);
      final idx = _tasks.indexWhere((t) => t.id == updated.id);
      if (idx != -1) {
        _tasks[idx] = updated;
        notifyListeners();
      }
      return true;
    } catch (e) {
      _errorMsg = e.toString();
      notifyListeners();
      return false;
    }
  }

  Future<bool> toggleComplete(
      String userId, String token, TaskModel task) async {
    final updated = task.copyWith(isCompleted: !task.isCompleted);
    return updateTask(userId, token, updated);
  }

  Future<bool> deleteTask(String userId, String token, String taskId) async {
    try {
      await _taskService.deleteTask(userId, token, taskId);
      _tasks.removeWhere((t) => t.id == taskId);
      notifyListeners();
      return true;
    } catch (e) {
      _errorMsg = e.toString();
      notifyListeners();
      return false;
    }
  }

  void clearTasks() {
    _tasks = [];
    _errorMsg = null;
    notifyListeners();
  }
}
