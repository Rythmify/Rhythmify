import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../widgets/premium_widgets.dart';

// ─────────────────────────────────────────────────────────────────────────────
// YOUR ASSET NAMES — only change these 3 lines
// Files must be in assets/images/ and declared in pubspec.yaml
// ─────────────────────────────────────────────────────────────────────────────

const _kBgAsset = 'assets/images/blackmarble.jpeg'; // black marble background
const _kOmbreAsset =
    'assets/images/yellowombre.jpeg'; // yellow/orange ombre card
const _kPortraitAsset = 'assets/images/dreadsguy.jpeg'; // guy with dreads

// ─────────────────────────────────────────────────────────────────────────────
// LANDING SCREEN
// ─────────────────────────────────────────────────────────────────────────────

class UpgradeLandingScreen extends StatelessWidget {
  const UpgradeLandingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.light);

    final size = MediaQuery.of(context).size;
    final botPad = MediaQuery.of(context).padding.bottom;
    final topPad = MediaQuery.of(context).padding.top;

    // Card dimensions — small cards floating above the text
    final cardW = size.width * 0.52; // portrait card width
    final cardH = size.height * 0.38; // portrait card height
    final ombreW = size.width * 0.48; // ombre card slightly narrower
    final ombreH = size.height * 0.34; // ombre card slightly shorter

    // Portrait card: centered horizontally, sits in top 40% of screen
    final portraitLeft = (size.width - cardW) / 2;
    final portraitTop = topPad + size.height * 0.05;

    // Ombre card: shifted RIGHT ~28px and UP ~20px from portrait
    // so it peeks from behind the top-right of the portrait
    final ombreLeft = portraitLeft + 28;
    final ombreTop = portraitTop - 20;

    return Scaffold(
      backgroundColor: Colors.black,
      extendBodyBehindAppBar: true,
      body: Stack(
        children: [
          // ── L1: Black marble — full screen ───────────────────────────
          Positioned.fill(
            child: Image.asset(
              _kBgAsset,
              fit: BoxFit.cover,
              errorBuilder: (_, _, _) =>
                  Container(color: const Color(0xFF0A0A0A)),
            ),
          ),

          // ── L2: Yellow ombre card — behind portrait, shifted down+right
          Positioned(
            left: ombreLeft,
            top: ombreTop,
            child: _PhotoCard(
              assetPath: _kOmbreAsset,
              width: ombreW,
              height: ombreH,
              fallbackColors: const [Color(0xFFFFB800), Color(0xFFFF5500)],
            ),
          ),

          // ── L3: Portrait card — front, centered, slightly above ombre
          Positioned(
            left: portraitLeft,
            top: portraitTop,
            child: _PhotoCard(
              assetPath: _kPortraitAsset,
              width: cardW,
              height: cardH,
              alignment: Alignment.topCenter,
              fallbackColors: const [Color(0xFF3A1800), Color(0xFF1A0800)],
            ),
          ),

          // ── L4: Bottom scrim — fades bottom half into black, leaves cards clear
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            height: size.height * 0.58,
            child: const DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  stops: [0.0, 0.15, 0.50, 1.0],
                  colors: [
                    Color(0x00000000),
                    Color(0x33000000),
                    Color(0xBB000000),
                    Color(0xFF000000),
                  ],
                ),
              ),
            ),
          ),

          // ── L5: Content — tags + headline + buttons ───────────────────
          Positioned(
            left: 20,
            right: 20,
            bottom: 80 + botPad,
            child: const _Content(),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// PHOTO CARD — reusable image card with shadow + sharp corners
// ─────────────────────────────────────────────────────────────────────────────

class _PhotoCard extends StatelessWidget {
  final String assetPath;
  final double width;
  final double height;
  final List<Color> fallbackColors;
  final Alignment alignment;

  const _PhotoCard({
    required this.assetPath,
    required this.width,
    required this.height,
    required this.fallbackColors,
    this.alignment = Alignment.center,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(6),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.55),
            blurRadius: 24,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(6),
        child: Image.asset(
          assetPath,
          width: width,
          height: height,
          fit: BoxFit.cover,
          alignment: alignment,
          errorBuilder: (_, _, _) => Container(
            width: width,
            height: height,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: fallbackColors,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// CONTENT — tags + headline + price + buttons
// ─────────────────────────────────────────────────────────────────────────────

class _Content extends StatelessWidget {
  const _Content();

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Tags
        Row(
          children: [
            _Tag(label: '★ ARTIST PRO', bg: const Color(0xFF1C1C1C)),
            const SizedBox(width: 6),
            _Tag(label: 'FOR ARTISTS', bg: const Color(0xFF2F80ED)),
          ],
        ),
        const SizedBox(height: 16),

        // Headline
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
        const SizedBox(height: 10),

        // Price line
        Text(
          'EGP 164.99/month. Cancel anytime.',
          style: GoogleFonts.inter(
            fontSize: 13,
            color: Colors.white70,
            fontWeight: FontWeight.w400,
          ),
        ),

        // Restrictions apply
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

        // Continue button
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
        const SizedBox(height: 16),

        // See all plans
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
        const SizedBox(height: 50),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// SHARP TAG — radius 4
// ─────────────────────────────────────────────────────────────────────────────

class _Tag extends StatelessWidget {
  final String label;
  final Color bg;
  const _Tag({required this.label, required this.bg});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(4),
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
