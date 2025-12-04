import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:iconsax/iconsax.dart';

import '../providers/app_state_provider.dart';
import '../utils/theme.dart';
import '../widgets/glass_card.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final _serverUrlController = TextEditingController();
  bool _isEditing = false;

  // Integration API Key Controllers
  final Map<String, TextEditingController> _apiKeyControllers = {};
  final Map<String, bool> _apiKeyVisible = {};
  final Map<String, bool> _apiKeyEditing = {};

  // Integration definitions
  static const List<Map<String, dynamic>> _integrations = [
    {
      'id': 'omi',
      'name': 'Omi Voice Pendant',
      'category': 'Capture Sources',
      'icon': Iconsax.microphone,
      'fields': [
        {'key': 'omi_api_key', 'label': 'API Key'},
        {'key': 'omi_user_id', 'label': 'User ID'},
      ],
    },
    {
      'id': 'limitless',
      'name': 'Limitless AI Pendant',
      'category': 'Capture Sources',
      'icon': Iconsax.cpu,
      'fields': [
        {'key': 'limitless_api_key', 'label': 'API Key'},
      ],
    },
    {
      'id': 'monica',
      'name': 'Monica CRM',
      'category': 'CRM & Business',
      'icon': Iconsax.people,
      'fields': [
        {'key': 'monica_api_token', 'label': 'API Token'},
        {'key': 'monica_base_url', 'label': 'Base URL (optional)'},
      ],
    },
    {
      'id': 'somniproperty',
      'name': 'SomniProperty',
      'category': 'CRM & Business',
      'icon': Iconsax.building,
      'fields': [
        {'key': 'somniproperty_api_key', 'label': 'API Key'},
        {'key': 'somniproperty_base_url', 'label': 'Base URL'},
      ],
    },
    {
      'id': 'vikunja',
      'name': 'Vikunja',
      'category': 'Task Management',
      'icon': Iconsax.task_square,
      'fields': [
        {'key': 'vikunja_api_token', 'label': 'API Token'},
        {'key': 'vikunja_base_url', 'label': 'Base URL'},
      ],
    },
    {
      'id': 'donetick',
      'name': 'Donetick',
      'category': 'Task Management',
      'icon': Iconsax.tick_circle,
      'fields': [
        {'key': 'donetick_api_key', 'label': 'API Key'},
        {'key': 'donetick_base_url', 'label': 'Base URL'},
      ],
    },
    {
      'id': 'apple_reminders',
      'name': 'Apple Reminders',
      'category': 'Task Management',
      'icon': Iconsax.notification_bing,
      'fields': [
        {'key': 'apple_reminders_list', 'label': 'Default List Name'},
      ],
    },
    {
      'id': 'calcom',
      'name': 'Cal.com',
      'category': 'Scheduling',
      'icon': Iconsax.calendar,
      'fields': [
        {'key': 'calcom_api_key', 'label': 'API Key'},
        {'key': 'calcom_base_url', 'label': 'Base URL (optional)'},
      ],
    },
    {
      'id': 'obsidian',
      'name': 'Obsidian',
      'category': 'Storage',
      'icon': Iconsax.document,
      'fields': [
        {'key': 'obsidian_vault_path', 'label': 'Vault Path'},
        {'key': 'obsidian_notes_folder', 'label': 'Notes Folder'},
      ],
    },
  ];

  @override
  void initState() {
    super.initState();
    final appState = context.read<AppStateProvider>();
    _serverUrlController.text = appState.serverUrl;

    // Initialize controllers for each integration field
    for (var integration in _integrations) {
      for (var field in integration['fields'] as List<Map<String, dynamic>>) {
        final key = field['key'] as String;
        _apiKeyControllers[key] = TextEditingController();
        _apiKeyVisible[key] = false;
        _apiKeyEditing[key] = false;
      }
    }

    // Load saved API keys
    _loadApiKeys();
  }

  Future<void> _loadApiKeys() async {
    final appState = context.read<AppStateProvider>();
    for (var key in _apiKeyControllers.keys) {
      final value = await appState.getApiKey(key);
      if (value != null) {
        _apiKeyControllers[key]!.text = value;
      }
    }
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    _serverUrlController.dispose();
    for (var controller in _apiKeyControllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Consumer<AppStateProvider>(
        builder: (_, appState, __) {
          return CustomScrollView(
            slivers: [
              const SliverAppBar(
                floating: true,
                backgroundColor: Colors.transparent,
                title: Text('Settings'),
              ),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Connection Section
                      Text(
                        'Connection',
                        style: Theme.of(context).textTheme.headlineSmall,
                      ),
                      const SizedBox(height: 12),
                      _buildConnectionCard(appState),
                      const SizedBox(height: 24),

                      // Integration API Keys Section
                      Text(
                        'Integration API Keys',
                        style: Theme.of(context).textTheme.headlineSmall,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Configure credentials for each integration',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                      const SizedBox(height: 12),
                      ..._buildIntegrationCards(appState),
                      const SizedBox(height: 24),

                      // Preferences Section
                      Text(
                        'Preferences',
                        style: Theme.of(context).textTheme.headlineSmall,
                      ),
                      const SizedBox(height: 12),
                      _buildPreferencesCard(appState),
                      const SizedBox(height: 24),

                      // System Info Section
                      Text(
                        'System Info',
                        style: Theme.of(context).textTheme.headlineSmall,
                      ),
                      const SizedBox(height: 12),
                      _buildSystemInfoCard(appState),
                      const SizedBox(height: 24),

                      // About Section
                      Text(
                        'About',
                        style: Theme.of(context).textTheme.headlineSmall,
                      ),
                      const SizedBox(height: 12),
                      _buildAboutCard(),
                      const SizedBox(height: 100),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildConnectionCard(AppStateProvider appState) {
    return GlassCard(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Iconsax.global, size: 20),
                const SizedBox(width: 12),
                Text(
                  'Server URL',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _serverUrlController,
                    enabled: _isEditing,
                    decoration: InputDecoration(
                      hintText: 'https://notecapture.home.lan',
                      isDense: true,
                      filled: _isEditing,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                IconButton(
                  icon: Icon(_isEditing ? Iconsax.tick_circle : Iconsax.edit),
                  onPressed: () async {
                    if (_isEditing) {
                      await appState.setServerUrl(_serverUrlController.text);
                      setState(() => _isEditing = false);
                      if (mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Server URL updated')),
                        );
                      }
                    } else {
                      setState(() => _isEditing = true);
                    }
                  },
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Container(
                  width: 10,
                  height: 10,
                  decoration: BoxDecoration(
                    color: appState.isConnected
                        ? AppTheme.success
                        : AppTheme.danger,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  appState.isConnected
                      ? 'Connected'
                      : (appState.connectionError ?? 'Not connected'),
                  style: TextStyle(
                    fontSize: 12,
                    color:
                        appState.isConnected ? AppTheme.success : AppTheme.danger,
                  ),
                ),
                const Spacer(),
                TextButton(
                  onPressed: appState.isConnecting ? null : appState.connect,
                  child: appState.isConnecting
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Text('Test'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  List<Widget> _buildIntegrationCards(AppStateProvider appState) {
    // Group integrations by category
    final Map<String, List<Map<String, dynamic>>> grouped = {};
    for (var integration in _integrations) {
      final category = integration['category'] as String;
      grouped.putIfAbsent(category, () => []);
      grouped[category]!.add(integration);
    }

    final widgets = <Widget>[];
    for (var entry in grouped.entries) {
      widgets.add(
        Padding(
          padding: const EdgeInsets.only(top: 16, bottom: 8),
          child: Text(
            entry.key,
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  color: AppTheme.primaryCyan,
                ),
          ),
        ),
      );

      for (var integration in entry.value) {
        widgets.add(_buildIntegrationCard(integration, appState));
        widgets.add(const SizedBox(height: 8));
      }
    }
    return widgets;
  }

  Widget _buildIntegrationCard(
      Map<String, dynamic> integration, AppStateProvider appState) {
    final fields = integration['fields'] as List<Map<String, dynamic>>;
    final icon = integration['icon'] as IconData;
    final name = integration['name'] as String;

    return GlassCard(
      child: ExpansionTile(
        leading: Icon(icon, color: AppTheme.primaryCyan),
        title: Text(name),
        subtitle: Text(
          _getIntegrationStatus(fields),
          style: TextStyle(
            fontSize: 12,
            color: _hasAnyApiKey(fields) ? AppTheme.success : AppTheme.textMuted,
          ),
        ),
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: Column(
              children: fields.map((field) {
                final key = field['key'] as String;
                final label = field['label'] as String;
                final isPassword =
                    key.contains('key') || key.contains('token');

                return Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _apiKeyControllers[key],
                          enabled: _apiKeyEditing[key] ?? false,
                          obscureText:
                              isPassword && !(_apiKeyVisible[key] ?? false),
                          decoration: InputDecoration(
                            labelText: label,
                            isDense: true,
                            filled: _apiKeyEditing[key] ?? false,
                            suffixIcon: isPassword
                                ? IconButton(
                                    icon: Icon(
                                      _apiKeyVisible[key] ?? false
                                          ? Iconsax.eye
                                          : Iconsax.eye_slash,
                                      size: 18,
                                    ),
                                    onPressed: () {
                                      setState(() {
                                        _apiKeyVisible[key] =
                                            !(_apiKeyVisible[key] ?? false);
                                      });
                                    },
                                  )
                                : null,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      IconButton(
                        icon: Icon(
                          _apiKeyEditing[key] ?? false
                              ? Iconsax.tick_circle
                              : Iconsax.edit,
                          size: 20,
                        ),
                        onPressed: () async {
                          if (_apiKeyEditing[key] ?? false) {
                            await appState.setApiKey(
                                key, _apiKeyControllers[key]!.text);
                            setState(() => _apiKeyEditing[key] = false);
                            if (mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text('$label saved')),
                              );
                            }
                          } else {
                            setState(() => _apiKeyEditing[key] = true);
                          }
                        },
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  String _getIntegrationStatus(List<Map<String, dynamic>> fields) {
    int configured = 0;
    for (var field in fields) {
      final key = field['key'] as String;
      if (_apiKeyControllers[key]?.text.isNotEmpty ?? false) {
        configured++;
      }
    }
    if (configured == 0) return 'Not configured';
    if (configured == fields.length) return 'Configured';
    return '$configured/${fields.length} fields configured';
  }

  bool _hasAnyApiKey(List<Map<String, dynamic>> fields) {
    for (var field in fields) {
      final key = field['key'] as String;
      if (_apiKeyControllers[key]?.text.isNotEmpty ?? false) {
        return true;
      }
    }
    return false;
  }

  Widget _buildPreferencesCard(AppStateProvider appState) {
    return GlassCard(
      child: Column(
        children: [
          SwitchListTile(
            title: const Text('Dark Mode'),
            subtitle: const Text('Use dark theme'),
            value: appState.darkMode,
            onChanged: appState.setDarkMode,
            secondary: const Icon(Iconsax.moon),
          ),
          const Divider(height: 1),
          SwitchListTile(
            title: const Text('Notifications'),
            subtitle: const Text('Receive sync notifications'),
            value: appState.notificationsEnabled,
            onChanged: appState.setNotificationsEnabled,
            secondary: const Icon(Iconsax.notification),
          ),
        ],
      ),
    );
  }

  Widget _buildSystemInfoCard(AppStateProvider appState) {
    return GlassCard(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _buildInfoRow(
              'Status',
              appState.stats.status,
              appState.stats.status == 'healthy'
                  ? AppTheme.success
                  : AppTheme.warning,
            ),
            const Divider(height: 24),
            _buildInfoRow(
              'Notes Processed',
              '${appState.stats.notesProcessed}',
            ),
            const Divider(height: 24),
            _buildInfoRow(
              'Active Tasks',
              '${appState.stats.activeTasks}',
            ),
            const Divider(height: 24),
            _buildInfoRow(
              'WebSocket Connections',
              '${appState.stats.websocketConnections}',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAboutCard() {
    return GlassCard(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _buildInfoRow('Version', '1.0.0'),
            const Divider(height: 24),
            _buildInfoRow('Build', 'Flutter'),
            const Divider(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Iconsax.note_215,
                  color: AppTheme.primaryCyan,
                ),
                const SizedBox(width: 8),
                ShaderMask(
                  shaderCallback: (bounds) =>
                      AppTheme.primaryGradient.createShader(bounds),
                  child: const Text(
                    'NoteCapture MCP',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            const Text(
              'Voice pendant note capture & AI processing',
              style: TextStyle(
                fontSize: 12,
                color: AppTheme.textMuted,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value, [Color? valueColor]) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: const TextStyle(color: AppTheme.textSecondary),
        ),
        Text(
          value,
          style: TextStyle(
            fontWeight: FontWeight.w600,
            color: valueColor ?? AppTheme.textPrimary,
          ),
        ),
      ],
    );
  }
}
