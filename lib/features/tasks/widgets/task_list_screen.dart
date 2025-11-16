import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../models/task.dart';
import '../../auth/controllers/auth_controller.dart';
import '../controllers/task_controller.dart';
import 'task_editor_sheet.dart';
import 'task_tile.dart';

class TaskListScreen extends StatelessWidget {
  const TaskListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final taskController = context.watch<TaskController>();
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Tasks'),
        actions: [
          IconButton(
            tooltip: 'Logout',
            onPressed: () => _logout(context),
            icon: const Icon(Icons.logout),
          ),
        ],
      ),
      body: _TaskBody(controller: taskController),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _createTask(context),
        icon: const Icon(Icons.add),
        label: const Text('New task'),
      ),
    );
  }

  Future<void> _createTask(BuildContext context) async {
    final controller = context.read<TaskController>();
    final messenger = ScaffoldMessenger.of(context);
    final result = await TaskEditorSheet.show(context);
    if (result == null) return;
    await controller.addTask(result.title, result.description);
    messenger
        .showSnackBar(const SnackBar(content: Text('Task created')));
  }

  Future<void> _logout(BuildContext context) async {
    final authController = context.read<AuthController>();
    final taskController = context.read<TaskController>();
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Logout?'),
        content: const Text('This will sign you out of the Task Manager.'),
        actions: [
          TextButton(onPressed: () => Navigator.of(context).pop(false), child: const Text('Cancel')),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Logout'),
          ),
        ],
      ),
    );
    if (confirmed == true) {
      await authController.logout();
      await taskController.attachUser(null);
    }
  }
}

class _TaskBody extends StatelessWidget {
  const _TaskBody({required this.controller});

  final TaskController controller;

  @override
  Widget build(BuildContext context) {
    if (controller.isLoading && !controller.hasTasks) {
      return const Center(child: CircularProgressIndicator());
    }

    return RefreshIndicator(
      onRefresh: controller.refresh,
      child: controller.hasTasks
          ? ListView.builder(
              physics: const AlwaysScrollableScrollPhysics(),
              itemCount: controller.tasks.length,
              itemBuilder: (context, index) {
                final task = controller.tasks[index];
                return TaskTile(
                  task: task,
                  onToggle: (_) => controller.toggleComplete(task),
                  onEdit: () => _editTask(context, task),
                  onDelete: () => _confirmDelete(context, task),
                );
              },
            )
          : ListView(
              physics: const AlwaysScrollableScrollPhysics(),
              children: const [
                SizedBox(height: 120),
                Icon(Icons.task_alt, size: 72, color: Colors.grey),
                Padding(
                  padding: EdgeInsets.all(24),
                  child: Text(
                    'No tasks yet.\nTap “New task” to add your first item.',
                    textAlign: TextAlign.center,
                  ),
                ),
              ],
            ),
    );
  }

  Future<void> _editTask(BuildContext context, Task task) async {
    final controller = context.read<TaskController>();
    final messenger = ScaffoldMessenger.of(context);
    final result = await TaskEditorSheet.show(context, task: task);
    if (result == null) return;
    await controller.updateTask(
      task.copyWith(
        title: result.title,
        description: result.description,
        isCompleted: result.isCompleted,
      ),
    );
    messenger
        .showSnackBar(const SnackBar(content: Text('Task updated')));
  }

  Future<void> _confirmDelete(BuildContext context, Task task) async {
    final controller = context.read<TaskController>();
    final messenger = ScaffoldMessenger.of(context);
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete task?'),
        content: Text('This will permanently delete "${task.title}".'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: FilledButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.error,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await controller.deleteTask(task);
      messenger
          .showSnackBar(const SnackBar(content: Text('Task deleted')));
    }
  }
}

