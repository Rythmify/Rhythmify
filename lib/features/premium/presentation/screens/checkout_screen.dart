import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../providers/premium_provider.dart';
import '../widgets/premium_widgets.dart';

class CheckoutScreen extends ConsumerStatefulWidget {
  final int planId;
  const CheckoutScreen({super.key, required this.planId});

  @override
  ConsumerState<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends ConsumerState<CheckoutScreen> {
  @override
  void initState() {
    super.initState();
    // Clear any previous success flag when screen opens
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(premiumProvider.notifier).clearCheckoutSuccess();
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(premiumProvider);

    // Navigate back with success once checkout completes
    ref.listen<PremiumState>(premiumProvider, (_, next) {
      if (next.checkoutSuccess) {
        _showSuccessSheet(context);
      }
    });

    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      appBar: AppBar(
        backgroundColor: const Color(0xFF121212),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Upgrade to Premium',
          style: GoogleFonts.inter(
            fontSize: 18,
            fontWeight: FontWeight.w800,
            color: Colors.white,
          ),
        ),
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.fromLTRB(20, 24, 20, 40),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Plan summary card
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: const Color(0xFF1E1E1E),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      PremiumTag(
                        label: '★ PREMIUM',
                        bg: const Color(0xFF2E2E2E),
                        textColor: Colors.white,
                      ),
                      const Spacer(),
                      Text(
                        '\$4.99/month',
                        style: GoogleFonts.inter(
                          fontSize: 18,
                          fontWeight: FontWeight.w900,
                          color: const Color(0xFFFF5500),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  ...[
                    'Unlimited track uploads',
                    'Unlimited playlists',
                    'Offline listening',
                    'No ads',
                    'Priority support',
                  ].map(
                    (f) => Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.check_circle,
                            color: Color(0xFFFF5500),
                            size: 20,
                          ),
                          const SizedBox(width: 12),
                          Text(
                            f,
                            style: GoogleFonts.inter(
                              fontSize: 14,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            Text(
              'Billed monthly. Cancel anytime.',
              style: GoogleFonts.inter(fontSize: 13, color: Colors.white54),
            ),
            const SizedBox(height: 6),
            BlueLink(
              label: 'Restrictions apply',
              onTap: () => showRestrictionsSheet(context),
            ),

            const Spacer(),

            if (state.error != null)
              Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: Text(
                  state.error!,
                  style: GoogleFonts.inter(
                    fontSize: 13,
                    color: Colors.redAccent,
                  ),
                ),
              ),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFFF5500),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(32),
                  ),
                  elevation: 0,
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
                          strokeWidth: 2,
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

            // Bottom player clearance
            const SizedBox(height: 80),
          ],
        ),
      ),
    );
  }
}

// ── Success sheet shown after payment ────────────────────────────────────────

void _showSuccessSheet(BuildContext context) {
  showModalBottomSheet(
    context: context,
    isDismissible: false,
    enableDrag: false,
    backgroundColor: Colors.transparent,
    builder: (_) => const _SuccessSheet(),
  );
}

class _SuccessSheet extends StatelessWidget {
  const _SuccessSheet();

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
          const SizedBox(height: 36),
          const Text('🎉', style: TextStyle(fontSize: 56)),
          const SizedBox(height: 20),
          Text(
            "You're now Premium!",
            style: GoogleFonts.inter(
              fontSize: 24,
              fontWeight: FontWeight.w900,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Your subscription is active.\nEnjoy unlimited uploads and more.',
            textAlign: TextAlign.center,
            style: GoogleFonts.inter(
              fontSize: 14,
              color: Colors.white60,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 36),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFFF5500),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(32),
                ),
                elevation: 0,
              ),
              onPressed: () {
                Navigator.pop(context); // close sheet
                Navigator.pop(context); // close checkout screen
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
