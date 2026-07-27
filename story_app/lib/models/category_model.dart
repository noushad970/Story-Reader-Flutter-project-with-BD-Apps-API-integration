import 'package:cloud_firestore/cloud_firestore.dart';

class CategoryModel {
  final String id;
  final String name;
  final String description;
  final DateTime? createdAt;

  CategoryModel({
    required this.id,
    required this.name,
    required this.description,
    this.createdAt,
  });

  factory CategoryModel.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> document,
  ) {
    final data = document.data() ?? {};

    return CategoryModel(
      id: document.id,
      name: data['name']?.toString() ?? '',
      description: data['description']?.toString() ?? '',
      createdAt: _convertTimestamp(data['createdAt']),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'name': name,
      'description': description,
      'createdAt': FieldValue.serverTimestamp(),
    };
  }

  static DateTime? _convertTimestamp(dynamic value) {
    if (value is Timestamp) {
      return value.toDate();
    }

    return null;
  }
}
