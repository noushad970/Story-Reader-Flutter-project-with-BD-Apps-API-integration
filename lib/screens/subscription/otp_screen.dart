import 'package:flutter/material.dart';

import '../../services/auth_service.dart';
import '../../theme/app_theme.dart';
import '../../widgets/animated_widgets.dart';
import '../user/home_screen.dart';

class OtpScreen extends StatefulWidget {
  final String phone;
  final String referenceNo;

  const OtpScreen({super.key, required this.phone, required this.referenceNo});

  @override
  State<OtpScreen> createState() => _OtpScreenState();
}

class _OtpScreenState extends State<OtpScreen> {
  final TextEditingController otpController = TextEditingController();
  bool loading = false;

  Future<void> verifyOtp() async {
    final otp = otpController.text.trim();
    if (otp.isEmpty) {
      showMessage('Please enter the OTP');
      return;
    }

    setState(() => loading = true);
    final result = await AuthService.verifyOtp(
      phone: widget.phone,
      otp: otp,
      referenceNo: widget.referenceNo,
    );
    if (!mounted) return;
    setState(() => loading = false);

    if (result['success'] == true) {
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => const HomeScreen()),
        (route) => false,
      );
    } else {
      showMessage(result['message']?.toString() ?? 'OTP verification failed');
    }
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
        title: const Text('Verify OTP'),
        flexibleSpace: Container(
          decoration: const BoxDecoration(gradient: AppGradients.sunset),
        ),
        foregroundColor: Colors.white,
        iconTheme: const IconThemeData(color: Colors.white),
        titleTextStyle: const TextStyle(
          color: Colors.white,
          fontSize: 20,
          fontWeight: FontWeight.w800,
        ),
      ),
      body: Stack(
        children: [
          const Positioned.fill(
            child: AnimatedGradientBackground(
              colors: AppColors.softBackground,
              child: SizedBox.expand(),
            ),
          ),
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(24, 80, 24, 24),
              child: Column(
                children: [
                  FadeInUp(
                    delay: const Duration(milliseconds: 80),
                    child: Container(
                      width: 110,
                      height: 110,
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: AppColors.heroGradient,
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.accent.withValues(alpha: 0.35),
                            blurRadius: 28,
                            offset: const Offset(0, 12),
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.verified_user_rounded,
                        color: Colors.white,
                        size: 52,
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  FadeInUp(
                    delay: const Duration(milliseconds: 160),
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
                  const SizedBox(height: 8),
                  FadeInUp(
                    delay: const Duration(milliseconds: 240),
                    child: Text(
                      'An OTP has been sent to ${widget.phone}',
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 14,
                        color: AppColors.textSecondary,
                        height: 1.4,
                      ),
                    ),
                  ),
                  const SizedBox(height: 30),
                  FadeInUp(
                    delay: const Duration(milliseconds: 320),
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(22),
                        boxShadow: const [AppShadows.soft],
                      ),
                      padding: const EdgeInsets.all(24),
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
                              fontWeight: FontWeight.w800,
                              letterSpacing: 12,
                              color: AppColors.textPrimary,
                            ),
                            decoration: InputDecoration(
                              hintText: '------',
                              hintStyle: TextStyle(
                                color: AppColors.textSecondary.withValues(
                                  alpha: 0.35,
                                ),
                                letterSpacing: 12,
                                fontWeight: FontWeight.w800,
                              ),
                              counterText: '',
                              contentPadding: const EdgeInsets.symmetric(
                                vertical: 22,
                                horizontal: 12,
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(16),
                                borderSide: const BorderSide(
                                  color: AppColors.primary,
                                  width: 1.6,
                                ),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(16),
                                borderSide: const BorderSide(
                                  color: AppColors.divider,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 22),
                          GradientButton(
                            label: 'VERIFY OTP',
                            icon: Icons.check_rounded,
                            loading: loading,
                            colors: AppColors.primaryGradient,
                            onPressed: loading ? null : verifyOtp,
                          ),
                          const SizedBox(height: 14),
                          TextButton(
                            onPressed: () => Navigator.pop(context),
                            child: const Text(
                              'Change Mobile Number',
                              style: TextStyle(
                                color: AppColors.textSecondary,
                                fontWeight: FontWeight.w600,
                              ),
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
        ],
      ),
    );
  }
}
