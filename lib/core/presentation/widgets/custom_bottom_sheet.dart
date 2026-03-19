import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';

class CustomBottomSheet {
  static void show({
    required BuildContext context,
    required String title,
    required String content,
    double initialChildSize = 0.5,
    double minChildSize = 0.3,
    double maxChildSize = 0.95,
  }) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      useRootNavigator: true, // To ensures it sits above everything (mini player/navbar)
      builder: (context) {
        return DraggableScrollableSheet(
          initialChildSize: initialChildSize,
          minChildSize: minChildSize,
          maxChildSize: maxChildSize,
          expand: false,
          builder: (context, scrollController) {
            return Container(
              decoration: const BoxDecoration(
                color: AppTheme.surface,
                borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
              ),
              child: Column(
                children: [
                  const SizedBox(height: 12),
                  // Grab Handle
                  Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Colors.white24,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  const SizedBox(height: 24),
                  
                  // Header
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      spacing: 16,
                      children: [
                        IconButton(
                          key: const Key('core_bottom_sheet_close_icon_button'),
                          icon: const Icon(Icons.close, color: AppTheme.textPrimary),
                          onPressed: () => Navigator.pop(context),
                          style: IconButton.styleFrom(
                          backgroundColor: Colors.white12,
                         ),
                        ),

                        Expanded(
                          child: Text(
                            title,
                            style: AppTheme.titleLarge.copyWith(fontSize: 22),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Content
                  Expanded(
                    child: ListView(
                      controller: scrollController,
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      children: [
                        Text(
                          content,
                          style: AppTheme.bodyMedium.copyWith(
                            color: Colors.white70,
                            height: 1.6,
                            fontSize: 15,
                          ),
                        ),
                        const SizedBox(height: 100), // Extra space at bottom
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}
