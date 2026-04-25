import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:rythmify/core/presentation/widgets/cast_media_sheet.dart';
import '../../../../core/theme/app_theme.dart';
import '../providers/library_providers.dart';
import '../../domain/entities/library_entities.dart';

/// Displays analytics insights for the current user's uploaded tracks.
///
/// - "SoundCloud" tab: if user has uploads, shows per-track stats.
///   If empty, shows marketing screen with "Upload" CTA button.
/// - "All Platforms" tab: premium upsell marketing screen
///   with "Goes to premium 'Pro'" CTA button.
class InsightsPage extends ConsumerStatefulWidget {
  /// Creates an [InsightsPage].
  const InsightsPage({super.key});

  @override
  ConsumerState<InsightsPage> createState() => _InsightsPageState();
}

/// State for [InsightsPage] managing tab selection.
class _InsightsPageState extends ConsumerState<InsightsPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        title: const Text('Your insights'),
        centerTitle: false,
        actions: [
          TextButton(
            key: const Key('insights_upgrade_pro_button'),
            onPressed: () => context.push('/upgrade'),
            style: TextButton.styleFrom(
              backgroundColor: const Color(0xFFFF7A00),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              minimumSize: Size.zero,
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(18),
              ),
            ),
            child: const Text(
              'Upgrade to Pro',
              style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700),
            ),
          ),
          const SizedBox(width: 4),
          IconButton(
            key: const Key('insights_share_icon_button'),
            icon: const Icon(Icons.share_outlined),
            onPressed: () {},
          ),
          IconButton(
            key: const Key('insights_cast_icon_button'),
            icon: const Icon(Icons.cast),
            onPressed: () => showCastMediaSheet(context, ref),
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: AppTheme.primaryBrand,
          indicatorWeight: 3,
          indicatorSize: TabBarIndicatorSize.tab,
          labelColor: AppTheme.textPrimary,
          unselectedLabelColor: AppTheme.textSecondary,
          labelStyle: AppTheme.labelLarge.copyWith(fontWeight: FontWeight.w600),
          unselectedLabelStyle: AppTheme.labelLarge,
          tabs: const [
            Tab(text: 'SoundCloud'),
            Tab(text: 'All Platforms'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [_SoundCloudTab(), _AllPlatformsTab()],
      ),
    );
  }
}

/// Builds the SoundCloud insights tab with loading/error/data states.
///
/// Watches [insightsProvider] and handles all three [AsyncValue] states:
/// - loading: Shows centered spinner
/// - error: Shows error message with retry button
/// - data: Shows empty state or insights data view
class _SoundCloudTab extends ConsumerWidget {
  /// Creates a [_SoundCloudTab].
  const _SoundCloudTab();
  
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(insightsProvider);

    return async.when(
      loading: () => const Center(
        child: CircularProgressIndicator(color: AppTheme.primaryBrand),
      ),
      error: (e, _) => Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(e.toString(), style: AppTheme.bodyMedium),
            const SizedBox(height: 16),
            ElevatedButton(
              key: const Key('insights_sc_retry_button'),
              onPressed: () => ref.invalidate(insightsProvider),
              child: const Text('Retry'),
            ),
          ],
        ),
      ),
      data: (insights) => insights.isEmpty
          ? _SoundCloudEmptyState()
          : _SoundCloudDataView(insights: insights),
    );
  }
}

