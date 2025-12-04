import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/api_service.dart';
import '../models/integration.dart';

class AppStateProvider extends ChangeNotifier {
  final ApiService _api = ApiService();

  // Connection state
  bool _isConnected = false;
  bool _isConnecting = false;
  String? _connectionError;

  // System stats
  SystemStats _stats = SystemStats();
  Duration _uptime = Duration.zero;
  Timer? _uptimeTimer;

  // Settings
  String _serverUrl = ApiService.defaultBaseUrl;
  bool _darkMode = true;
  bool _notificationsEnabled = true;

  // Getters
  bool get isConnected => _isConnected;
  bool get isConnecting => _isConnecting;
  String? get connectionError => _connectionError;
  SystemStats get stats => _stats;
  Duration get uptime => _uptime;
  String get serverUrl => _serverUrl;
  bool get darkMode => _darkMode;
  bool get notificationsEnabled => _notificationsEnabled;
  ApiService get api => _api;

  AppStateProvider() {
    _loadSettings();
    _startUptimeTimer();
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    _serverUrl = prefs.getString('server_url') ?? ApiService.defaultBaseUrl;
    _darkMode = prefs.getBool('dark_mode') ?? true;
    _notificationsEnabled = prefs.getBool('notifications_enabled') ?? true;

    _api.setBaseUrl(_serverUrl);
    notifyListeners();

    // Auto-connect
    await connect();
  }

  void _startUptimeTimer() {
    _uptimeTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (_isConnected) {
        _uptime = _stats.uptime + Duration(seconds: 1);
        notifyListeners();
      }
    });
  }

  // ============================================================================
  // CONNECTION
  // ============================================================================

  Future<void> connect() async {
    if (_isConnecting) return;

    _isConnecting = true;
    _connectionError = null;
    notifyListeners();

    try {
      _stats = await _api.getHealth();
      _uptime = _stats.uptime;
      _isConnected = _stats.status == 'healthy';
      _connectionError = _isConnected ? null : 'Server unhealthy';
    } catch (e) {
      _isConnected = false;
      _connectionError = e.toString();
    } finally {
      _isConnecting = false;
      notifyListeners();
    }
  }

  Future<void> refreshStats() async {
    if (!_isConnected) return;

    try {
      final statsData = await _api.getStats();
      _stats = SystemStats(
        notesProcessed: statsData['notes_processed'] ?? _stats.notesProcessed,
        activeTasks: statsData['active_tasks'] ?? _stats.activeTasks,
        websocketConnections:
            statsData['websocket_connections'] ?? _stats.websocketConnections,
        uptime: _stats.uptime,
        status: _stats.status,
        integrations: _stats.integrations,
        services: _stats.services,
      );
      notifyListeners();
    } catch (e) {
      debugPrint('Failed to refresh stats: $e');
    }
  }

  // ============================================================================
  // SETTINGS
  // ============================================================================

  Future<void> setServerUrl(String url) async {
    _serverUrl = url;
    _api.setBaseUrl(url);

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('server_url', url);

    notifyListeners();
    await connect();
  }

  Future<void> setDarkMode(bool value) async {
    _darkMode = value;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('dark_mode', value);
    notifyListeners();
  }

  Future<void> setNotificationsEnabled(bool value) async {
    _notificationsEnabled = value;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('notifications_enabled', value);
    notifyListeners();
  }

  @override
  void dispose() {
    _uptimeTimer?.cancel();
    super.dispose();
  }
}
