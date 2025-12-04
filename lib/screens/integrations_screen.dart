import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:iconsax/iconsax.dart';

import '../providers/integrations_provider.dart';
import '../models/integration.dart';
import '../utils/theme.dart';
import '../widgets/glass_card.dart';

class IntegrationsScreen extends StatelessWidget {
  const IntegrationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Consumer<IntegrationsProvider>(
        builder: (_, integrations, __) {
          final categories = [
            {'key': 'capture', 'name': 'Capture Sources', 'icon': Iconsax.microphone_2},
            {'key': 'crm', 'name': 'CRM & Business', 'icon': Iconsax.building},
            {'key': 'tasks', 'name': 'Task Management', 'icon': Iconsax.task_square},
            {'key': 'scheduling', 'name': 'Scheduling', 'icon': Iconsax.calendar},
            {'key': 'storage', 'name': 'Storage', 'icon': Iconsax.folder},
          ];

          return RefreshIndicator(
            onRefresh: () => integrations.refresh(),
            child: CustomScrollView(
              slivers: [
                SliverAppBar(
                  floating: true,
                  backgroundColor: Colors.transparent,
                  title: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Integrations'),
                      Text(
                        '${integrations.connectedCount} of ${integrations.totalCount} connected',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ],
                  ),
                  actions: [
                    IconButton(
                      icon: integrations.isLoading
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Icon(Iconsax.refresh),
                      onPressed:
                          integrations.isLoading ? null : integrations.refresh,
                    ),
                  ],
                ),
                ...categories.map((cat) {
                  final items = integrations.getByCategory(cat['key'] as String);
                  if (items.isEmpty) return const SliverToBoxAdapter(child: SizedBox());

                  return SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(
                                cat['icon'] as IconData,
                                size: 20,
                                color: AppTheme.primaryCyan,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                cat['name'] as String,
                                style:
                                    Theme.of(context).textTheme.headlineSmall,
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          ...items.map((i) => Padding(
                                padding: const EdgeInsets.only(bottom: 12),
                                child: _IntegrationCard(integration: i),
                              )),
                        ],
                      ),
                    ),
                  );
                }),
                const SliverToBoxAdapter(child: SizedBox(height: 100)),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _IntegrationCard extends StatelessWidget {
  final Integration integration;

  const _IntegrationCard({required this.integration});

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: integration.isConnected
                ? AppTheme.success.withOpacity(0.1)
                : AppTheme.bgGlass,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(
            _getIcon(),
            color: integration.isConnected
                ? AppTheme.success
                : AppTheme.textMuted,
          ),
        ),
        title: Text(
          integration.name,
          style: Theme.of(context).textTheme.titleMedium,
        ),
        subtitle: Text(
          integration.description,
          style: Theme.of(context).textTheme.bodySmall,
        ),
        trailing: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: integration.isConnected
                ? AppTheme.success.withOpacity(0.1)
                : AppTheme.danger.withOpacity(0.1),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(
            integration.isConnected ? 'Connected' : 'Not configured',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color:
                  integration.isConnected ? AppTheme.success : AppTheme.danger,
            ),
          ),
        ),
      ),
    );
  }

  IconData _getIcon() {
    final iconMap = {
      'brain': Iconsax.cpu,
      'infinity': Iconsax.unlimited,
      'users': Iconsax.people,
      'building': Iconsax.building,
      'list-check': Iconsax.task,
      'checkbox': Iconsax.tick_square,
      'checklist': Iconsax.clipboard_tick,
      'calendar-event': Iconsax.calendar_1,
      'notes': Iconsax.note_1,
    };
    return iconMap[integration.icon] ?? Iconsax.link;
  }
}
