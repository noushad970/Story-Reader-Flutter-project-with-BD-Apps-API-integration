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
      final result = await AuthService.sendOtp(phone);

      if (!mounted) return;

      if (result['success'] == true) {
        final referenceNo = result['referenceNo']?.toString();

        // ======================================================
        // TEST USER
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
      if (!mounted) return;

      setState(() {
        loading = false;
      });
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
      appBar: AppBar(title: const Text('Subscribe')),
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
                'Enter your Bangladesh mobile number to continue with subscription.',
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
                'Subscription charge: ৳2 per day',
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
