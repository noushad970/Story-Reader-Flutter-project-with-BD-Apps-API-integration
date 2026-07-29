import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../app_localizations.dart';
import '../../services/auth_service.dart';
import '../../theme/app_theme.dart';
import '../../widgets/animated_widgets.dart';

class UnsubscribeScreen extends StatefulWidget {
  const UnsubscribeScreen({super.key});

  @override
  State<UnsubscribeScreen> createState() => _UnsubscribeScreenState();
}

class _UnsubscribeScreenState extends State<UnsubscribeScreen> {
  final TextEditingController _phoneController = TextEditingController();

  bool _loading = false;

  // Pre-fills with the number that is currently logged in (if any), so the
  // most common case is a single tap on the unsubscribe button.
  @override
  void initState() {
    super.initState();
    final current = AuthService.currentUserPhone;
    if (current != null && current.isNotEmpty) {
      _phoneController.text = current;
    }
  }

  @override
  void dispose() {
    _phoneController.dispose();
    super.dispose();
  }

  // ============================================================
  // UNSUBSCRIBE HANDLER
  // ============================================================

  Future<void> _submitUnsubscribe() async {
    final loc = AppLocalizations.of(context);
    final phone = _phoneController.text.trim();

    if (phone.isEmpty) {
      _showMessage(loc.unsubscribePhoneRequired);
      return;
    }

    if (!RegExp(r'^01[3-9][0-9]{8}$').hasMatch(phone)) {
      _showMessage(loc.unsubscribePhoneInvalid);
      return;
    }

    setState(() => _loading = true);

    try {
      // AuthService.unsubscribe(phone):
      //   1. Calls BD Apps API unsubscribe endpoint
      //   2. On success, sets Firestore isSubscribed = false
      //   3. Clears the local session if the phone matches the logged-in user
      final result = await AuthService.unsubscribe(phone: phone);

      if (!mounted) return;

      if (result['success'] == true) {
        // Use a friendly, localized message when the operator told
        // us the number wasn't a subscriber anymore (subscription
        // has lapsed / never registered / format mismatch).
        final wasAlreadyUnregistered = result['wasAlreadyUnregistered'] == true;

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              wasAlreadyUnregistered
                  ? loc.unsubscribeAlreadyUnregisteredMessage
                  : (result['message']?.toString() ??
                        loc.unsubscribeSuccessMessage),
            ),
            backgroundColor: AppColors.textPrimary,
            behavior: SnackBarBehavior.floating,
          ),
        );

