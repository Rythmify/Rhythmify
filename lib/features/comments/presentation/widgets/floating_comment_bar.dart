import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart'; 

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
          border: Border.all(color: Colors.white.withValues(alpha: 0.5)),
        ),
        child: Row(
          children: [
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                'Drop a comment...',
                style: AppTheme.bodyNormal,
              ),
            ),
            Text('🔥', style: TextStyle(fontSize: 20)),
            SizedBox(width: 24),
            Text('👏', style: TextStyle(fontSize: 20)),
            SizedBox(width: 24),
            Text('🥺', style: TextStyle(fontSize: 20)),
          ],
        ),
      ),
    );
  }
}