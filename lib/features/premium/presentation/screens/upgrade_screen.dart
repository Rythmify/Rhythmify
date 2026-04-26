import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../providers/premium_provider.dart';
import '../widgets/premium_widgets.dart';

// ── 4 plans — PDF pages 2-5 ──────────────────────────────────────────────────

const _kPlans = [
  (
    period: 'Monthly',
    periodBg: Color(0xFF9B4DCA),
    name: 'Artist Pro ★',
    price: 'EGP 164.99/month',
    planId: 'premium',
    features: [
      'Unlimited track uploads',
      'Get paid directly and more fairly',
      'Discover and connect with your biggest fans',
      'Unlimited distribution to all major streaming and social platforms',
    ],
  ),
  (
    period: 'Yearly',
    periodBg: Color(0xFFFF5500),
    name: 'Artist Pro ★',
    price: 'EGP 1,149.99/year',
    planId: 'premium',
    features: [
      'Unlimited track uploads',
      'Get paid directly and more fairly',
      'Discover and connect with your biggest fans',
      'Unlimited distribution to all major streaming and social platforms',
    ],
  ),
  (
    period: 'Monthly',
    periodBg: Color(0xFFCC2200),
    name: 'Artist ★',
    price: 'EGP 65.00/month',
    planId: 'premium',
    features: [
      '3 hours of uploads',
      '2 distributed and monetized tracks per month',
      'Discover and connect with your biggest fans',
      '3 replaceable tracks without losing stats per month',
    ],
  ),
  (
    period: 'Yearly',
    periodBg: Color(0xFFFF5500),
    name: 'Artist ★',
    price: 'EGP 479.99/year',
    planId: 'premium',
    features: [
      '3 hours of uploads',
      '2 distributed and monetized tracks per month',
      'Discover and connect with your biggest fans',
      '3 replaceable tracks without losing stats per month',
    ],
  ),
];

// ── Ombre palettes — random per session ──────────────────────────────────────
const _kPalettes = [
  [Color(0xFF6B1FBE), Color(0xFF3D0F8A)],
  [Color(0xFFCC1F88), Color(0xFF8A0F55)],
  [Color(0xFFCC3D1F), Color(0xFF8A2000)],
  [Color(0xFFE86B00), Color(0xFFBE4400)],
  [Color(0xFFDBAA00), Color(0xFF996600)],
  [Color(0xFFBE1F55), Color(0xFF8A0F35)],
];

// ─────────────────────────────────────────────────────────────────────────────
// UPGRADE SCREEN
// ─────────────────────────────────────────────────────────────────────────────

class UpgradeScreen extends ConsumerStatefulWidget {
  const UpgradeScreen({super.key});
  @override
  ConsumerState<UpgradeScreen> createState() => _UpgradeScreenState();
}

class _UpgradeScreenState extends ConsumerState<UpgradeScreen> {
  final _pageCtrl = PageController(viewportFraction: 0.92);
  int _activePlan = 0;
  late final int _paletteOffset;

  @override
  void initState() {
    super.initState();
    _paletteOffset = math.Random().nextInt(_kPalettes.length);
  }

  @override
  void dispose() {
    _pageCtrl.dispose();
    super.dispose();
  }

  List<Color> get _gradient {
    final idx = (_activePlan + _paletteOffset) % _kPalettes.length;
    return _kPalettes[idx];
  }

  Color get _stripColor => _gradient[0];

  @override
  Widget build(BuildContext context) {
    final mq = MediaQuery.of(context);
    final topPad = mq.padding.top;
    final botPad = mq.padding.bottom;

    return Scaffold(
      backgroundColor: _stripColor,
      body: AnimatedContainer(
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOut,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: _gradient,
          ),
        ),
        child: SingleChildScrollView(
          physics: const ClampingScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: topPad),

              // ── Back button ─────────────────────────────────────────────
              Padding(
                padding: const EdgeInsets.only(left: 4, top: 4),
                child: IconButton(
                  icon: Container(
                    width: 34,
                    height: 34,
                    decoration: const BoxDecoration(
                      color: Colors.black26,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.arrow_back_ios_new,
                      color: Colors.white,
                      size: 15,
                    ),
                  ),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ),

              // ── Headline ────────────────────────────────────────────────
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 4, 20, 20),
                child: Text(
                  "What's next in music is first\non Rythmify",
                  style: GoogleFonts.inter(
                    fontSize: 24,
                    fontWeight: FontWeight.w900,
                    color: Colors.white,
                    height: 1.15,
                  ),
                ),
              ),

