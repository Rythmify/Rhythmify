import 'package:flutter/material.dart';

class Avatar extends StatelessWidget {
  final String? img;
  final double radius;

  const Avatar({super.key, this.img, this.radius = 20});

  @override
  Widget build(BuildContext context) {
    final hasImg = img != null && img!.trim().isNotEmpty;
    
    return Container(
      width: radius * 2,
      height: radius * 2,
      decoration: const BoxDecoration(
        shape: BoxShape.circle,
        color: Color(0xFF2B2B2B), // Background color when loading or transparent
      ),
      child: ClipOval(
        key: const Key('messaging_user_avatar_clip_oval'),
        child: hasImg
            ? Image.network(
                img!.trim(),
                width: radius * 2,
                height: radius * 2,
                fit: BoxFit.cover,
                // If the HTTPS image fails to load for ANY reason, show the icon
                errorBuilder: (context, error, stackTrace) {
                  return Icon(Icons.person, color: const Color(0xFFD0D0D0), size: radius);
                },
                // Optional: Add a loading indicator while the image fetches
                loadingBuilder: (context, child, loadingProgress) {
                  if (loadingProgress == null) return child;
                  return Icon(Icons.person, color: const Color(0xFFD0D0D0), size: radius);
                },
              )
            : Icon(Icons.person, color: const Color(0xFFD0D0D0), size: radius),
      ),
    );
  }
}