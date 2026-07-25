import 'package:cloud_firestore/cloud_firestore.dart';

class StoryModel {
  final String id;
  final String title;
  final String description;
  final String content;
  final String author;
  final String categoryId;
  final String categoryName;
  final String coverImageUrl;
  final bool isPublished;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  StoryModel({
    required this.id,
    required this.title,
    required this.description,
    required this.content,
    required this.author,
    required this.categoryId,
    required this.categoryName,
    required this.coverImageUrl,
    required this.isPublished,
    this.createdAt,
    this.updatedAt,
  });

  factory StoryModel.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> document,
  ) {
    final data = document.data() ?? {};

    return StoryModel(
      id: document.id,
      title: data['title']?.toString() ?? '',
      description: data['description']?.toString() ?? '',
      content: data['content']?.toString() ?? '',
      author: data['author']?.toString() ?? '',
      categoryId: data['categoryId']?.toString() ?? '',
      categoryName: data['categoryName']?.toString() ?? '',
      coverImageUrl: data['coverImageUrl']?.toString() ?? '',
      isPublished: data['isPublished'] == true,
      createdAt: _convertTimestamp(data['createdAt']),
      updatedAt: _convertTimestamp(data['updatedAt']),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'title': title,
      'description': description,
      'content': content,
      'author': author,
      'categoryId': categoryId,
      'categoryName': categoryName,
      'coverImageUrl': coverImageUrl,
      'isPublished': isPublished,
      'createdAt': createdAt != null
          ? Timestamp.fromDate(createdAt!)
          : FieldValue.serverTimestamp(),
      'updatedAt': updatedAt != null
          ? Timestamp.fromDate(updatedAt!)
          : FieldValue.serverTimestamp(),
    };
  }

  static DateTime? _convertTimestamp(dynamic value) {
    if (value is Timestamp) {
      return value.toDate();
    }

    return null;
  }
}
