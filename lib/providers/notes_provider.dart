import 'package:flutter/foundation.dart';
import '../models/note.dart';
import '../services/api_service.dart';

class NotesProvider extends ChangeNotifier {
  final ApiService _api = ApiService();

  List<Note> _notes = [];
  bool _isLoading = false;
  bool _isSyncing = false;
  String? _error;
  Map<String, int> _syncResults = {};

  // Getters
  List<Note> get notes => _notes;
  bool get isLoading => _isLoading;
  bool get isSyncing => _isSyncing;
  String? get error => _error;
  Map<String, int> get syncResults => _syncResults;

  int get pendingCount =>
      _notes.where((n) => n.status == NoteStatus.pending).length;
  int get processedCount =>
      _notes.where((n) => n.status == NoteStatus.completed).length;

  // ============================================================================
  // LOAD NOTES
  // ============================================================================

  Future<void> loadNotes({int limit = 50}) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _notes = await _api.getNotes(limit: limit);
      _notes.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // ============================================================================
  // CAPTURE NOTE
  // ============================================================================

  Future<Note?> captureNote({
    required String content,
    String? project,
    List<String> tags = const [],
    String? aiProvider,
  }) async {
    try {
      final note = await _api.captureNote(
        content: content,
        project: project,
        tags: tags,
        aiProvider: aiProvider,
      );

      _notes.insert(0, note);
      notifyListeners();
      return note;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return null;
    }
  }

  // ============================================================================
  // SYNC
  // ============================================================================

  Future<void> syncNotes({String? source, int limit = 20}) async {
    if (_isSyncing) return;

    _isSyncing = true;
    _error = null;
    _syncResults = {};
    notifyListeners();

    try {
      final results = await _api.syncNotes(source: source, limit: limit);

      results.forEach((key, value) {
        _syncResults[key] = value.count;
      });

      // Reload notes after sync
      await loadNotes();
    } catch (e) {
      _error = e.toString();
    } finally {
      _isSyncing = false;
      notifyListeners();
    }
  }

  // ============================================================================
  // HELPERS
  // ============================================================================

  void clearError() {
    _error = null;
    notifyListeners();
  }

  List<Note> getByCategory(String category) {
    return _notes.where((n) => n.category == category).toList();
  }

  List<Note> getBySource(String source) {
    return _notes.where((n) => n.source == source).toList();
  }

  List<Note> searchNotes(String query) {
    final q = query.toLowerCase();
    return _notes.where((n) {
      return n.content.toLowerCase().contains(q) ||
          (n.summary?.toLowerCase().contains(q) ?? false) ||
          n.topics.any((t) => t.toLowerCase().contains(q));
    }).toList();
  }
}