/// Marketing empty state for the SoundCloud tab.
class _SoundCloudEmptyState extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ListView(
      key: const Key('insights_sc_empty_state'),
      padding: EdgeInsets.zero,
      children: [
        Container(
          width: double.infinity,
          height: 220,
          color: Colors.black,
          child: Stack(
            alignment: Alignment.center,
            children: [
              Icon(
                Icons.equalizer_rounded,
                size: 140,
                color: AppTheme.primaryBrand.withValues(alpha: 0.3),
              ),
              Icon(
                Icons.analytics_outlined,
                size: 80,
                color: AppTheme.primaryBrand.withValues(alpha: 0.7),
              ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(28, 28, 28, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Get unmatched insights into your listeners that you won\'t find anywhere else.',
                key: Key('insights_sc_headline_text'),
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                  height: 1.3,
                ),
              ),
              const SizedBox(height: 14),
              Text(
                'SoundCloud is the only platform that lets you easily identify and connect with your top fans based on their listening and engagement habits.',
                key: Key('insights_sc_body_text'),
                style: AppTheme.bodyMedium.copyWith(height: 1.5),
              ),
              const SizedBox(height: 8),
              Text(
                'To get started, all it takes is an upload.',
                style: AppTheme.bodyMedium,
              ),
              const SizedBox(height: 22),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  key: const Key('insights_sc_upload_button'),
                  onPressed: () => context.push('/upload-track'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppTheme.textPrimary,
                    side: const BorderSide(color: AppTheme.textSecondary),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(6),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                  child: const Text(
                    'Upload',
                    style: TextStyle(fontWeight: FontWeight.w700, fontSize: 15),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

/// Data view shown when the user has uploads.
class _SoundCloudDataView extends StatelessWidget {
  final List<TrackInsight> insights;
  const _SoundCloudDataView({required this.insights});

  @override
  Widget build(BuildContext context) {
    final totalPlays = insights.fold(0, (s, i) => s + i.totalPlays);
    final totalListeners = insights.fold(0, (s, i) => s + i.uniqueListeners);
    final totalLikes = insights.fold(0, (s, i) => s + i.likes);

    return ListView(
      key: const Key('insights_sc_data_list_view'),
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 120),
      children: [
        // Summary card
        Container(
          key: const Key('insights_summary_card'),
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: AppTheme.surface,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: AppTheme.primaryBrand.withValues(alpha: 0.3),
            ),
          ),
          child: Row(
            children: [
              Expanded(
                child: _StatItem(
                  icon: Icons.play_arrow,
                  label: 'Plays',
                  value: _fmt(totalPlays),
                  key: const Key('insights_total_plays_stat'),
                ),
              ),
              Expanded(
                child: _StatItem(
                  icon: Icons.people_outline,
                  label: 'Listeners',
                  value: _fmt(totalListeners),
                  key: const Key('insights_total_listeners_stat'),
                ),
              ),
              Expanded(
                child: _StatItem(
                  icon: Icons.favorite_border,
                  label: 'Likes',
                  value: _fmt(totalLikes),
                  key: const Key('insights_total_likes_stat'),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),
        Text('By Track', style: AppTheme.titleMedium),
        const SizedBox(height: 12),
        ...insights.map((insight) => _InsightTrackCard(insight: insight)),
      ],
    );
  }

  String _fmt(int n) {
    if (n >= 1000000) return '${(n / 1000000).toStringAsFixed(1)}M';
    if (n >= 1000) return '${(n / 1000).toStringAsFixed(1)}K';
    return n.toString();
  }
}

class _AllPlatformsTab extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ListView(
      key: const Key('insights_all_platforms_tab_scroll'),
      padding: EdgeInsets.zero,
      children: [
        Container(
          width: double.infinity,
          height: 220,
          color: Colors.black,
          child: Stack(
            alignment: Alignment.center,
            children: [
              Icon(
                Icons.devices_rounded,
                size: 140,
                color: Colors.purple.withValues(alpha: 0.2),
              ),
              Icon(
                Icons.multitrack_audio_rounded,
                size: 80,
                color: Colors.purpleAccent.withValues(alpha: 0.7),
              ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(28, 28, 28, 24),
          child: Column(
            key: const Key('insights_all_platforms_tab'),
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Unlock key performance and audience insights across multiple platforms for your music',
                key: Key('insights_ap_headline_text'),
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                  height: 1.3,
                ),
              ),
              const SizedBox(height: 14),
              Text(
                'Access audience and performance insights for your distributed tracks from Spotify, Apple Music, and SoundCloud all from one dashboard.',
                key: Key('insights_ap_body_text'),
                style: AppTheme.bodyMedium.copyWith(height: 1.5),
              ),
              const SizedBox(height: 8),
              Text(
                'Upgrade your account, upload and distribute your track to get started.',
                style: AppTheme.bodyMedium,
              ),
              const SizedBox(height: 22),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  key: const Key('insights_ap_upgrade_button'),
                  onPressed: () => context.push('/upgrade'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppTheme.textPrimary,
                    side: const BorderSide(color: AppTheme.textSecondary),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(6),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                  child: const Text(
                    'Upgrade to Pro',
                    style: TextStyle(fontWeight: FontWeight.w700, fontSize: 15),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _StatItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _StatItem({
    required this.icon,
    required this.label,
    required this.value,
    super.key,
  });

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
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: insight.artworkUrl != null
                    ? CachedNetworkImage(
                        imageUrl: insight.artworkUrl!,
                        width: 44,
                        height: 44,
                        fit: BoxFit.cover,
                        errorWidget: (c, u, e) => _placeholder(),
                      )
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
          Row(
            children: [
              Expanded(
                child: _MiniStat(
                  icon: Icons.play_arrow,
                  value: _fmt(insight.totalPlays),
                  label: 'plays',
                  key: Key('insights_track_${insight.trackId}_plays_stat'),
                ),
              ),
              Expanded(
                child: _MiniStat(
                  icon: Icons.people_outline,
                  value: _fmt(insight.uniqueListeners),
                  label: 'listeners',
                  key: Key('insights_track_${insight.trackId}_listeners_stat'),
                ),
              ),
              Expanded(
                child: _MiniStat(
                  icon: Icons.favorite_border,
                  value: _fmt(insight.likes),
                  label: 'likes',
                  key: Key('insights_track_${insight.trackId}_likes_stat'),
                ),
              ),
              Expanded(
                child: _MiniStat(
                  icon: Icons.repeat,
                  value: _fmt(insight.reposts),
                  label: 'reposts',
                  key: Key('insights_track_${insight.trackId}_reposts_stat'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _placeholder() => Container(
    width: 44,
    height: 44,
    color: AppTheme.lighterSurface,
    child: const Icon(
      Icons.music_note,
      color: AppTheme.textSecondary,
      size: 20,
    ),
  );
  String _fmt(int n) =>
      n >= 1000 ? '${(n / 1000).toStringAsFixed(1)}K' : n.toString();
}

class _MiniStat extends StatelessWidget {
  final IconData icon;
  final String value;
  final String label;

  const _MiniStat({
    required this.icon,
    required this.value,
    required this.label,
    super.key,
  });

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
