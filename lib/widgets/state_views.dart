import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

/// Tampilan state loading bergaya minimalis.
class MinimalLoadingView extends StatelessWidget {
  final String message;

  const MinimalLoadingView({
    super.key,
    this.message = 'MEMUAT DATA CUACA...',
  });

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(
              width: 30,
              height: 30,
              child: CircularProgressIndicator(
                strokeWidth: 1.5,
                color: AppTheme.inkPrimary,
              ),
            ),
            const SizedBox(height: 20),
            Text(
              message,
              style: textTheme.bodySmall?.copyWith(
                letterSpacing: 2.2,
                color: AppTheme.inkSecondary,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

/// Tampilan state kosong bergaya minimalis.
class MinimalEmptyView extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;

  const MinimalEmptyView({
    super.key,
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 36, color: AppTheme.inkMuted),
            const SizedBox(height: 16),
            Text(
              title,
              style: textTheme.labelLarge?.copyWith(
                letterSpacing: 2.0,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              subtitle,
              style: textTheme.bodySmall,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

/// Tampilan state error dengan tombol Coba Lagi.
class MinimalErrorView extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const MinimalErrorView({
    super.key,
    required this.message,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.cloud_off_outlined,
              size: 40,
              color: AppTheme.errorColor,
            ),
            const SizedBox(height: 16),
            Text(
              'TERJADI KESALAHAN',
              style: textTheme.labelLarge?.copyWith(
                color: AppTheme.inkPrimary,
                letterSpacing: 2.2,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              message,
              style: textTheme.bodySmall,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            OutlinedButton(
              onPressed: onRetry,
              style: OutlinedButton.styleFrom(
                foregroundColor: AppTheme.inkPrimary,
                side: const BorderSide(color: AppTheme.inkPrimary, width: 1),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(24),
                ),
                padding: const EdgeInsets.symmetric(
                  horizontal: 28,
                  vertical: 12,
                ),
              ),
              child: Text(
                'COBA LAGI',
                style: textTheme.labelLarge?.copyWith(
                  fontSize: 12,
                  letterSpacing: 2.0,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
