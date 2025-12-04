import 'package:flutter/foundation.dart';
import '../models/integration.dart';
import '../services/api_service.dart';

class IntegrationsProvider extends ChangeNotifier {
  final ApiService _api = ApiService();

  List<Integration> _integrations = [];
  bool _isLoading = false;
  String? _error;

  // Getters
  List<Integration> get integrations => _integrations;
  bool get isLoading => _isLoading;
  String? get error => _error;

  int get connectedCount => _integrations.where((i) => i.isConnected).length;
  int get totalCount => _integrations.length;

  List<Integration> getByCategory(String category) {
    return _integrations.where((i) => i.category == category).toList();
  }

  IntegrationsProvider() {
    _initializeIntegrations();
  }

  void _initializeIntegrations() {
    // Define all integrations with their metadata
    _integrations = [
      // Capture Sources
      Integration(
        name: 'Omi',
        key: 'omi_client',
        icon: 'brain',
        description: 'Voice pendant capture',
        category: 'capture',
      ),
      Integration(
        name: 'Limitless',
        key: 'limitless_client',
        icon: 'infinity',
        description: 'AI pendant capture',
        category: 'capture',
      ),
      // CRM & Business
      Integration(
        name: 'Monica CRM',
        key: 'monica',
        icon: 'users',
        description: 'Contact management',
        category: 'crm',
      ),
      Integration(
        name: 'SomniProperty',
        key: 'somniproperty',
        icon: 'building',
        description: 'Lead tracking',
        category: 'crm',
      ),
      // Task Management
      Integration(
        name: 'Vikunja',
        key: 'vikunja',
        icon: 'list-check',
        description: 'Task management',
        category: 'tasks',
      ),
      Integration(
        name: 'Donetick',
        key: 'donetick',
        icon: 'checkbox',
        description: 'Chore tracker',
        category: 'tasks',
      ),
      Integration(
        name: 'Apple Reminders',
        key: 'apple_reminders',
        icon: 'checklist',
        description: 'Task sync',
        category: 'tasks',
      ),
      // Scheduling
      Integration(
        name: 'Cal.com',
        key: 'calcom',
        icon: 'calendar-event',
        description: 'Scheduling',
        category: 'scheduling',
      ),
      // Storage
      Integration(
        name: 'Obsidian',
        key: 'obsidian',
        icon: 'notes',
        description: 'Note storage',
        category: 'storage',
        isConnected: true, // Obsidian is always connected
      ),
    ];
  }

  Future<void> loadIntegrationStatus() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final status = await _api.getIntegrationStatus();

      _integrations = _integrations.map((integration) {
        final isConnected = status[integration.key] ??
            (integration.key == 'obsidian' ? true : false);
        return integration.copyWith(isConnected: isConnected);
      }).toList();
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> refresh() async {
    await loadIntegrationStatus();
  }
}
