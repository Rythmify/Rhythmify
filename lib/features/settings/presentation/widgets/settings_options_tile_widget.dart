import 'package:flutter/material.dart';

class SettingsOptionsTileWidget extends StatelessWidget {
  final String title;
  final VoidCallback? onTap;

  const SettingsOptionsTileWidget({super.key, required this.title, this.onTap});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(
        title,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 16,
          fontWeight: FontWeight.w400,
        ),
      ),
      trailing: Icon(Icons.chevron_right, color: Colors.white),
      onTap: onTap,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16),
    );
  }
}
