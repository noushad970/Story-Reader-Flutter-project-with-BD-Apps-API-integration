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

  // ============================================================
  // PAGED STORIES (cursor based, 10 per page)
  // ============================================================

  static Future<PagedStories> getStoriesPaged({
    DocumentSnapshot? after,
    int limit = 10,
  }) async {
    Query<Map<String, dynamic>> query = _firestore
        .collection(storiesCollection)
        .where('isPublished', isEqualTo: true)
        .limit(limit);

    if (after != null) {
      query = query.startAfterDocument(after);
    }

    final snapshot = await query.get();
    final stories = snapshot.docs
        .map((doc) => StoryModel.fromFirestore(doc))
        .toList();
    final nextCursor = snapshot.docs.isEmpty ? null : snapshot.docs.last;
    return PagedStories(stories: stories, nextCursor: nextCursor);
  }

  // ============================================================
  // LIKES
  // ============================================================

  static Future<bool> hasLiked({
    required String storyId,
    required String userPhone,
  }) async {
    final doc = await _firestore
        .collection(storiesCollection)
        .doc(storyId)
        .collection('likes')
        .doc(userPhone)
        .get();
    return doc.exists;
  }

  static Stream<int> watchLikeCount(String storyId) {
    return _firestore
        .collection(storiesCollection)
        .doc(storyId)
        .collection('likes')
        .snapshots()
        .map((snap) => snap.docs.length);
  }

  static Stream<bool> watchHasLiked({
    required String storyId,
    required String userPhone,
  }) {
    return _firestore
        .collection(storiesCollection)
        .doc(storyId)
        .collection('likes')
        .doc(userPhone)
        .snapshots()
        .map((snap) => snap.exists);
  }

  static Future<bool> toggleLike({
    required String storyId,
    required String userPhone,
  }) async {
    final ref = _firestore
        .collection(storiesCollection)
        .doc(storyId)
        .collection('likes')
        .doc(userPhone);

    final snap = await ref.get();
    if (snap.exists) {
      await ref.delete();
      return false;
    } else {
      await ref.set({
        'userPhone': userPhone,
        'createdAt': FieldValue.serverTimestamp(),
      });
      return true;
    }
  }

  // ============================================================
  // COMMENT COUNT
  // ============================================================

  static Stream<int> watchCommentCount(String storyId) {
    return _firestore
        .collection(storiesCollection)
        .doc(storyId)
        .collection('comments')
        .snapshots()
        .map((snap) => snap.docs.length);
  }
}

class PagedStories {
  final List<StoryModel> stories;
  final DocumentSnapshot? nextCursor;

  const PagedStories({required this.stories, this.nextCursor});
}
