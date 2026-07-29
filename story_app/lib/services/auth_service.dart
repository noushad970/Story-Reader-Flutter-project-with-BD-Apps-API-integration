import 'package:flutter/foundation.dart';

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
  // LOGIN IF SUBSCRIBED
  //
  // Called from the login screen. If the user already has an active
  // subscription, save them locally and report success so the UI can
  // jump straight to the home screen. Otherwise report failure so the
  // UI can fall through to the OTP-based subscription flow.
  // ============================================================

  static Future<Map<String, dynamic>> loginIfSubscribed(String phone) async {
    final normalizedPhone = _normalizePhone(phone);

    // ==========================================================
    // TEST USER: always treated as subscribed
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
    // NORMAL USER: ask the BD Apps backend
    // ==========================================================

    final result = await ApiService.checkSubscription(normalizedPhone);

    // ----------------------------------------------------------------
    // IMPORTANT: E1313 means the BD Apps backend itself failed to
    // authenticate (wrong appId / password / deactivated service).
    // That is NOT a signal about THIS user's subscription. If we
    // treated it as "subscribed", non-subscribers would be sent
    // straight into the home screen and never see the OTP flow
    // they need to start their subscription.
    //
    // Treat E1313 as "unknown, fall through to OTP" so the user
    // gets a chance to verify their number with the operator.
    // ----------------------------------------------------------------
    if (_isBackendAuthFailure(result)) {
      debugPrint(
        '[AuthService] loginIfSubscribed: backend auth failure (E1313) — '
        'falling through to OTP flow. result: $result',
      );
      return {
        'success': false,
        'isSubscribed': false,
        'message':
            'Subscription status could not be verified. '
            'Please verify with OTP to continue.',
      };
    }

    final isSubscribed = _isSubscriptionActive(result);

    if (isSubscribed) {
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
        'isSubscribed': true,
        'message': 'Logged in successfully',
      };
    }

    return {
      'success': false,
      'isSubscribed': false,
      'message': 'No active subscription for this number',
    };
  }

  // ============================================================
  // IS "ALREADY REGISTERED" ERROR
  //
  // Returns true when a BD Apps API response indicates the phone
  // number has previously interacted with the operator. Used by
  // the login screen to show a friendlier hint on the OTP screen.
  //
  // Note: previously the login flow auto-logged the user in when
  // this was true. That was incorrect — being "already registered"
  // with BD Apps only means the number has interacted before, NOT
  // that the subscription is currently active. A lapsed subscriber
  // (subscription expired) is still considered "registered" by
  // BD Apps. They MUST complete OTP verification to re-activate
  // their subscription before they can read stories.
  // ============================================================

  static bool isAlreadyRegisteredError(Map<String, dynamic> result) {
    if (result['success'] == true) return false;

    final message = result['message']?.toString().toLowerCase() ?? '';
    final statusDetail = result['statusDetail']?.toString().toLowerCase() ?? '';
    final statusCode = result['statusCode']?.toString().toUpperCase() ?? '';

    const knownAlreadyRegisteredCodes = {'E1336', 'E1301'};

    if (knownAlreadyRegisteredCodes.contains(statusCode)) return true;

    if (message.contains('already registered') ||
        message.contains('already subscribed') ||
        message.contains('already exist')) {
      return true;
    }

    if (statusDetail.contains('already registered') ||
        statusDetail.contains('already subscribed') ||
        statusDetail.contains('already exist')) {
      return true;
    }

    return false;
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

    // ----------------------------------------------------------------
    // IMPORTANT: E1313 means the BD Apps backend itself failed to
    // authenticate (wrong appId / password / deactivated service).
    // That is NOT a signal about THIS user's subscription. If we
    // overwrite Firestore with isSubscribed=false here, we would
    // log the user out every time the backend has a config issue.
    // Bail out and keep whatever state we already have.
    // ----------------------------------------------------------------
    if (_isBackendAuthFailure(result)) {
      debugPrint(
        '[AuthService] checkSubscription: backend auth failure (E1313) — '
        'keeping local state intact. result: $result',
      );
      // Best effort: assume the user is still subscribed so we don't
      // show the "subscribe" banner. The next time the home screen
      // re-runs, this check will happen again.
      return true;
    }

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
  //
  // Cancels the subscription for [phone] (or the currently logged-in
  // number when [phone] is null):
  //   1. Calls BD Apps API unsubscribe endpoint
  //   2. On success, sets Firestore isSubscribed = false for that user
  //   3. If the unsubscribed number matches the local session, clears it
  // ============================================================

  static Future<Map<String, dynamic>> unsubscribe({String? phone}) async {
    final currentPhone = await LocalStorage.getPhone();

    String targetPhone;

    if (phone != null && phone.trim().isNotEmpty) {
      targetPhone = _normalizePhone(phone);
    } else if (currentPhone != null && currentPhone.isNotEmpty) {
      targetPhone = _normalizePhone(currentPhone);
    } else {
      return {
        'success': false,
        'message': 'No mobile number provided to unsubscribe',
      };
    }

    // ==========================================================
    // TEST USER
    // ==========================================================

    if (targetPhone == testMobileNumber) {
      await FirestoreService.updateSubscriptionStatus(
        phone: targetPhone,
        isSubscribed: false,
      );

      if (currentPhone != null &&
          _normalizePhone(currentPhone) == targetPhone) {
        await LocalStorage.clearUser();
      }

      return {
        'success': true,
        'isTestUser': true,
        'message': 'Test user unsubscribed successfully',
      };
    }

    // ==========================================================
    // NORMAL UNSUBSCRIBE
    //
    // The PHP endpoint returns the operator's response wrapped in
    // an envelope:
    //   { success, statusCode, statusDetail,
    //     subscriptionStatus, rawResponse, ... }
    //
    // We treat BOTH "explicit success" AND "already unregistered"
    // as a successful local unsubscribe. The latter happens when:
    //   - the user already cancelled via SMS (STOP 1297 -> 21213)
    //   - BD Apps returns E1951 "User Already UnRegistered"
    //   - PHP reports subscriptionStatus: UNREGISTERED
    //
    // In all of those cases the local app state should be cleared
    // even though success=false.
    // ==========================================================

    final result = await ApiService.unsubscribe(targetPhone);

    // ==========================================================
    // BACKEND AUTH FAILURE
    //
    // If the PHP backend itself can't authenticate with the BD Apps
    // operator (E1313), we DO NOT touch local state. We have no
    // ground truth about whether this user is subscribed, so wiping
    // the session would be wrong. Surface the error verbatim to the
    // UI instead.
    // ==========================================================
    if (_isBackendAuthFailure(result)) {
      debugPrint(
        '[AuthService] unsubscribe: backend auth failure (E1313) — '
        'NOT modifying local state.',
      );
      return {
        ...result,
        'success': false,
        'message':
            result['statusDetail']?.toString() ??
            'Operator backend is temporarily unavailable. Please try again later.',
      };
    }

    final wasAlreadyUnregistered =
        !_isSuccessful(result) && _isUnregistered(result);

    if (_isSuccessful(result) || _isUnregistered(result)) {
      await FirestoreService.updateSubscriptionStatus(
        phone: targetPhone,
        isSubscribed: false,
      );

      if (currentPhone != null &&
          _normalizePhone(currentPhone) == targetPhone) {
        await LocalStorage.clearUser();
      }

      // Bubble a normalized success flag to the caller (UI uses
      // this to decide whether to pop with `true`). When the user
      // wasn't actually a subscriber on BD Apps (lapsed/never/format
      // mismatch), show a friendly hint instead of the raw operator
      // wording.
      final fallback = wasAlreadyUnregistered
          ? 'This number is not registered with the operator. Your local '
                'session has been cleared.'
          : 'Subscription cancelled successfully';

      return {
        ...result,
        'success': true,
        'wasAlreadyUnregistered': wasAlreadyUnregistered,
        'message': result['statusDetail']?.toString() ?? fallback,
      };
    }

    // Real failure: surface the operator's statusDetail so the
    // snackbar in UnsubscribeScreen shows something meaningful.
    return {
      ...result,
      'success': false,
      'message':
          result['statusDetail']?.toString() ??
          result['message']?.toString() ??
          'Unsubscribe failed',
    };
  }

  // ============================================================
  // LOGOUT
  // ============================================================

  static Future<void> logout() async {
    await LocalStorage.clearUser();
  }

  // ============================================================
  // CURRENT USER PHONE (sync)
  // ============================================================

  static String? get currentUserPhone {
    return LocalStorage.getPhoneSync();
  }

  // ============================================================
  // SUCCESS CHECK
  //
  // The server-side PHP (send_otp.php, verify_otp.php,
  // unsubscribe.php, check_subscription.php) wraps every response
  // in this envelope:
  //
  //   {
  //     "success": true|false,
  //     "statusCode": "S1000" | "S1320" | "E1313" | ...,
  //     "statusDetail": "human-readable message",
  //     "subscriptionStatus": "REGISTERED" | "UNREGISTERED" | "UNKNOWN",
  //     ...
  //   }
  //
  // Treat the response as successful when EITHER:
  //   - explicit success flag is true
  //   - statusCode starts with 'S' (BD Apps operator success codes:
  //     S1000 = generic success, S1320 = already subscribed, etc.)
  //   - subscriptionStatus == UNREGISTERED (a successful *un*sub)        // ============================================================

  static bool _isSuccessful(Map<String, dynamic> result) {
    if (result['success'] == true) return true;

    final statusCode = result['statusCode']?.toString().toUpperCase() ?? '';
    if (statusCode.startsWith('S')) return true;

    return false;
  }

  // True when the response is a server-side authentication failure
  // that says nothing about the user's actual subscription status.
  //
  // The BD Apps operator returns E1313 ("Authentication failure.
  // There is no active application, or no active service provider
  // or given password in the request is invalid.") when the PHP
  // wrapper either passed wrong credentials OR never passed them
  // at all (this is the most common cause in the field — the PHP
  // forgot to include `applicationId` + `password` in the operator
  // request).
  //
  // In that case we MUST NOT touch Firestore — the user's real
  // subscription is unknown to us, and resetting it would lock
  // them out.
  static bool _isBackendAuthFailure(Map<String, dynamic> result) {
    final statusCode = result['statusCode']?.toString().toUpperCase() ?? '';
    if (statusCode == 'E1313') return true;

    final detail = result['statusDetail']?.toString().toLowerCase() ?? '';
    if (detail.contains('authentication failure')) return true;
    if (detail.contains('no active application')) return true;
    if (detail.contains('no active service provider')) return true;
    if (detail.contains('password in the request is invalid')) return true;

    return false;
  }

  // True when the server has confirmed the user no longer holds a
  // subscription (either we just cancelled it, or they were already
  // gone). Used by the unsubscribe flow to know it's safe to clear
  // the local session + flip Firestore isSubscribed -> false.
  //
  // The BD Apps operator returns a few different status codes for
  // "this number is not a registered subscriber right now":
  //
  //   - S1000 + subscriptionStatus: UNREGISTERED  -> success
  //   - E1951 "User Already UnRegistered"        -> not on file
  //   - E1951 "Format of the address is invalid"
  //     Or "User Already UnRegistered"           -> same effect
  //   - E1971 "Charging Failed"                  -> operator rejected
  //                                                the billing, treat
  //                                                as un-subscribed
  //
  // For a user trying to *unsubscribe*, every one of these means
  // the same thing: there is nothing to cancel. The local session
  // should be cleared so they don't get stuck behind a stale flag.
  static bool _isUnregistered(Map<String, dynamic> result) {
    if (_isSuccessful(result)) return true;

    final subStatus =
        result['subscriptionStatus']?.toString().toUpperCase() ?? '';
    if (subStatus == 'UNREGISTERED') return true;

    final statusCode = result['statusCode']?.toString().toUpperCase() ?? '';
    final detail = result['statusDetail']?.toString().toLowerCase() ?? '';
    final error = result['error']?.toString().toLowerCase() ?? '';

    // E1951: "User Already UnRegistered" / "Format of address is invalid"
    if (statusCode == 'E1951') return true;

    // Loose text matches — the operator's wording varies a bit
    // across deployments, so we check the common phrasings.
    bool matches(String phrase) =>
        detail.contains(phrase) || error.contains(phrase);

    if (matches('already unregistered')) return true;
    if (matches('user already unregistered')) return true;
    if (matches('format of the address is invalid')) return true;
    if (matches('format of address')) return true;
    if (matches('not registered')) return true;
    if (matches('charging failed')) return true;

    return false;
  }

  // ============================================================
  // SUBSCRIPTION STATUS CHECK
  //
  // The BD Apps backend (check_subscription.php) returns responses
  // in this shape (observed live):
  //   {
  //     "subscriptionStatus": "active" | "inactive" | "",
  //     "isSubscribed": true | false,
  //     "statusCode": "S1320" | "E1313" | ...,
  //     "statusDetail": "...",
  //     "subscriberId": "tel:880..."
  //   }
  //
  // We treat the user as subscribed when ANY of these are true:
  //   - isSubscribed == true
  //   - subscriptionStatus == 'active' (camelCase match)
  //   - subscription_status == 'active' (snake_case fallback)
  //   - statusCode starts with 'S' (success codes from BD Apps)
  //   - a nested data.subscriptionStatus / data.isSubscribed is true
  // ============================================================

  static bool _isSubscriptionActive(Map<String, dynamic> result) {
    // ---- TEMP DEBUG: print the raw payload so we can confirm shape ----
    debugPrint('[AuthService] checkSubscription result: $result');
    // -------------------------------------------------------------------

    // Bail out for known backend-auth failures BEFORE doing any
    // loose substring matching on statusDetail. Otherwise an E1313
    // message like "There is no active application" would match the
    // word "active" and we'd treat a backend-config error as a real
    // subscription confirmation, letting non-subscribers into the
    // home screen without OTP verification.
    if (_isBackendAuthFailure(result)) {
      return false;
    }

    // Direct field checks (BD Apps camelCase + common fallbacks)
    if (result['isSubscribed'] == true) return true;
    if (result['subscriptionStatus'] == 'active') return true;
    if (result['subscription_status'] == 'active') return true;

    // statusCode starting with 'S' is a BD Apps success code
    final statusCode = result['statusCode']?.toString().toUpperCase() ?? '';
    if (statusCode.isNotEmpty && statusCode.startsWith('S')) return true;

    // statusDetail containing 'active' (loose fallback).
    // We deliberately exclude phrasings that mention "no active"
    // (e.g. "no active application", "no active service provider")
    // — those describe the operator's backend state, not the
    // user's subscription.
    final statusDetail = result['statusDetail']?.toString().toLowerCase() ?? '';
    if (statusDetail.contains('not active')) return false;
    if (statusDetail.contains('no active')) return false;
    if (statusDetail.contains('active')) return true;

    // Nested data envelope (some upstream proxies wrap responses)
    final data = result['data'];
    if (data is Map<String, dynamic>) {
      if (data['isSubscribed'] == true) return true;
      if (data['subscriptionStatus'] == 'active') return true;
      if (data['subscription_status'] == 'active') return true;
      if (data['subscribed'] == true) return true;
      if (data['is_subscribed'] == true) return true;
    }

    // Legacy snake_case fields
    if (result['subscribed'] == true) return true;
    if (result['is_subscribed'] == true) return true;
    if (result['status'] == 'active') return true;
    if (result['active'] == true) return true;

    return false;
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
