import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/task_model.dart';

class TaskService {
  static const _dbUrl =
      'https://fir-todo-app-adb17-default-rtdb.firebaseio.com';

  Future<List<TaskModel>> getTasks(String userId, String token) async {
    final url = '$_dbUrl/tasks/$userId.json?auth=$token';
    final res = await http.get(Uri.parse(url));

    if (res.statusCode != 200) {
      print('fetch error: ${res.statusCode}');
      throw 'Failed to load tasks';
    }

    final data = json.decode(res.body) as Map<String, dynamic>?;
    if (data == null) return [];

    final tasks = data.entries
        .map((e) => TaskModel.fromJson(e.key, e.value))
        .toList();
    tasks.sort((a, b) => b.createdAt.compareTo(a.createdAt));

    return tasks;
  }

  Future<TaskModel> addTask(
      String userId, String token, TaskModel task) async {
    final url = '$_dbUrl/tasks/$userId.json?auth=$token';
    final res = await http.post(
      Uri.parse(url),
      body: json.encode(task.toJson()),
    );

    if (res.statusCode != 200) {
      throw 'Failed to add task';
    }

    final data = json.decode(res.body);
    return task.copyWith(id: data['name']);
  }

  Future<void> updateTask(
      String userId, String token, TaskModel task) async {
    final url = '$_dbUrl/tasks/$userId/${task.id}.json?auth=$token';
    final res = await http.patch(
      Uri.parse(url),
      body: json.encode(task.toJson()),
    );

    if (res.statusCode != 200) {
      throw 'Failed to update task';
    }
  }

  Future<void> deleteTask(
      String userId, String token, String taskId) async {
    final url = '$_dbUrl/tasks/$userId/$taskId.json?auth=$token';
    final res = await http.delete(Uri.parse(url));

    if (res.statusCode != 200) {
      throw 'Failed to delete task';
    }
  }
}
