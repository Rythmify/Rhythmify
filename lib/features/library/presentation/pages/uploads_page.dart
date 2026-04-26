import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:file_picker/file_picker.dart';
import 'package:just_audio/just_audio.dart';
import '../../../../core/theme/app_theme.dart';
import '../providers/library_providers.dart';
import '../../../track/presentation/widgets/track_card.dart';
import '../../../track_upload/presentation/providers/upload_track_provider.dart';

// ── Added for artist name fix ──
import 'package:rythmify/features/authentication/presentation/providers/auth_provider.dart';
import 'package:rythmify/features/authentication/presentation/providers/auth_state.dart';

/// Your Uploads page matching SoundCloud's layout.
///
/// Layout sections (top → bottom):
/// 1. [AppBar] — back arrow, search bar, filter icon, cast icon.
/// 2. Header area — "Your uploads" title, upload icon button,
///    shuffle + play FAB row, and stat chips (Amplify credits / mins used).
/// 3. [ListView] of upload [TrackCard] tiles, or an empty state when
///    [UploadsState.tracks] is empty.
///
/// The minutes-used chip is computed from [UploadsState] by summing
/// [TrackEntity.duration] across all uploaded tracks and converting
/// to whole minutes (capped at [_kUploadLimitMinutes]).
class UploadsPage extends ConsumerStatefulWidget {
  const UploadsPage({super.key});

  @override
  ConsumerState<UploadsPage> createState() => _UploadsPageState();
}

class _UploadsPageState extends ConsumerState<UploadsPage> {
  /// Maximum upload minutes allowed per the free tier (matches SoundCloud's 120 min).
  static const int _kUploadLimitMinutes = 120;

  final _scrollController = ScrollController();
  final _searchController = TextEditingController();
  String _query = '';

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  /// Triggers paginated load when the user scrolls within 200 px of the bottom.
  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      ref.read(uploadsProvider.notifier).load();
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  /// Returns the total uploaded duration in whole minutes by summing
  /// [duration.inSeconds] across all tracks in [state].
  ///
  /// Falls back to 0 when [state.tracks] is empty.
  int _computeUsedMinutes(UploadsState state) {
    final totalSeconds = state.tracks.fold<int>(
      0,
      (sum, item) => sum + item.track.duration.inSeconds,
    );
    return (totalSeconds / 60).floor();
  }

