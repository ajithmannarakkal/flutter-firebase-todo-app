import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../providers/task_provider.dart';
import '../widgets/task_tile.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
    _fetchTasks();
  }

  Future<void> _fetchTasks() async {
    final auth = context.read<AuthProvider>();
    if (!auth.isAuth) return;
    await context.read<TaskProvider>().fetchTasks(auth.userId!, auth.token!);
    // print('tasks loaded');
  }

  void _logout() async {
    context.read<TaskProvider>().clearTasks();
    await context.read<AuthProvider>().logout();
    if (!mounted) return;
    Navigator.of(context).pushReplacementNamed('/login');
  }

  void _confirmDelete(TaskProvider taskProv, String taskId) {
    final auth = context.read<AuthProvider>();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Task'),
        content: const Text('Are you sure you want to delete this task?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              taskProv.deleteTask(auth.userId!, auth.token!, taskId);
              Navigator.pop(ctx);
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.read<AuthProvider>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Tasks'),
        centerTitle: true,
        backgroundColor: Colors.deepPurple,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: _logout,
          ),
        ],
      ),
      body: Consumer<TaskProvider>(
        builder: (ctx, taskProv, _) {
          if (taskProv.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (taskProv.error != null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(taskProv.error!,
                      style: const TextStyle(color: Colors.red)),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: _fetchTasks,
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }

          if (taskProv.tasks.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.task_alt, size: 64, color: Colors.grey[400]),
                  const SizedBox(height: 16),
                  Text(
                    'No tasks yet!\nTap + to add a new task.',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                  ),
                ],
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: _fetchTasks,
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
              itemCount: taskProv.tasks.length,
              itemBuilder: (ctx, i) {
                final task = taskProv.tasks[i];
                return TaskTile(
                  task: task,
                  onToggle: () => taskProv.toggleComplete(
                      auth.userId!, auth.token!, task),
                  onEdit: () => Navigator.pushNamed(
                      context, '/add-edit-task',
                      arguments: task),
                  onDelete: () => _confirmDelete(taskProv, task.id!),
                );
              },
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.deepPurple,
        foregroundColor: Colors.white,
        onPressed: () => Navigator.pushNamed(context, '/add-edit-task'),
        child: const Icon(Icons.add),
      ),
    );
  }
}
