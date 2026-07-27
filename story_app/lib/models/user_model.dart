import 'package:cloud_firestore/cloud_firestore.dart';

class UserModel {
  final String uid;
  final String phone;
  final String subscriberId;
  final bool isSubscribed;
  final DateTime? createdAt;
  final DateTime? lastLogin;

  UserModel({
    required this.uid,
    required this.phone,
    required this.subscriberId,
    required this.isSubscribed,
    this.createdAt,
    this.lastLogin,
  });

  Map<String, dynamic> toFirestore() {
    return {
      'uid': uid,
      'phone': phone,
      'subscriberId': subscriberId,
      'isSubscribed': isSubscribed,
      'createdAt': createdAt != null
          ? Timestamp.fromDate(createdAt!)
          : FieldValue.serverTimestamp(),
      'lastLogin': lastLogin != null
          ? Timestamp.fromDate(lastLogin!)
          : FieldValue.serverTimestamp(),
    };
  }

  factory UserModel.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> document,
  ) {
    final data = document.data() ?? {};

    return UserModel(
      uid: data['uid']?.toString() ?? document.id,
      phone: data['phone']?.toString() ?? '',
      subscriberId: data['subscriberId']?.toString() ?? '',
      isSubscribed: data['isSubscribed'] == true,
      createdAt: _timestampToDate(data['createdAt']),
      lastLogin: _timestampToDate(data['lastLogin']),
    );
  }

  static DateTime? _timestampToDate(dynamic value) {
    if (value is Timestamp) {
      return value.toDate();
    }

    return null;
  }
}
