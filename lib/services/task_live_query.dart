import 'dart:async';

import 'package:parse_server_sdk_flutter/parse_server_sdk_flutter.dart';

import '../models/task.dart';

enum TaskLiveEventType { create, update, delete }

class TaskLiveEvent {
  TaskLiveEvent({required this.type, required this.task});

  final TaskLiveEventType type;
  final Task task;
}

class TaskLiveSubscription {
  TaskLiveSubscription(this._controller, this._client, this._subscription);

  final StreamController<TaskLiveEvent> _controller;
  final LiveQueryClient _client;
  final Subscription<ParseObject> _subscription;

  Stream<TaskLiveEvent> get stream => _controller.stream;

  Future<void> dispose() async {
    _client.unSubscribe(_subscription);
    await _controller.close();
  }
}

class TaskLiveQueryService {
  final LiveQuery _liveQuery = LiveQuery();

  Future<TaskLiveSubscription> subscribe(ParseUser user) async {
    final client = _liveQuery.client;
    final controller = StreamController<TaskLiveEvent>.broadcast();
    final query = QueryBuilder<ParseObject>(ParseObject(Task.className))
      ..whereEqualTo(
        Task.fieldOwner,
        ParseUser.forQuery()..objectId = user.objectId,
      );

    final subscription = await client.subscribe(query);

    subscription.on(LiveQueryEvent.create, (ParseObject object) {
      controller.add(
        TaskLiveEvent(
          type: TaskLiveEventType.create,
          task: Task.fromParse(object),
        ),
      );
    });

    subscription.on(LiveQueryEvent.update, (ParseObject object) {
      controller.add(
        TaskLiveEvent(
          type: TaskLiveEventType.update,
          task: Task.fromParse(object),
        ),
      );
    });

    subscription.on(LiveQueryEvent.delete, (ParseObject object) {
      controller.add(
        TaskLiveEvent(
          type: TaskLiveEventType.delete,
          task: Task.fromParse(object),
        ),
      );
    });

    return TaskLiveSubscription(controller, client, subscription);
  }
}

