import 'dart:convert';

import 'package:http/http.dart' as http;

class ApiService {
  // NOTE: The single 'NADB26020/' prefix is the correct host path.
  // Some upstream proxies were observed to duplicate the segment
  // (e.g. /NADB26020//NADB26020/send_otp.php) — keep this constant
  // declared once and reuse it to avoid that bug.
  //
  // For local dev, override the host with a CORS proxy:
  //   flutter run -d edge --dart-define=API_BASE=http://localhost:8787/NADB26020
  // The default stays on the real BD Apps host for production builds.
  static const String _prodBaseUrl =
      'https://www.bdappsdigitalapps.com/NADB26020';
  static const String baseUrl = String.fromEnvironment(
    'API_BASE',
    defaultValue: _prodBaseUrl,
  );

  static String get sendOtpUrl => '$baseUrl/send_otp.php';
  static String get verifyOtpUrl => '$baseUrl/verify_otp.php';
  static String get unsubscribeUrl => '$baseUrl/unsubscribe.php';
  static String get checkSubscriptionUrl => '$baseUrl/check_subscription.php';

  // Common headers. 'Accept: application/json' helps the server
  // respond with JSON without an HTML error page. These are added
  // because Flutter web runs the request from the browser, which
  // also requires the server to send proper CORS headers — see
  // the CORS section below in the catch handlers.
  static const Map<String, String> _jsonHeaders = {
    'Content-Type': 'application/x-www-form-urlencoded',
    'Accept': 'application/json',
  };
  // ============================================================
  // SEND OTP
  // ============================================================

  static Future<Map<String, dynamic>> sendOtp(String phone) async {
    try {
      final response = await http.post(
        Uri.parse(sendOtpUrl),
        headers: _jsonHeaders,
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
        headers: _jsonHeaders,
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
        headers: _jsonHeaders,
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
        headers: _jsonHeaders,
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
