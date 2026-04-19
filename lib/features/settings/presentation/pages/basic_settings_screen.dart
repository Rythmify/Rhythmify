import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:rythmify/features/settings/presentation/widgets/no_switch_tile_widget.dart';

/// Provides basic app settings including cache clearing and app icon customisation.
/// Cache clearing shows a confirmation dialog before proceeding.
class BasicSettingsScreen extends StatelessWidget {
  const BasicSettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: Theme.of(context).copyWith(
        splashColor: const Color(0xFF3A3A3A),
        highlightColor: const Color(0xFF2A2A2A),
      ),
      child: Scaffold(
        appBar: AppBar(title: const Text('Basic Settings'), centerTitle: false),
        body: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            NoSwitchTileWidget(
              key: Key('Clear_application_cache_tile'),
              title: 'Clear application cache',
              subtitle:
                  'clear the application cache to free up memory on your device',
              onTap: () async {
                final confirmClearCache = await showDialog<bool>(
                  context: context,
                  builder: (context) => AlertDialog(
                    backgroundColor: const Color(0xFF2A2A2A),
                    title: const Text(
                      'Are you Sure you want to clear the app cache',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    content: const Text(
                      'This will restart the app and stop any ongoing playback',
                      style: TextStyle(color: Colors.white),
                    ),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context, false),
                        child: const Text(
                          'NO',
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                      TextButton(
                        onPressed: () => Navigator.pop(context, true),
                        child: const Text('YES'),
                      ),
                    ],
                  ),
                );

                if (confirmClearCache == true) {}
              },
            ),
            NoSwitchTileWidget(
              key: Key('change_app_icon_tile'),
              title: 'Change app icon',
              subtitle: 'Custom app icons to match your style',
              onTap: () {
                context.push('/library/settings/basic-settings/app-icons');
              },
            ),
          ],
        ),
      ),
    );
  }
}
