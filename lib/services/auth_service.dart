import 'api_service.dart';
import 'firestore_service.dart';
import '../storage/local_storage.dart';

class AuthService {
  // ============================================================
  // TEST USER
  // ============================================================

  static const String testMobileNumber = '01812345678';

  // ============================================================
  // SEND OTP
  // ============================================================

  static Future<Map<String, dynamic>> sendOtp(String phone) async {
    final normalizedPhone = _normalizePhone(phone);

    // TEST USER BYPASS
    if (normalizedPhone == testMobileNumber) {
      return {
        'success': true,
        'referenceNo': 'TEST_REFERENCE',
        'isTestUser': true,
        'message': 'Test user OTP bypass enabled',
      };
    }

    return await ApiService.sendOtp(normalizedPhone);
  }

  // ============================================================
  // VERIFY OTP
  // ============================================================

  static Future<Map<String, dynamic>> verifyOtp({
    required String phone,
    required String otp,
    required String referenceNo,
  }) async {
    final normalizedPhone = _normalizePhone(phone);

    // ==========================================================
    // TEST USER BYPASS
    // ==========================================================

    if (normalizedPhone == testMobileNumber) {
      final subscriberId = _createSubscriberId(normalizedPhone);

      await FirestoreService.createOrUpdateUser(
        phone: normalizedPhone,
        subscriberId: subscriberId,
        isSubscribed: true,
      );

      await LocalStorage.saveUser(
        phone: normalizedPhone,
        subscriberId: subscriberId,
      );

      return {
        'success': true,
        'isTestUser': true,
        'isSubscribed': true,
        'message': 'Test user logged in successfully',
      };
    }

    // ==========================================================
    // NORMAL OTP VERIFICATION
    // ==========================================================

    final result = await ApiService.verifyOtp(
      phone: normalizedPhone,
      otp: otp,
      referenceNo: referenceNo,
    );

    if (_isSuccessful(result)) {
      final subscriberId = _createSubscriberId(normalizedPhone);

      await FirestoreService.createOrUpdateUser(
        phone: normalizedPhone,
        subscriberId: subscriberId,
        isSubscribed: true,
      );

      await LocalStorage.saveUser(
        phone: normalizedPhone,
        subscriberId: subscriberId,
      );
    }

    return result;
  }

  // ============================================================
  // CHECK CURRENT SUBSCRIPTION
  // ============================================================

  static Future<bool> checkCurrentSubscription() async {
    final phone = await LocalStorage.getPhone();

    if (phone == null || phone.isEmpty) {
      return false;
    }

    final normalizedPhone = _normalizePhone(phone);

    // ==========================================================
    // TEST USER ALWAYS SUBSCRIBED
    // ==========================================================

    if (normalizedPhone == testMobileNumber) {
      await FirestoreService.updateSubscriptionStatus(
        phone: normalizedPhone,
        isSubscribed: true,
      );

      return true;
    }

    // ==========================================================
    // NORMAL SUBSCRIPTION CHECK
    // ==========================================================

    final result = await ApiService.checkSubscription(normalizedPhone);

    final isSubscribed = _isSubscriptionActive(result);

    await FirestoreService.updateSubscriptionStatus(
      phone: normalizedPhone,
      isSubscribed: isSubscribed,
    );

    if (!isSubscribed) {
      await LocalStorage.clearUser();
    }

    return isSubscribed;
  }

  // ============================================================
  // UNSUBSCRIBE
  // ============================================================

  static Future<Map<String, dynamic>> unsubscribe() async {
    final phone = await LocalStorage.getPhone();

    if (phone == null || phone.isEmpty) {
      return {'success': false, 'message': 'User phone number not found'};
    }

    final normalizedPhone = _normalizePhone(phone);

    // ==========================================================
    // TEST USER
    // ==========================================================

    if (normalizedPhone == testMobileNumber) {
      await FirestoreService.updateSubscriptionStatus(
        phone: normalizedPhone,
        isSubscribed: false,
      );

      await LocalStorage.clearUser();

      return {
        'success': true,
        'isTestUser': true,
        'message': 'Test user unsubscribed successfully',
      };
    }

    // ==========================================================
    // NORMAL UNSUBSCRIBE
    // ==========================================================

    final result = await ApiService.unsubscribe(normalizedPhone);

    if (_isSuccessful(result)) {
      await FirestoreService.updateSubscriptionStatus(
        phone: normalizedPhone,
        isSubscribed: false,
      );

      await LocalStorage.clearUser();
    }

    return result;
  }

  // ============================================================
  // LOGOUT
  // ============================================================

  static Future<void> logout() async {
    await LocalStorage.clearUser();
  }

  // ============================================================
  // SUCCESS CHECK
  // ============================================================

  static bool _isSuccessful(Map<String, dynamic> result) {
    return result['success'] == true ||
        result['status'] == 'success' ||
        result['status'] == true;
  }

  // ============================================================
  // SUBSCRIPTION STATUS CHECK
  // ============================================================

  static bool _isSubscriptionActive(Map<String, dynamic> result) {
    return result['subscribed'] == true ||
        result['is_subscribed'] == true ||
        result['isSubscribed'] == true ||
        result['subscription_status'] == 'active' ||
        result['status'] == 'active' ||
        result['active'] == true;
  }

  // ============================================================
  // NORMALIZE PHONE NUMBER
  // ============================================================

  static String _normalizePhone(String phone) {
    String digits = phone.replaceAll(RegExp(r'\D'), '');

    if (digits.startsWith('880') && digits.length == 13) {
      digits = '0${digits.substring(3)}';
    } else if (digits.startsWith('88') && digits.length == 12) {
      digits = '0${digits.substring(2)}';
    }

    return digits;
  }

  // ============================================================
  // SUBSCRIBER ID
  // ============================================================

  static String _createSubscriberId(String phone) {
    String digits = _normalizePhone(phone);

    if (digits.startsWith('0')) {
      digits = digits.substring(1);
    }

    return 'tel:88$digits';
  }
}
