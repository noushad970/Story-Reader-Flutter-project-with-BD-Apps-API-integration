import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/story_model.dart';

/// Manages bookmarks — both the user's saved-stories list (Firestore) and a
/// local cache (SharedPreferences) so the home screen can quickly tell whether
/// the bookmark icon should be filled or outlined.
class BookmarkService {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  static const String _localKey = 'local_bookmarks';

  /// Toggle a bookmark for [storyId] under the given [userPhone].
  static Future<bool> toggle(String userPhone, StoryModel story) async {
    final ref = _firestore
        .collection('users')
        .doc(userPhone)
        .collection('bookmarks')
        .doc(story.id);

    final snap = await ref.get();

    if (snap.exists) {
      await ref.delete();
      await _removeLocal(story.id);
      return false; // now unbookmarked
    } else {
      await ref.set({
        'storyId': story.id,
        'title': story.title,
        'description': story.description,
        'author': story.author,
        'categoryName': story.categoryName,
        'coverImageUrl': story.coverImageUrl,
        'savedAt': FieldValue.serverTimestamp(),
      });
      await _addLocal(story.id);
      return true; // now bookmarked
    }
  }

  /// Live stream of the user's bookmarked stories.
  static Stream<List<StoryModel>> watchBookmarks(String userPhone) {
    return _firestore
        .collection('users')
        .doc(userPhone)
        .collection('bookmarks')
        .orderBy('savedAt', descending: true)
        .snapshots()
        .map(
          (snap) => snap.docs.map((d) {
            final data = d.data();
            return StoryModel(
              id: d.id,
              title: data['title']?.toString() ?? '',
              description: data['description']?.toString() ?? '',
              content: '',
              author: data['author']?.toString() ?? '',
              categoryId: '',
              categoryName: data['categoryName']?.toString() ?? '',
              coverImageUrl: data['coverImageUrl']?.toString() ?? '',
              isPublished: true,
            );
          }).toList(),
        );
  }

  /// One-shot fetch used by the home screen to paint bookmark icons.
  static Future<Set<String>> getBookmarkIds(String userPhone) async {
    final snap = await _firestore
        .collection('users')
        .doc(userPhone)
        .collection('bookmarks')
        .get();

    final ids = snap.docs.map((d) => d.id).toSet();
    await _saveLocal(ids);
    return ids;
  }

  static Future<bool> isBookmarked(String userPhone, String storyId) async {
    final doc = await _firestore
        .collection('users')
        .doc(userPhone)
        .collection('bookmarks')
        .doc(storyId)
        .get();

    return doc.exists;
  }

  // ---------------------------------------------------------------
  // Local cache so home screen can decide icon state immediately
  // ---------------------------------------------------------------

  static Future<Set<String>> _readLocal() async {
    final prefs = await SharedPreferences.getInstance();
    final list = prefs.getStringList(_localKey) ?? const <String>[];
    return list.toSet();
  }

  static Future<void> _saveLocal(Set<String> ids) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(_localKey, ids.toList());
  }

  static Future<void> _addLocal(String id) async {
    final ids = await _readLocal();
    ids.add(id);
    await _saveLocal(ids);
  }

  static Future<void> _removeLocal(String id) async {
    final ids = await _readLocal();
    ids.remove(id);
    await _saveLocal(ids);
  }

  /// Read locally-cached bookmark IDs (no network call).
  static Future<Set<String>> readLocalCache() => _readLocal();
}
