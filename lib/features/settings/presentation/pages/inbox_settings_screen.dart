import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:rythmify/features/settings/presentation/widgets/reusable_tile_widget.dart';
import 'package:rythmify/features/settings/presentation/widgets/settings_options_tile_widget.dart';

class InboxSettingsScreen extends StatelessWidget{
  const InboxSettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: Theme.of(context).copyWith(
        splashColor: const Color(0xFF3A3A3A),
        highlightColor: const Color(0xFF2A2A2A),
      ),
      child: Scaffold(
          appBar: AppBar(title: const Text('Inbox Settings'), centerTitle: false),
          body: Column(
            children: [
              ReusableTileWidget(
                key: Key('inbox_tile'),
                title: 'Receive messages from anyone',
                subtitle: 'If you turn this setting off, only people you follow will be able to send you messages',
                switchExists: true,
                initSwitchValue: true,
                onSwitchChanged: (val){},
                onTap: (){},
              ),
              const SizedBox(height: 24),
              SettingsOptionsTileWidget(
                key: Key('inbox_notification_settings_tile'),
                title: 'Notification settings',
                onTap: (){context.push('/library/settings/notifications');},
              )
            ],
          ),
        )
    );
  }
}