              // ── Plan cards ─────────────────────────────────────────────
              LayoutBuilder(
                builder: (context, constraints) {
                  final cardWidth = constraints.maxWidth * 0.92;
                  return SizedBox(
                    height: _cardHeight(cardWidth),
                    child: PageView.builder(
                      controller: _pageCtrl,
                      itemCount: _kPlans.length,
                      onPageChanged: (p) => setState(() => _activePlan = p),
                      itemBuilder: (_, i) {
                        final p = _kPlans[i];
                        return _PlanCard(
                          periodTag: p.period,
                          periodBg: p.periodBg,
                          name: p.name,
                          price: p.price,
                          features: p.features,
                          onSubscribe: () {
                            final plans = ref.read(premiumProvider).plans;
                            final premiumPlan = plans.firstWhere(
                              (pl) => pl.isPremium,
                              orElse: () =>
                                  plans.isNotEmpty ? plans.last : plans.first,
                            );
                            context.push(
                              '/upgrade/checkout',
                              extra: {
                                'planId': premiumPlan.planId,
                                'planName': p.name,
                                'price': p.price,
                                'features': List<String>.from(p.features),
                              },
                            );
                          },
                        );
                      },
                    ),
                  );
                },
              ),

              // ── Dots ───────────────────────────────────────────────────
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 14),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(_kPlans.length, (i) {
                    final active = _activePlan == i;
                    return AnimatedContainer(
                      duration: const Duration(milliseconds: 250),
                      margin: const EdgeInsets.symmetric(horizontal: 3),
                      width: active ? 18 : 7,
                      height: 7,
                      decoration: BoxDecoration(
                        color: active ? Colors.white : Colors.white38,
                        borderRadius: BorderRadius.circular(4),
                      ),
                    );
                  }),
                ),
              ),

              // ── Down chevron ────────────────────────────────────────────
              const Center(
                child: Icon(
                  Icons.keyboard_arrow_down,
                  color: Colors.white70,
                  size: 28,
                ),
              ),
              const SizedBox(height: 10),

              // ── Dark info section ───────────────────────────────────────
              _DarkInfoSection(botPad: botPad),

              // ── Colored bottom strip ────────────────────────────────────
              AnimatedContainer(
                duration: const Duration(milliseconds: 400),
                height: 160 + botPad,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: _gradient,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  double _cardHeight(double cardWidth) => 500;
}

// ─────────────────────────────────────────────────────────────────────────────
// PLAN CARD
// ─────────────────────────────────────────────────────────────────────────────

class _PlanCard extends StatelessWidget {
  final String periodTag;
  final Color periodBg;
  final String name;
  final String price;
  final List<String> features;
  final VoidCallback onSubscribe;

