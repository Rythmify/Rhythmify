import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'premium_widgets.dart';

// ─────────────────────────────────────────────────────────────────────────────
// HERO SECTION  (PDF page 1)
// ─────────────────────────────────────────────────────────────────────────────

class HeroSection extends StatelessWidget {
  final bool isPremium;
  final String? endDate;
  final VoidCallback onContinue;
  final VoidCallback onSeeAllPlans;
  final VoidCallback onCancel;

  const HeroSection({
    super.key,
    required this.isPremium,
    required this.endDate,
    required this.onContinue,
    required this.onSeeAllPlans,
    required this.onCancel,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: MediaQuery.of(context).size.height,
      child: Stack(
        children: [
          // Artist photo — swap Container with Image.asset when you have the file
          Positioned(
            top: 60,
            left: 0,
            right: 0,
            child: Center(
              child: Transform.rotate(
                angle: 0.03,
                child: Container(
                  width: 260,
                  height: 320,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(4),
                    gradient: const LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [Color(0xFF5C3A10), Color(0xFF1A1000)],
                    ),
                    boxShadow: const [
                      BoxShadow(
                        color: Colors.black54,
                        blurRadius: 40,
                        offset: Offset(0, 20),
                      ),
                    ],
                  ),
                  child: const Center(
                    child: Icon(
                      Icons.music_note,
                      color: Color(0xFFFF5500),
                      size: 64,
                    ),
                  ),
                ),
              ),
            ),
          ),
          // Bottom gradient fade
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            height: 360,
            child: Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.transparent,
                    Color(0xD9121212),
                    Color(0xFF121212),
                  ],
                ),
              ),
            ),
          ),
          // CTA overlay
          Positioned(
            bottom: 100,
            left: 20,
            right: 20,
            child: isPremium
                ? ActivePremiumInfo(endDate: endDate, onCancel: onCancel)
                : UpsellContent(
                    onContinue: onContinue,
                    onSeeAllPlans: onSeeAllPlans,
                  ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// UPSELL CONTENT  (shown when user is on free plan)
// ─────────────────────────────────────────────────────────────────────────────

class UpsellContent extends StatelessWidget {
  final VoidCallback onContinue;
  final VoidCallback onSeeAllPlans;
  const UpsellContent({
    super.key,
    required this.onContinue,
    required this.onSeeAllPlans,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            PremiumTag(
              label: '★ PREMIUM',
              bg: const Color(0xFF1E1E1E),
              textColor: Colors.white,
            ),
            const SizedBox(width: 8),
            PremiumTag(
              label: 'FOR YOU',
              bg: const Color(0xFF2F80ED),
              textColor: Colors.white,
            ),
          ],
        ),
        const SizedBox(height: 16),
        Text(
          'Unlock unlimited\nuploads &\nmore.',
          style: GoogleFonts.inter(
            fontSize: 38,
            fontWeight: FontWeight.w900,
            color: Colors.white,
            height: 1.1,
            letterSpacing: -1,
          ),
        ),
        const SizedBox(height: 12),
        Text(
          '\$4.99/month. Cancel anytime.',
          style: GoogleFonts.inter(fontSize: 14, color: Colors.white70),
        ),
        BlueLink(
          label: 'Restrictions apply.',
          onTap: () => showRestrictionsSheet(context),
        ),
        const SizedBox(height: 28),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white,
              foregroundColor: Colors.black,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(32),
              ),
              elevation: 0,
            ),
            onPressed: onContinue,
            child: Text(
              'Continue',
              style: GoogleFonts.inter(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.black,
              ),
            ),
          ),
        ),
        const SizedBox(height: 16),
        Center(
          child: GestureDetector(
            onTap: onSeeAllPlans,
            child: Text(
              'See all plans',
              style: GoogleFonts.inter(
                fontSize: 15,
                color: Colors.white,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// ACTIVE PREMIUM INFO  (shown when user already has premium)
// ─────────────────────────────────────────────────────────────────────────────

class ActivePremiumInfo extends StatelessWidget {
  final String? endDate;
  final VoidCallback onCancel;
  const ActivePremiumInfo({super.key, this.endDate, required this.onCancel});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        PremiumTag(
          label: '★ PREMIUM ACTIVE',
          bg: const Color(0xFFFF5500),
          textColor: Colors.white,
        ),
        const SizedBox(height: 16),
        Text(
          "You're Premium!",
          style: GoogleFonts.inter(
            fontSize: 32,
            fontWeight: FontWeight.w900,
            color: Colors.white,
          ),
        ),
        if (endDate != null) ...[
          const SizedBox(height: 8),
          Text(
            'Active until $endDate',
            style: GoogleFonts.inter(fontSize: 14, color: Colors.white70),
          ),
        ],
        const SizedBox(height: 28),
        GestureDetector(
          onTap: onCancel,
          child: Text(
            'Cancel subscription',
            style: GoogleFonts.inter(
              fontSize: 15,
              color: Colors.white54,
              decoration: TextDecoration.underline,
              decorationColor: Colors.white54,
            ),
          ),
        ),
      ],
    );
  }
}
