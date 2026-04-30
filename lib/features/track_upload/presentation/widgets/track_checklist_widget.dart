import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rythmify/features/track_upload/presentation/providers/upload_track_provider.dart';

class TrackChecklistBadge extends ConsumerWidget {
  const TrackChecklistBadge({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final draft = ref.watch(uploadFormProvider).draft;
    final count = draft?.checklistCount ?? 0;

    return GestureDetector(
      onTap: () => _showChecklistSheet(context, draft),
      child: SizedBox(
        width: 40,
        height: 40,
        child: Stack(
          alignment: Alignment.center,
          children: [
            // Circular progress
            SizedBox(
              width: 36,
              height: 36,
              child: CircularProgressIndicator(
                value: count / 4,
                strokeWidth: 3,
                backgroundColor: Colors.white12,
                color: count == 4 ? Colors.green : Colors.white,
              ),
            ),
            // Count text
            Text(
              '$count/4',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 10,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showChecklistSheet(BuildContext context, dynamic draft) {
    final hasTitle = draft?.title != null && draft!.title!.trim().isNotEmpty;
    final hasArtwork = draft?.localArtworkPath != null;
    final hasGenre = draft?.genre != null && draft!.genre!.trim().isNotEmpty;
    final hasDesc =
        draft?.description != null && draft!.description!.trim().isNotEmpty;

    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF1A1A1A),
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => Padding(
        padding: const EdgeInsets.fromLTRB(24, 20, 24, 40),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Handle
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.white24,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Title
            const Text(
              'Get everything in place',
              style: TextStyle(
                color: Colors.white,
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Fans are more likely to play your music when you complete these:',
              style: TextStyle(color: Colors.grey, fontSize: 14),
            ),
            const SizedBox(height: 28),

            // Progress circle + checklist items side by side
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Big circle
                SizedBox(
                  width: 180,
                  height: 180,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      SizedBox(
                        width: 100,
                        height: 100,
                        child: CircularProgressIndicator(
                          value: (draft?.checklistCount ?? 0) / 4,
                          strokeWidth: 6,
                          backgroundColor: Colors.white12,
                          color: Colors.white,
                        ),
                      ),
                      RichText(
                        text: TextSpan(
                          children: [
                            TextSpan(
                              text: '${draft?.checklistCount ?? 0}',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 30,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const TextSpan(
                              text: '/4',
                              style: TextStyle(
                                color: Colors.grey,
                                fontSize: 30,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 24),

                // Items
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _CheckItem(label: 'Track title', done: hasTitle),
                      _CheckItem(label: 'Artwork', done: hasArtwork),
                      _CheckItem(label: 'Genre', done: hasGenre),
                      _CheckItem(label: 'Description', done: hasDesc),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 32),

            // Ok button
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
                onPressed: () => Navigator.pop(context),
                child: const Text(
                  'Ok, got it',
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CheckItem extends StatelessWidget {
  final String label;
  final bool done;

  const _CheckItem({required this.label, required this.done});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Row(
        children: [
          Container(
            width: 22,
            height: 22,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: done ? Colors.white : Colors.white38,
                width: 2,
              ),
              color: done ? Colors.white : Colors.transparent,
            ),
            child: done
                ? const Icon(Icons.check_rounded, color: Colors.black, size: 14)
                : null,
          ),
          const SizedBox(width: 12),
          Text(
            label,
            style: TextStyle(
              color: done ? Colors.white : Colors.grey,
              fontSize: 14,
              fontWeight: done ? FontWeight.w600 : FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }
}