import 'package:flutter/material.dart';

/// A tappable text link that navigates to the Rythmify Privacy Policy.
/// Displayed at the bottom of analytics, advertising, and communication settings screens.
class PrivacyPolicyWidget extends StatelessWidget {
  const PrivacyPolicyWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {},
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Text(
          'Learn more in our Privacy Policy',
          style: TextStyle(color: Colors.blue, fontSize: 14),
        ),
      ),
    );
  }
}
