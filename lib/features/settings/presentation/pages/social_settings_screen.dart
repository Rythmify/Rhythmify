import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rythmify/features/settings/presentation/providers/floating_comments_visibility_provider.dart';
import 'package:rythmify/features/settings/presentation/providers/privacy_settings_notifier.dart';
import 'package:rythmify/features/settings/presentation/widgets/switch_tile_widget.dart';

/// Controls social visibility preferences divided into two sections:
/// "Social networking" for waveform comments and activity visibility,
/// and "Insights visibility" for First/Top Fan status display.
class SocialSettingsScreen extends ConsumerWidget {
  const SocialSettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final privacyAsync = ref.watch(privacySettingsProvider);
    return Theme(
      data: Theme.of(context).copyWith(
        splashColor: const Color(0xFF3A3A3A),
        highlightColor: const Color(0xFF2A2A2A),
      ),
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Social settings'),
          centerTitle: false,
        ),
        body: privacyAsync.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, _) => Center(
            child: Text(
              'Error: $e',
              style: const TextStyle(color: Colors.white),
            ),
          ),
          data: (data) {
            final showWaveformComments =
                ref.watch(floatingCommentsVisibilityProvider);
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Text(
                    'Social networking',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                SwitchTileWidget(
                  key: const Key('show_comments_tile'),
                  title: 'Show comments and reactions on the waveform',
                  subtitle:
                      'Waveform comments and reactions are visible in the fullscreen player',
                  initSwitchValue: showWaveformComments,
                  onSwitchChanged: (value) {
                    ref
                        .read(floatingCommentsVisibilityProvider.notifier)
                        .set(value);
                  },
                ),
                SwitchTileWidget(
                  key: const Key('show_activities_tile'),
                  title:
                      'Show my activities in social discovery playlists and modules',
                  subtitle:
                      "Your Likes, Reactions and other engagement may be shown to other users in discovery features such as 'Liked By' playlists or update feeds. Turning this off won't hide your Likes on your profile or tracks.",
                  initSwitchValue: data.showActivitiesInDiscovery,
                  onSwitchChanged: (value) {
                    ref
                        .read(privacySettingsProvider.notifier)
                        .save(data.copyWith(showActivitiesInDiscovery: value));
                  },
                ),
                const SizedBox(height: 2),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Text(
                    'Insights visibility',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                SwitchTileWidget(
                  key: const Key('show_top_fan_tile'),
                  title: "Show when I'm a First or Top Fan",
                  subtitle:
                      'You will appear in public First Fans and Top Fans lists',
                  initSwitchValue: data.showAsTopFan,
                  onSwitchChanged: (value) {
                    ref
                        .read(privacySettingsProvider.notifier)
                        .save(data.copyWith(showAsTopFan: value));
                  },
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
