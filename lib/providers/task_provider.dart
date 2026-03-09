import 'package:flutter/material.dart';
import '../models/task_model.dart';
import '../services/task_service.dart';

class TaskProvider with ChangeNotifier {
  final TaskService _taskService = TaskService();

  List<TaskModel> _tasks = [];
  bool _isLoading = false;
  String? _error;

  List<TaskModel> get tasks => [..._tasks];
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> fetchTasks(String userId, String token) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _tasks = await _taskService.getTasks(userId, token);
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> addTask(String userId, String token, String title) async {
    _error = null;

    try {
      final task = TaskModel(title: title);
      final newTask = await _taskService.addTask(userId, token, task);
      _tasks.insert(0, newTask);
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }

  Future<bool> updateTask(
      String userId, String token, TaskModel updatedTask) async {
    _error = null;

    try {
      await _taskService.updateTask(userId, token, updatedTask);
      final index = _tasks.indexWhere((t) => t.id == updatedTask.id);
      if (index >= 0) {
        _tasks[index] = updatedTask;
        notifyListeners();
      }
      return true;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }

  Future<bool> toggleComplete(
      String userId, String token, TaskModel task) async {
    final updatedTask = task.copyWith(isCompleted: !task.isCompleted);
    return updateTask(userId, token, updatedTask);
  }

  Future<bool> deleteTask(
      String userId, String token, String taskId) async {
    _error = null;

    try {
      await _taskService.deleteTask(userId, token, taskId);
      _tasks.removeWhere((t) => t.id == taskId);
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }

  void clearTasks() {
    _tasks = [];
    _error = null;
    notifyListeners();
  }
}
