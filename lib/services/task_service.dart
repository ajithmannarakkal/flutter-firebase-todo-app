import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/task_model.dart';

class TaskService {
  // Replace with your Firebase Realtime Database URL
  static const String _baseUrl =
      'https://fir-todo-app-adb17-default-rtdb.firebaseio.com';

  Future<List<TaskModel>> getTasks(String userId, String token) async {
    final url = '$_baseUrl/tasks/$userId.json?auth=$token';
    final response = await http.get(Uri.parse(url));

    if (response.statusCode != 200) {
      throw 'Failed to fetch tasks.';
    }

    final data = json.decode(response.body) as Map<String, dynamic>?;

    if (data == null) return [];

    final List<TaskModel> tasks = [];
    data.forEach((key, value) {
      tasks.add(TaskModel.fromJson(key, value));
    });

    tasks.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return tasks;
  }

  Future<TaskModel> addTask(
      String userId, String token, TaskModel task) async {
    final url = '$_baseUrl/tasks/$userId.json?auth=$token';
    final response = await http.post(
      Uri.parse(url),
      body: json.encode(task.toJson()),
    );

    if (response.statusCode != 200) {
      throw 'Failed to add task.';
    }

    final data = json.decode(response.body);
    return task.copyWith(id: data['name']);
  }

  Future<void> updateTask(
      String userId, String token, TaskModel task) async {
    final url = '$_baseUrl/tasks/$userId/${task.id}.json?auth=$token';
    final response = await http.patch(
      Uri.parse(url),
      body: json.encode(task.toJson()),
    );

    if (response.statusCode != 200) {
      throw 'Failed to update task.';
    }
  }

  Future<void> deleteTask(
      String userId, String token, String taskId) async {
    final url = '$_baseUrl/tasks/$userId/$taskId.json?auth=$token';
    final response = await http.delete(Uri.parse(url));

    if (response.statusCode != 200) {
      throw 'Failed to delete task.';
    }
  }
}
