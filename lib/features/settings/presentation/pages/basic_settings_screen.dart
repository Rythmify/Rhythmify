import 'package:flutter/material.dart';
import 'package:rythmify/features/settings/presentation/widgets/reusable_tile_widget.dart';

class BasicSettingsScreen extends StatelessWidget{
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
            children: [
              ReusableTileWidget(
                key: Key('Clear_application_cache_tile'),
                title: 'Clear application cache',
                subtitle: 'clear the application cache to free up memory on your device',
                switchExists: false,
                onTap: (){},
              ),
              const SizedBox(height: 20),
              ReusableTileWidget(
                key: Key('change_app_icon_tile'),
                title: 'Change app icon',
                subtitle: 'Custom app icons to match your style',
                switchExists: false,
                onTap: (){},
              )
            ],
          ),
        )
    );
  }
}