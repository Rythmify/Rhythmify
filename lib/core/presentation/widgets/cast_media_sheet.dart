import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_chrome_cast/flutter_chrome_cast.dart';
import 'package:rythmify/core/network/api_client.dart';
import 'package:rythmify/core/theme/app_theme.dart';
import 'package:rythmify/features/player/presentation/providers/player_provider.dart';

/// Opens a shared cast UI for app cast buttons.
Future<void> showCastMediaSheet(BuildContext context, WidgetRef ref) async {
  final track = ref.read(playerStateProvider).currentTrack;
  GoogleCastDiscoveryManager.instance.startDiscovery();

  try {
    await showModalBottomSheet(
      context: context,
      backgroundColor: AppTheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 200),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Cast media',
                  style: AppTheme.titleMedium.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  track == null
                      ? 'Play a track first, then pick a TV.'
                      : 'Choose a device for "${track.title}"',
                  style: AppTheme.bodyMedium,
                ),
                const SizedBox(height: 12),
                StreamBuilder<List<GoogleCastDevice>>(
                  stream: GoogleCastDiscoveryManager.instance.devicesStream,
                  builder: (context, snapshot) {
                    final devices = snapshot.data ?? const <GoogleCastDevice>[];
                    if (devices.isEmpty) {
                      return const Padding(
                        padding: EdgeInsets.symmetric(vertical: 14),
                        child: Text('Searching for Cast devices...'),
                      );
                    }

                    return ConstrainedBox(
                      constraints: const BoxConstraints(maxHeight: 300),
                      child: ListView.builder(
                        shrinkWrap: true,
                        itemCount: devices.length,
                        itemBuilder: (context, index) {
                          final d = devices[index];
                          return ListTile(
                            leading: const Icon(Icons.cast),
                            title: Text(d.friendlyName),
                            subtitle: Text(d.modelName ?? ''),
                            onTap: track == null
                                ? null
                                : () async {
                                    try {
                                      await GoogleCastSessionManager.instance
                                          .startSessionWithDevice(d);

                                      final mediaUri = _resolveCastableUri(
                                        track.streamUrl ?? track.audioUrl,
                                      );
                                      if (mediaUri == null) {
                                        throw Exception(
                                          'Current media URL is not castable.',
                                        );
                                      }

                                      final mediaInfo =
                                          GoogleCastMediaInformation(
                                            contentId: track.id,
                                            streamType:
                                                CastMediaStreamType.buffered,
                                            contentUrl: mediaUri,
                                            contentType: _guessContentType(
                                              mediaUri.toString(),
                                            ),
                                            metadata:
                                                GoogleCastMovieMediaMetadata(
                                                  title: track.title,
                                                  subtitle: track.artist,
                                                  images: [
                                                    if (_resolveCastableUri(
                                                          track.artworkUrl,
                                                        )
                                                        case final artworkUri?)
                                                      GoogleCastImage(
                                                        url: artworkUri,
                                                        height: 300,
                                                        width: 300,
                                                      ),
                                                  ],
                                                ),
                                          );

                                      await GoogleCastRemoteMediaClient.instance
                                          .loadMedia(mediaInfo);

                                      if (context.mounted) {
                                        Navigator.of(context).pop();
                                        ScaffoldMessenger.of(
                                          context,
                                        ).showSnackBar(
                                          SnackBar(
                                            content: Text(
                                              'Casting to ${d.friendlyName}',
                                            ),
                                          ),
                                        );
                                      }
                                    } catch (e) {
                                      if (context.mounted) {
                                        ScaffoldMessenger.of(
                                          context,
                                        ).showSnackBar(
                                          SnackBar(
                                            content: Text(
                                              'Cast failed: ${e.toString()}',
                                            ),
                                          ),
                                        );
                                      }
                                    }
                                  },
                          );
                        },
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  } finally {
    GoogleCastDiscoveryManager.instance.stopDiscovery();
  }
}

String _guessContentType(String url) {
  final lower = url.toLowerCase();
  if (lower.endsWith('.m3u8')) return 'application/x-mpegURL';
  if (lower.endsWith('.mp3')) return 'audio/mpeg';
  if (lower.endsWith('.aac')) return 'audio/aac';
  if (lower.endsWith('.m4a')) return 'audio/mp4';
  if (lower.endsWith('.wav')) return 'audio/wav';
  return 'audio/mpeg';
}

Uri? _resolveCastableUri(String rawUrl) {
  final trimmed = rawUrl.trim();
  if (trimmed.isEmpty) return null;

  final parsed = Uri.tryParse(trimmed);
  if (parsed != null &&
      parsed.hasScheme &&
      (parsed.scheme == 'http' || parsed.scheme == 'https')) {
    return parsed;
  }

  final base = Uri.parse(ApiClient.baseUrl);
  final origin = Uri(
    scheme: base.scheme,
    host: base.host,
    port: base.hasPort ? base.port : null,
  );
  final resolved = origin.resolve(trimmed);
  if (resolved.scheme == 'http' || resolved.scheme == 'https') {
    return resolved;
  }

  return null;
}
