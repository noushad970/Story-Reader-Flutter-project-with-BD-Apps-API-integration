import 'package:firebase_auth/firebase_auth.dart';

class AdminInitializer {
  static const String adminEmail = 'admin@gmail.com';

  static const String adminPassword = '12345678';

  static Future<void> initializeAdmin() async {
    try {
      // Check if the admin account already exists
      try {
        await FirebaseAuth.instance.signInWithEmailAndPassword(
          email: adminEmail,
          password: adminPassword,
        );

        // Admin already exists
        await FirebaseAuth.instance.signOut();

        print('Admin account already exists.');
      } on FirebaseAuthException catch (e) {
        // If user does not exist, create it
        if (e.code == 'user-not-found' || e.code == 'invalid-credential') {
          await FirebaseAuth.instance.createUserWithEmailAndPassword(
            email: adminEmail,
            password: adminPassword,
          );

          print('Admin account created successfully.');

          await FirebaseAuth.instance.signOut();
        } else {
          print('Admin initialization error: ${e.message}');
        }
      }
    } catch (e) {
      print('Admin initialization failed: $e');
    }
  }
}
