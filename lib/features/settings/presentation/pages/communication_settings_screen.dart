import 'package:flutter/material.dart';
import 'package:rythmify/features/settings/presentation/widgets/privacy_policy_widget.dart';
import 'package:rythmify/features/settings/presentation/widgets/switch_tile_widget.dart';

/// Allows the user to toggle personalised news, tips, and offers.
/// Includes a restart warning and a link to the Privacy Policy.
class CommunicationSettingsScreen extends StatelessWidget {
  const CommunicationSettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: Theme.of(context).copyWith(
        splashColor: const Color(0xFF3A3A3A),
        highlightColor: const Color(0xFF2A2A2A),
      ),
      child: Scaffold(
        appBar: AppBar(title: const Text('Communications'), centerTitle: false),
        body: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SwitchTileWidget(
              key: Key('Communications_tile'),
              title:
                  'Personalise news, tips, and offers for SoundCloud products',
              subtitle:
                  'If you turn this setting off, the communications you\'ll see may be less relevant',
              initSwitchValue: true,
              onSwitchChanged: (val) {},
              onTap: () {},
            ),
            const SizedBox(height: 24),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                'changes require an app restart to become effective.',
                style: TextStyle(color: Colors.grey, fontSize: 14),
              ),
            ),
            const SizedBox(height: 16),
            PrivacyPolicyWidget(),
          ],
        ),
      ),
    );
  }
}
