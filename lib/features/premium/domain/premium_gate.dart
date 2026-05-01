import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

/// A UI-level helper class responsible for handling subscription-related
/// access restrictions in a centralized way.
///
/// This class detects backend subscription limit errors and displays a
/// consistent upgrade prompt across the entire app.
///
/// Backend Contract:
/// - HTTP 403 with:
///   { "error": { "code": "SUBSCRIPTION_LIMIT_REACHED" } }
///
/// Responsibilities:
/// - Detect subscription limit errors from DioException
/// - Show upgrade bottom sheet when limit is reached
/// - Route user to upgrade screen when needed
/// - Provide a single reusable error handler for all features
///
/// Usage Pattern:
/// Call inside any onError block:
///
///   PremiumGate.handleError(context, error);
///
/// Behavior:
/// - Returns true → handled as subscription error (UI shown)
/// - Returns false → not subscription-related, handle normally
///
/// UI Component:
/// - Displays a bottom sheet explaining the limit
/// - Shows benefits of premium subscription
/// - Navigates to /upgrade route when user taps "See plans"
///
/// Notes:
/// - This class does NOT perform API calls
/// - It is strictly a UI + error interpretation layer
/// - Keeps feature modules free from duplicated subscription logic

// ─────────────────────────────────────────────────────────────────────────────
// PREMIUM GATE
//
// The backend already enforces limits and returns:
//   HTTP 403 + body: { "error": { "code": "SUBSCRIPTION_LIMIT_REACHED" } }
//
// All you do in any feature is call:
//   PremiumGate.handleError(context, error);
//
// inside your existing onError callback. If the error is a subscription limit,
// it shows the upgrade prompt. Otherwise it returns false and you show your
// normal error message.
//
// ─────────────────────────────────────────────────────────────────────────────

class PremiumGate {
  PremiumGate._();

  // ── Main entry point ───────────────────────────────────────────────────────
  // Call this inside any onError callback.
  // Returns true  → error was a subscription limit, upgrade prompt shown.
  // Returns false → not a subscription error, handle it yourself.
  static bool handleError(BuildContext context, Object error) {
    if (_isSubscriptionLimit(error)) {
      showUpgradePrompt(context);
      return true;
    }
    return false;
  }

  // ── Detects SUBSCRIPTION_LIMIT_REACHED from a Dio 403 ─────────────────────
  static bool _isSubscriptionLimit(Object error) {
    if (error is DioException) {
      final statusCode = error.response?.statusCode;
      if (statusCode == 403) {
        final data = error.response?.data;
        if (data is Map) {
          final code = data['error']?['code'] as String?;
          return code == 'SUBSCRIPTION_LIMIT_REACHED';
        }
      }
    }
    // Also handle if error was already converted to a string
    return error.toString().contains('SUBSCRIPTION_LIMIT_REACHED');
  }

  // ── Shows the upgrade bottom sheet ────────────────────────────────────────
  static void showUpgradePrompt(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => const _UpgradePromptSheet(),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// UPGRADE PROMPT SHEET
// ─────────────────────────────────────────────────────────────────────────────

class _UpgradePromptSheet extends StatelessWidget {
  const _UpgradePromptSheet();

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Color(0xFF1A1A1A),
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      padding: EdgeInsets.fromLTRB(
        24,
        16,
        24,
        32 + MediaQuery.of(context).padding.bottom,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Handle
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.white24,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 24),

          // Lock icon
          Container(
            width: 56,
            height: 56,
            decoration: const BoxDecoration(
              color: Color(0xFF2A2A2A),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.lock_outline,
              color: Color(0xFFFF5500),
              size: 26,
            ),
          ),
          const SizedBox(height: 16),

          Text(
            'Upgrade to Premium',
            style: GoogleFonts.inter(
              fontSize: 20,
              fontWeight: FontWeight.w900,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            "You've reached the limit of your free plan.",
            textAlign: TextAlign.center,
            style: GoogleFonts.inter(
              fontSize: 14,
              color: Colors.white60,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 16),

          // What they unlock
          ...[
            'Unlimited track uploads',
            'Unlimited playlists',
            'Download tracks for offline listening',
          ].map(
            (f) => Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Row(
                children: [
                  const Icon(Icons.check, color: Color(0xFFFF5500), size: 16),
                  const SizedBox(width: 10),
                  Text(
                    f,
                    style: GoogleFonts.inter(fontSize: 14, color: Colors.white),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),

          // See plans button
          SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFFF5500),
                foregroundColor: Colors.white,
                elevation: 0,
                shape: const StadiumBorder(),
              ),
              onPressed: () {
                Navigator.pop(context);
                context.go('/upgrade');
              },
              child: Text(
                'See plans',
                style: GoogleFonts.inter(
                  fontWeight: FontWeight.w700,
                  fontSize: 15,
                ),
              ),
            ),
          ),
          const SizedBox(height: 8),

          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Not now',
              style: GoogleFonts.inter(fontSize: 14, color: Colors.white38),
            ),
          ),
        ],
      ),
    );
  }
}
