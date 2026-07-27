import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../app_localizations.dart';
import '../services/locale_provider.dart';

/// A small icon button that toggles between English and Bangla.
class LanguageToggleButton extends StatelessWidget {
  const LanguageToggleButton({super.key});

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context);
    final provider = context.watch<LocaleProvider>();
    final scheme = Theme.of(context).colorScheme;

    return IconButton(
      tooltip: loc.tooltipLanguage,
      onPressed: () => context.read<LocaleProvider>().toggle(),
      icon: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        decoration: BoxDecoration(
          color: scheme.surface,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: scheme.outlineVariant),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.language_rounded,
              size: 16,
              color: scheme.primary,
            ),
            const SizedBox(width: 4),
            Text(
              provider.isBangla ? 'EN' : 'BN',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: scheme.primary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}