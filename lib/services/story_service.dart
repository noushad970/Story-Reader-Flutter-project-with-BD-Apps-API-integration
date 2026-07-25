import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/story_model.dart';

class StoryService {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  static const String storiesCollection = 'stories';

  // ============================================================
  // GET ALL PUBLISHED STORIES
  // ============================================================

  static Stream<List<StoryModel>> getPublishedStories() {
    return _firestore
        .collection(storiesCollection)
        .where('isPublished', isEqualTo: true)
        .snapshots()
        .map((snapshot) {
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

  // ============================================================
  // GET STORIES BY CATEGORY
  // ============================================================

  static Stream<List<StoryModel>> getStoriesByCategory(String categoryId) {
    return _firestore
        .collection(storiesCollection)
        .where('isPublished', isEqualTo: true)
        .where('categoryId', isEqualTo: categoryId)
        .snapshots()
        .map((snapshot) {
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

  // ============================================================
  // GET SINGLE STORY
  // ============================================================

  static Future<StoryModel?> getStoryById(String storyId) async {
    final document = await _firestore
        .collection(storiesCollection)
        .doc(storyId)
        .get();

    if (!document.exists) {
      return null;
    }

    return StoryModel.fromFirestore(document);
  }
}
