class Note {
  final String id;
  final String content;
  final String? summary;
  final String source;
  final String? sourceId;
  final String category;
  final List<String> topics;
  final List<String> keyPoints;
  final List<ActionItem> actionItems;
  final List<Entity> entities;
  final String? obsidianPath;
  final NoteStatus status;
  final DateTime createdAt;
  final DateTime? processedAt;
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

enum NoteStatus {
  pending,
  processing,
  completed,
  failed,
}

class ActionItem {
  final String task;
  final String? assignee;
  final String priority;
  final String? dueDate;
  final String? context;
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

class Entity {
  final String name;
  final String type;
  final String? context;
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
