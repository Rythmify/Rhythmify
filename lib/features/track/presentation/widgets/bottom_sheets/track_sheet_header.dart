import 'package:flutter/material.dart';
import '../../../../../core/domain/entities/track.dart';
import '../../../../../core/theme/app_theme.dart';


class TrackSheetHeader extends StatelessWidget {
  final Track track;

  const TrackSheetHeader({super.key, required this.track});

  @override
  Widget build(BuildContext context) {
    final artworkUrl = track.coverImage ?? '';

    final imageProvider = artworkUrl.startsWith('http')
        ? NetworkImage(artworkUrl) as ImageProvider
        : AssetImage(artworkUrl.isNotEmpty ? artworkUrl : 'assets/images/track_1.jpg');

    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Color.fromARGB(255, 0, 54, 141), 
            Color.fromARGB(255, 58, 83, 193), 
            Color(0xFF6FB1FC), 
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        // This keeps the top of the entire bottom sheet curved
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      // Reduced top padding slightly to make room for the drag handle
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // The Dragging Edge (Pill)
          Container(
            width: 40,
            height: 5,
            margin: const EdgeInsets.only(bottom: 16),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.7),
              borderRadius: BorderRadius.circular(10),
            ),
          ),
          
          // The existing Row containing the Artwork and Text
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SizedBox(
                width: 160,
                height: 100,
                child: Stack(
                  children: [
                    // The CD Graphic
                    Positioned(
                      left: 60,
                      top: 0,
                      child: Image.asset(
                        'assets/images/cd.png',
                        width: 100,
                        height: 100,
                      ),
                    ),
                    // The small circular artwork on the CD
                    Positioned(
                      left: 95, 
                      top: 35,
                      child: Container(
                        width: 30,
                        height: 30,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          image: DecorationImage(
                            image: imageProvider,
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                    ),
                    // The main album artwork
                    Positioned(
                      left: 0,
                      top: 0,
                      child: Container(
                        width: 100,
                        height: 100,
                        decoration: BoxDecoration(
                          // Added curved edges
                          borderRadius: BorderRadius.circular(12),
                          // Added thin light border
                          border: Border.all(
                            color: Colors.white.withValues(alpha: 0.5),
                            width: 1, // Thin border
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.25),
                              blurRadius: 8,
                              offset: const Offset(2, 4),
                            ),
                          ],
                          image: DecorationImage(
                            image: imageProvider,
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      track.title,
                      style: AppTheme.titleLarge,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      track.artist,
                      style: AppTheme.bodyNormal.copyWith(color: AppTheme.fadedWhite),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}