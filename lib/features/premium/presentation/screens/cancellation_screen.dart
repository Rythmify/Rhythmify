/// Shows active premium subscription and handles cancellation.
///
/// Responsibilities:
/// - Displays active subscription status
/// - Shows countdown timer for current session
/// - Handles subscription cancellation
/// - Shows premium benefits list
///
/// Behavior:
/// - 5-minute session timer updates every second
/// - Auto-renews session if not canceled
/// - After cancel: subscription stays active until session ends
///
/// Actions:
/// - Cancel subscription → disables auto-renew via backend
/// - Resubscribe → navigates to upgrade flow
///
/// Notes:
/// - Uses simulated session timer for UX purposes
/// - endDate is optional backend data
library;

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../providers/premium_provider.dart';

const _kBgAsset = 'assets/images/premium_bg.jpg';
const _kSessionDuration = Duration(minutes: 5);
const _kPurple = Color(0xFF7B2FBE);
const _kPurpleLight = Color(0xFFB57BEE);
const _kGreen = Color(0xFF2E7D32);
const _kGreenLight = Color(0xFF81C784);
const _kDark = Color(0xFF0D0D0D);
const _kCard = Color(0xFF1A1A1A);

class CancellationScreen extends ConsumerStatefulWidget {
  const CancellationScreen({super.key});
  @override
  ConsumerState<CancellationScreen> createState() => _CancellationScreenState();
}

class _CancellationScreenState extends ConsumerState<CancellationScreen> {
  Timer? _timer;
  Duration _remaining = _kSessionDuration;
  bool _isCanceled = false;

