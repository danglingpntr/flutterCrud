import 'package:flutter/material.dart';

import '../../../models/task.dart';

class TaskFormResult {
  const TaskFormResult({
    required this.title,
    required this.description,
    required this.isCompleted,
  });

  final String title;
  final String description;
  final bool isCompleted;
}

class TaskEditorSheet extends StatefulWidget {
  const TaskEditorSheet({super.key, this.initialTask});

  final Task? initialTask;

  static Future<TaskFormResult?> show(
    BuildContext context, {
    Task? task,
  }) {
    return showModalBottomSheet<TaskFormResult>(
      context: context,
      isScrollControlled: true,
      builder: (context) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        child: TaskEditorSheet(initialTask: task),
      ),
    );
  }

  @override
  State<TaskEditorSheet> createState() => _TaskEditorSheetState();
}

class _TaskEditorSheetState extends State<TaskEditorSheet> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _titleController;
  late final TextEditingController _descriptionController;
  late bool _isCompleted;

  @override
  void initState() {
    super.initState();
    _titleController =
        TextEditingController(text: widget.initialTask?.title ?? '');
    _descriptionController =
        TextEditingController(text: widget.initialTask?.description ?? '');
    _isCompleted = widget.initialTask?.isCompleted ?? false;
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.initialTask != null;
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 48,
              height: 4,
              margin: const EdgeInsets.only(bottom: 24),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.outlineVariant,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            Text(
              isEditing ? 'Edit Task' : 'New Task',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _titleController,
              decoration: const InputDecoration(
                labelText: 'Title',
                prefixIcon: Icon(Icons.title),
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Title is required';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _descriptionController,
              decoration: const InputDecoration(
                labelText: 'Description',
                prefixIcon: Icon(Icons.notes),
              ),
              maxLines: 4,
            ),
            const SizedBox(height: 8),
            CheckboxListTile(
              value: _isCompleted,
              onChanged: (value) {
                setState(() => _isCompleted = value ?? false);
              },
              title: const Text('Mark as completed'),
            ),
            const SizedBox(height: 24),
            FilledButton(
              onPressed: _submit,
              child: Text(isEditing ? 'Save changes' : 'Create task'),
            ),
            const SizedBox(height: 12),
          ],
        ),
      ),
    );
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;
    Navigator.of(context).pop(
      TaskFormResult(
        title: _titleController.text.trim(),
        description: _descriptionController.text.trim(),
        isCompleted: _isCompleted,
      ),
    );
  }
}

