import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/home_providers.dart';
import '../../../track/presentation/widgets/track_card.dart';

class RelatedTracksPage extends ConsumerWidget {
  const RelatedTracksPage({
    super.key,
    required this.trackId,
    required this.trackTitle,
  });

  final String trackId;
  final String trackTitle;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(relatedTracksProvider(trackId));

    return Scaffold(
      appBar: AppBar(title: Text('Related to $trackTitle')),
      body: async.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
        data: (tracks) => ListView.builder(
          padding: const EdgeInsets.only(bottom: 100),
          itemCount: tracks.length,
          itemBuilder: (_, i) => TrackCard(track: tracks[i]),
        ),
      ),
    );
  }
}