  @override
  void initState() {
    super.initState();
    _startSession();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  // Always show a fresh 5-min countdown — increments auto-renew every session
  void _startSession() {
    final state = ref.read(premiumProvider);
    _isCanceled = state.isCanceled;

    // If subscription has an end_date, count down to it (capped at 5 min display)
    final endDateStr = state.subscription?.endDate;
    if (endDateStr != null) {
      final endDate = DateTime.tryParse(endDateStr);
      if (endDate != null) {
        final diff = endDate.difference(DateTime.now());
        // Show real time remaining but cap display at 5 min max for UX
        _remaining = diff.isNegative
            ? Duration.zero
            : (diff > _kSessionDuration ? _kSessionDuration : diff);
      }
    }

    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (!mounted) return;
      setState(() {
        if (_remaining.inSeconds > 0) {
          _remaining -= const Duration(seconds: 1);
        } else {
          _timer?.cancel();
          if (!_isCanceled) {
            // Auto-renew: reset to new 5-min session
            _remaining = _kSessionDuration;
            _startSession();
          } else {
            ref.read(premiumProvider.notifier).loadMySubscription();
          }
        }
      });
    });
  }

  String _pad(int n) => n.toString().padLeft(2, '0');
  String get _display {
    final m = _remaining.inMinutes % 60;
    final s = _remaining.inSeconds % 60;
    return '${_pad(m)}:${_pad(s)}';
  }

  double get _progress =>
      1.0 -
      (_remaining.inSeconds / _kSessionDuration.inSeconds).clamp(0.0, 1.0);

  Future<void> _cancel() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => _ConfirmDialog(),
    );
    if (confirm != true || !mounted) return;
    
    setState(() => _isCanceled = true);
    await ref.read(premiumProvider.notifier).cancel();
  }

  @override
  Widget build(BuildContext context) {
    final mq = MediaQuery.of(context);
    final topPad = mq.padding.top;
    final botPad = mq.padding.bottom;

    final isPremium = ref.watch(isPremiumProvider);
    final accentColor = isPremium ? _kPurple : _kGreen;
    final lightAccentColor = isPremium ? _kPurpleLight : _kGreenLight;
    final topGradientColor = isPremium
        ? const Color(0xFF2A0A5E)
        : const Color(0xFF0A2E10);

    return Scaffold(
      backgroundColor: _kDark,
      body: Stack(
        children: [
          // Background photo top half
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            height: mq.size.height * 0.42,
            child: Stack(
              fit: StackFit.expand,
              children: [
                Image.asset(
                  _kBgAsset,
                  fit: BoxFit.cover,
                  errorBuilder: (_, _, _) => Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [topGradientColor, _kDark],
                      ),
                    ),
                  ),
                ),
                Container(
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      stops: [0.0, 0.5, 1.0],
                      colors: [Colors.transparent, Color(0x88000000), _kDark],
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Content
          SingleChildScrollView(
            padding: EdgeInsets.fromLTRB(20, topPad + 16, 20, 80 + botPad),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Back button
                GestureDetector(
                  onTap: () => Navigator.of(context).pop(),
                  child: Container(
                    width: 34,
                    height: 34,
                    decoration: const BoxDecoration(
                      color: Colors.black38,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.arrow_back_ios_new,
                      color: Colors.white,
                      size: 15,
                    ),
                  ),
                ),
                const SizedBox(height: 120),

                // Badge
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 5,
                  ),
                  color: accentColor,
                  child: Text(
                    isPremium ? '★ PREMIUM ACTIVE' : 'FREE TIER',
                    style: GoogleFonts.inter(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                      letterSpacing: 0.4,
                    ),
                  ),
                ),
                const SizedBox(height: 14),

                Text(
                  isPremium ? "You're Premium." : "Not Premium.",
                  style: GoogleFonts.inter(
                    fontSize: 30,
                    fontWeight: FontWeight.w900,
                    color: Colors.white,
                    height: 1.1,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  isPremium
                      ? (_isCanceled
                            ? 'Access ends when this session expires.'
                            : 'You have unlimited access to all features.')
                      : 'Upgrade to Artist Pro to unlock the full experience.',
                  style: GoogleFonts.inter(
                    fontSize: 13,
                    color: lightAccentColor,
                  ),
                ),
                const SizedBox(height: 32),

                // ── Timer/Status Card ─────────────────────────────
                if (isPremium && _isCanceled)
                  Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      border: Border.all(color: accentColor, width: 1.5),
                      color: _kCard,
                    ),
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Session ends in',
                              style: GoogleFonts.inter(
                                fontSize: 11,
                                color: lightAccentColor,
                                fontWeight: FontWeight.w600,
                                letterSpacing: 0.5,
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 3,
                              ),
                              color: accentColor.withValues(alpha: 0.2),
                              child: Text(
                                '5 MIN',
                                style: GoogleFonts.inter(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w700,
                                  color: lightAccentColor,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),

                        // Big timer display
                        Center(
                          child: Text(
                            _display,
                            style: GoogleFonts.inter(
                              fontSize: 52,
                              fontWeight: FontWeight.w900,
                              color: lightAccentColor,
                              letterSpacing: -2,
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),

                        // Progress bar
                        LinearProgressIndicator(
                          value: _progress,
                          backgroundColor: accentColor.withValues(alpha: 0.2),
                          valueColor: AlwaysStoppedAnimation(accentColor),
                          minHeight: 4,
                        ),
                        const SizedBox(height: 8),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Session start',
                              style: GoogleFonts.inter(
                                fontSize: 10,
                                color: Colors.white24,
                              ),
                            ),
                            Text(
                              'Final session',
                              style: GoogleFonts.inter(
                                fontSize: 10,
                                color: Colors.white24,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  )
                else
                  // Status Info Card
                  Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      border: Border.all(color: accentColor, width: 1.5),
                      color: _kCard,
                    ),
                    padding: const EdgeInsets.all(24),
                    child: Row(
                      children: [
                        Icon(
                          isPremium
                              ? Icons.workspace_premium
                              : Icons.info_outline,
                          color: lightAccentColor,
                          size: 40,
                        ),
                        const SizedBox(width: 20),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                isPremium
                                    ? 'Full Access Enabled'
                                    : 'Limited Access',
                                style: GoogleFonts.inter(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                isPremium
                                    ? 'Your subscription is active and auto-renews.'
                                    : 'Ads and upload limits are currently active.',
                                style: GoogleFonts.inter(
                                  fontSize: 13,
                                  color: Colors.white60,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                const SizedBox(height: 20),

                // ── Benefits ─────────────────────────────────────────
                Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: accentColor.withValues(alpha: 0.3),
                    ),
                    color: _kCard,
                  ),
                  padding: const EdgeInsets.all(18),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        isPremium
                            ? 'Your Premium benefits'
                            : 'Premium features you\'re missing',
                        style: GoogleFonts.inter(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: lightAccentColor,
                        ),
                      ),
                      const SizedBox(height: 12),
                      ...[
                        'Unlimited track uploads',
                        'Unlimited playlists',
                        'Offline listening',
                        'No ads',
                        'Priority support',
                      ].map(
                        (f) => Padding(
                          padding: const EdgeInsets.only(bottom: 8),
                          child: Row(
                            children: [
                              Icon(
                                isPremium ? Icons.check : Icons.lock_outline,
                                color: accentColor,
                                size: 14,
                              ),
                              const SizedBox(width: 10),
                              Text(
                                f,
                                style: GoogleFonts.inter(
                                  fontSize: 13,
                                  color: Colors.white70,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 28),

                // Actions (Only for Premium)
                if (isPremium) ...[
                  if (!_isCanceled) ...[
                    SizedBox(
                      width: double.infinity,
                      height: 48,
                      child: OutlinedButton(
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(color: Colors.white24),
                          shape: const RoundedRectangleBorder(),
                        ),
                        onPressed: ref.watch(premiumProvider).isLoading
                            ? null
                            : _cancel,
                        child: Text(
                          'Cancel subscription',
                          style: GoogleFonts.inter(
                            fontSize: 14,
                            color: Colors.white38,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Center(
                      child: Text(
                        'Premium stays active until session ends.',
                        style: GoogleFonts.inter(
                          fontSize: 11,
                          color: Colors.white24,
                        ),
                      ),
                    ),
                  ] else ...[
                    SizedBox(
                      width: double.infinity,
                      height: 48,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: accentColor,
                          foregroundColor: Colors.white,
                          elevation: 0,
                          shape: const RoundedRectangleBorder(),
                        ),
                        onPressed: () => context.go('/upgrade/plans'),
                        child: Text(
                          'Resubscribe',
                          style: GoogleFonts.inter(
                            fontWeight: FontWeight.w700,
                            fontSize: 15,
                          ),
                        ),
                      ),
                    ),
                  ],
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ConfirmDialog extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: _kCard,
      shape: const RoundedRectangleBorder(),
      title: Text(
        'Cancel subscription?',
        style: GoogleFonts.inter(
          fontSize: 17,
          fontWeight: FontWeight.w800,
          color: Colors.white,
        ),
      ),
      content: Text(
        'You keep Premium until this session ends. After that, your account returns to free.',
        style: GoogleFonts.inter(
          fontSize: 13,
          color: Colors.white60,
          height: 1.5,
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context, false),
          child: Text(
            'Keep Premium',
            style: GoogleFonts.inter(
              fontSize: 14,
              color: _kPurpleLight,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
        TextButton(
          onPressed: () => Navigator.pop(context, true),
          child: Text(
            'Cancel anyway',
            style: GoogleFonts.inter(fontSize: 14, color: Colors.white38),
          ),
        ),
      ],
    );
  }
}