  /// Handles audio file selection and prepares it for upload.
  ///
  /// This follows the same flow as the home page upload button:
  /// 1. Opens file picker restricted to audio files
  /// 2. Extracts selected file path and metadata
  /// 3. Determines audio duration using local player
  /// 4. Initializes upload draft via Riverpod provider
  /// 5. Navigates to upload screen if successful
  Future<void> _handleUploadButtonPress() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.audio,
      allowMultiple: false,
    );

    if (result == null || result.files.isEmpty) return;
    final picked = result.files.first;
    if (picked.path == null) return;

    Duration duration = Duration.zero;
    try {
      final player = AudioPlayer();
      final detected = await player.setFilePath(picked.path!);
      duration = detected ?? Duration.zero;
      await player.dispose();
    } catch (_) {}

    // ── Fix: read display name from auth provider ──
    final authState = ref.read(authProvider);
    final displayName = authState is AuthAuthenticated
        ? authState.user.displayName
        : 'Your Name';

    ref
        .read(uploadFormProvider.notifier)
        .initDraft(
          artistId:       'dev_user_001',
          artistName:     displayName,
          localAudioPath: picked.path!,
          duration:       duration,
          fileName:       picked.name,
        );

    if (mounted) {
      context.push('/upload-track');
      // Start audio upload right after navigating
      ref.read(uploadFormProvider.notifier).startAudioUpload();
    }
  }

  // ─── build ──────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(uploadsProvider);

    return Scaffold(
      backgroundColor: AppTheme.background,
      // ── AppBar: back + inline search + filter + cast ──────────────────────
      appBar: AppBar(
        backgroundColor: AppTheme.background,
        elevation: 0,
        leading: IconButton(
          key: const Key('uploads_back_button'),
          icon: const Icon(Icons.arrow_back, color: AppTheme.appBarItems),
          onPressed: () => context.pop(),
        ),
        title: _SearchBar(
          key: const Key('uploads_search_bar'),
          controller: _searchController,
          onChanged: (v) => setState(() => _query = v),
        ),
        actions: [
          IconButton(
            key: const Key('uploads_filter_button'),
            icon: const Icon(Icons.tune, color: AppTheme.appBarItems),
            onPressed: () {},
          ),
          IconButton(
            key: const Key('uploads_cast_button'),
            icon: const Icon(Icons.cast, color: AppTheme.appBarItems),
            onPressed: () {},
          ),
        ],
      ),
      body: RefreshIndicator(
        color: AppTheme.primaryBrand,
        onRefresh: () => ref.read(uploadsProvider.notifier).load(refresh: true),
        child: state.isLoading && state.tracks.isEmpty
            ? const Center(
                child: CircularProgressIndicator(color: AppTheme.primaryBrand),
              )
            : _buildScrollView(context, state),
      ),
    );
  }

  /// Builds the full scrollable body containing the header section and track list.
  Widget _buildScrollView(BuildContext context, UploadsState state) {
    final filtered = _query.isEmpty
        ? state.tracks
        : state.tracks
              .where(
                (t) => t.title.toLowerCase().contains(_query.toLowerCase()),
              )
              .toList();

    return CustomScrollView(
      key: const Key('uploads_scroll_view'),
      controller: _scrollController,
      physics: const AlwaysScrollableScrollPhysics(),
      slivers: [
        // ── Header: title + controls + stat chips ──────────────────────────
        SliverToBoxAdapter(
          child: _UploadsHeader(
            usedMinutes: _computeUsedMinutes(state),
            limitMinutes: _kUploadLimitMinutes,
            onUpload: _handleUploadButtonPress,
            onShuffle: () {},
            onPlay: () {},
          ),
        ),

        if (state.tracks.isEmpty)
          // ── Empty state ────────────────────────────────────────────────
          SliverFillRemaining(
            hasScrollBody: false,
            child: _EmptyUploads(onUpload: _handleUploadButtonPress),
          )
        else ...[
          // ── Track list ─────────────────────────────────────────────────
          SliverPadding(
            padding: const EdgeInsets.only(bottom: 120),
            sliver: SliverList.builder(
              itemCount: filtered.length + 1,
              itemBuilder: (context, index) {
                if (index == filtered.length) {
                  return state.isLoading
                      ? const Padding(
                          padding: EdgeInsets.all(16),
                          child: Center(
                            child: CircularProgressIndicator(
                              color: AppTheme.primaryBrand,
                              strokeWidth: 2,
                            ),
                          ),
                        )
                      : const SizedBox.shrink();
                }
                return TrackCard(track: filtered[index].track);
              },
            ),
          ),
        ],
        const SliverToBoxAdapter(child: SizedBox(height: 30)),
      ],
    );
  }
}

// ─── _SearchBar ──────────────────────────────────────────────────────────────

/// Compact inline search bar rendered inside the [AppBar].
///
/// Styled as a rounded pill with a leading search icon and transparent
/// background so it blends with the dark app bar.
class _SearchBar extends StatelessWidget {
  const _SearchBar({
    super.key,
    required this.controller,
    required this.onChanged,
  });

  /// Controls the text field value.
  final TextEditingController controller;

  /// Called whenever the user modifies the search text.
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 38,
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(19),
      ),
      child: TextField(
        controller: controller,
        onChanged: onChanged,
        style: AppTheme.bodyMedium.copyWith(color: AppTheme.textPrimary),
        decoration: InputDecoration(
          hintText: 'Search in your uploads',
          hintStyle: AppTheme.bodyMedium,
          prefixIcon: const Icon(
            Icons.search,
            color: AppTheme.textSecondary,
            size: 18,
          ),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(vertical: 10),
          isDense: true,
        ),
      ),
    );
  }
}

// ─── _UploadsHeader ──────────────────────────────────────────────────────────

/// Header section rendered beneath the [AppBar].
///
/// Contains:
/// - "Your uploads" headline.
/// - Upload icon button (left), shuffle icon + play FAB (right).
/// - Two stat chips: Amplify credits (always "No Amplify credits" for free tier)
///   and minutes used out of [limitMinutes].
class _UploadsHeader extends StatelessWidget {
  const _UploadsHeader({
    required this.usedMinutes,
    required this.limitMinutes,
    required this.onUpload,
    required this.onShuffle,
    required this.onPlay,
  });

  /// Total minutes of audio already uploaded.
  final int usedMinutes;

