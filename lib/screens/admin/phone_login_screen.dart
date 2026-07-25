import 'package:flutter/material.dart';

import '../../services/auth_service.dart';
import '../../theme/app_theme.dart';
import '../../widgets/animated_widgets.dart';
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
    }

    if (!mounted) return;

    setState(() {
      loading = false;
    });
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
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.85),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.arrow_back_rounded,
              color: AppColors.textPrimary,
              size: 20,
            ),
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Subscribe',
          style: TextStyle(
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary,
          ),
        ),
      ),
      body: AnimatedGradientBackground(
        colors: const [Color(0xFFF0EEFF), Color(0xFFFFF0F7), Color(0xFFFDF1E6)],
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(24, 80, 24, 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 20),

                FadeInUp(
                  child: Center(
                    child: Container(
                      width: 110,
                      height: 110,
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: AppGradients.ocean,
                        boxShadow: [
                          BoxShadow(
                            color: Color(0x554FACFE),
                            blurRadius: 30,
                            offset: Offset(0, 14),
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.phone_android_rounded,
                        size: 56,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 28),

                FadeInUp(
                  delay: const Duration(milliseconds: 120),
                  child: const Text(
                    'Enter Your Mobile Number',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.w800,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ),

                const SizedBox(height: 12),

                FadeInUp(
                  delay: const Duration(milliseconds: 200),
                  child: Text(
                    'Enter your Bangladesh mobile number to continue with subscription.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 15,
                      height: 1.5,
                    ),
                  ),
                ),

                const SizedBox(height: 32),

                FadeInUp(
                  delay: const Duration(milliseconds: 280),
                  child: GlassCard(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        TextField(
                          controller: phoneController,
                          keyboardType: TextInputType.phone,
                          maxLength: 11,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            letterSpacing: 1.2,
                          ),
                          decoration: InputDecoration(
                            labelText: 'Mobile Number',
                            hintText: '01XXXXXXXXX',
                            prefixIcon: Container(
                              margin: const EdgeInsets.all(8),
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                gradient: AppGradients.primary,
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: const Icon(
                                Icons.phone_rounded,
                                color: Colors.white,
                                size: 18,
                              ),
                            ),
                            counterText: '',
                          ),
                        ),
                        const SizedBox(height: 8),
                        GradientButton(
                          label: 'CONTINUE',
                          icon: Icons.arrow_forward_rounded,
                          loading: loading,
                          colors: AppColors.primaryGradient,
                          onPressed: loading ? null : sendOtp,
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 24),

                FadeInUp(
                  delay: const Duration(milliseconds: 360),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.7),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.info_outline_rounded,
                          color: AppColors.primary,
                          size: 18,
                        ),
                        SizedBox(width: 8),
                        Text(
                          'Subscription charge: ৳2 per day',
                          style: TextStyle(
                            color: AppColors.textPrimary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
