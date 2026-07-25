import 'package:flutter/material.dart';

import '../../services/auth_service.dart';
import '../../theme/app_theme.dart';
import '../../widgets/animated_widgets.dart';
import 'otp_screen.dart';

class SubscriptionScreen extends StatefulWidget {
  const SubscriptionScreen({super.key});

  @override
  State<SubscriptionScreen> createState() => _SubscriptionScreenState();
}

class _SubscriptionScreenState extends State<SubscriptionScreen> {
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

    setState(() => loading = true);
    final result = await AuthService.sendOtp(phone);
    if (!mounted) return;
    setState(() => loading = false);

    if (result['success'] == true) {
      final referenceNo = result['referenceNo']?.toString();
      if (referenceNo == null || referenceNo.isEmpty) {
        showMessage('Reference number was not received');
        return;
      }
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => OtpScreen(phone: phone, referenceNo: referenceNo),
        ),
      );
    } else {
      showMessage(result['message']?.toString() ?? 'OTP request failed');
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
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text('Subscription'),
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
                      width: 120,
                      height: 120,
                      decoration: const BoxDecoration(
                        gradient: AppGradients.sunset,
                        shape: BoxShape.circle,
                        boxShadow: [AppShadows.glow],
                      ),
                      child: const Icon(
                        Icons.phone_android_rounded,
                        color: Colors.white,
                        size: 56,
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  FadeInUp(
                    delay: const Duration(milliseconds: 160),
                    child: const Text(
                      'Subscribe for ৳2 per day',
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
                    child: const Text(
                      'Enter your Bangladesh mobile number to continue with subscription.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
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
                      padding: const EdgeInsets.all(22),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: AppColors.sunsetGradient,
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(22),
                        boxShadow: const [AppShadows.glow],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 6,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.white.withValues(alpha: 0.25),
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: const Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      Icons.bolt_rounded,
                                      color: Colors.white,
                                      size: 14,
                                    ),
                                    SizedBox(width: 4),
                                    Text(
                                      'PREMIUM',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 11,
                                        fontWeight: FontWeight.w800,
                                        letterSpacing: 0.6,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const Spacer(),
                              const Text(
                                '৳2',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 28,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                              const SizedBox(width: 4),
                              const Text(
                                '/ day',
                                style: TextStyle(
                                  color: Colors.white70,
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          const Text(
                            'Unlimited access to all stories & categories',
                            style: TextStyle(color: Colors.white, fontSize: 14),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 22),
                  FadeInUp(
                    delay: const Duration(milliseconds: 400),
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: const [AppShadows.soft],
                      ),
                      padding: const EdgeInsets.all(22),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          TextField(
                            controller: phoneController,
                            keyboardType: TextInputType.phone,
                            maxLength: 11,
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 1.2,
                              color: AppColors.textPrimary,
                            ),
                            decoration: InputDecoration(
                              labelText: 'Mobile Number',
                              hintText: '018XXXXXXXX',
                              prefixIcon: Container(
                                margin: const EdgeInsets.all(8),
                                width: 36,
                                height: 36,
                                decoration: BoxDecoration(
                                  gradient: AppGradients.ocean,
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: const Icon(
                                  Icons.phone_iphone_rounded,
                                  color: Colors.white,
                                  size: 18,
                                ),
                              ),
                              prefixIconConstraints: const BoxConstraints(
                                minWidth: 0,
                                minHeight: 0,
                              ),
                              counterText: '',
                            ),
                          ),
                          const SizedBox(height: 18),
                          GradientButton(
                            label: 'SEND OTP',
                            icon: Icons.arrow_forward_rounded,
                            loading: loading,
                            colors: AppColors.primaryGradient,
                            onPressed: loading ? null : sendOtp,
                          ),
                          const SizedBox(height: 12),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.info_outline_rounded,
                                size: 14,
                                color: AppColors.textSecondary,
                              ),
                              const SizedBox(width: 6),
                              Flexible(
                                child: Text(
                                  'OTP charges may apply',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: AppColors.textSecondary,
                                  ),
                                ),
                              ),
                            ],
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
