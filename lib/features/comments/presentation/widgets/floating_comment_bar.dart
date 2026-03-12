import 'package:flutter/material.dart';

class FloatingCommentBar extends StatelessWidget {
  const FloatingCommentBar({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Container(
        height: 50,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        decoration: BoxDecoration(
          color: Colors.black.withValues(alpha: 0.6),
          borderRadius: BorderRadius.circular(25),
          border: Border.all(color: Colors.white.withValues(alpha: 0.2)),
        ),
        child: Row(
          children: const [
            Expanded(
              child: Text(
                'Drop a comment...',
                style: TextStyle(color: Colors.white70, fontSize: 14, fontWeight: FontWeight.w600),
              ),
            ),
            Text('🔥', style: TextStyle(fontSize: 20)),
            SizedBox(width: 12),
            Text('👏', style: TextStyle(fontSize: 20)),
            SizedBox(width: 12),
            Text('🥺', style: TextStyle(fontSize: 20)),
          ],
        ),
      ),
    );
  }
}