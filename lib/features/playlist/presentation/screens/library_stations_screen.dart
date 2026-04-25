// lib/features/playlist/presentation/screens/library_stations_screen.dart
// ignore_for_file: avoid_print
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_theme.dart';
import '../../data/local/local_saved_store.dart';
import '../providers/saved_content_provider.dart';

class LibraryStationsScreen extends ConsumerStatefulWidget {
  const LibraryStationsScreen({super.key});

  @override
  ConsumerState<LibraryStationsScreen> createState() =>
      _LibraryStationsScreenState();
}

class _LibraryStationsScreenState
    extends ConsumerState<LibraryStationsScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabs;

  @override
  void initState() {
    super.initState();
    _tabs = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabs.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        backgroundColor: AppTheme.background,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.chevron_left,
              color: AppTheme.textPrimary, size: 28),
          onPressed: () => context.pop(),
        ),
        title: Text('Stations', style: AppTheme.titleLarge),
        bottom: TabBar(
          controller: _tabs,
          labelColor: AppTheme.primaryBrand,
          unselectedLabelColor: AppTheme.textSecondary,
          indicatorColor: AppTheme.primaryBrand,
          tabs: const [
            Tab(text: 'Saved'),
            Tab(text: 'Browse'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabs,
        children: [
          _SavedStationsTab(),
          _BrowseStationsTab(),
        ],
      ),
    );
  }
}

// ── Saved Stations — reads from backend via savedStationsProvider ─────────────
class _SavedStationsTab extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final asyncStations = ref.watch(savedStationsProvider);

    return asyncStations.when(
      loading: () => const Center(
        child: CircularProgressIndicator(color: AppTheme.primaryBrand),
      ),
      error: (e, _) => Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Could not load stations',
                style: AppTheme.bodyMedium),
            const SizedBox(height: 12),
            TextButton(
              onPressed: () =>
                  ref.read(savedStationsProvider.notifier).refresh(),
              child: Text('Retry',
                  style: AppTheme.bodyMedium
                      .copyWith(color: AppTheme.primaryBrand)),
            ),
          ],
        ),
      ),
      data: (stations) {
        if (stations.isEmpty) {
          return Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.sensors_off,
                    color: AppTheme.textSecondary, size: 48),
                const SizedBox(height: 12),
                Text('No saved stations yet', style: AppTheme.bodyMedium),
                const SizedBox(height: 4),
                Text('Save stations from the home screen',
                    style: AppTheme.labelSmall),
              ],
            ),
          );
        }

        return RefreshIndicator(
          color: AppTheme.primaryBrand,
          backgroundColor: AppTheme.surface,
          onRefresh: () =>
              ref.read(savedStationsProvider.notifier).refresh(),
          child: ListView.builder(
            padding: const EdgeInsets.only(bottom: 140),
            itemCount: stations.length,
            itemBuilder: (context, i) {
              final s = stations[i];
              return _StationTile(
                station: s,
                onTap: () => context.push(
                  '/home/station/${s.artistId}',
                  extra: {
                    'artistName': s.artistName,
                    'stationName': s.stationName,
                    'coverUrl': s.coverUrl,
                  },
                ),
                onUnsave: () =>
                    ref.read(savedStationsProvider.notifier).toggle(s),
              );
            },
          ),
        );
      },
    );
  }
}

// ── Browse tab — placeholder for station discovery ────────────────────────────
class _BrowseStationsTab extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.sensors, color: AppTheme.textSecondary, size: 48),
          const SizedBox(height: 12),
          Text('Discover stations on the home screen',
              style: AppTheme.bodyMedium),
        ],
      ),
    );
  }
}

// ── Station tile ──────────────────────────────────────────────────────────────
class _StationTile extends StatelessWidget {
  const _StationTile({
    required this.station,
    required this.onTap,
    required this.onUnsave,
  });

  final SavedStation station;
  final VoidCallback onTap;
  final VoidCallback onUnsave;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: onTap,
      contentPadding:
          const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      leading: ClipRRect(
        borderRadius: BorderRadius.circular(4),
        child: SizedBox(
          width: 52,
          height: 52,
          child: station.coverUrl != null &&
                  station.coverUrl!.startsWith('http')
              ? Image.network(
                  station.coverUrl!,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => _placeholder(),
                )
              : _placeholder(),
        ),
      ),
      title: Text(
        station.stationName,
        style: AppTheme.bodyNormal,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      subtitle: Text(
        '${station.trackCount} tracks',
        style: AppTheme.labelSmall,
      ),
      trailing: IconButton(
        icon: const Icon(Icons.sensors_off,
            color: AppTheme.textSecondary, size: 20),
        tooltip: 'Remove station',
        onPressed: onUnsave,
      ),
    );
  }

  Widget _placeholder() => Container(
        color: AppTheme.surface,
        child: Center(
          child: Text(
            station.stationName.isNotEmpty
                ? station.stationName[0].toUpperCase()
                : 'S',
            style: const TextStyle(
              color: AppTheme.textSecondary,
              fontSize: 20,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      );
}