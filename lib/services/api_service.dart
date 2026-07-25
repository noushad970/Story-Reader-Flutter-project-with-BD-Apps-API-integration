import 'dart:convert';

import 'package:http/http.dart' as http;

class ApiService {
  static const String baseUrl = 'https://www.bdappsdigitalapps.com/NADB26020/';

  static const String sendOtpUrl = '${baseUrl}send_otp.php';

  static const String verifyOtpUrl = '${baseUrl}verify_otp.php';

  static const String unsubscribeUrl = '${baseUrl}unsubscribe.php';

  static const String checkSubscriptionUrl = '${baseUrl}check_subscription.php';

  // ============================================================
  // SEND OTP
  // ============================================================

  static Future<Map<String, dynamic>> sendOtp(String phone) async {
    try {
      final response = await http.post(
        Uri.parse(sendOtpUrl),
        headers: {'Content-Type': 'application/x-www-form-urlencoded'},
        body: {'user_mobile': phone},
      );

      return _parseResponse(response);
    } catch (e) {
      return {'success': false, 'message': 'Network error: $e'};
    }
  }

  // ============================================================
  // VERIFY OTP
  // ============================================================

  static Future<Map<String, dynamic>> verifyOtp({
    required String phone,
    required String otp,
    required String referenceNo,
  }) async {
    try {
      final response = await http.post(
        Uri.parse(verifyOtpUrl),
        headers: {'Content-Type': 'application/x-www-form-urlencoded'},
        body: {'user_mobile': phone, 'otp': otp, 'referenceNo': referenceNo},
      );

      return _parseResponse(response);
    } catch (e) {
      return {'success': false, 'message': 'Network error: $e'};
    }
  }

  // ============================================================
  // CHECK SUBSCRIPTION
  // ============================================================

  static Future<Map<String, dynamic>> checkSubscription(String phone) async {
    try {
      final response = await http.post(
        Uri.parse(checkSubscriptionUrl),
        headers: {'Content-Type': 'application/x-www-form-urlencoded'},
        body: {'user_mobile': phone},
      );

      return _parseResponse(response);
    } catch (e) {
      return {'success': false, 'message': 'Network error: $e'};
    }
  }

  // ============================================================
  // UNSUBSCRIBE
  // ============================================================

  static Future<Map<String, dynamic>> unsubscribe(String phone) async {
    try {
      final response = await http.post(
        Uri.parse(unsubscribeUrl),
        headers: {'Content-Type': 'application/x-www-form-urlencoded'},
        body: {'user_mobile': phone},
      );

      return _parseResponse(response);
    } catch (e) {
      return {'success': false, 'message': 'Network error: $e'};
    }
  }

  // ============================================================
  // PARSE SERVER RESPONSE
  // ============================================================

  static Map<String, dynamic> _parseResponse(http.Response response) {
    try {
      final decoded = jsonDecode(response.body);

      if (decoded is Map<String, dynamic>) {
        return decoded;
      }

      return {
        'success': false,
        'message': 'Invalid server response',
        'httpCode': response.statusCode,
      };
    } catch (e) {
      return {
        'success': false,
        'message': 'Invalid JSON response',
        'rawResponse': response.body,
        'httpCode': response.statusCode,
      };
    }
  }
}
