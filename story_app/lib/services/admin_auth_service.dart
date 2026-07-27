import 'package:firebase_auth/firebase_auth.dart';

class AdminAuthService {
  static final FirebaseAuth _auth = FirebaseAuth.instance;

  // ============================================================
  // ADMIN LOGIN
  // ============================================================

  static Future<UserCredential> login({
    required String email,
    required String password,
  }) async {
    return await _auth.signInWithEmailAndPassword(
      email: email.trim(),
      password: password.trim(),
    );
  }

  // ============================================================
  // LOGOUT
  // ============================================================

  static Future<void> logout() async {
    await _auth.signOut();
  }

  // ============================================================
  // CURRENT USER
  // ============================================================

  static User? get currentUser {
    return _auth.currentUser;
  }

  // ============================================================
  // CHECK LOGIN
  // ============================================================

  static bool get isLoggedIn {
    return _auth.currentUser != null;
  }
}
