class Integration {
  final String name;
  final String key;
  final String icon;
  final String description;
  final String category;
  final bool isConnected;
  final Map<String, dynamic>? config;

  Integration({
    required this.name,
    required this.key,
    required this.icon,
    required this.description,
    required this.category,
    this.isConnected = false,
    this.config,
  });

  factory Integration.fromJson(Map<String, dynamic> json) {
    return Integration(
      name: json['name'] ?? '',
      key: json['key'] ?? '',
      icon: json['icon'] ?? 'integration',
      description: json['description'] ?? '',
      category: json['category'] ?? 'other',
      isConnected: json['is_connected'] ?? false,
      config: json['config'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'key': key,
      'icon': icon,
      'description': description,
      'category': category,
      'is_connected': isConnected,
      'config': config,
    };
  }

  Integration copyWith({
    String? name,
    String? key,
    String? icon,
    String? description,
    String? category,
    bool? isConnected,
    Map<String, dynamic>? config,
  }) {
    return Integration(
      name: name ?? this.name,
      key: key ?? this.key,
      icon: icon ?? this.icon,
      description: description ?? this.description,
      category: category ?? this.category,
      isConnected: isConnected ?? this.isConnected,
      config: config ?? this.config,
    );
  }
}

class SystemStats {
  final int notesProcessed;
  final int activeTasks;
  final int websocketConnections;
  final Duration uptime;
  final String status;
  final Map<String, bool> integrations;
  final Map<String, bool> services;

  SystemStats({
    this.notesProcessed = 0,
    this.activeTasks = 0,
    this.websocketConnections = 0,
    this.uptime = Duration.zero,
    this.status = 'unknown',
    this.integrations = const {},
    this.services = const {},
  });

  factory SystemStats.fromJson(Map<String, dynamic> json) {
    return SystemStats(
      notesProcessed: json['notes_processed'] ?? 0,
      activeTasks: json['active_tasks'] ?? 0,
      websocketConnections: json['websocket_connections'] ?? 0,
      uptime: Duration(seconds: json['uptime_seconds'] ?? 0),
      status: json['status'] ?? 'unknown',
      integrations: Map<String, bool>.from(json['integrations'] ?? {}),
      services: Map<String, bool>.from(json['services'] ?? {}),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'notes_processed': notesProcessed,
      'active_tasks': activeTasks,
      'websocket_connections': websocketConnections,
      'uptime_seconds': uptime.inSeconds,
      'status': status,
      'integrations': integrations,
      'services': services,
    };
  }
}

class SyncResult {
  final String source;
  final int count;
  final bool success;
  final String? error;
  final List<String> noteIds;

  SyncResult({
    required this.source,
    this.count = 0,
    this.success = false,
    this.error,
    this.noteIds = const [],
  });

  factory SyncResult.fromJson(Map<String, dynamic> json) {
    return SyncResult(
      source: json['source'] ?? '',
      count: json['count'] ?? 0,
      success: json['success'] ?? false,
      error: json['error'],
      noteIds: List<String>.from(json['note_ids'] ?? []),
    );
  }
}
