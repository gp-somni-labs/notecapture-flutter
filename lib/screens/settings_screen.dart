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

  @override
  void initState() {
    super.initState();
    final appState = context.read<AppStateProvider>();
    _serverUrlController.text = appState.serverUrl;
  }

  @override
  void dispose() {
    _serverUrlController.dispose();
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
                      GlassCard(
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
                                    icon: Icon(_isEditing
                                        ? Iconsax.tick_circle
                                        : Iconsax.edit),
                                    onPressed: () async {
                                      if (_isEditing) {
                                        await appState.setServerUrl(
                                            _serverUrlController.text);
                                        setState(() => _isEditing = false);
                                        if (mounted) {
                                          ScaffoldMessenger.of(context)
                                              .showSnackBar(
                                            const SnackBar(
                                              content: Text('Server URL updated'),
                                            ),
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
                                        : (appState.connectionError ??
                                            'Not connected'),
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: appState.isConnected
                                          ? AppTheme.success
                                          : AppTheme.danger,
                                    ),
                                  ),
                                  const Spacer(),
                                  TextButton(
                                    onPressed: appState.isConnecting
                                        ? null
                                        : appState.connect,
                                    child: appState.isConnecting
                                        ? const SizedBox(
                                            width: 16,
                                            height: 16,
                                            child: CircularProgressIndicator(
                                              strokeWidth: 2,
                                            ),
                                          )
                                        : const Text('Test'),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),

                      // Preferences Section
                      Text(
                        'Preferences',
                        style: Theme.of(context).textTheme.headlineSmall,
                      ),
                      const SizedBox(height: 12),
                      GlassCard(
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
                              subtitle:
                                  const Text('Receive sync notifications'),
                              value: appState.notificationsEnabled,
                              onChanged: appState.setNotificationsEnabled,
                              secondary: const Icon(Iconsax.notification),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),

                      // System Info Section
                      Text(
                        'System Info',
                        style: Theme.of(context).textTheme.headlineSmall,
                      ),
                      const SizedBox(height: 12),
                      GlassCard(
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
                      ),
                      const SizedBox(height: 24),

                      // About Section
                      Text(
                        'About',
                        style: Theme.of(context).textTheme.headlineSmall,
                      ),
                      const SizedBox(height: 12),
                      GlassCard(
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
                                        AppTheme.primaryGradient
                                            .createShader(bounds),
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
                      ),
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
