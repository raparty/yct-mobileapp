// ─────────────────────────────────────────
// YCT — Reusable error + empty state widgets
// Every screen uses these — never a blank screen
// ─────────────────────────────────────────
import 'package:flutter/material.dart';
import '../core/constants.dart';

/// Full-screen error with retry button
class ErrorView extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;
  final String? title;

  const ErrorView({
    super.key,
    required this.message,
    required this.onRetry,
    this.title,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 72, height: 72,
              decoration: BoxDecoration(
                color: Colors.orange.shade50,
                shape: BoxShape.circle),
              child: Icon(Icons.wifi_off_rounded,
                  color: Colors.orange.shade600, size: 36)),
            const SizedBox(height: 20),
            Text(title ?? 'Could not load content',
              textAlign: TextAlign.center,
              style: const TextStyle(
                  fontSize: 17, fontWeight: FontWeight.w600,
                  color: AppColors.textDark)),
            const SizedBox(height: 10),
            Text(message,
              textAlign: TextAlign.center,
              style: const TextStyle(
                  fontSize: 13, color: AppColors.textLight, height: 1.5)),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh, color: Colors.white, size: 18),
              label: const Text('Try Again',
                  style: TextStyle(color: Colors.white, fontSize: 14)),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                padding: const EdgeInsets.symmetric(
                    horizontal: 28, vertical: 12),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8))),
            ),
          ],
        ),
      ),
    );
  }
}

/// Full-screen loading indicator
class LoadingView extends StatelessWidget {
  final String? message;
  const LoadingView({super.key, this.message});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
        const CircularProgressIndicator(color: AppColors.primary, strokeWidth: 2.5),
        if (message != null) ...[
          const SizedBox(height: 16),
          Text(message!,
            style: const TextStyle(fontSize: 13, color: AppColors.textMid)),
        ],
      ]),
    );
  }
}

/// Empty state — when list has no items
class EmptyView extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final Widget? action;

  const EmptyView({
    super.key,
    required this.icon,
    required this.title,
    required this.subtitle,
    this.action,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
          Container(
            width: 80, height: 80,
            decoration: const BoxDecoration(
                color: AppColors.primaryLight, shape: BoxShape.circle),
            child: Icon(icon, color: AppColors.primary, size: 40)),
          const SizedBox(height: 20),
          Text(title,
            textAlign: TextAlign.center,
            style: const TextStyle(
                fontSize: 17, fontWeight: FontWeight.w600,
                color: AppColors.textDark)),
          const SizedBox(height: 8),
          Text(subtitle,
            textAlign: TextAlign.center,
            style: const TextStyle(
                fontSize: 13, color: AppColors.textLight, height: 1.5)),
          if (action != null) ...[
            const SizedBox(height: 20),
            action!,
          ],
        ]),
      ),
    );
  }
}

/// Slim inline error banner (for partial failures)
class ErrorBanner extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;
  const ErrorBanner({super.key, required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(12),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.orange.shade50,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.orange.shade200)),
      child: Row(children: [
        Icon(Icons.warning_amber_rounded,
            color: Colors.orange.shade600, size: 18),
        const SizedBox(width: 10),
        Expanded(child: Text(message,
          style: TextStyle(fontSize: 12, color: Colors.orange.shade900))),
        TextButton(
          onPressed: onRetry,
          child: const Text('Retry',
            style: TextStyle(fontSize: 12, color: AppColors.primary))),
      ]),
    );
  }
}
