import 'dart:async';

import 'package:flutter/material.dart';
import 'package:parse_server_sdk_flutter/parse_server_sdk_flutter.dart';

import '../../../models/task.dart';
import '../../../services/task_live_query.dart';
import '../../../services/task_service.dart';

class TaskController extends ChangeNotifier {
  TaskController({
    required this.taskService,
    required this.liveQueryService,
  });

  final TaskService taskService;
  final TaskLiveQueryService liveQueryService;

  ParseUser? _user;
  bool _isLoading = false;
  String? _errorMessage;
  List<Task> _tasks = [];

  TaskLiveSubscription? _subscription;
  StreamSubscription<TaskLiveEvent>? _streamSubscription;

  List<Task> get tasks => List.unmodifiable(_tasks);
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get hasTasks => _tasks.isNotEmpty;

  Future<void> attachUser(ParseUser? user) async {
    if (_user?.objectId == user?.objectId) {
      return;
    }
    _user = user;
    await _tearDownSubscription();
    _tasks = [];
    _errorMessage = null;
    notifyListeners();
    if (user != null) {
      await _bootstrap(user);
    }
  }

  Future<void> _bootstrap(ParseUser user) async {
    _setLoading(true);
    try {
      _tasks = await taskService.fetchTasks(user);
      await _createSubscription(user);
    } on Object catch (error) {
      _errorMessage = error.toString();
    } finally {
      _setLoading(false);
    }
  }

  Future<void> refresh() async {
    final user = _user;
    if (user == null) return;
    _setLoading(true);
    try {
      _tasks = await taskService.fetchTasks(user);
    } finally {
      _setLoading(false);
    }
  }

  Future<void> addTask(String title, String description) async {
    final user = _requireUser();
    final task = await taskService.createTask(
      owner: user,
      title: title,
      description: description,
    );
    _insertOrUpdate(task);
    notifyListeners();
  }

  Future<void> updateTask(Task task) async {
    final user = _requireUser();
    final updated = await taskService.updateTask(task: task, owner: user);
    _insertOrUpdate(updated);
    notifyListeners();
  }

  Future<void> toggleComplete(Task task) async {
    await updateTask(task.copyWith(isCompleted: !task.isCompleted));
  }

  Future<void> deleteTask(Task task) async {
    await taskService.deleteTask(task);
    _tasks.removeWhere((t) => t.id == task.id);
    notifyListeners();
  }

  Future<void> _createSubscription(ParseUser user) async {
    _subscription = await liveQueryService.subscribe(user);
    _streamSubscription = _subscription!.stream.listen(_handleLiveEvent);
  }

  void _handleLiveEvent(TaskLiveEvent event) {
    switch (event.type) {
      case TaskLiveEventType.create:
      case TaskLiveEventType.update:
        _insertOrUpdate(event.task);
        break;
      case TaskLiveEventType.delete:
        _tasks.removeWhere((t) => t.id == event.task.id);
        break;
    }
    notifyListeners();
  }

  Future<void> _tearDownSubscription() async {
    await _streamSubscription?.cancel();
    _streamSubscription = null;
    await _subscription?.dispose();
    _subscription = null;
  }

  ParseUser _requireUser() {
    final user = _user;
    if (user == null) {
      throw StateError('User must be authenticated');
    }
    return user;
  }

  void _insertOrUpdate(Task task) {
    final index = _tasks.indexWhere((element) => element.id == task.id);
    if (index >= 0) {
      _tasks[index] = task;
    } else {
      _tasks = [task, ..._tasks];
    }
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  @override
  void dispose() {
    unawaited(_tearDownSubscription());
    super.dispose();
  }
}

