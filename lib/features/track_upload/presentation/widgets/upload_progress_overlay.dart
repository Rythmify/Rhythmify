import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rythmify/core/theme/app_theme.dart';
import 'package:rythmify/features/track_upload/domain/entities/track_draft.dart';
import 'package:rythmify/features/track_upload/presentation/providers/upload_track_provider.dart';

class UploadProgressOverlay extends ConsumerWidget {
  final VoidCallback onDismiss;

  const UploadProgressOverlay({super.key, required this.onDismiss});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(uploadFormProvider);
    final draft = state.draft;

    if (draft == null) return const SizedBox.shrink();

    final isUploading = draft.status == UploadStatus.uploading;
    final isSuccess   = draft.status == UploadStatus.success;
    final isError     = draft.status == UploadStatus.error;

    if (!isUploading && !isSuccess && !isError) {
      return const SizedBox.shrink();
    }

    return GestureDetector(
      onTap: (isSuccess || isError) ? onDismiss : null,
      child: Container(
        color: Colors.black87,
        child: Center(
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 32),
            padding: const EdgeInsets.all(28),
            decoration: BoxDecoration(
              color: AppTheme.surface,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (isUploading) ...[
                  _buildProgressRing(draft.uploadProgress),
                  const SizedBox(height: 20),
                  Text('Uploading...', style: AppTheme.titleMedium),
                  const SizedBox(height: 8),
                  Text(
                    'Please keep the app open',
                    style: AppTheme.bodyMedium,
                  ),
                ],

                if (isSuccess) ...[
                  _buildStatusIcon(
                    icon: Icons.check_rounded,
                    color: AppTheme.primaryBrand,
                  ),
                  const SizedBox(height: 20),
                  Text('Upload complete!', style: AppTheme.titleMedium),
                  const SizedBox(height: 8),
                  Text('Your track is being processed',
                      style: AppTheme.bodyMedium),
                  const SizedBox(height: 20),
                  Text('Tap to continue',
                      style: AppTheme.labelSmall),
                ],

                if (isError) ...[
                  _buildStatusIcon(
                    icon: Icons.error_outline_rounded,
                    color: Colors.red,
                  ),
                  const SizedBox(height: 20),
                  Text('Upload failed', style: AppTheme.titleMedium),
                  const SizedBox(height: 8),
                  Text(
                    state.errorMessage ?? 'Something went wrong.',
                    style: AppTheme.bodyMedium,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 20),
                  Text('Tap to try again',
                      style: AppTheme.labelSmall),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildProgressRing(double progress) {
    return SizedBox(
      width: 72,
      height: 72,
      child: Stack(
        fit: StackFit.expand,
        children: [
          CircularProgressIndicator(
            value:           progress,
            strokeWidth:     4,
            backgroundColor: Colors.white12,
            color:           AppTheme.primaryBrand,
          ),
          Center(
            child: Text(
              '${(progress * 100).toInt()}%',
              style: AppTheme.labelLarge.copyWith(
                color: AppTheme.primaryBrand,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusIcon({
    required IconData icon,
    required Color color,
  }) {
    return Container(
      width: 64,
      height: 64,
      decoration: BoxDecoration(
        color:  color.withOpacity(0.15),
        shape:  BoxShape.circle,
        border: Border.all(color: color, width: 2),
      ),
      child: Icon(icon, color: color, size: 32),
    );
  }
}