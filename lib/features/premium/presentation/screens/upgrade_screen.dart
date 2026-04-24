import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../providers/premium_provider.dart';
import '../widgets/premium_widgets.dart';
import '../widgets/premium_hero_widgets.dart';
import '../widgets/premium_legal.dart';
import 'checkout_screen.dart';

// ── Ombre bg stops matching PDF pages ────────────────────────────────────────
const _kBgStops = [
  Color(0xFF121212),
  Color(0xFF6B2D8B),
  Color(0xFF8B2D8B),
  Color(0xFFB03060),
  Color(0xFF8B2D8B),
  Color(0xFF8B1A8B),
  Color(0xFF9B2080),
  Color(0xFF121212),
];

Color _interpolateBg(double fraction) {
  final t = fraction * (_kBgStops.length - 1);
  final lo = t.floor().clamp(0, _kBgStops.length - 2);
  final hi = (lo + 1).clamp(0, _kBgStops.length - 1);
  return Color.lerp(_kBgStops[lo], _kBgStops[hi], t - lo)!;
}

// ─────────────────────────────────────────────────────────────────────────────
// UPGRADE SCREEN
// ─────────────────────────────────────────────────────────────────────────────

class UpgradeScreen extends ConsumerStatefulWidget {
  const UpgradeScreen({super.key});

  @override
  ConsumerState<UpgradeScreen> createState() => _UpgradeScreenState();
}

class _UpgradeScreenState extends ConsumerState<UpgradeScreen> {
  final _scroll = ScrollController();
  double _scrollFraction = 0.0;
  final List<bool> _faqOpen = [false, false];

  static const _faqs = [
    {
      'q': "What's included in Premium?",
      'a': 'Premium unlocks unlimited uploads, unlimited playlists, offline listening, and removes all ads.',
    },
    {
      'q': 'Can I cancel anytime?',
      'a': 'Yes. Cancel at any time from Account Settings. Your access stays active until the end of your billing period.',
    },
  ];

  @override
  void initState() {
    super.initState();
    _scroll.addListener(() {
      final max = _scroll.position.maxScrollExtent;
      if (max > 0) {
        setState(() => _scrollFraction = (_scroll.offset / max).clamp(0.0, 1.0));
      }
    });
  }

  @override
  void dispose() {
    _scroll.dispose();
    super.dispose();
  }

  void _scrollToPlans() {
    final screenH = MediaQuery.of(context).size.height;
    _scroll.animateTo(
      screenH * 0.85,
      duration: const Duration(milliseconds: 500),
      curve: Curves.easeInOut,
    );
  }

