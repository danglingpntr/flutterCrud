import 'package:parse_server_sdk_flutter/parse_server_sdk_flutter.dart';

class Task {
  Task({
    required this.id,
    required this.title,
    required this.description,
    required this.isCompleted,
    required this.ownerId,
    DateTime? createdAt,
    DateTime? updatedAt,
  })  : createdAt = createdAt ?? DateTime.now(),
        updatedAt = updatedAt ?? DateTime.now();

  static const className = 'Task';
  static const fieldTitle = 'title';
  static const fieldDescription = 'description';
  static const fieldCompleted = 'isCompleted';
  static const fieldOwner = 'owner';

  final String id;
  final String title;
  final String description;
  final bool isCompleted;
  final String ownerId;
  final DateTime createdAt;
  final DateTime updatedAt;

  Task copyWith({
    String? id,
    String? title,
    String? description,
    bool? isCompleted,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Task(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      isCompleted: isCompleted ?? this.isCompleted,
      ownerId: ownerId,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  static Task fromParse(ParseObject object) {
    final owner = object.get<ParseUser>(fieldOwner);
    return Task(
      id: object.objectId ?? '',
      title: object.get<String>(fieldTitle) ?? '',
      description: object.get<String>(fieldDescription) ?? '',
      isCompleted: object.get<bool>(fieldCompleted) ?? false,
      ownerId: owner?.objectId ?? '',
      createdAt: object.createdAt ?? DateTime.now(),
      updatedAt: object.updatedAt ?? DateTime.now(),
    );
  }

  ParseObject toParse(ParseUser owner) {
    final parseObject = ParseObject(className)
      ..objectId = id.isEmpty ? null : id
      ..set<String>(fieldTitle, title)
      ..set<String>(fieldDescription, description)
      ..set<bool>(fieldCompleted, isCompleted)
      ..set<ParseUser>(fieldOwner, _ownerPointer(owner));
    return parseObject;
  }
}

ParseUser _ownerPointer(ParseUser user) {
  return ParseUser.forQuery()..objectId = user.objectId;
}

