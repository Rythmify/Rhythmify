import 'package:flutter/material.dart';

/// A settings tile representing a single app icon option.
/// Shows the icon image, its name, and a trailing indicator:
/// - Checkmark circle if currently selected
/// - Lock icon if premium (and not selected)
/// - Nothing if free and unselected
class IconTileWidget extends StatelessWidget {
  final String name;
  final String assetPath;
  final bool isPremium;
  final bool isSelected;
  final VoidCallback onTap;

  const IconTileWidget({
    super.key,
    required this.name,
    required this.assetPath,
    required this.isPremium,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: Theme.of(context).copyWith(splashFactory: InkRipple.splashFactory),
      child: ListTile(
        onTap: onTap,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: Image.asset(
            assetPath,
            width: 72,
            height: 72,
            fit: BoxFit.cover,
          ),
        ),
        title: Text(
          name,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.w400,
          ),
        ),
        trailing: isSelected
            ? const Icon(Icons.check_circle, color: Colors.white, size: 26)
            : isPremium
            ? const Icon(Icons.lock, color: Colors.white, size: 22)
            : const SizedBox.shrink(),
      ),
    );
  }
}
