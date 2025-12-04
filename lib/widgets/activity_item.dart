import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:timeago/timeago.dart' as timeago;

import '../models/note.dart';
import '../utils/theme.dart';
import 'glass_card.dart';

class ActivityItem extends StatelessWidget {
  final Note note;

  const ActivityItem({super.key, required this.note});

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildIcon(),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          _getTitle(),
                          style: Theme.of(context).textTheme.titleSmall,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Text(
                        timeago.format(note.createdAt),
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    note.summary ?? note.content,
                    style: Theme.of(context).textTheme.bodySmall,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildIcon() {
    IconData icon;
    Color color;

    switch (note.source) {
      case 'omi':
        icon = Iconsax.microphone_2;
        color = AppTheme.primaryCyan;
        break;
      case 'limitless':
        icon = Iconsax.cpu;
        color = AppTheme.primaryPurple;
        break;
      default:
        icon = Iconsax.note_1;
        color = AppTheme.textMuted;
    }

    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Icon(icon, color: color, size: 20),
    );
  }

  String _getTitle() {
    switch (note.category) {
      case 'meeting':
        return 'Meeting Note';
      case 'conversation':
        return 'Conversation';
      case 'business_lead':
        return 'Business Lead';
      case 'task':
        return 'Task Note';
      default:
        return 'Note from ${note.source}';
    }
  }
}
