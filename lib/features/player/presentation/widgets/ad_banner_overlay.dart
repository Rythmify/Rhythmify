import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/ad_provider.dart';
import 'package:go_router/go_router.dart';

class AdBannerOverlay extends ConsumerWidget {
  final VoidCallback? onCollapse;
  const AdBannerOverlay({super.key, this.onCollapse});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Stack(
        children: [
          // --- Blurred Background ---
          Positioned.fill(
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
              child: Container(color: Colors.black.withValues(alpha: 0.7)),
            ),
          ),

          // --- Close Button ---
          Positioned(
            top: 60,
            right: 20,
            child: IconButton(
              icon: const Icon(Icons.close, color: Color(0xFFD4AF37), size: 30),
              onPressed: () => ref.read(adProvider.notifier).dismissAd(),
            ),
          ),

          // --- Ad Content ---
          Center(
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 24),
              padding: const EdgeInsets.all(32),
              decoration: BoxDecoration(
                color: const Color(0xFF121212),
                borderRadius: BorderRadius.circular(32),
                border: Border.all(
                  color: const Color(0xFFD4AF37).withValues(alpha: 0.5),
                  width: 1.5,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.8),
                    blurRadius: 40,
                    offset: const Offset(0, 20),
                  ),
                  BoxShadow(
                    color: const Color(0xFFD4AF37).withValues(alpha: 0.1),
                    blurRadius: 20,
                    offset: const Offset(0, 0),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.workspace_premium,
                    color: Color(0xFFD4AF37),
                    size: 80,
                  ),
                  const SizedBox(height: 24),
                  const Text(
                    "Unlock Artist Pro",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Color(0xFFD4AF37),
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      letterSpacing: -0.5,
                    ),
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    "Tired of interruptions? Subscribe to Artist Pro and enjoy your music ad-free, with high-fidelity sound and exclusive features.",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 16,
                      height: 1.5,
                    ),
                  ),
                  const SizedBox(height: 32),
                  ElevatedButton(
                    onPressed: () {
                      ref.read(adProvider.notifier).dismissAd();
                      onCollapse?.call();
                      context.go('/upgrade');
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFD4AF37),
                      foregroundColor: Colors.black,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 48,
                        vertical: 16,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(100),
                      ),
                      elevation: 0,
                    ),
                    child: const Text(
                      "Go Premium",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
