import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/home_providers.dart';
import '../../../track/presentation/widgets/track_card.dart';
import '../../../player/presentation/providers/queue_provider.dart';

class MixTracksPage extends ConsumerWidget {
  const MixTracksPage({super.key, required this.mixId, required this.title});
  final String mixId;
  final String title;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(mixTracksProvider(mixId));

    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: async.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
        data: (tracks) => ListView.builder(
          padding: const EdgeInsets.only(bottom: 100),
          itemCount: tracks.length,
          itemBuilder: (_, i) => TrackCard(
            track: tracks[i],
            onTap: () {
              ref.read(queueStateProvider.notifier).playQueue(
                    tracks: tracks,
                    initialIndex: i,
                  );
            },
          ),
        ),
      ),
    );
  }
}
