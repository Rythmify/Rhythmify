import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../widgets/premium_widgets.dart';

/// Full-screen hero landing shown when user taps the Upgrade tab.
/// Tapping "Continue" or "See all plans" pushes to /upgrade/plans.
class UpgradeLandingScreen extends StatelessWidget {
  const UpgradeLandingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      body: SizedBox.expand(
        child: Stack(
          children: [
            // ── Artist photo (boy with dreads) ──────────────────────────
            // Swap the Container below with:
            //   Image.asset('assets/images/upgrade_hero.jpg',
            //     fit: BoxFit.cover, width: double.infinity, height: double.infinity)
            // once you have the photo.
            Positioned.fill(
              child: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [Color(0xFF3D2000), Color(0xFF1A0D00), Color(0xFF000000)],
                  ),
                ),
                child: const Center(
                  child: Icon(Icons.music_note, color: Color(0xFFFF5500), size: 80),
                ),
              ),
            ),

            // ── Bottom gradient scrim ────────────────────────────────────
            Positioned(
              bottom: 0, left: 0, right: 0, height: 420,
              child: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [Colors.transparent, Color(0xCC121212), Color(0xFF121212)],
                  ),
                ),
              ),
            ),

            // ── Content overlay ──────────────────────────────────────────
            Positioned(
              bottom: 90, // above mini-player bar
              left: 20,
              right: 20,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Tags
                  Row(children: [
                    PremiumTag(
                      label: '★ ARTIST PRO',
                      bg: const Color(0xFF1E1E1E),
                      textColor: Colors.white,
                    ),
                    const SizedBox(width: 8),
                    PremiumTag(
                      label: 'FOR ARTISTS',
                      bg: const Color(0xFF2F80ED),
                      textColor: Colors.white,
                    ),
                  ]),
                  const SizedBox(height: 20),

                  // Headline (matches PDF page 1)
                  Text(
                    'Unlock unlimited\nuploads &\nmore.',
                    style: GoogleFonts.inter(
                      fontSize: 40,
                      fontWeight: FontWeight.w900,
                      color: Colors.white,
                      height: 1.05,
                      letterSpacing: -1.2,
                    ),
                  ),
                  const SizedBox(height: 14),

                  Text(
                    '\$4.99/month. Cancel anytime.',
                    style: GoogleFonts.inter(fontSize: 14, color: Colors.white70),
                  ),
                  BlueLink(
                    label: 'Restrictions apply.',
                    onTap: () => showRestrictionsSheet(context),
                  ),
                  const SizedBox(height: 28),

                  // Continue → goes to upgrade/plans
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: Colors.black,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(32)),
                        elevation: 0,
                      ),
                      onPressed: () => context.push('/upgrade/plans'),
                      child: Text(
                        'Continue',
                        style: GoogleFonts.inter(
                            fontSize: 16, fontWeight: FontWeight.w600, color: Colors.black),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // See all plans → also goes to upgrade/plans
                  Center(
                    child: GestureDetector(
                      onTap: () => context.push('/upgrade/plans'),
                      child: Text(
                        'See all plans',
                        style: GoogleFonts.inter(
                            fontSize: 15, color: Colors.white, fontWeight: FontWeight.w500),
                      ),
                    ),
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