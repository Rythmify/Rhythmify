/// Handles subscription payment confirmation flow.
///
/// Responsibilities:
/// - Shows selected plan summary (price + features)
/// - Simulates payment UI (mock Stripe)
/// - Triggers checkout via PremiumNotifier
/// - Displays success sheet on completion
///
/// Flow:
/// Confirm → checkout API → mock confirm → refresh subscription → success UI
///
/// UI states:
/// - Loading: disables button + shows spinner
/// - Error: shows payment error message
/// - Success: triggers success bottom sheet
///
/// Notes:
/// - Uses mock payment flow (no real gateway)
/// - Plan data is passed from previous screen
library;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';
import '../providers/premium_provider.dart';

/// Shown after the user taps "Subscribe now" on any plan card.
/// Simulates a Stripe checkout:
///   1. User reviews the plan summary.
///   2. Taps "Confirm Payment".
///   3. App calls POST /subscriptions/checkout → POST /subscriptions/mock-confirm.
///   4. On success → success sheet → back to upgrade screen.
///
/// Usage (from upgrade_screen.dart):
///   Navigator.push(context, MaterialPageRoute(
///     builder: (_) => CheckoutScreen(planId: p.planId, planName: p.name, price: p.price),
///   ));

class CheckoutScreen extends ConsumerStatefulWidget {
  final String planId; // UUID from GET /subscriptions/plans
  final String planName;
  final String price;
  final List<String> features;

  const CheckoutScreen({
    super.key,
    required this.planId, // UUID string
    required this.planName,
    required this.price,
    required this.features,
  });

  @override
  ConsumerState<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends ConsumerState<CheckoutScreen> {
  @override
  void initState() {
    super.initState();
    // Clear any stale success flag from a previous checkout
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(premiumProvider.notifier).clearCheckoutSuccess();
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(premiumProvider);
    final botPad = MediaQuery.of(context).padding.bottom;

    // Navigate to success sheet when checkout completes
    ref.listen<PremiumState>(premiumProvider, (_, next) {
      if (next.checkoutSuccess && mounted) {
        _showSuccessSheet(context);
      }
    });

    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      appBar: AppBar(
        backgroundColor: const Color(0xFF121212),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new,
            color: Colors.white,
            size: 18,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Complete your order',
          style: GoogleFonts.inter(
            fontSize: 17,
            fontWeight: FontWeight.w700,
            color: Colors.white,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.fromLTRB(20, 16, 20, 24 + botPad),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Plan summary card ─────────────────────────────────────
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(18),
              decoration: const BoxDecoration(color: Color(0xFF1E1E1E)),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Plan name + price row
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        widget.planName,
                        style: GoogleFonts.inter(
                          fontSize: 18,
                          fontWeight: FontWeight.w900,
                          color: Colors.white,
                        ),
                      ),
                      Text(
                        widget.price,
                        style: GoogleFonts.inter(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: const Color(0xFFFF5500),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  const Divider(color: Colors.white12),
                  const SizedBox(height: 12),

                  // Feature list
                  ...widget.features.map(
                    (f) => Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Icon(
                            Icons.check_circle_outline,
                            color: Color(0xFFFF5500),
                            size: 17,
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              f,
                              style: GoogleFonts.inter(
                                fontSize: 13,
                                color: Colors.white,
                                height: 1.4,
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
            const SizedBox(height: 20),

            // ── Billing note ──────────────────────────────────────────
            Text(
              'Billed automatically. Cancel anytime from Account Settings.',
              style: GoogleFonts.inter(
                fontSize: 12,
                color: Colors.white54,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 6),

            // ── Simulated payment method (mock Stripe) ────────────────
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.white12),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.credit_card,
                    color: Colors.white54,
                    size: 20,
                  ),
                  const SizedBox(width: 12),
                  Text(
                    '•••• •••• •••• 4242',
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      color: Colors.white70,
                    ),
                  ),
                  const Spacer(),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 3,
                    ),
                    color: const Color(0xFF2A2A2A),
                    child: Text(
                      'TEST',
                      style: GoogleFonts.inter(
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        color: Colors.white38,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // ── Error message ─────────────────────────────────────────
            if (state.error != null) ...[
              Container(
                padding: const EdgeInsets.all(12),
                color: const Color(0xFF2A0000),
                child: Row(
                  children: [
                    const Icon(
                      Icons.error_outline,
                      color: Colors.redAccent,
                      size: 16,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Payment failed. Please try again.',
                        style: GoogleFonts.inter(
                          fontSize: 13,
                          color: Colors.redAccent,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 14),
            ],

            // ── Confirm payment button ────────────────────────────────
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFFF5500),
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: const StadiumBorder(),
                  disabledBackgroundColor: const Color(
                    0xFFFF5500,
                  ).withValues(alpha: 0.4),
                ),
                onPressed: state.isCheckingOut
                    ? null
                    : () => ref
                          .read(premiumProvider.notifier)
                          .checkout(widget.planId),
                child: state.isCheckingOut
                    ? const SizedBox(
                        width: 22,
                        height: 22,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2.5,
                        ),
                      )
                    : Text(
                        'Confirm Payment',
                        style: GoogleFonts.inter(
                          fontWeight: FontWeight.w700,
                          fontSize: 16,
                        ),
                      ),
              ),
            ),
            const SizedBox(height: 12),

            Center(
              child: Text(
                'Secured by Stripe · Mock mode',
                style: GoogleFonts.inter(fontSize: 11, color: Colors.white24),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// SUCCESS SHEET
// ─────────────────────────────────────────────────────────────────────────────

void _showSuccessSheet(BuildContext context) {
  // Capture the router before showing the sheet — the sheet's BuildContext
  // won't have access to the shell navigator otherwise
  final router = GoRouter.of(context);
  showModalBottomSheet(
    context: context,
    isDismissible: false,
    enableDrag: false,
    backgroundColor: Colors.transparent,
    builder: (_) => _SuccessSheet(router: router),
  );
}

class _SuccessSheet extends StatelessWidget {
  final GoRouter router;
  const _SuccessSheet({required this.router});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Color(0xFF1A1A1A),
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      padding: const EdgeInsets.fromLTRB(24, 20, 24, 48),
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
          const SizedBox(height: 32),
          const Text('🎉', style: TextStyle(fontSize: 52)),
          const SizedBox(height: 18),
          Text(
            "You're now Premium!",
            style: GoogleFonts.inter(
              fontSize: 24,
              fontWeight: FontWeight.w900,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            'Upload unlimited tracks, create unlimited playlists,\nand download music for offline listening.',
            textAlign: TextAlign.center,
            style: GoogleFonts.inter(
              fontSize: 13,
              color: Colors.white60,
              height: 1.6,
            ),
          ),
          const SizedBox(height: 32),
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
                // Close sheet + checkout screen, then navigate to upgrade tab
                // popUntil root, then go to /upgrade which shows CancellationScreen
                Navigator.of(
                  context,
                  rootNavigator: true,
                ).popUntil((route) => route.isFirst);
                router.go('/upgrade');
              },
              child: Text(
                'Start exploring',
                style: GoogleFonts.inter(
                  fontWeight: FontWeight.w700,
                  fontSize: 16,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
