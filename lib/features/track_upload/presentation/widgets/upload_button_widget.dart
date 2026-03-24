import 'package:flutter/material.dart';

enum UploadButtonState { uploading, processing, done }

class UploadButtonWidget extends StatefulWidget {
  final UploadButtonState buttonState;
  final double progress; // 0.0 to 1.0
  final VoidCallback? onReplace;

  const UploadButtonWidget({
    super.key,
    required this.buttonState,
    required this.progress,
    this.onReplace,
  });

  @override
  State<UploadButtonWidget> createState() => _UploadButtonWidgetState();
}

class _UploadButtonWidgetState extends State<UploadButtonWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _progressAnimation;
  double _previousProgress = 0.0;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    _progressAnimation = Tween<double>(
      begin: 0.0,
      end: widget.progress,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic));
    _controller.forward();
  }

  @override
  void didUpdateWidget(UploadButtonWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.progress != widget.progress) {
      _progressAnimation =
          Tween<double>(begin: _previousProgress, end: widget.progress).animate(
            CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic),
          );
      _previousProgress = widget.progress;
      _controller.forward(from: 0);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // ── STATE 3: Done ────────────────────────────────────────────────
    if (widget.buttonState == UploadButtonState.done) {
      return GestureDetector(
        key: const Key('track_upload_replace_button_gesture_detector'),
        onTap: widget.onReplace,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Green circle with checkmark
            Container(
              width: 22,
              height: 22,
              decoration: const BoxDecoration(
                color: Color(0xFF1DB954),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.check_rounded,
                color: Colors.white,
                size: 14,
              ),
            ),
            const SizedBox(width: 8),
            // Replace button
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 7),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.white38),
                borderRadius: BorderRadius.circular(4),
              ),
              child: const Text(
                'Replace',
                key: Key('track_upload_replace_button_text'),
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
      );
    }

    // ── STATE 1 & 2: Uploading / Processing ──────────────────────────
    return AnimatedBuilder(
      animation: _progressAnimation,
      builder: (context, child) {
        final progress = _progressAnimation.value;
        final isProcessing = widget.buttonState == UploadButtonState.processing;

        return ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: SizedBox(
            width: double.infinity,
            height: 38,
            child: Stack(
              children: [
                // Background — dark grey
                Container(color: const Color(0xFF2E2E2E)),

                // Green fill — grows left to right
                FractionallySizedBox(
                  widthFactor: isProcessing ? 1.0 : progress,
                  child: Container(color: const Color(0xFF1DB954)),
                ),

                // Text on top
                Center(
                  child: Text(
                    isProcessing
                        ? 'Preparing to process'
                        : 'Uploading ${(progress * 100).toInt()}%',
                    key: const Key('track_upload_status_text'),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
