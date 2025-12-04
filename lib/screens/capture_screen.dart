import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:iconsax/iconsax.dart';

import '../providers/notes_provider.dart';
import '../utils/theme.dart';

class CaptureScreen extends StatefulWidget {
  const CaptureScreen({super.key});

  @override
  State<CaptureScreen> createState() => _CaptureScreenState();
}

class _CaptureScreenState extends State<CaptureScreen> {
  final _contentController = TextEditingController();
  final _projectController = TextEditingController();
  final _tagsController = TextEditingController();
  String _selectedProvider = 'claude';
  bool _isSubmitting = false;

  @override
  void dispose() {
    _contentController.dispose();
    _projectController.dispose();
    _tagsController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Capture Note'),
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          TextButton.icon(
            onPressed: _isSubmitting ? null : _submitNote,
            icon: _isSubmitting
                ? const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Iconsax.send_1),
            label: const Text('Save'),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Content Input
            Text(
              'Note Content',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _contentController,
              maxLines: 8,
              decoration: const InputDecoration(
                hintText: 'What\'s on your mind?',
              ),
            ),
            const SizedBox(height: 24),

            // Project Input
            Text(
              'Project (optional)',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _projectController,
              decoration: const InputDecoration(
                hintText: 'e.g., Work, Personal',
                prefixIcon: Icon(Iconsax.folder_2),
              ),
            ),
            const SizedBox(height: 24),

            // Tags Input
            Text(
              'Tags (comma-separated)',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _tagsController,
              decoration: const InputDecoration(
                hintText: 'e.g., meeting, ideas, follow-up',
                prefixIcon: Icon(Iconsax.tag),
              ),
            ),
            const SizedBox(height: 24),

            // AI Provider Selection
            Text(
              'AI Provider',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            _buildProviderSelector(),
          ],
        ),
      ),
    );
  }

  Widget _buildProviderSelector() {
    final providers = [
      {'key': 'claude', 'name': 'Claude', 'icon': Iconsax.magic_star},
      {'key': 'openai', 'name': 'OpenAI', 'icon': Iconsax.cpu},
      {'key': 'ollama', 'name': 'Ollama', 'icon': Iconsax.code},
    ];

    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: providers.map((p) {
        final isSelected = _selectedProvider == p['key'];
        return ChoiceChip(
          label: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                p['icon'] as IconData,
                size: 16,
                color: isSelected ? AppTheme.bgPrimary : AppTheme.textSecondary,
              ),
              const SizedBox(width: 8),
              Text(p['name'] as String),
            ],
          ),
          selected: isSelected,
          onSelected: (selected) {
            if (selected) {
              setState(() => _selectedProvider = p['key'] as String);
            }
          },
          selectedColor: AppTheme.primaryCyan,
          backgroundColor: AppTheme.bgCard,
        );
      }).toList(),
    );
  }

  Future<void> _submitNote() async {
    if (_contentController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter some content')),
      );
      return;
    }

    setState(() => _isSubmitting = true);

    try {
      final tags = _tagsController.text
          .split(',')
          .map((t) => t.trim())
          .where((t) => t.isNotEmpty)
          .toList();

      final note = await context.read<NotesProvider>().captureNote(
            content: _contentController.text,
            project: _projectController.text.isNotEmpty
                ? _projectController.text
                : null,
            tags: tags,
            aiProvider: _selectedProvider,
          );

      if (mounted && note != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Note captured successfully'),
            backgroundColor: AppTheme.success,
          ),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to capture note: $e'),
            backgroundColor: AppTheme.danger,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isSubmitting = false);
      }
    }
  }
}
