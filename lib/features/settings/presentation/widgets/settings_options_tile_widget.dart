import 'package:flutter/material.dart';

/// A reusable settings tile with a chevron trailing icon.
/// Used in [SettingsScreen] and other screens for navigation tiles.
/// Applies [InkRipple.splashFactory] for a proper ripple effect on tap.
class SettingsOptionsTileWidget extends StatelessWidget {
  final String title;
  final VoidCallback? onTap;

  const SettingsOptionsTileWidget({super.key, required this.title, this.onTap});

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: Theme.of(context).copyWith(splashFactory: InkRipple.splashFactory),
      child: ListTile(
        title: Text(
          title,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.w400,
          ),
        ),
        trailing: Icon(Icons.chevron_right, color: Colors.white),
        onTap: onTap,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16),
        minVerticalPadding: 0,
        dense: true,
      ),
    );
  }
}
