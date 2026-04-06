import 'package:flutter/material.dart';

class FloatingComment extends StatelessWidget {
  final String? imageUrl;

  const FloatingComment({super.key, this.imageUrl});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 24,
      height: 24,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: Colors.white, width: 1),
        image: imageUrl != null
            ? DecorationImage(image: NetworkImage(imageUrl!), fit: BoxFit.cover)
            : null,
      ),
      child: imageUrl == null
          ? const Icon(Icons.person, size: 16, color: Colors.white)
          : null,
    );
  }
}
