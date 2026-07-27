import 'package:cloud_firestore/cloud_firestore.dart';

class AdminCategoryService {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  static const String collection = 'categories';

  // ============================================================
  // CREATE CATEGORY
  // ============================================================

  static Future<void> createCategory({
    required String name,
    required String description,
  }) async {
    await _firestore.collection(collection).add({
      'name': name.trim(),
      'description': description.trim(),
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  // ============================================================
  // UPDATE CATEGORY
  // ============================================================

  static Future<void> updateCategory({
    required String categoryId,
    required String name,
    required String description,
  }) async {
    await _firestore.collection(collection).doc(categoryId).update({
      'name': name.trim(),
      'description': description.trim(),
    });
  }

  // ============================================================
  // DELETE CATEGORY
  // ============================================================

  static Future<void> deleteCategory(String categoryId) async {
    await _firestore.collection(collection).doc(categoryId).delete();
  }
}
