import 'package:flutter/material.dart';

import '../../services/auth_service.dart';
import '../../theme/app_theme.dart';
import '../../widgets/animated_widgets.dart';
import '../user/home_screen.dart';

class OtpVerificationScreen extends StatefulWidget {
  final String phone;
  final String referenceNo;

  const OtpVerificationScreen({
    super.key,
    required this.phone,
    required this.referenceNo,
  });

  @override
  State<OtpVerificationScreen> createState() => _OtpVerificationScreenState();
}

class _OtpVerificationScreenState extends State<OtpVerificationScreen> {
  final TextEditingController otpController = TextEditingController();

  bool loading = false;

  Future<void> verifyOtp() async {
    final otp = otpController.text.trim();

    if (otp.isEmpty) {
      showMessage('Please enter the OTP');
      return;
    }

    setState(() {
      loading = true;
    });

    try {
      final result = await AuthService.verifyOtp(
        phone: widget.phone,
        otp: otp,
        referenceNo: widget.referenceNo,
      );

      if (!mounted) return;

      if (result['success'] == true) {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (_) => const HomeScreen()),
          (route) => false,
        );
      } else {
        showMessage(
          result['message']?.toString() ??
              result['statusDetail']?.toString() ??
              'Invalid OTP',
        );
      }
    } catch (e) {
      if (!mounted) return;

      showMessage('Verification failed: $e');
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
    otpController.dispose();

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
          'Verify OTP',
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
                const SizedBox(height: 30),

                FadeInUp(
                  child: Center(
                    child: Container(
                      width: 110,
                      height: 110,
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: AppGradients.hero,
                        boxShadow: [AppShadows.glow],
                      ),
                      child: const Icon(
                        Icons.verified_user_rounded,
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
                    'Enter OTP',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.w800,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ),

                const SizedBox(height: 10),

                FadeInUp(
                  delay: const Duration(milliseconds: 200),
                  child: Text(
                    'An OTP has been sent to\n${widget.phone}',
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 15,
                      color: AppColors.textSecondary,
                      height: 1.5,
                    ),
                  ),
                ),

                const SizedBox(height: 32),

                FadeInUp(
                  delay: const Duration(milliseconds: 280),
                  child: GlassCard(
                    padding: const EdgeInsets.all(22),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        TextField(
                          controller: otpController,
                          keyboardType: TextInputType.number,
                          maxLength: 6,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontSize: 28,
                            letterSpacing: 12,
                            fontWeight: FontWeight.w800,
                            color: AppColors.textPrimary,
                          ),
                          decoration: InputDecoration(
                            labelText: '6-digit OTP',
                            hintText: '• • • • • •',
                            counterText: '',
                            hintStyle: TextStyle(
                              color: AppColors.textSecondary.withValues(
                                alpha: 0.5,
                              ),
                              letterSpacing: 6,
                            ),
                          ),
                        ),
                        const SizedBox(height: 14),
                        GradientButton(
                          label: 'VERIFY OTP',
                          icon: Icons.check_circle_outline_rounded,
                          loading: loading,
                          colors: AppColors.primaryGradient,
                          onPressed: loading ? null : verifyOtp,
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 20),

                FadeInUp(
                  delay: const Duration(milliseconds: 360),
                  child: Center(
                    child: TextButton.icon(
                      onPressed: loading
                          ? null
                          : () {
                              Navigator.pop(context);
                            },
                      icon: const Icon(
                        Icons.edit_rounded,
                        size: 18,
                        color: AppColors.primary,
                      ),
                      label: const Text(
                        'Change Mobile Number',
                        style: TextStyle(
                          color: AppColors.primary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
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
