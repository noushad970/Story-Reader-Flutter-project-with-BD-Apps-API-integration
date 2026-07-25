import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/category_model.dart';

class CategoryService {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  static const String categoriesCollection = 'categories';

  static Stream<List<CategoryModel>> getCategories() {
    return _firestore
        .collection(categoriesCollection)
        .orderBy('name')
        .snapshots()
        .map((snapshot) {
          return snapshot.docs
              .map((doc) => CategoryModel.fromFirestore(doc))
              .toList();
        });
  }
}
