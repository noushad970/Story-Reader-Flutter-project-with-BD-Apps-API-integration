import 'package:cloud_firestore/cloud_firestore.dart';

class FirestoreService {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  static const String usersCollection = 'users';

  // ============================================================
  // CREATE OR UPDATE USER
  // ============================================================

  static Future<void> createOrUpdateUser({
    required String phone,
    required String subscriberId,
    required bool isSubscribed,
  }) async {
    final userRef = _firestore.collection(usersCollection).doc(phone);

    final userSnapshot = await userRef.get();

    if (userSnapshot.exists) {
      await userRef.update({
        'phone': phone,
        'subscriberId': subscriberId,
        'isSubscribed': isSubscribed,
        'lastLogin': FieldValue.serverTimestamp(),
      });
    } else {
      await userRef.set({
        'phone': phone,
        'subscriberId': subscriberId,
        'isSubscribed': isSubscribed,
        'createdAt': FieldValue.serverTimestamp(),
        'lastLogin': FieldValue.serverTimestamp(),
      });
    }
  }

  // ============================================================
  // UPDATE SUBSCRIPTION STATUS
  // ============================================================

  static Future<void> updateSubscriptionStatus({
    required String phone,
    required bool isSubscribed,
  }) async {
    await _firestore.collection(usersCollection).doc(phone).set({
      'phone': phone,
      'isSubscribed': isSubscribed,
      'lastChecked': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }

  // ============================================================
  // GET USER
  // ============================================================

  static Future<DocumentSnapshot<Map<String, dynamic>>> getUser(
    String phone,
  ) async {
    return await _firestore.collection(usersCollection).doc(phone).get();
  }
}
