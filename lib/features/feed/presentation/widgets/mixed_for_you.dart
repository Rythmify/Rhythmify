import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_theme.dart';
import '../providers/home_providers.dart';
import 'package:go_router/go_router.dart';
import '../../../authentication/presentation/providers/auth_provider.dart';
import '../../../authentication/presentation/providers/auth_state.dart';

class MixedPlaylistsSection extends ConsumerWidget {
  const MixedPlaylistsSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final asyncMixedForYou = ref.watch(mixedForYouProvider);

    return Column(
      key: const Key('mixed_for_you_section'),
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 6, left: 16),
          child: Text("Mixed For You", style: AppTheme.homeTitle),
        ),
        asyncMixedForYou.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, _) =>
              Text("Error: $e", key: const Key('mixed_for_you_error_text')),
          data: (items) {
            if (items.isEmpty) return const SizedBox.shrink();
            return SizedBox(
              height: 160,
              child: ListView.separated(
                key: const Key('mixed_list_view'),
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: items.length,
                separatorBuilder: (_, _) => const SizedBox(width: 12),
                itemBuilder: (context, index) {
                  final item = items[index];
                  return MixedPlaylistCard(
                    key: Key('mixed_for_you_item_${item.id}'),
                    id: item.id,
                    mixLabel: item.label,
                    artistName: item.previewTrack.artist,
                    imagePath: item.coverImage,
                  );
                },
              ),
            );
          },
        ),
      ],
    );
  }
}

class MixedPlaylistCard extends ConsumerWidget {
  final String id;
  final String mixLabel;
  final String artistName;
  final String imagePath;

  const MixedPlaylistCard({
    super.key,
    required this.id,
    required this.mixLabel,
    required this.artistName,
    required this.imagePath,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authProvider);
    final currentUserName = authState is AuthAuthenticated
        ? authState.user.displayName
        : '';
    return GestureDetector(
      onTap: () => context.push(
        '/mix/$id',
        extra: {
          'title': mixLabel,
          'ownerName': currentUserName, // ← now the signed-in user's name
          'mixType': 'genre',
          'coverUrl': imagePath,
          'trackCount': 0,
        },
      ),

      child: SizedBox(
        key: Key('mixed_card_container_$mixLabel'),
        width: 140,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              children: [
                Container(
                  key: Key('mixed_image_$mixLabel'),
                  height: 130,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(1),
                    border: Border.all(color: Colors.grey, width: 0.5),
                    image: imagePath.isNotEmpty
                        ? DecorationImage(
                            image: imagePath.startsWith('http')
                                ? NetworkImage(imagePath) as ImageProvider
                                : AssetImage(imagePath),
                            fit: BoxFit.cover,
                          )
                        : null,
                  ),
                  child: imagePath.isEmpty
                      ? const Center(child: Icon(Icons.music_note))
                      : null,
                ),
                Positioned(
                  bottom: 8,
                  left: 8,
                  child: Container(
                    padding: const EdgeInsets.only(top: 3, left: 10, right: 80),
                    decoration: BoxDecoration(
                      color: Colors.grey.withAlpha(180),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      key: Key('mixed_label_$mixLabel'),
                      mixLabel,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              key: Key('mixed_artists_$mixLabel'),
              artistName,
              style: const TextStyle(color: Colors.white70, fontSize: 12),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}
