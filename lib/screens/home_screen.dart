import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:iconsax/iconsax.dart';

import '../providers/app_state_provider.dart';
import '../providers/notes_provider.dart';
import '../providers/integrations_provider.dart';
import '../utils/theme.dart';
import '../widgets/glass_card.dart';
import '../widgets/stat_card.dart';
import '../widgets/integration_chip.dart';
import '../widgets/activity_item.dart';
import 'capture_screen.dart';
import 'notes_screen.dart';
import 'integrations_screen.dart';
import 'settings_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final appState = context.read<AppStateProvider>();
    final notes = context.read<NotesProvider>();
    final integrations = context.read<IntegrationsProvider>();

    await Future.wait([
      appState.connect(),
      notes.loadNotes(),
      integrations.loadIntegrationStatus(),
    ]);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: const [
          _DashboardView(),
          NotesScreen(),
          IntegrationsScreen(),
          SettingsScreen(),
        ],
      ),
      bottomNavigationBar: _buildBottomNav(),
      floatingActionButton: _currentIndex == 0 || _currentIndex == 1
          ? FloatingActionButton(
              onPressed: () => _showCaptureModal(),
              backgroundColor: AppTheme.primaryCyan,
              child: const Icon(Iconsax.add, color: AppTheme.bgPrimary),
            )
          : null,
    );
  }

  Widget _buildBottomNav() {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.bgSecondary,
        border: Border(
          top: BorderSide(
            color: AppTheme.primaryCyan.withOpacity(0.1),
          ),
        ),
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildNavItem(0, Iconsax.home, 'Home'),
              _buildNavItem(1, Iconsax.note_2, 'Notes'),
              _buildNavItem(2, Iconsax.link, 'Integrations'),
              _buildNavItem(3, Iconsax.setting_2, 'Settings'),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(int index, IconData icon, String label) {
    final isSelected = _currentIndex == index;
    return GestureDetector(
      onTap: () => setState(() => _currentIndex = index),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected
              ? AppTheme.primaryCyan.withOpacity(0.1)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              color: isSelected ? AppTheme.primaryCyan : AppTheme.textMuted,
              size: 24,
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                color: isSelected ? AppTheme.primaryCyan : AppTheme.textMuted,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showCaptureModal() {
    Navigator.of(context).push(
      MaterialPageRoute(
        fullscreenDialog: true,
        builder: (_) => const CaptureScreen(),
      ),
    );
  }
}

class _DashboardView extends StatelessWidget {
  const _DashboardView();

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: RefreshIndicator(
        onRefresh: () async {
          await context.read<AppStateProvider>().connect();
          await context.read<NotesProvider>().loadNotes();
          await context.read<IntegrationsProvider>().loadIntegrationStatus();
        },
        child: CustomScrollView(
          slivers: [
            // App Bar
            SliverAppBar(
              floating: true,
              backgroundColor: Colors.transparent,
              title: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      gradient: AppTheme.primaryGradient,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      Iconsax.note_215,
                      color: Colors.white,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 12),
                  const Text('NoteCapture'),
                ],
              ),
              actions: [
                Consumer<AppStateProvider>(
                  builder: (_, state, __) => _ConnectionBadge(
                    isConnected: state.isConnected,
                    isConnecting: state.isConnecting,
                  ),
                ),
                const SizedBox(width: 16),
              ],
            ),

            // Stats Section
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Overview',
                      style: Theme.of(context).textTheme.headlineSmall,
                    ),
                    const SizedBox(height: 16),
                    Consumer<AppStateProvider>(
                      builder: (_, state, __) => Row(
                        children: [
                          Expanded(
                            child: StatCard(
                              icon: Iconsax.note_2,
                              label: 'Notes',
                              value: '${state.stats.notesProcessed}',
                              color: AppTheme.primaryCyan,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: StatCard(
                              icon: Iconsax.task_square,
                              label: 'Tasks',
                              value: '${state.stats.activeTasks}',
                              color: AppTheme.primaryPurple,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: StatCard(
                              icon: Iconsax.timer_1,
                              label: 'Uptime',
                              value: _formatUptime(state.uptime),
                              color: AppTheme.success,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Quick Actions
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Quick Sync',
                      style: Theme.of(context).textTheme.headlineSmall,
                    ),
                    const SizedBox(height: 12),
                    Consumer<NotesProvider>(
                      builder: (_, notes, __) => Row(
                        children: [
                          Expanded(
                            child: _SyncButton(
                              label: 'Omi',
                              icon: Iconsax.microphone_2,
                              isSyncing: notes.isSyncing,
                              onPressed: () => notes.syncNotes(source: 'omi'),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _SyncButton(
                              label: 'Limitless',
                              icon: Iconsax.cpu,
                              isSyncing: notes.isSyncing,
                              onPressed: () =>
                                  notes.syncNotes(source: 'limitless'),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _SyncButton(
                              label: 'All',
                              icon: Iconsax.refresh,
                              isSyncing: notes.isSyncing,
                              onPressed: () => notes.syncNotes(),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Integrations Section
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Integrations',
                          style: Theme.of(context).textTheme.headlineSmall,
                        ),
                        Consumer<IntegrationsProvider>(
                          builder: (_, integrations, __) => Text(
                            '${integrations.connectedCount}/${integrations.totalCount}',
                            style: Theme.of(context).textTheme.bodyMedium,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Consumer<IntegrationsProvider>(
                      builder: (_, integrations, __) => Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: integrations.integrations
                            .map((i) => IntegrationChip(integration: i))
                            .toList(),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Recent Notes
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Text(
                  'Recent Notes',
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
              ),
            ),

            Consumer<NotesProvider>(
              builder: (_, notes, __) {
                if (notes.isLoading) {
                  return const SliverToBoxAdapter(
                    child: Center(
                      child: Padding(
                        padding: EdgeInsets.all(32),
                        child: CircularProgressIndicator(),
                      ),
                    ),
                  );
                }

                if (notes.notes.isEmpty) {
                  return SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.all(32),
                      child: Center(
                        child: Column(
                          children: [
                            Icon(
                              Iconsax.note_remove,
                              size: 48,
                              color: AppTheme.textMuted,
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'No notes yet',
                              style: Theme.of(context).textTheme.bodyLarge,
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Capture a note or sync from your pendants',
                              style: Theme.of(context).textTheme.bodySmall,
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                }

                return SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      if (index >= notes.notes.length || index >= 5) {
                        return null;
                      }
                      final note = notes.notes[index];
                      return Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                        child: ActivityItem(note: note),
                      );
                    },
                    childCount: notes.notes.length.clamp(0, 5),
                  ),
                );
              },
            ),

            const SliverToBoxAdapter(
              child: SizedBox(height: 100),
            ),
          ],
        ),
      ),
    );
  }

  String _formatUptime(Duration duration) {
    if (duration.inHours > 0) {
      return '${duration.inHours}h';
    } else if (duration.inMinutes > 0) {
      return '${duration.inMinutes}m';
    } else {
      return '${duration.inSeconds}s';
    }
  }
}

class _ConnectionBadge extends StatelessWidget {
  final bool isConnected;
  final bool isConnecting;

  const _ConnectionBadge({
    required this.isConnected,
    required this.isConnecting,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: isConnected
            ? AppTheme.success.withOpacity(0.1)
            : AppTheme.danger.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isConnected
              ? AppTheme.success.withOpacity(0.3)
              : AppTheme.danger.withOpacity(0.3),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (isConnecting)
            const SizedBox(
              width: 12,
              height: 12,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: AppTheme.primaryCyan,
              ),
            )
          else
            Container(
              width: 8,
              height: 8,
              decoration: BoxDecoration(
                color: isConnected ? AppTheme.success : AppTheme.danger,
                shape: BoxShape.circle,
              ),
            ),
          const SizedBox(width: 8),
          Text(
            isConnecting
                ? 'Connecting'
                : (isConnected ? 'Online' : 'Offline'),
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: isConnected ? AppTheme.success : AppTheme.danger,
            ),
          ),
        ],
      ),
    );
  }
}

class _SyncButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool isSyncing;
  final VoidCallback onPressed;

  const _SyncButton({
    required this.label,
    required this.icon,
    required this.isSyncing,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      child: InkWell(
        onTap: isSyncing ? null : onPressed,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              isSyncing
                  ? const SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: AppTheme.primaryCyan,
                      ),
                    )
                  : Icon(icon, color: AppTheme.primaryCyan),
              const SizedBox(height: 8),
              Text(
                label,
                style: Theme.of(context).textTheme.labelMedium,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
