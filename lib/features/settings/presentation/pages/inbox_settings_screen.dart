import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:rythmify/features/settings/presentation/providers/privacy_settings_notifier.dart';
import 'package:rythmify/features/settings/presentation/widgets/switch_tile_widget.dart';
import 'package:rythmify/features/settings/presentation/widgets/settings_options_tile_widget.dart';

/// Controls inbox message permissions via a switch tile.
/// Contains a link to [NotificationsSettingsScreen] for notification preferences.
class InboxSettingsScreen extends ConsumerWidget {
  const InboxSettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final privacyAsync = ref.watch(privacySettingsProvider);
    return Theme(
      data: Theme.of(context).copyWith(
        splashColor: const Color(0xFF3A3A3A),
        highlightColor: const Color(0xFF2A2A2A),
      ),
      child: Scaffold(
        appBar: AppBar(title: const Text('Inbox Settings'), centerTitle: false),
        body: privacyAsync.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, _) => Center(
            child: Text(
              'Error: $e',
              style: const TextStyle(color: Colors.white),
            ),
          ),
          data: (data) => Column(
            children: [
              SwitchTileWidget(
                key: Key('inbox_tile'),
                title: 'Receive messages from anyone',
                subtitle:
                    'If you turn this setting off, only people you follow will be able to send you messages',
                initSwitchValue: data.receiveMessageFromAnyone,
                onSwitchChanged: (value) {
                  ref
                      .read(privacySettingsProvider.notifier)
                      .save(data.copyWith(receiveMessageFromAnyone: value));
                },
                onTap: () {},
              ),
              const SizedBox(height: 24),
              SettingsOptionsTileWidget(
                key: Key('inbox_notification_settings_tile'),
                title: 'Notification settings',
                onTap: () {
                  context.push('/library/settings/notifications');
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
