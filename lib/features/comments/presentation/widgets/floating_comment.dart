import 'package:flutter/material.dart';

/// A UI widget that displays a "floating" comment tag over an audio waveform.
///
/// This widget renders a horizontal row containing the user's profile picture
/// (or a fallback icon) next to a dark, semi-transparent bubble showing a snippet
/// of the comment text. It is used to visualize comments at specific timestamps.
class FloatingComment extends StatelessWidget {
  /// The optional network URL for the user's profile picture.
  final String? imageUrl;

  /// The text content to display inside the floating bubble.
  final String text;

  /// Creates a [FloatingComment] with the specified [text] and optional [imageUrl].
  const FloatingComment({super.key, this.imageUrl, required this.text});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
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

        Flexible(
          child: Container(
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
