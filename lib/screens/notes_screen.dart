import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:iconsax/iconsax.dart';
import 'package:timeago/timeago.dart' as timeago;

import '../providers/notes_provider.dart';
import '../models/note.dart';
import '../utils/theme.dart';
import '../widgets/glass_card.dart';

class NotesScreen extends StatefulWidget {
  const NotesScreen({super.key});

  @override
  State<NotesScreen> createState() => _NotesScreenState();
}

class _NotesScreenState extends State<NotesScreen> {
  final _searchController = TextEditingController();
  String _searchQuery = '';
  String? _selectedCategory;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Column(
        children: [
          // Header
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Notes',
                  style: Theme.of(context).textTheme.displaySmall,
                ),
                const SizedBox(height: 16),
                // Search Bar
                TextField(
                  controller: _searchController,
                  onChanged: (value) => setState(() => _searchQuery = value),
                  decoration: InputDecoration(
                    hintText: 'Search notes...',
                    prefixIcon: const Icon(Iconsax.search_normal),
                    suffixIcon: _searchQuery.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear),
                            onPressed: () {
                              _searchController.clear();
                              setState(() => _searchQuery = '');
                            },
                          )
                        : null,
                  ),
                ),
                const SizedBox(height: 12),
                // Category Filter
                _buildCategoryFilter(),
              ],
            ),
          ),
          // Notes List
          Expanded(
            child: Consumer<NotesProvider>(
              builder: (_, notes, __) {
                if (notes.isLoading) {
                  return const Center(child: CircularProgressIndicator());
                }

                var filteredNotes = _searchQuery.isEmpty
                    ? notes.notes
                    : notes.searchNotes(_searchQuery);

                if (_selectedCategory != null) {
                  filteredNotes = filteredNotes
                      .where((n) => n.category == _selectedCategory)
                      .toList();
                }

                if (filteredNotes.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Iconsax.note_remove,
                          size: 64,
                          color: AppTheme.textMuted,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'No notes found',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                      ],
                    ),
                  );
                }

                return RefreshIndicator(
                  onRefresh: () => notes.loadNotes(),
                  child: ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: filteredNotes.length,
                    itemBuilder: (context, index) {
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: _NoteCard(note: filteredNotes[index]),
                      );
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryFilter() {
    final categories = [
      {'key': null, 'label': 'All', 'icon': Iconsax.element_4},
      {'key': 'conversation', 'label': 'Conversations', 'icon': Iconsax.message},
      {'key': 'meeting', 'label': 'Meetings', 'icon': Iconsax.people},
      {'key': 'business_lead', 'label': 'Leads', 'icon': Iconsax.briefcase},
      {'key': 'task', 'label': 'Tasks', 'icon': Iconsax.task_square},
    ];

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: categories.map((cat) {
          final isSelected = _selectedCategory == cat['key'];
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: FilterChip(
              label: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    cat['icon'] as IconData,
                    size: 16,
                    color: isSelected
                        ? AppTheme.bgPrimary
                        : AppTheme.textSecondary,
                  ),
                  const SizedBox(width: 6),
                  Text(cat['label'] as String),
                ],
              ),
              selected: isSelected,
              onSelected: (_) {
                setState(() => _selectedCategory = cat['key'] as String?);
              },
              selectedColor: AppTheme.primaryCyan,
              backgroundColor: AppTheme.bgCard,
            ),
          );
        }).toList(),
      ),
    );
  }
}

class _NoteCard extends StatelessWidget {
  final Note note;

  const _NoteCard({required this.note});

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              children: [
                _buildSourceBadge(),
                const SizedBox(width: 8),
                _buildCategoryBadge(),
                const Spacer(),
                Text(
                  timeago.format(note.createdAt),
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
            const SizedBox(height: 12),
            // Summary or Content
            Text(
              note.summary ?? note.content,
              style: Theme.of(context).textTheme.bodyMedium,
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
            ),
            // Topics
            if (note.topics.isNotEmpty) ...[
              const SizedBox(height: 12),
              Wrap(
                spacing: 6,
                runSpacing: 6,
                children: note.topics.take(4).map((topic) {
                  return Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: AppTheme.primaryCyan.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      topic,
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppTheme.primaryCyan,
                      ),
                    ),
                  );
                }).toList(),
              ),
            ],
            // Action Items Count
            if (note.actionItems.isNotEmpty) ...[
              const SizedBox(height: 12),
              Row(
                children: [
                  const Icon(
                    Iconsax.task_square,
                    size: 16,
                    color: AppTheme.primaryPurple,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    '${note.actionItems.length} action items',
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppTheme.primaryPurple,
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildSourceBadge() {
    final sourceColors = {
      'omi': AppTheme.primaryCyan,
      'limitless': AppTheme.primaryPurple,
      'manual': AppTheme.textMuted,
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: (sourceColors[note.source] ?? AppTheme.textMuted)
            .withOpacity(0.1),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        note.source.toUpperCase(),
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w600,
          color: sourceColors[note.source] ?? AppTheme.textMuted,
        ),
      ),
    );
  }

  Widget _buildCategoryBadge() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: AppTheme.bgGlass,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        note.category,
        style: const TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w500,
          color: AppTheme.textSecondary,
        ),
      ),
    );
  }
}