  /// Hard cap for uploaded audio (e.g. 120 mins on the free tier).
  final int limitMinutes;

  /// Called when the user taps the upload icon.
  final VoidCallback onUpload;

  /// Called when the user taps the shuffle icon.
  final VoidCallback onShuffle;

  /// Called when the user taps the play FAB.
  final VoidCallback onPlay;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Title row
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                child: Text(
                  'Your uploads',
                  style: AppTheme.headlineLarge.copyWith(height: 1),
                ),
              ),
              // Upload icon button
              _CircleIconButton(
                key: const Key('uploads_upload_circle_button'),
                icon: Icons.upload_outlined,
                onTap: onUpload,
              ),
              const SizedBox(width: 12),
              // Shuffle
              _CircleIconButton(
                key: const Key('uploads_shuffle_button'),
                icon: Icons.shuffle,
                onTap: onShuffle,
              ),
              const SizedBox(width: 12),
              // Play FAB
              GestureDetector(
                key: const Key('uploads_play_button'),
                onTap: onPlay,
                child: Container(
                  width: 48,
                  height: 48,
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.play_arrow_rounded,
                    color: Colors.black,
                    size: 28,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          // Stat chips row
          Row(
            children: [
              _StatChip(
                key: const Key('uploads_amplify_chip'),
                icon: Icons.bolt,
                iconColor: Colors.amber,
                label: 'No Amplify credits',
              ),
              const SizedBox(width: 10),
              _StatChip(
                key: const Key('uploads_minutes_chip'),
                icon: Icons.cloud_upload_outlined,
                iconColor: AppTheme.primaryBrand,
                label: '$usedMinutes/$limitMinutes mins used',
              ),
            ],
          ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }
}

// ─── _CircleIconButton ───────────────────────────────────────────────────────

/// A borderless circular icon button used in [_UploadsHeader].
class _CircleIconButton extends StatelessWidget {
  const _CircleIconButton({super.key, required this.icon, required this.onTap});

  /// The icon to display inside the circle.
  final IconData icon;

  /// Called when the button is tapped.
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(
            color: AppTheme.textSecondary.withValues(alpha: 0.4),
          ),
        ),
        child: Icon(icon, color: AppTheme.appBarItems, size: 20),
      ),
    );
  }
}

// ─── _StatChip ───────────────────────────────────────────────────────────────

/// A pill-shaped chip displaying an [icon] and a text [label].
///
/// Used to show quick stats like upload quota or Amplify credits.
class _StatChip extends StatelessWidget {
  const _StatChip({
    super.key,
    required this.icon,
    required this.iconColor,
    required this.label,
  });

  /// Leading icon.
  final IconData icon;

  /// Tint colour for the [icon].
  final Color iconColor;

  /// Text displayed after the icon.
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: iconColor, size: 16),
          const SizedBox(width: 6),
          Text(
            label,
            style: AppTheme.labelSmall.copyWith(color: AppTheme.textPrimary),
          ),
        ],
      ),
    );
  }
}

// ─── _EmptyUploads ───────────────────────────────────────────────────────────

/// Centered empty state shown when the user has no uploads yet.
///
/// Displays a gradient card with a cloud-upload icon, headline, body text,
/// and an [OutlinedButton] that navigates to the track-upload flow.
class _EmptyUploads extends StatelessWidget {
  const _EmptyUploads({required this.onUpload});

  /// Called when the "Upload a track" button is tapped.
  final VoidCallback onUpload;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 40),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: double.infinity,
            height: 160,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              gradient: const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Color(0xFF4A0080), Color(0xFF1A0040)],
              ),
            ),
            child: const Icon(
              Icons.cloud_upload_outlined,
              color: Colors.white54,
              size: 64,
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'No tracks uploaded yet',
            key: const Key('uploads_empty_headline_text'),
            style: AppTheme.titleMedium,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            'Tracks you\'ve uploaded will show up here',
            key: const Key('uploads_empty_body_text'),
            style: AppTheme.bodyMedium,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          OutlinedButton(
            key: const Key('uploads_empty_upload_button'),
            onPressed: onUpload,
            style: OutlinedButton.styleFrom(
              foregroundColor: AppTheme.textPrimary,
              side: const BorderSide(color: AppTheme.textSecondary),
              shape: const StadiumBorder(),
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
            ),
            child: const Text('Upload a track'),
          ),
        ],
      ),
    );
  }
}