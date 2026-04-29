import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

/// Call this anywhere instead of showing an error when user hits a limit.
///
/// Usage in upload screen onError:
///   PremiumUpgradePrompt.show(context, reason: 'upload more tracks');
///
/// Usage in playlist screen onError:
///   PremiumUpgradePrompt.show(context, reason: 'create more playlists');
class PremiumUpgradePrompt {
  static void show(BuildContext context, {required String reason}) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) => _Sheet(reason: reason),
    );
  }
}

class _Sheet extends StatelessWidget {
  final String reason;
  const _Sheet({required this.reason});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Color(0xFF1A1A1A),
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      padding: EdgeInsets.fromLTRB(
          24, 16, 24, 32 + MediaQuery.of(context).padding.bottom),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 40, height: 4,
            decoration: BoxDecoration(
                color: Colors.white24, borderRadius: BorderRadius.circular(2)),
          ),
          const SizedBox(height: 24),

          // Icon
          Container(
            width: 56, height: 56,
            decoration: const BoxDecoration(
                color: Color(0xFF2A1A3E), shape: BoxShape.circle),
            child: const Icon(Icons.workspace_premium_rounded,
                color: Color(0xFF7B2FBE), size: 28),
          ),
          const SizedBox(height: 16),

          Text('Upgrade to Premium',
              style: GoogleFonts.inter(
                  fontSize: 20, fontWeight: FontWeight.w900, color: Colors.white)),
          const SizedBox(height: 8),
          Text(
            'Upgrade to Premium to $reason\nand unlock unlimited access.',
            textAlign: TextAlign.center,
            style: GoogleFonts.inter(
                fontSize: 14, color: Colors.white60, height: 1.5),
          ),
          const SizedBox(height: 20),

          // Benefits
          ...[
            'Unlimited track uploads',
            'Unlimited playlist creation',
          ].map((f) => Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Row(children: [
                  const Icon(Icons.check, color: Color(0xFF7B2FBE), size: 15),
                  const SizedBox(width: 10),
                  Text(f,
                      style: GoogleFonts.inter(
                          fontSize: 13, color: Colors.white70)),
                ]),
              )),
          const SizedBox(height: 24),

          SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF7B2FBE),
                foregroundColor: Colors.white,
                elevation: 0,
                shape: const StadiumBorder(),
              ),
              onPressed: () {
                Navigator.pop(context);
                context.go('/upgrade');
              },
              child: Text('See Premium plans',
                  style: GoogleFonts.inter(
                      fontWeight: FontWeight.w700, fontSize: 15)),
            ),
          ),
          const SizedBox(height: 8),
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Not now',
                style: GoogleFonts.inter(fontSize: 14, color: Colors.white38)),
          ),
        ],
      ),
    );
  }
}