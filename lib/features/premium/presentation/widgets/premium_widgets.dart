import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'premium_legal.dart';

// ─────────────────────────────────────────────────────────────────────────────
// TAG CHIP
// ─────────────────────────────────────────────────────────────────────────────

class PremiumTag extends StatelessWidget {
  final String label;
  final Color bg;
  final Color textColor;

  const PremiumTag({super.key, required this.label, required this.bg, required this.textColor});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(4)),
      child: Text(
        label,
        style: GoogleFonts.inter(
            fontSize: 11, fontWeight: FontWeight.w700, color: textColor, letterSpacing: 0.4),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// BLUE LINK
// ─────────────────────────────────────────────────────────────────────────────

class BlueLink extends StatelessWidget {
  final String label;
  final VoidCallback onTap;

  const BlueLink({super.key, required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Text(
        label,
        style: GoogleFonts.inter(fontSize: 15, color: const Color(0xFF2F80ED), fontWeight: FontWeight.w500),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// PLAN CARD  (used inside horizontal PageView on upgrade screen)
// ─────────────────────────────────────────────────────────────────────────────

class PlanCard extends StatelessWidget {
  final String periodLabel;
  final Color periodColor;
  final String planName;
  final String priceDisplay;
  final List<String> features;
  final VoidCallback onSubscribe;

  const PlanCard({
    super.key,
    required this.periodLabel,
    required this.periodColor,
    required this.planName,
    required this.priceDisplay,
    required this.features,
    required this.onSubscribe,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 8),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(color: const Color(0xFF1A1A1A), borderRadius: BorderRadius.circular(12)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [
            PremiumTag(label: 'FOR YOU', bg: const Color(0xFF2F80ED), textColor: Colors.white),
            const SizedBox(width: 8),
            PremiumTag(label: periodLabel, bg: periodColor, textColor: Colors.white),
          ]),
          const SizedBox(height: 16),
          Text(planName,
              style: GoogleFonts.inter(fontSize: 22, fontWeight: FontWeight.w900, color: Colors.white)),
          Text(priceDisplay,
              style: GoogleFonts.inter(fontSize: 20, fontWeight: FontWeight.w700, color: Colors.white)),
          const SizedBox(height: 16),
          ...features.map((f) => Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(Icons.check, color: Colors.white70, size: 18),
                    const SizedBox(width: 10),
                    Expanded(child: Text(f, style: GoogleFonts.inter(fontSize: 14, color: Colors.white))),
                  ],
                ),
              )),
          const Spacer(),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white, foregroundColor: Colors.black,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(32)),
                elevation: 0,
              ),
              onPressed: onSubscribe,
              child: Text('Subscribe now',
                  style: GoogleFonts.inter(fontWeight: FontWeight.w600, fontSize: 15)),
            ),
          ),
          const SizedBox(height: 12),
          Text('Cancel anytime.', style: GoogleFonts.inter(fontSize: 13, color: Colors.white54)),
          BlueLink(label: 'Restrictions apply', onTap: () => showRestrictionsSheet(context)),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// SHEET HELPER FUNCTIONS  (call from anywhere)
// ─────────────────────────────────────────────────────────────────────────────

void showRestrictionsSheet(BuildContext context) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (_) => const _RestrictionsSheet(),
  );
}

void showTextDocSheet(BuildContext context, String title, String body) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (_) => _TextDocSheet(title: title, body: body),
  );
}

// ─────────────────────────────────────────────────────────────────────────────
// RESTRICTIONS SHEET  (PDF page 11)
// ─────────────────────────────────────────────────────────────────────────────

class _RestrictionsSheet extends StatelessWidget {
  const _RestrictionsSheet();

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.6,
      maxChildSize: 0.92,
      minChildSize: 0.3,
      builder: (_, ctrl) => Container(
        decoration: const BoxDecoration(
          color: Color(0xFF1A1A1A),
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          children: [
            const _SheetHandle(),
            Expanded(
              child: ListView(
                controller: ctrl,
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 40),
                children: [
                  Text('Restrictions apply',
                      style: GoogleFonts.inter(fontSize: 20, fontWeight: FontWeight.w800, color: Colors.white)),
                  const SizedBox(height: 16),
                  Text(
                    'Subscription may be managed and cancelled at any time in your Account Settings. '
                    'All prices include applicable local taxes. Rythmify Premium Terms of Use & Privacy Policy.',
                    style: GoogleFonts.inter(fontSize: 14, color: Colors.white70, height: 1.6),
                  ),
                  const SizedBox(height: 24),
                  Text('Premium',
                      style: GoogleFonts.inter(fontSize: 15, fontWeight: FontWeight.w700, color: Colors.white)),
                  const SizedBox(height: 12),
                  BlueLink(
                    label: 'Terms of Use',
                    onTap: () {
                      Navigator.pop(context);
                      showTextDocSheet(context, 'Terms of Use', kTermsText);
                    },
                  ),
                  const SizedBox(height: 12),
                  BlueLink(
                    label: 'Privacy Policy',
                    onTap: () {
                      Navigator.pop(context);
                      showTextDocSheet(context, 'Privacy Policy', kPrivacyText);
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// GENERIC TEXT DOC SHEET  (Terms / Privacy)
// ─────────────────────────────────────────────────────────────────────────────

class _TextDocSheet extends StatelessWidget {
  final String title;
  final String body;
  const _TextDocSheet({required this.title, required this.body});

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.85,
      maxChildSize: 0.95,
      minChildSize: 0.4,
      builder: (_, ctrl) => Container(
        decoration: const BoxDecoration(
          color: Color(0xFF121212),
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          children: [
            const _SheetHandle(),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 4, 20, 16),
              child: Row(
                children: [
                  Expanded(
                    child: Text(title,
                        style: GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.w800, color: Colors.white)),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close, color: Colors.white54),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                controller: ctrl,
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 40),
                child: Text(body,
                    style: GoogleFonts.inter(fontSize: 13, color: Colors.white70, height: 1.8)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// SHARED SMALL WIDGETS
// ─────────────────────────────────────────────────────────────────────────────

class _SheetHandle extends StatelessWidget {
  const _SheetHandle();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        margin: const EdgeInsets.only(top: 12, bottom: 8),
        width: 40,
        height: 4,
        decoration: BoxDecoration(color: Colors.white24, borderRadius: BorderRadius.circular(2)),
      ),
    );
  }
}