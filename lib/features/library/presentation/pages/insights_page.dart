import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_theme.dart';
import '../providers/library_providers.dart';
import '../../domain/entities/library_entities.dart';

/// Analytics dashboard showing listener stats for the creator's uploaded tracks.
///
/// Displays a summary card with totals at the top, then a per-track breakdown.
class InsightsPage extends ConsumerWidget {
  const InsightsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(insightsProvider);

    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(title: const Text('Your Insights'), centerTitle: false),
      body: async.when(
        loading: () => const Center(child: CircularProgressIndicator(color: AppTheme.primaryBrand)),
        error: (e, _) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(e.toString(), style: AppTheme.bodyMedium),
              const SizedBox(height: 16),
              ElevatedButton(
                key: const Key('insights_retry_button'),
                onPressed: () => ref.invalidate(insightsProvider),
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
        data: (insights) {
          if (insights.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.bar_chart, color: AppTheme.textSecondary, size: 56),
                  const SizedBox(height: 16),
                  Text('No insights yet', style: AppTheme.titleMedium.copyWith(color: AppTheme.textSecondary)),
                  const SizedBox(height: 8),
                  Text('Upload tracks to see your listener stats.', style: AppTheme.bodyMedium, textAlign: TextAlign.center),
                ],
              ),
            );
          }

          // Compute totals
          final totalPlays = insights.fold(0, (s, i) => s + i.totalPlays);
          final totalListeners = insights.fold(0, (s, i) => s + i.uniqueListeners);
          final totalLikes = insights.fold(0, (s, i) => s + i.likes);

          return ListView(
            key: const Key('insights_list_view'),
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 120),
            children: [
              // ── Summary card ──────────────────────────────────────────────
              _SummaryCard(
                totalPlays: totalPlays,
                totalListeners: totalListeners,
                totalLikes: totalLikes,
              ),
              const SizedBox(height: 24),
              Text('By Track', style: AppTheme.titleMedium),
              const SizedBox(height: 12),
              // ── Per-track rows ─────────────────────────────────────────────
              ...insights.map((insight) => _InsightTrackCard(insight: insight)),
            ],
          );
        },
      ),
    );
  }
}

class _SummaryCard extends StatelessWidget {
  final int totalPlays;
  final int totalListeners;
  final int totalLikes;

  const _SummaryCard({
    required this.totalPlays,
    required this.totalListeners,
    required this.totalLikes,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      key: const Key('insights_summary_card'),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.primaryBrand.withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('All time', style: AppTheme.labelSmall),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(child: _StatItem(icon: Icons.play_arrow, label: 'Plays', value: _fmt(totalPlays), key: const Key('insights_total_plays_stat'))),
              Expanded(child: _StatItem(icon: Icons.people_outline, label: 'Listeners', value: _fmt(totalListeners), key: const Key('insights_total_listeners_stat'))),
              Expanded(child: _StatItem(icon: Icons.favorite_border, label: 'Likes', value: _fmt(totalLikes), key: const Key('insights_total_likes_stat'))),
            ],
          ),
        ],
      ),
    );
  }

  String _fmt(int n) {
    if (n >= 1000000) return '${(n / 1000000).toStringAsFixed(1)}M';
    if (n >= 1000) return '${(n / 1000).toStringAsFixed(1)}K';
    return n.toString();
  }
}

class _StatItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _StatItem({required this.icon, required this.label, required this.value, super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(icon, color: AppTheme.primaryBrand, size: 22),
        const SizedBox(height: 6),
        Text(value, style: AppTheme.titleMedium.copyWith(fontSize: 20)),
        const SizedBox(height: 2),
        Text(label, style: AppTheme.labelSmall),
      ],
    );
  }
}

class _InsightTrackCard extends StatelessWidget {
  final TrackInsight insight;

  const _InsightTrackCard({required this.insight});

  @override
  Widget build(BuildContext context) {
    return Container(
      key: Key('insights_track_${insight.trackId}_card'),
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(color: AppTheme.surface, borderRadius: BorderRadius.circular(10)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Track header
          Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: insight.artworkUrl != null
                    ? CachedNetworkImage(imageUrl: insight.artworkUrl!, width: 44, height: 44, fit: BoxFit.cover, errorWidget: (c, u, e) => _placeholder())
                    : _placeholder(),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  insight.title,
                  key: Key('insights_track_${insight.trackId}_title_text'),
                  style: AppTheme.labelLarge,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          // Stats row
          Row(
            children: [
              Expanded(child: _MiniStat(icon: Icons.play_arrow, value: _fmt(insight.totalPlays), label: 'plays', key: Key('insights_track_${insight.trackId}_plays_stat'))),
              Expanded(child: _MiniStat(icon: Icons.people_outline, value: _fmt(insight.uniqueListeners), label: 'listeners', key: Key('insights_track_${insight.trackId}_listeners_stat'))),
              Expanded(child: _MiniStat(icon: Icons.favorite_border, value: _fmt(insight.likes), label: 'likes', key: Key('insights_track_${insight.trackId}_likes_stat'))),
              Expanded(child: _MiniStat(icon: Icons.repeat, value: _fmt(insight.reposts), label: 'reposts', key: Key('insights_track_${insight.trackId}_reposts_stat'))),
            ],
          ),
        ],
      ),
    );
  }

  Widget _placeholder() => Container(width: 44, height: 44, color: AppTheme.lighterSurface, child: const Icon(Icons.music_note, color: AppTheme.textSecondary, size: 20));

  String _fmt(int n) {
    if (n >= 1000) return '${(n / 1000).toStringAsFixed(1)}K';
    return n.toString();
  }
}

class _MiniStat extends StatelessWidget {
  final IconData icon;
  final String value;
  final String label;

  const _MiniStat({required this.icon, required this.value, required this.label, super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(icon, color: AppTheme.textSecondary, size: 16),
        const SizedBox(height: 4),
        Text(value, style: AppTheme.labelLarge.copyWith(fontSize: 13)),
        Text(label, style: AppTheme.labelSmall.copyWith(fontSize: 10)),
      ],
    );
  }
}
