import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:rythmify/features/settings/domain/entities/notification_preferences_entity.dart';
import 'package:rythmify/features/settings/presentation/providers/notification_prefs_notifier.dart';
import 'package:rythmify/features/settings/presentation/widgets/switch_tile_widget.dart';
import 'package:rythmify/features/settings/presentation/widgets/settings_options_tile_widget.dart';

class InboxSettingsScreen extends ConsumerWidget {
  const InboxSettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final prefsAsync = ref.watch(notificationPrefsProvider);
    return Theme(
      data: Theme.of(context).copyWith(
        splashColor: const Color(0xFF3A3A3A),
        highlightColor: const Color(0xFF2A2A2A),
      ),
      child: Scaffold(
        appBar: AppBar(title: const Text('Inbox Settings'), centerTitle: false),
        body: prefsAsync.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, _) => Center(
            child: Text(
              'Error: $e',
              style: const TextStyle(color: Colors.white),
            ),
          ),
          data: (prefs) => Column(
            children: [
              SwitchTileWidget(
                key: const Key('inbox_tile'),
                title: 'Receive messages from anyone',
                subtitle:
                    'If turned off, only people you follow can send you messages',
                initSwitchValue: prefs.messagesFrom == MessagesFrom.everyone,
                onSwitchChanged: (value) {
                  ref.read(notificationPrefsProvider.notifier).save(
                    prefs.copyWith(
                      messagesFrom: value
                          ? MessagesFrom.everyone
                          : MessagesFrom.followersOnly,
                    ),
                  );
                },
                onTap: () {},
              ),
              const SizedBox(height: 24),
              SettingsOptionsTileWidget(
                key: const Key('inbox_notification_settings_tile'),
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
