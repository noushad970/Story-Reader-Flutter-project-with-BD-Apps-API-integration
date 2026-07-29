import 'package:flutter/material.dart';

import '../../services/auth_service.dart';
import '../user/home_screen.dart';
import 'otp_verification_screen.dart';

class PhoneLoginScreen extends StatefulWidget {
  const PhoneLoginScreen({super.key});

  @override
  State<PhoneLoginScreen> createState() => _PhoneLoginScreenState();
}

class _PhoneLoginScreenState extends State<PhoneLoginScreen> {
  final TextEditingController phoneController = TextEditingController();

  bool loading = false;

  Future<void> sendOtp() async {
    final phone = phoneController.text.trim();

    if (phone.isEmpty) {
      showMessage('Please enter your mobile number');
      return;
    }

    if (!RegExp(r'^01[3-9][0-9]{8}$').hasMatch(phone)) {
      showMessage('Enter a valid Bangladesh mobile number');
      return;
    }

    setState(() {
      loading = true;
    });

    try {
      // ======================================================
      // STEP 1: Ask the BD Apps backend whether this number is
      // already an active subscriber. If yes, sign them in
      // immediately — no OTP needed (they already pay for the
      // service).
      // ======================================================

      final loginResult = await AuthService.loginIfSubscribed(phone);

      if (!mounted) return;

      if (loginResult['success'] == true) {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (_) => const HomeScreen()),
          (route) => false,
        );
        return;
      }

      // ======================================================
      // STEP 2: NOT an active subscriber.
      //
      // They MUST verify with OTP before they can read stories.
      // We send the OTP now and hand the user off to the OTP
      // screen. Even if the backend later calls the number
      // "already registered" (E1336 — a lapsed/former
      // subscriber), they still need to complete OTP to
      // re-activate the subscription with the operator.
      //
      // We do NOT auto-open a local account here. Doing so
      // would let non-subscribers into the home screen without
      // paying, which defeats the point of the BD Apps
      // subscription gate.
      // ======================================================

      final result = await AuthService.sendOtp(phone);

      if (!mounted) return;

      // If the operator reports the number is "already
      // registered" (lapsed subscriber), we surface a friendlier
      // hint on the OTP screen via a SnackBar — but we still
      // require the user to enter the OTP that was just sent.
      if (AuthService.isAlreadyRegisteredError(result)) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'This number has subscribed before. Please enter the OTP '
              'we just sent to re-activate your subscription.',
            ),
          ),
        );
      }

      if (result['success'] == true) {
        final referenceNo = result['referenceNo']?.toString();

        // ======================================================
        // TEST USER (no real OTP, jump straight in)
        // ======================================================

        if (phone == AuthService.testMobileNumber) {
          final verifyResult = await AuthService.verifyOtp(
            phone: phone,
            otp: 'TEST',
            referenceNo: referenceNo ?? 'TEST_REFERENCE',
          );

          if (!mounted) return;

          if (verifyResult['success'] == true) {
            Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(builder: (_) => const HomeScreen()),
              (route) => false,
            );

            return;
          }
        }

        // ======================================================
        // NORMAL USER
        // ======================================================

        if (referenceNo == null || referenceNo.isEmpty) {
          showMessage('Reference number was not returned');
          return;
        }

        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) =>
                OtpVerificationScreen(phone: phone, referenceNo: referenceNo),
          ),
        );
      } else {
        showMessage(result['message']?.toString() ?? 'Failed to send OTP');
      }
    } catch (e) {
      if (!mounted) return;

      showMessage('Something went wrong: $e');
    } finally {
      if (mounted) {
        setState(() {
          loading = false;
        });
      }
    }
  }

  void showMessage(String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  void dispose() {
    phoneController.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Login / Subscribe')),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 40),

              const Icon(Icons.phone_android, size: 80),

              const SizedBox(height: 24),

              const Text(
                'Enter Your Mobile Number',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
              ),

              const SizedBox(height: 12),

              Text(
                'Subscribers will be signed in automatically. New users will be guided through subscription.',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey.shade700, fontSize: 16),
              ),

              const SizedBox(height: 40),

              TextField(
                controller: phoneController,
                keyboardType: TextInputType.phone,
                maxLength: 11,
                decoration: const InputDecoration(
                  labelText: 'Mobile Number',
                  hintText: '01812345678',
                  prefixIcon: Icon(Icons.phone),
                  border: OutlineInputBorder(),
                  counterText: '',
                ),
              ),

              const SizedBox(height: 24),

              SizedBox(
                height: 54,
                child: ElevatedButton(
                  onPressed: loading ? null : sendOtp,
                  child: loading
                      ? const SizedBox(
                          height: 24,
                          width: 24,
                          child: CircularProgressIndicator(),
                        )
                      : const Text(
                          'CONTINUE',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                ),
              ),

              const SizedBox(height: 24),

              const Text(
                'New users: subscription charge is ৳2 per day',
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
