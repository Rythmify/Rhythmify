import 'package:flutter/material.dart';
import 'package:rythmify/features/settings/presentation/widgets/switch_widget.dart';

/// A reusable settings tile with an embedded [SwitchWidget].
/// Displays a [title], optional [subtitle], and a toggle switch aligned to the top right.
/// The text content flows freely including beneath the switch area.
/// Used across analytics, advertising, communication, social, inbox, and notification screens.

class SwitchTileWidget extends StatelessWidget {
  final String title;
  final String subtitle;
  final bool initSwitchValue;
  final ValueChanged<bool>? onSwitchChanged;
  final VoidCallback? onTap;

  const SwitchTileWidget({
    super.key,
    required this.title,
    this.subtitle = '',
    this.initSwitchValue = false,
    this.onSwitchChanged,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      splashColor: const Color(0xFF3A3A3A),
      highlightColor: const Color(0xFF2A2A2A),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  if (subtitle.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: const TextStyle(
                        color: Colors.grey,
                        fontSize: 14,
                        height: 1.4,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            Positioned(
              top: 0,
              right: 0,
              child: SwitchWidget(
                key: Key('switch$title'),
                initValue: initSwitchValue,
                onChanged: onSwitchChanged,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
