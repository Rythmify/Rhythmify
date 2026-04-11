import 'package:flutter/material.dart';

class FloatingComment extends StatelessWidget {
  final String? imageUrl;
  final String text;

  const FloatingComment({super.key, this.imageUrl, required this.text});

  @override
  Widget build(BuildContext context) {
    // The Row is now the root widget
    return Row(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // 1. Profile Picture
        Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: Colors.white, width: 1),
            image: imageUrl != null && imageUrl!.isNotEmpty
                ? DecorationImage(
                    image: NetworkImage(imageUrl!),
                    fit: BoxFit.cover,
                  )
                : null,
          ),
          child: imageUrl == null || imageUrl!.isEmpty
              ? const Icon(Icons.person, size: 16, color: Colors.white)
              : null,
        ),
        
        const SizedBox(width: 8),

        // 2. The Comment Box
        Flexible(
          child: Container(
            // Adjusted padding to look balanced without the pfp inside
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.black.withValues(alpha: 0.75),
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: Colors.white.withValues(alpha: 0.2)),
            ),
            child: Text(
              text,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 13,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ),
      ],
    );
  }
}