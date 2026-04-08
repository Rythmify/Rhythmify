import 'package:flutter/material.dart';
import 'package:rythmify/features/settings/presentation/widgets/privacy_policy_widget.dart';
import 'package:rythmify/features/settings/presentation/widgets/reusable_tile_widget.dart';

class AnalyticsSettingsScreen extends StatelessWidget{
  const AnalyticsSettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: Theme.of(context).copyWith(
        splashColor: const Color(0xFF3A3A3A),
        highlightColor: const Color(0xFF2A2A2A),
      ),
      child: Scaffold(
          appBar: AppBar(title: const Text('Analytics'), centerTitle: false),
          body: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ReusableTileWidget(
                key: Key('Analytics_tile'),
                title: 'Help improve Rythmify by sending us regular usage and device data',
                switchExists: true,
                initSwitchValue: true,
                onTap: (){},
              ),
              const SizedBox(height: 24),
              Text(
                'changes require an app restart to become effective.',
                style: TextStyle(color: Colors.grey, fontSize: 14),
              ),
              const SizedBox(height: 16),
              PrivacyPolicyWidget()
            ],
          ),
        )
    );
  }
}