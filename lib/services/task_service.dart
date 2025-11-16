import 'package:parse_server_sdk_flutter/parse_server_sdk_flutter.dart';

import '../models/task.dart';

class TaskService {
  Future<List<Task>> fetchTasks(ParseUser user) async {
    final query = QueryBuilder<ParseObject>(ParseObject(Task.className))
      ..whereEqualTo(Task.fieldOwner, _ownerPointer(user))
      ..orderByDescending('createdAt');
    final response = await query.query();
    _validate(response);
    final results = response.results ?? [];
    return results.whereType<ParseObject>().map(Task.fromParse).toList();
  }

  Future<Task> createTask({
    required ParseUser owner,
    required String title,
    required String description,
  }) async {
    final object = ParseObject(Task.className)
      ..set<String>(Task.fieldTitle, title.trim())
      ..set<String>(Task.fieldDescription, description.trim())
      ..set<bool>(Task.fieldCompleted, false)
      ..set<ParseUser>(Task.fieldOwner, _ownerPointer(owner));
    final response = await object.save();
    _validate(response);
    return Task.fromParse(response.result as ParseObject);
  }

  Future<Task> updateTask({
    required Task task,
    required ParseUser owner,
  }) async {
    final object = task.toParse(owner);
    final response = await object.save();
    _validate(response);
    return Task.fromParse(response.result as ParseObject);
  }

  Future<void> deleteTask(Task task) async {
    final object = ParseObject(Task.className)..objectId = task.id;
    final response = await object.delete();
    _validate(response);
  }

  void _validate(ParseResponse response) {
    if (!response.success) {
      throw StateError(response.error?.message ?? 'Unknown Parse error');
    }
  }

  ParseUser _ownerPointer(ParseUser user) {
    return ParseUser.forQuery()..objectId = user.objectId;
  }
}