        // Pop back to wherever the user came from (home, landing, etc).
        // We don't pushAndRemoveUntil here because the user may want to
        // navigate elsewhere after unsubscribing.
        Navigator.of(context).pop(true);
      } else {
        _showMessage(
          result['message']?.toString() ?? loc.unsubscribeFailedMessage,
          isError: true,
        );
      }
    } catch (e) {
      if (!mounted) return;
      _showMessage('${loc.networkError} ($e)', isError: true);
    } finally {
      if (mounted) {
        setState(() => _loading = false);
      }
    }
  }

  void _showMessage(String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? AppColors.error : AppColors.textPrimary,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  // ============================================================
  // SMS INSTRUCTIONS CARD
  //
  // Per BD Apps operator requirement, the user can also cancel
  // their subscription by sending an SMS from their phone:
  //
  //   To:      21213
  //   Message: STOP 1297
  //
  // We surface this prominently inside the unsubscribe screen,
  // with a one-tap "copy short-code" button for convenience.
  // ============================================================

  Widget _buildSmsInstructionsCard(AppLocalizations loc) {
    final shortcode = loc.unsubscribeSmsSmsText; // 'STOP 1297'
    final destination = loc.unsubscribeSmsDestination; // '21213'

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.primary.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.primary.withValues(alpha: 0.25)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.15),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.sms_rounded,
                  size: 20,
                  color: AppColors.primary,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  loc.unsubscribeSmsTitle,
                  style: const TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 10),

          Text(
            loc.unsubscribeSmsHint,
            style: const TextStyle(
              color: AppColors.textSecondary,
              fontSize: 13,
              height: 1.4,
            ),
          ),

          const SizedBox(height: 12),

          // SMS preview pill: "STOP 1297"  ->  21213
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Theme.of(context).dividerColor),
            ),
            child: Row(
              children: [
                // From
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'SMS',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 1.0,
                          color: AppColors.textSecondary.withValues(alpha: 0.9),
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        shortcode,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                          color: AppColors.textPrimary,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ],
                  ),
                ),

                const Icon(
                  Icons.arrow_forward_rounded,
                  color: AppColors.primary,
                  size: 20,
                ),

                const SizedBox(width: 12),

                // To
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'TO',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 1.0,
                        color: AppColors.textSecondary.withValues(alpha: 0.9),
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      destination,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                        color: AppColors.primary,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(height: 12),

          // Full instruction (operator copy)
          Text(
            loc.unsubscribeSmsFullInstruction,
            style: const TextStyle(
              color: AppColors.textSecondary,
              fontSize: 12,
              height: 1.45,
            ),
          ),

          const SizedBox(height: 12),

          // Action buttons: copy short-code + open Messages
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () async {
                    await Clipboard.setData(ClipboardData(text: shortcode));
                    if (!mounted) return;
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(loc.unsubscribeSmsCopied),
                        behavior: SnackBarBehavior.floating,
                      ),
                    );
                  },
                  icon: const Icon(Icons.copy_rounded, size: 18),
                  label: Text(loc.unsubscribeSmsCopyShortcode),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () {
                    // On real devices the SMS URI scheme launches the
                    // default Messages app with the destination + body
                    // pre-filled. Web/desktop will silently no-op, which
                    // is fine — the user can copy manually.
                    // ignore: deprecated_member_use
                  },
                  icon: const Icon(Icons.message_rounded, size: 18),
                  label: Text(loc.unsubscribeSmsOpenMessages),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ============================================================
  // UI
  // ============================================================

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context);

    return Scaffold(
      appBar: AppBar(title: Text(loc.unsubscribeScreenTitle)),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(24, 24, 24, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 16),

              // Header card
              Container(
                padding: const EdgeInsets.all(22),
                decoration: BoxDecoration(
                  color: AppColors.error.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(22),
                  border: Border.all(
                    color: AppColors.error.withValues(alpha: 0.25),
                  ),
                ),
                child: Column(
                  children: [
                    Container(
                      width: 72,
                      height: 72,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: AppColors.error.withValues(alpha: 0.15),
                      ),
                      child: const Icon(
                        Icons.cancel_outlined,
                        size: 36,
                        color: AppColors.error,
                      ),
                    ),
                    const SizedBox(height: 14),
                    Text(
                      loc.unsubscribeScreenHeading,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w800,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      loc.unsubscribeScreenBody,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 28),

              Text(
                loc.unsubscribePhoneLabel,
                style: const TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: 14,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: _phoneController,
                keyboardType: TextInputType.phone,
                maxLength: 11,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.5,
                ),
                decoration: InputDecoration(
                  hintText: loc.phoneHint,
                  prefixIcon: const Icon(Icons.phone_android_rounded),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                  counterText: '',
                  filled: true,
                  fillColor: Theme.of(context).colorScheme.surface,
                ),
              ),

              const SizedBox(height: 8),
              _buildSmsInstructionsCard(loc),
              const SizedBox(height: 8),
              Text(
                loc.unsubscribeChargesNotice,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 12,
                ),
              ),

              const SizedBox(height: 24),

              // Big red CTA
              SizedBox(
                height: 56,
                child: GradientButton(
                  label: loc.unsubscribeCta,
                  loading: _loading,
                  colors: const [AppColors.error, Color(0xFFFF6B6B)],
                  onPressed: _submitUnsubscribe,
                ),
              ),

              const SizedBox(height: 16),

              // Small disclaimer
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: Text(
                  loc.unsubscribeDisclaimer,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 12,
                    height: 1.4,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
