import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';

class FansLeaderboard extends StatefulWidget {
  const FansLeaderboard({super.key});

  @override
  State<FansLeaderboard> createState() => _FansLeaderboardState();
}

class _FansLeaderboardState extends State<FansLeaderboard> {
  int _selectedTab = 0;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text("Fans Leaderboard", style: AppTheme.titleLarge),
            const SizedBox(width: 8),
            const Icon(
              key: Key('fans_leaderboard_info_icon'),
              Icons.info_outline,
              size: 18,
              color: AppTheme.textSecondary,
            ),
          ],
        ),
        const SizedBox(height: 16),
        Container(
          
          width: double.infinity,
          decoration: const BoxDecoration(
            color: AppTheme.lighterSurface,
            borderRadius: BorderRadius.all(Radius.circular(32)),
          ),
          child: Column(
            children: [
              const SizedBox(height: 24),
              // Segmented Control with Animation
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Container(
                  height: 48,
                  decoration: BoxDecoration(
                    color: AppTheme.background,
                    borderRadius: BorderRadius.circular(24),
                  ),
                  child: Stack(
                    children: [
                      // The Animated Sliding Indicator
                      AnimatedAlign(
                        alignment: _selectedTab == 0
                            ? Alignment.centerLeft
                            : Alignment.centerRight,
                        duration: const Duration(milliseconds: 200), // Animation speed
                        curve: Curves.easeInOut,
                        child: FractionallySizedBox(
                          widthFactor: 0.5,
                          child: Container(
                            margin: const EdgeInsets.all(4),
                            decoration: BoxDecoration(
                              border: Border.all(
                                  color: AppTheme.textPrimary, width: 0.8),
                              borderRadius: BorderRadius.circular(20),
                              color: AppTheme.lighterSurface,
                            ),
                          ),
                        ),
                      ),
                      // 2. The Text Labels (Transparent & Clickable)
                      Row(
                        children: [
                          _buildSegmentText("Top", 0),
                          _buildSegmentText("First", 1),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Text("Top fans based on listening activity", style: AppTheme.labelSmall),
              const SizedBox(height: 32),
              
              // List View (Empty for now)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 40.0),
                child: Text("No fan activity yet", style: TextStyle(color: AppTheme.textSecondary)),
              ),
              
              const SizedBox(height: 40),
            ],
          ),
        ),
      ],
    );
  }

  // Only handles text and tap detection
  Widget _buildSegmentText(String label, int index) {
    return Expanded(
      child: GestureDetector(
        key: Key('fans_leaderboard_${label.toLowerCase()}_segment_gesture_detector'),
        onTap: () => setState(() => _selectedTab = index),
        behavior: HitTestBehavior.opaque,
        child: Container(
          alignment: Alignment.center,
          child: Text(
            label,
            style: AppTheme.labelLarge.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }
}