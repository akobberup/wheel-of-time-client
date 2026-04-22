import 'dart:io';

import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../l10n/app_strings.dart';

/// Blokerende skærm der vises når klient-versionen er for gammel.
/// Tilbyder at åbne butikken så brugeren kan opdatere.
class UpdateRequiredScreen extends StatelessWidget {
  static const String _playStoreUrl =
      'https://play.google.com/store/apps/details?id=com.aarshjulet.app';
  static const String _appStoreUrl =
      'https://apps.apple.com/app/id0000000000';

  const UpdateRequiredScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final strings = AppStrings.of(context);
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.system_update_alt_rounded,
                size: 72,
                color: colorScheme.primary,
              ),
              const SizedBox(height: 24),
              Text(
                strings.updateRequiredTitle,
                textAlign: TextAlign.center,
                style: theme.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                strings.updateRequiredMessage,
                textAlign: TextAlign.center,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 32),
              FilledButton.icon(
                onPressed: () => _openStore(context),
                icon: const Icon(Icons.open_in_new),
                label: Text(strings.updateRequiredOpenStore),
                style: FilledButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 14,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _openStore(BuildContext context) async {
    final url = Platform.isIOS ? _appStoreUrl : _playStoreUrl;
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(AppStrings.of(context).error)),
      );
    }
  }
}