  const _PlanCard({
    required this.periodTag,
    required this.periodBg,
    required this.name,
    required this.price,
    required this.features,
    required this.onSubscribe,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10),
      child: Container(
        decoration: const BoxDecoration(
          color: Color(0xFF1A1A1A),
          borderRadius: BorderRadius.zero,
        ),
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                _SharpTag(label: 'FOR ARTISTS', bg: const Color(0xFF2F80ED)),
                const SizedBox(width: 6),
                _SharpTag(label: periodTag, bg: periodBg),
              ],
            ),
            const SizedBox(height: 10),
            Text(
              name,
              style: GoogleFonts.inter(
                fontSize: 20,
                fontWeight: FontWeight.w900,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              price,
              style: GoogleFonts.inter(
                fontSize: 17,
                fontWeight: FontWeight.w700,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 14),
            ...features.map(
              (f) => Padding(
                padding: const EdgeInsets.only(bottom: 14),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Padding(
                      padding: EdgeInsets.only(top: 2),
                      child: Icon(Icons.check, color: Colors.white, size: 15),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        f,
                        style: GoogleFonts.inter(
                          fontSize: 13,
                          color: Colors.white,
                          height: 1.45,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 8),
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: Colors.black,
                  elevation: 0,
                  shape: const StadiumBorder(),
                ),
                onPressed: onSubscribe,
                child: Text(
                  'Subscribe now',
                  style: GoogleFonts.inter(
                    fontWeight: FontWeight.w600,
                    fontSize: 15,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 10),
            Text(
              'Cancel anytime.',
              style: GoogleFonts.inter(fontSize: 13, color: Colors.white60),
            ),
            const SizedBox(height: 4),
            GestureDetector(
              onTap: () => showRestrictionsSheet(context),
              child: Text(
                'Restrictions apply',
                style: GoogleFonts.inter(
                  fontSize: 13,
                  color: const Color(0xFF2F80ED),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// SHARP TAG
// ─────────────────────────────────────────────────────────────────────────────

class _SharpTag extends StatelessWidget {
  final String label;
  final Color bg;
  const _SharpTag({required this.label, required this.bg});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      color: bg,
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

// ─────────────────────────────────────────────────────────────────────────────
// DARK INFO SECTION
// ─────────────────────────────────────────────────────────────────────────────

class _DarkInfoSection extends StatefulWidget {
  final double botPad;
  const _DarkInfoSection({required this.botPad});
  @override
  State<_DarkInfoSection> createState() => _DarkInfoSectionState();
}

class _DarkInfoSectionState extends State<_DarkInfoSection> {
  final _faqOpen = [false, false];

  static const _faqs = [
    {
      'q': "What's the difference between fan and artist plans?",
      'a':
          'Our fan-oriented plans are designed for those who primarily visit '
          'the site to listen to music. Artist plans offer unique features '
          'designed to help artists create and distribute their music and content.',
    },
    {
      'q': 'Can I purchase an annual plan and/or family plan?',
      'a':
          'Unfortunately we do not currently offer an annual or family plan '
          'option for purchase in the app.',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xFF121212),
      padding: const EdgeInsets.fromLTRB(20, 28, 20, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Rythmify supports\nindependent artists',
            style: GoogleFonts.inter(
              fontSize: 22,
              fontWeight: FontWeight.w800,
              color: Colors.white,
              height: 1.2,
            ),
          ),
          const SizedBox(height: 14),
          Text(
            'From fan-powered royalties to our audience-building artist plans, '
            'your subscription helps support the Rythmify global community.',
            style: GoogleFonts.inter(
              fontSize: 14,
              color: Colors.white70,
              height: 1.65,
            ),
          ),
          const SizedBox(height: 22),
          Text(
            '"It\'s such a simple idea. Your monthly fees get split up between the songs"',
            style: GoogleFonts.inter(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Colors.white,
              fontStyle: FontStyle.italic,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            '– Rythmify artist',
            style: GoogleFonts.inter(fontSize: 13, color: Colors.white54),
          ),
          const SizedBox(height: 30),
          Center(
            child: Container(
              width: 150,
              height: 150,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: const Color(0xFF2A2A2A),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.35),
                    blurRadius: 18,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: ClipOval(
                child: Image.asset(
                  'assets/images/premiumartist.jpg',
                  width: 150,
                  height: 150,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) =>
                      const Icon(Icons.person, color: Colors.white24, size: 52),
                ),
              ),
            ),
          ),
          const SizedBox(height: 36),
          Text(
            'Frequently asked questions',
            style: GoogleFonts.inter(
              fontSize: 19,
              fontWeight: FontWeight.w800,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 16),
          ...List.generate(
            _faqs.length,
            (i) => Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                InkWell(
                  onTap: () => setState(() => _faqOpen[i] = !_faqOpen[i]),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Text(
                            _faqs[i]['q']!,
                            style: GoogleFonts.inter(
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                              height: 1.3,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Icon(
                          _faqOpen[i]
                              ? Icons.keyboard_arrow_up
                              : Icons.keyboard_arrow_down,
                          color: Colors.white,
                          size: 22,
                        ),
                      ],
                    ),
                  ),
                ),
                if (_faqOpen[i])
                  Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: Text(
                      _faqs[i]['a']!,
                      style: GoogleFonts.inter(
                        fontSize: 14,
                        color: Colors.white70,
                        height: 1.6,
                      ),
                    ),
                  ),
                const Divider(color: Colors.white12, height: 1),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
