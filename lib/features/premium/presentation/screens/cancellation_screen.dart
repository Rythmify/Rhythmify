import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../providers/premium_provider.dart';

// ─────────────────────────────────────────────────────────────────────────────
// ASSET — paste your background photo filename here
// Same background color as your photo for a seamless blended effect
// ─────────────────────────────────────────────────────────────────────────────
const _kBgAsset = 'assets/images/premium_bg.jpg'; // ← change to your filename

// ─────────────────────────────────────────────────────────────────────────────
// CANCELLATION SCREEN
// Shown on the Upgrade tab when the user IS premium.
// ─────────────────────────────────────────────────────────────────────────────

class CancellationScreen extends ConsumerStatefulWidget {
  const CancellationScreen({super.key});

  @override
  ConsumerState<CancellationScreen> createState() => _CancellationScreenState();
}

class _CancellationScreenState extends ConsumerState<CancellationScreen> {
  Timer? _timer;
  Duration _remaining = Duration.zero;
  bool _isCanceled = false;

  @override
  void initState() {
    super.initState();
    _startCountdown();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _startCountdown() {
    final state = ref.read(premiumProvider);
    final endDateStr = state.subscription?.endDate;
    _isCanceled = state.isCanceled;

    if (endDateStr != null) {
      final endDate = DateTime.tryParse(endDateStr);
      if (endDate != null) {
        _remaining = endDate.difference(DateTime.now());
        if (_remaining.isNegative) _remaining = Duration.zero;
      }
    } else {
      // Backend simulates 30 days premium — show 30 day countdown
      _remaining = const Duration(days: 30);
    }

    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (!mounted) return;
      setState(() {
        if (_remaining.inSeconds > 0) {
          _remaining -= const Duration(seconds: 1);
        } else {
          _timer?.cancel();
        }
      });
    });
  }

  String _pad(int n) => n.toString().padLeft(2, '0');

  String get _countdownDisplay {
    final d = _remaining.inDays;
    final h = _remaining.inHours % 24;
    final m = _remaining.inMinutes % 60;
    final s = _remaining.inSeconds % 60;
    if (d > 0) return '${d}d ${_pad(h)}h ${_pad(m)}m ${_pad(s)}s';
    return '${_pad(h)}:${_pad(m)}:${_pad(s)}';
  }

  // Progress 0.0 → 1.0 (how much of 30 days has elapsed)
  double get _progress {
    const total = Duration(days: 30);
    final elapsed = total - _remaining;
    if (elapsed.isNegative) return 0.0;
    return (elapsed.inSeconds / total.inSeconds).clamp(0.0, 1.0);
  }

  Future<void> _cancel() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => _ConfirmCancelDialog(),
    );
    if (confirm != true || !mounted) return;

    await ref.read(premiumProvider.notifier).cancel();

    if (!mounted) return;
    setState(() => _isCanceled = true);

    // Backend gives 5 min after cancel — restart countdown to 5 min
    _timer?.cancel();
    _remaining = const Duration(minutes: 5);
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (!mounted) return;
      setState(() {
        if (_remaining.inSeconds > 0) {
          _remaining -= const Duration(seconds: 1);
        } else {
          _timer?.cancel();
          // Subscription ended — refresh and stay on this tab
          ref.read(premiumProvider.notifier).loadMySubscription();
        }
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final mq = MediaQuery.of(context);
    final topPad = mq.padding.top;
    final botPad = mq.padding.bottom;

    return Scaffold(
      backgroundColor: const Color(0xFF0D0D0D),
      body: Stack(
        children: [
          // ── Background photo — top portion ─────────────────────────
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            height: mq.size.height * 0.45,
            child: Stack(
              fit: StackFit.expand,
              children: [
                Image.asset(
                  _kBgAsset,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => Container(
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [Color(0xFF1A0A2E), Color(0xFF0D0D0D)],
                      ),
                    ),
                  ),
                ),
                // Fade photo into dark background
                Container(
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      stops: [0.0, 0.5, 1.0],
                      colors: [
                        Colors.transparent,
                        Color(0x66000000),
                        Color(0xFF0D0D0D),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),

          // ── Scrollable content ──────────────────────────────────────
          SingleChildScrollView(
            padding: EdgeInsets.fromLTRB(20, topPad + 16, 20, 80 + botPad),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Premium badge
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 5,
                  ),
                  color: const Color(0xFFFF5500),
                  child: Text(
                    '★ PREMIUM ACTIVE',
                    style: GoogleFonts.inter(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                      letterSpacing: 0.4,
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                Text(
                  "You're Premium.",
                  style: GoogleFonts.inter(
                    fontSize: 32,
                    fontWeight: FontWeight.w900,
                    color: Colors.white,
                    height: 1.1,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  _isCanceled
                      ? 'Your subscription was cancelled. Access ends in:'
                      : 'Your premium access expires in:',
                  style: GoogleFonts.inter(fontSize: 14, color: Colors.white60),
                ),
                const SizedBox(height: 28),

                // ── Countdown card ──────────────────────────────────
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  color: const Color(0xFF1A1A1A),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _isCanceled ? 'Access ends in' : 'Time remaining',
                        style: GoogleFonts.inter(
                          fontSize: 12,
                          color: Colors.white38,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 0.5,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        _countdownDisplay,
                        style: GoogleFonts.inter(
                          fontSize: 36,
                          fontWeight: FontWeight.w900,
                          color: const Color(0xFFFF5500),
                          letterSpacing: -1,
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Progress bar
                      ClipRRect(
                        borderRadius: BorderRadius.zero,
                        child: LinearProgressIndicator(
                          value: _progress,
                          backgroundColor: Colors.white12,
                          valueColor: const AlwaysStoppedAnimation(
                            Color(0xFFFF5500),
                          ),
                          minHeight: 6,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Start',
                            style: GoogleFonts.inter(
                              fontSize: 11,
                              color: Colors.white30,
                            ),
                          ),
                          Text(
                            _isCanceled ? '5 min window' : '30 days',
                            style: GoogleFonts.inter(
                              fontSize: 11,
                              color: Colors.white30,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),

                // ── What you have ───────────────────────────────────
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(18),
                  color: const Color(0xFF1A1A1A),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Your Premium benefits',
                        style: GoogleFonts.inter(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 14),
                      ...[
                        'Unlimited track uploads',
                        'Unlimited playlists',
                        'Offline listening',
                        'No ads',
                        'Priority support',
                      ].map(
                        (f) => Padding(
                          padding: const EdgeInsets.only(bottom: 10),
                          child: Row(
                            children: [
                              const Icon(
                                Icons.check,
                                color: Color(0xFFFF5500),
                                size: 15,
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

                // ── Cancel button (only if not already cancelled) ────
                if (!_isCanceled) ...[
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: Colors.white24),
                        shape: const RoundedRectangleBorder(),
                        foregroundColor: Colors.white54,
                      ),
                      onPressed: ref.watch(premiumProvider).isLoading
                          ? null
                          : _cancel,
                      child: ref.watch(premiumProvider).isLoading
                          ? const SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(
                                color: Colors.white38,
                                strokeWidth: 2,
                              ),
                            )
                          : Text(
                              'Cancel subscription',
                              style: GoogleFonts.inter(
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                                color: Colors.white38,
                              ),
                            ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Center(
                    child: Text(
                      'You keep Premium access until your period ends.',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        color: Colors.white24,
                      ),
                    ),
                  ),
                ] else ...[
                  // Resubscribe option after cancellation
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
                      onPressed: () => context.push('/upgrade/plans'),
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
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// CONFIRM CANCEL DIALOG
// ─────────────────────────────────────────────────────────────────────────────

class _ConfirmCancelDialog extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: const Color(0xFF1E1E1E),
      shape: const RoundedRectangleBorder(),
      title: Text(
        'Cancel subscription?',
        style: GoogleFonts.inter(
          fontSize: 18,
          fontWeight: FontWeight.w800,
          color: Colors.white,
        ),
      ),
      content: Text(
        'You will keep Premium access until your current period ends. '
        'After that your account returns to the free plan.',
        style: GoogleFonts.inter(
          fontSize: 14,
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
              color: const Color(0xFFFF5500),
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
