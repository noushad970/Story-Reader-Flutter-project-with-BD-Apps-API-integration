import 'package:cloud_firestore/cloud_firestore.dart';

class CommentModel {
  final String id;
  final String storyId;
  final String userPhone;
  final String userName;
  final String text;
  final DateTime? createdAt;

  CommentModel({
    required this.id,
    required this.storyId,
    required this.userPhone,
    required this.userName,
    required this.text,
    this.createdAt,
  });

  factory CommentModel.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> document,
  ) {
    final data = document.data() ?? {};
    return CommentModel(
      id: document.id,
      storyId: data['storyId']?.toString() ?? '',
      userPhone: data['userPhone']?.toString() ?? '',
      userName: data['userName']?.toString() ?? 'User',
      text: data['text']?.toString() ?? '',
      createdAt: _convertTimestamp(data['createdAt']),
    );
  }

  static DateTime? _convertTimestamp(dynamic value) {
    if (value is Timestamp) return value.toDate();
    return null;
  }
}
