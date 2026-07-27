import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/story_model.dart';

class AdminStoryService {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  static const String collection = 'stories';

  // ============================================================
  // CREATE STORY
  // ============================================================

  static Future<void> createStory({
    required String title,
    required String description,
    required String content,
    required String author,
    required String categoryId,
    required String categoryName,
    required String coverImageUrl,
    required bool isPublished,
  }) async {
    await _firestore.collection(collection).add({
      'title': title,
      'description': description,
      'content': content,
      'author': author,
      'categoryId': categoryId,
      'categoryName': categoryName,
      'coverImageUrl': coverImageUrl,
      'isPublished': isPublished,
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  // ============================================================
  // UPDATE STORY
  // ============================================================

  static Future<void> updateStory({
    required StoryModel story,
    required String title,
    required String description,
    required String content,
    required String author,
    required String categoryId,
    required String categoryName,
    required String coverImageUrl,
    required bool isPublished,
  }) async {
    await _firestore.collection(collection).doc(story.id).update({
      'title': title,
      'description': description,
      'content': content,
      'author': author,
      'categoryId': categoryId,
      'categoryName': categoryName,
      'coverImageUrl': coverImageUrl,
      'isPublished': isPublished,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  // ============================================================
  // DELETE STORY
  // ============================================================

  static Future<void> deleteStory(String storyId) async {
    await _firestore.collection(collection).doc(storyId).delete();
  }

  // ============================================================
  // PUBLISH / UNPUBLISH
  // ============================================================

  static Future<void> updatePublishStatus({
    required String storyId,
    required bool isPublished,
  }) async {
    await _firestore.collection(collection).doc(storyId).update({
      'isPublished': isPublished,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  // ============================================================
  // GET ALL STORIES FOR ADMIN
  // ============================================================

  static Stream<List<StoryModel>> getAllStories() {
    return _firestore.collection(collection).snapshots().map((snapshot) {
      final stories = snapshot.docs
          .map((doc) => StoryModel.fromFirestore(doc))
          .toList();

      stories.sort((a, b) {
        final aTime = a.createdAt;
        final bTime = b.createdAt;

        if (aTime == null && bTime == null) return 0;
        if (aTime == null) return 1;
        if (bTime == null) return -1;

        return bTime.compareTo(aTime);
      });

      return stories;
    });
  }
}
