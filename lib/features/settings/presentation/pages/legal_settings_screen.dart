import 'package:flutter/material.dart';
import 'package:rythmify/features/settings/presentation/widgets/settings_options_tile_widget.dart';

/// Displays legal information tiles including copyright, terms of use,
/// privacy policy, and imprint. Each tile navigates to the respective page.
class LegalSettingsScreen extends StatelessWidget {
  const LegalSettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: Theme.of(context).copyWith(
        splashColor: const Color(0xFF3A3A3A),
        highlightColor: const Color(0xFF2A2A2A),
      ),
      child: Scaffold(
        appBar: AppBar(title: const Text('Legal'), centerTitle: false),
        body: Column(
          children: [
            SettingsOptionsTileWidget(
              key: Key('legal-copyright-settings-tile'),
              title: 'Copyright information',
              onTap: () {},
            ),
            SettingsOptionsTileWidget(
              key: Key('legal-terms-of-use-settings-tile'),
              title: 'Terms of use',
              onTap: () {},
            ),
            SettingsOptionsTileWidget(
              key: Key('legal-privacy-policy-settings-tile'),
              title: 'Privacy Policy',
              onTap: () {},
            ),
            SettingsOptionsTileWidget(
              key: Key('legal-imprint-settings-tile'),
              title: 'Imprint',
              onTap: () {},
            ),
          ],
        ),
      ),
    );
  }
}