  void _goToCheckout() {
    final plans = ref.read(premiumProvider).plans;
    final premiumPlan = plans.firstWhere((p) => p.isPremium, orElse: () => plans.first);
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => CheckoutScreen(planId: premiumPlan.planId)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(premiumProvider);
    final bgColor = _interpolateBg(_scrollFraction);

    return Scaffold(
      backgroundColor: bgColor,
      body: Stack(
        children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 100),
            color: bgColor,
            width: double.infinity,
            height: double.infinity,
          ),
          CustomScrollView(
            controller: _scroll,
            physics: const ClampingScrollPhysics(),
            slivers: [
              // Hero — HeroSection, UpsellContent, ActivePremiumInfo in premium_hero_widgets.dart
              SliverToBoxAdapter(
                child: HeroSection(
                  isPremium: state.isPremium,
                  endDate: state.subscription?.endDate,
                  onContinue: _goToCheckout,
                  onSeeAllPlans: _scrollToPlans,
                  onCancel: () => ref.read(premiumProvider.notifier).cancel(),
                ),
              ),
              SliverToBoxAdapter(child: _PlansSection(onSubscribe: _goToCheckout)),
              const SliverToBoxAdapter(child: _SupportSection()),
              SliverToBoxAdapter(
                child: _FaqSection(
                  faqs: _faqs,
                  open: _faqOpen,
                  onToggle: (i) => setState(() => _faqOpen[i] = !_faqOpen[i]),
                ),
              ),
              // Clearance for mini-player bar
              const SliverToBoxAdapter(child: SizedBox(height: 80)),
            ],
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// PLANS SECTION  (PDF pages 2-5, horizontal PageView)
// ─────────────────────────────────────────────────────────────────────────────

class _PlansSection extends StatefulWidget {
  final VoidCallback onSubscribe;
  const _PlansSection({required this.onSubscribe});

  @override
  State<_PlansSection> createState() => _PlansSectionState();
}

class _PlansSectionState extends State<_PlansSection> {
  final _pc = PageController(viewportFraction: 0.88);
  int _page = 0;

  static const _cards = [
    {
      'period': 'Monthly',
      'periodColor': Color(0xFF8B2D8B),
      'name': 'Premium ★',
      'price': '\$4.99/month',
      'features': ['Unlimited track uploads', 'Unlimited playlists', 'Offline listening', 'No ads', 'Priority support'],
    },
    {
      'period': 'Free',
      'periodColor': Color(0xFF444444),
      'name': 'Free',
      'price': '\$0',
      'features': ['Up to 10 track uploads', 'Up to 5 playlists', 'Basic playback'],
    },
  ];

  @override
  void dispose() {
    _pc.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 40, 20, 24),
          child: Text(
            "What's next in music\nis first on Rythmify",
            style: GoogleFonts.inter(
              fontSize: 28, fontWeight: FontWeight.w900, color: Colors.white, height: 1.2),
          ),
        ),
        SizedBox(
          height: 400,
          child: PageView.builder(
            controller: _pc,
            itemCount: _cards.length,
            onPageChanged: (i) => setState(() => _page = i),
            itemBuilder: (_, i) {
              final c = _cards[i];
              return PlanCard(
                periodLabel: c['period'] as String,
                periodColor: c['periodColor'] as Color,
                planName: c['name'] as String,
                priceDisplay: c['price'] as String,
                features: List<String>.from(c['features'] as List),
                onSubscribe: widget.onSubscribe,
              );
            },
          ),
        ),
        const SizedBox(height: 20),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(_cards.length, (i) {
            return AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              margin: const EdgeInsets.symmetric(horizontal: 4),
              width: _page == i ? 20 : 8,
              height: 8,
              decoration: BoxDecoration(
                color: _page == i ? Colors.white : Colors.white30,
                borderRadius: BorderRadius.circular(4),
              ),
            );
          }),
        ),
        const SizedBox(height: 20),
        const Icon(Icons.keyboard_arrow_down, color: Colors.white54, size: 32),
        const SizedBox(height: 40),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// SUPPORT SECTION  (PDF pages 6-7)
// ─────────────────────────────────────────────────────────────────────────────

class _SupportSection extends StatelessWidget {
  const _SupportSection();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Rythmify supports\nindependent artists',
            style: GoogleFonts.inter(fontSize: 24, fontWeight: FontWeight.w800, color: Colors.white, height: 1.25),
          ),
          const SizedBox(height: 16),
          Text(
            'From fan-powered plays to artist tools, your subscription helps support the Rythmify global community.',
            style: GoogleFonts.inter(fontSize: 14, color: Colors.white70, height: 1.6),
          ),
          const SizedBox(height: 24),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: const BoxDecoration(
              border: Border(left: BorderSide(color: Color(0xFFFF5500), width: 3)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '"Your monthly fees go directly to the artists you love most."',
                  style: GoogleFonts.inter(fontSize: 15, fontWeight: FontWeight.w600,
                      color: Colors.white, fontStyle: FontStyle.italic),
                ),
                const SizedBox(height: 8),
                Text('– Rythmify Team',
                    style: GoogleFonts.inter(fontSize: 13, color: Colors.white54)),
              ],
            ),
          ),
          const SizedBox(height: 32),
          Center(
            child: Container(
              width: 180,
              height: 180,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: const Color(0xFF2E2E2E),
                boxShadow: [BoxShadow(color: Colors.black54, blurRadius: 30, offset: const Offset(0, 10))],
              ),
              child: const Icon(Icons.person, color: Colors.white30, size: 60),
            ),
          ),
          const SizedBox(height: 40),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// FAQ SECTION  (PDF pages 7-8 + 3 blue links → PDF pages 7, 8, 11)
// ─────────────────────────────────────────────────────────────────────────────

class _FaqSection extends StatelessWidget {
  final List<Map<String, String>> faqs;
  final List<bool> open;
  final void Function(int) onToggle;

  const _FaqSection({required this.faqs, required this.open, required this.onToggle});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 40),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Frequently asked questions',
              style: GoogleFonts.inter(fontSize: 22, fontWeight: FontWeight.w800, color: Colors.white)),
          const SizedBox(height: 24),
          ...List.generate(faqs.length, (i) => Column(
            children: [
              InkWell(
                onTap: () => onToggle(i),
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Text(faqs[i]['q']!,
                            style: GoogleFonts.inter(fontSize: 15, fontWeight: FontWeight.w600, color: Colors.white)),
                      ),
                      Icon(open[i] ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
                          color: Colors.white),
                    ],
                  ),
                ),
              ),
              if (open[i])
                Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: Text(faqs[i]['a']!,
                      style: GoogleFonts.inter(fontSize: 14, color: Colors.white70, height: 1.6)),
                ),
              const Divider(color: Colors.white12),
            ],
          )),
          const SizedBox(height: 32),
          // 3 blue links (PDF pages 7, 8, 11)
          BlueLink(
            label: 'Terms of Use',
            onTap: () => showTextDocSheet(context, 'Terms of Use', kTermsText),
          ),
          const SizedBox(height: 12),
          BlueLink(
            label: 'Privacy Policy',
            onTap: () => showTextDocSheet(context, 'Privacy Policy', kPrivacyText),
          ),
          const SizedBox(height: 12),
          BlueLink(
            label: 'Restrictions apply',
            onTap: () => showRestrictionsSheet(context),
          ),
        ],
      ),
    );
  }
}