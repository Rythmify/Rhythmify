import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../widgets/premium_widgets.dart';

/// Page 1 of the PDF:
/// - Artist photo fills the full screen
/// - Dark scrim fades in over the bottom half
/// - Tags + headline + price + Continue button + "See all plans" overlaid at bottom
/// - Continue  → /upgrade/checkout  (mock payment)
/// - See all plans → /upgrade/plans  (the scrolling plans + info page)
class UpgradeLandingScreen extends StatelessWidget {
  const UpgradeLandingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Make status bar icons light (photo is dark bg)
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.light);
    final bottomPad = MediaQuery.of(context).padding.bottom;

    return Scaffold(
      backgroundColor: Colors.black,
      extendBodyBehindAppBar: true,
      body: Stack(
        fit: StackFit.expand,
        children: [
          // ── Full-screen artist photo ──────────────────────────────────
          // Replace with your actual asset:
          // Image.asset('assets/images/upgrade_hero.jpg', fit: BoxFit.cover)
          _PlaceholderPhoto(),

          // ── Bottom scrim — dark fade so text is readable ──────────────
          Positioned(
            bottom: 0, left: 0, right: 0,
            height: MediaQuery.of(context).size.height * 0.58,
            child: Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  stops: [0.0, 0.35, 1.0],
                  colors: [
                    Colors.transparent,
                    Color(0xB3000000),
                    Colors.black,
                  ],
                ),
              ),
            ),
          ),

          // ── Text + buttons overlaid at bottom ─────────────────────────
          Positioned(
            left: 20, right: 20,
            bottom: 80 + bottomPad, // 80 = mini-player height
            child: _LandingContent(),
          ),
        ],
      ),
    );
  }
}

// ── Placeholder photo (replace body with Image.asset when asset is available) ─
class _PlaceholderPhoto extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.center,
          colors: [Color(0xFF4A2800), Color(0xFF1A0E00)],
        ),
      ),
      child: const Center(
        child: Icon(Icons.person, color: Color(0x33FF5500), size: 180),
      ),
    );
  }
}

// ── Content: tags + headline + price + buttons ────────────────────────────────
class _LandingContent extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Tags row — sharp corners (borderRadius: 4), exactly as in PDF
        Row(
          children: [
            _SharpTag(label: '★ ARTIST PRO', bg: const Color(0xFF1C1C1C)),
            const SizedBox(width: 6),
            _SharpTag(label: 'FOR ARTISTS', bg: const Color(0xFF2F80ED)),
          ],
        ),
        const SizedBox(height: 18),

        // Headline — heavy Inter, large, matches PDF
        Text(
          'Unlock artist tools\n& unlimited\nuploads.',
          style: GoogleFonts.inter(
            fontSize: 36,
            fontWeight: FontWeight.w900,
            color: Colors.white,
            height: 1.08,
            letterSpacing: -0.8,
          ),
        ),
        const SizedBox(height: 12),

        // Price line
        Text(
          '\$4.99/month. Cancel anytime.',
          style: GoogleFonts.inter(
            fontSize: 13,
            color: Colors.white70,
            fontWeight: FontWeight.w400,
          ),
        ),
        // Restrictions apply — blue link
        GestureDetector(
          onTap: () => showRestrictionsSheet(context),
          child: Text(
            'Restrictions apply.',
            style: GoogleFonts.inter(
              fontSize: 13,
              color: const Color(0xFF2F80ED),
              fontWeight: FontWeight.w400,
            ),
          ),
        ),
        const SizedBox(height: 24),

        // Continue button — large white pill (fully rounded), PDF style
        SizedBox(
          width: double.infinity,
          height: 52,
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white,
              foregroundColor: Colors.black,
              elevation: 0,
              shape: const StadiumBorder(),
            ),
            // Continue → mock checkout / payment screen
            onPressed: () => context.push('/upgrade/checkout'),
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
        const SizedBox(height: 18),

        // "See all plans" — plain centered white text, no frame
        Center(
          child: GestureDetector(
            onTap: () => context.push('/upgrade/plans'),
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

// ── Sharp-cornered tag pill (radius 4, matches PDF exactly) ──────────────────
class _SharpTag extends StatelessWidget {
  final String label;
  final Color bg;

  const _SharpTag({required this.label, required this.bg});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(4), // sharp, not rounded pill
      ),
      child: Text(
        label,
        style: GoogleFonts.inter(
          fontSize: 11,
          fontWeight: FontWeight.w700,
          color: Colors.white,
          letterSpacing: 0.2,
        ),
      ),
    );
  }
}