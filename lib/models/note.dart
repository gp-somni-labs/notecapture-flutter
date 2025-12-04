import 'package:hive/hive.dart';

part 'note.g.dart';

@HiveType(typeId: 0)
class Note {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String content;

  @HiveField(2)
  final String? summary;

  @HiveField(3)
  final String source;

  @HiveField(4)
  final String? sourceId;

  @HiveField(5)
  final String category;

  @HiveField(6)
  final List<String> topics;

  @HiveField(7)
  final List<String> keyPoints;

  @HiveField(8)
  final List<ActionItem> actionItems;

  @HiveField(9)
  final List<Entity> entities;

  @HiveField(10)
  final String? obsidianPath;

  @HiveField(11)
  final NoteStatus status;

  @HiveField(12)
  final DateTime createdAt;

  @HiveField(13)
  final DateTime? processedAt;

  @HiveField(14)
  final Map<String, dynamic>? metadata;

  Note({
    required this.id,
    required this.content,
    this.summary,
    required this.source,
    this.sourceId,
    this.category = 'conversation',
    this.topics = const [],
    this.keyPoints = const [],
    this.actionItems = const [],
    this.entities = const [],
    this.obsidianPath,
    this.status = NoteStatus.pending,
    required this.createdAt,
    this.processedAt,
    this.metadata,
  });

  factory Note.fromJson(Map<String, dynamic> json) {
    return Note(
      id: json['id'] ?? '',
      content: json['content'] ?? '',
      summary: json['summary'],
      source: json['source'] ?? 'manual',
      sourceId: json['source_id'],
      category: json['category'] ?? 'conversation',
      topics: List<String>.from(json['topics'] ?? []),
      keyPoints: List<String>.from(json['key_points'] ?? []),
      actionItems: (json['action_items'] as List<dynamic>?)
              ?.map((e) => ActionItem.fromJson(e))
              .toList() ??
          [],
      entities: (json['entities'] as List<dynamic>?)
              ?.map((e) => Entity.fromJson(e))
              .toList() ??
          [],
      obsidianPath: json['obsidian_path'],
      status: NoteStatus.values.firstWhere(
        (e) => e.name == json['status'],
        orElse: () => NoteStatus.pending,
      ),
      createdAt: DateTime.parse(json['created_at']),
      processedAt: json['processed_at'] != null
          ? DateTime.parse(json['processed_at'])
          : null,
      metadata: json['metadata'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'content': content,
      'summary': summary,
      'source': source,
      'source_id': sourceId,
      'category': category,
      'topics': topics,
      'key_points': keyPoints,
      'action_items': actionItems.map((e) => e.toJson()).toList(),
      'entities': entities.map((e) => e.toJson()).toList(),
      'obsidian_path': obsidianPath,
      'status': status.name,
      'created_at': createdAt.toIso8601String(),
      'processed_at': processedAt?.toIso8601String(),
      'metadata': metadata,
    };
  }

  Note copyWith({
    String? id,
    String? content,
    String? summary,
    String? source,
    String? sourceId,
    String? category,
    List<String>? topics,
    List<String>? keyPoints,
    List<ActionItem>? actionItems,
    List<Entity>? entities,
    String? obsidianPath,
    NoteStatus? status,
    DateTime? createdAt,
    DateTime? processedAt,
    Map<String, dynamic>? metadata,
  }) {
    return Note(
      id: id ?? this.id,
      content: content ?? this.content,
      summary: summary ?? this.summary,
      source: source ?? this.source,
      sourceId: sourceId ?? this.sourceId,
      category: category ?? this.category,
      topics: topics ?? this.topics,
      keyPoints: keyPoints ?? this.keyPoints,
      actionItems: actionItems ?? this.actionItems,
      entities: entities ?? this.entities,
      obsidianPath: obsidianPath ?? this.obsidianPath,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      processedAt: processedAt ?? this.processedAt,
      metadata: metadata ?? this.metadata,
    );
  }
}

@HiveType(typeId: 1)
enum NoteStatus {
  @HiveField(0)
  pending,
  @HiveField(1)
  processing,
  @HiveField(2)
  completed,
  @HiveField(3)
  failed,
}

@HiveType(typeId: 2)
class ActionItem {
  @HiveField(0)
  final String task;

  @HiveField(1)
  final String? assignee;

  @HiveField(2)
  final String priority;

  @HiveField(3)
  final String? dueDate;

  @HiveField(4)
  final String? context;

  @HiveField(5)
  final bool completed;

  ActionItem({
    required this.task,
    this.assignee,
    this.priority = 'medium',
    this.dueDate,
    this.context,
    this.completed = false,
  });

  factory ActionItem.fromJson(Map<String, dynamic> json) {
    return ActionItem(
      task: json['task'] ?? '',
      assignee: json['assignee'],
      priority: json['priority'] ?? 'medium',
      dueDate: json['due_date'],
      context: json['context'],
      completed: json['completed'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'task': task,
      'assignee': assignee,
      'priority': priority,
      'due_date': dueDate,
      'context': context,
      'completed': completed,
    };
  }
}

@HiveType(typeId: 3)
class Entity {
  @HiveField(0)
  final String name;

  @HiveField(1)
  final String type;

  @HiveField(2)
  final String? context;

  @HiveField(3)
  final Map<String, dynamic>? attributes;

  Entity({
    required this.name,
    required this.type,
    this.context,
    this.attributes,
  });

  factory Entity.fromJson(Map<String, dynamic> json) {
    return Entity(
      name: json['name'] ?? '',
      type: json['type'] ?? 'unknown',
      context: json['context'],
      attributes: json['attributes'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'type': type,
      'context': context,
      'attributes': attributes,
    };
  }
}
