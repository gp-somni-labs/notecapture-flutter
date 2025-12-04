import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import '../models/note.dart';
import '../models/integration.dart';

class ApiService {
  static const String defaultBaseUrl = 'https://notecapture.home.lan';

  late final Dio _dio;
  WebSocketChannel? _wsChannel;
  String _baseUrl;

  ApiService({String? baseUrl}) : _baseUrl = baseUrl ?? defaultBaseUrl {
    _dio = Dio(BaseOptions(
      baseUrl: _baseUrl,
      connectTimeout: const Duration(seconds: 30),
      receiveTimeout: const Duration(seconds: 30),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
    ));

    // Add interceptors for logging and error handling
    _dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) {
        print('API Request: ${options.method} ${options.path}');
        return handler.next(options);
      },
      onResponse: (response, handler) {
        print('API Response: ${response.statusCode}');
        return handler.next(response);
      },
      onError: (error, handler) {
        print('API Error: ${error.message}');
        return handler.next(error);
      },
    ));
  }

  void setBaseUrl(String url) {
    _baseUrl = url;
    _dio.options.baseUrl = url;
  }

  String get baseUrl => _baseUrl;

  // ============================================================================
  // HEALTH & STATUS
  // ============================================================================

  Future<SystemStats> getHealth() async {
    try {
      final response = await _dio.get('/health');
      return SystemStats.fromJson(response.data);
    } catch (e) {
      throw ApiException('Failed to get health status: $e');
    }
  }

  Future<Map<String, dynamic>> getStats() async {
    try {
      final response = await _dio.get('/api/stats');
      return response.data;
    } catch (e) {
      throw ApiException('Failed to get stats: $e');
    }
  }

  Future<Map<String, dynamic>> getProviders() async {
    try {
      final response = await _dio.get('/api/stats/providers');
      return response.data;
    } catch (e) {
      throw ApiException('Failed to get providers: $e');
    }
  }

  // ============================================================================
  // NOTES
  // ============================================================================

  Future<Note> captureNote({
    required String content,
    String? project,
    List<String> tags = const [],
    String? aiProvider,
  }) async {
    try {
      final response = await _dio.post('/capture', data: {
        'content': content,
        'project': project,
        'tags': tags,
        'ai_provider': aiProvider,
      });
      return Note.fromJson(response.data);
    } catch (e) {
      throw ApiException('Failed to capture note: $e');
    }
  }

  Future<List<Note>> getNotes({int limit = 50, int skip = 0}) async {
    try {
      final response = await _dio.get('/api/notes', queryParameters: {
        'limit': limit,
        'skip': skip,
      });
      final List<dynamic> data = response.data['items'] ?? response.data;
      return data.map((e) => Note.fromJson(e)).toList();
    } catch (e) {
      throw ApiException('Failed to get notes: $e');
    }
  }

  Future<Note> getNote(String id) async {
    try {
      final response = await _dio.get('/api/notes/$id');
      return Note.fromJson(response.data);
    } catch (e) {
      throw ApiException('Failed to get note: $e');
    }
  }

  // ============================================================================
  // SYNC
  // ============================================================================

  Future<Map<String, SyncResult>> syncNotes({
    String? source,
    int limit = 20,
  }) async {
    try {
      final queryParams = <String, dynamic>{'limit': limit};
      if (source != null) queryParams['source'] = source;

      final response = await _dio.post('/sync', queryParameters: queryParams);
      final results = <String, SyncResult>{};

      if (response.data['results'] != null) {
        final resultsData = response.data['results'] as Map<String, dynamic>;
        resultsData.forEach((key, value) {
          results[key] = SyncResult.fromJson(value);
        });
      }

      return results;
    } catch (e) {
      throw ApiException('Failed to sync notes: $e');
    }
  }

  // ============================================================================
  // DEDUPLICATION
  // ============================================================================

  Future<Map<String, dynamic>> getDedupStats() async {
    try {
      final response = await _dio.get('/api/deduplication/stats');
      return response.data;
    } catch (e) {
      throw ApiException('Failed to get dedup stats: $e');
    }
  }

  Future<void> clearDedup({String? source}) async {
    try {
      final queryParams = source != null ? {'source': source} : null;
      await _dio.post('/api/deduplication/clear', queryParameters: queryParams);
    } catch (e) {
      throw ApiException('Failed to clear dedup: $e');
    }
  }

  // ============================================================================
  // AI TESTING
  // ============================================================================

  Future<String> testAI({
    required String text,
    required String provider,
    String? systemPrompt,
  }) async {
    try {
      final response = await _dio.post('/api/test-ai', data: {
        'text': text,
        'provider': provider,
        'system_prompt': systemPrompt,
      });
      return response.data['result'] ?? '';
    } catch (e) {
      throw ApiException('Failed to test AI: $e');
    }
  }

  // ============================================================================
  // WEBSOCKET
  // ============================================================================

  WebSocketChannel connectWebSocket() {
    final wsUrl = _baseUrl.replaceFirst('http', 'ws');
    _wsChannel = WebSocketChannel.connect(Uri.parse('$wsUrl/ws'));
    return _wsChannel!;
  }

  void disconnectWebSocket() {
    _wsChannel?.sink.close();
    _wsChannel = null;
  }

  Stream<dynamic>? get websocketStream => _wsChannel?.stream;

  // ============================================================================
  // INTEGRATIONS
  // ============================================================================

  Future<Map<String, bool>> getIntegrationStatus() async {
    try {
      final health = await getHealth();
      return {...health.integrations, ...health.services};
    } catch (e) {
      throw ApiException('Failed to get integration status: $e');
    }
  }
}

class ApiException implements Exception {
  final String message;
  ApiException(this.message);

  @override
  String toString() => message;
}
