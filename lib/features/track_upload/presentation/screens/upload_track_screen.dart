import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:rythmify/core/theme/app_theme.dart';
import 'package:rythmify/features/track_upload/presentation/providers/upload_track_provider.dart';
import 'package:rythmify/features/track_upload/presentation/widgets/audio_picker_widget.dart';
import 'package:rythmify/features/track_upload/presentation/widgets/upload_progress_overlay.dart';
import 'package:rythmify/features/track_upload/presentation/widgets/track_checklist_widget.dart';
import 'package:rythmify/features/track_upload/data/mock/upload_mock_store.dart';

/// Screen: UploadTrackScreen
///
/// Main UI for uploading tracks.
///
/// Responsibilities:
/// - Display upload form (tabs: Track Info, Advanced, Permissions)
/// - Collect user input (title, artist, tags, etc.)
/// - Trigger upload process via provider
/// - Display upload progress overlay
///
/// Notes:
/// - Uses TabBar for multi-step form
/// - Uses Riverpod for state management

class UploadTrackScreen extends ConsumerStatefulWidget {
  const UploadTrackScreen({super.key});

  @override
  ConsumerState<UploadTrackScreen> createState() => _UploadTrackScreenState();
}

class _UploadTrackScreenState extends ConsumerState<UploadTrackScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  static const List<String> _genres = [
    'Electronic',
    'Hip-Hop',
    'Rock',
    'Pop',
    'Jazz',
    'Classical',
    'R&B / Soul',
    'Ambient',
    'Folk',
    'Metal',
    'Country',
    'Reggae',
    'Podcast',
    'Other',
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _tabController.addListener(() {
      if (_tabController.indexIsChanging) {
        ref.read(uploadFormProvider.notifier).setTab(_tabController.index);
      }
    });
    // Fetch real genres from backend
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(uploadFormProvider.notifier).fetchGenres(ref);
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(uploadFormProvider);

    return Scaffold(
      backgroundColor: AppTheme.background,

      // ── AppBar ────────────────────────────────────────────────────
      appBar: AppBar(
        backgroundColor: AppTheme.background,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new_rounded,
            color: Colors.white,
            size: 18,
          ),
          onPressed: () {
            ref.read(uploadFormProvider.notifier).reset();
            context.pop();
          },
        ),
        title: const Text(
          'Upload',
          style: TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
        actions: [
          // Checklist badge — top right
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: const TrackChecklistBadge(),
          ),
        ],
      ),

      // ── Body ──────────────────────────────────────────────────────
      body: Stack(
        children: [
          Column(
            children: [
              // Pill-shaped tab bar
              _buildTabBar(),

              // Tab content
              Expanded(
                child: TabBarView(
                  controller: _tabController,
                  children: [
                    _TrackInfoTab(genres: _genres),
                    const _AdvancedTab(),
                    const _PermissionsTab(),
                  ],
                ),
              ),
            ],
          ),

          // Progress overlay
          if (state.draft != null)
            UploadProgressOverlay(
              onDismiss: () {
                ref.read(uploadFormProvider.notifier).reset();
                context.pop();
              },
            ),
        ],
      ),
    );
  }

  Widget _buildTabBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Container(
        height: 40,
        decoration: BoxDecoration(
          color: Colors.white10,
          borderRadius: BorderRadius.circular(20),
        ),
        child: TabBar(
          controller: _tabController,
          indicator: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
          ),
          indicatorSize: TabBarIndicatorSize.tab,
          dividerColor: Colors.transparent,
          labelColor: Colors.black,
          unselectedLabelColor: Colors.grey,
          labelStyle: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
          ),
          unselectedLabelStyle: const TextStyle(fontSize: 13),
          tabs: const [
            Tab(text: 'Track Info'),
            Tab(text: 'Advanced'),
            Tab(text: 'Permissions'),
          ],
        ),
      ),
    );
  }

  ////////////////////IMPORTANT///////////////////////
  void _handleSave(BuildContext context) {
    debugPrint('=== SAVE BUTTON PRESSED ===');

    final state = ref.read(uploadFormProvider);
    final draft = state.draft;

    debugPrint('canSave: ${state.canSave}');
    debugPrint('title: ${draft?.title}');
    debugPrint('artist: ${draft?.artist}');

    if (draft == null) {
      debugPrint('STOPPED: draft is null');
      return;
    }

    // ── Step 1: Mock store — always runs ──────────────────────────────
    try {
      UploadMockStore.add(
        MockTrackSubmission(
          title: draft.title ?? '',
          artist: draft.artist ?? '',
          genre: draft.genre,
          tags: draft.tags,
          description: draft.description,
          caption: null,
          isPublic: draft.isPublic,
          localAudioPath: draft.localAudioPath,
          localArtworkPath: draft.localArtworkPath,
          duration: draft.duration,
          submittedAt: DateTime.now(),
        ),
      );
      debugPrint('=== MOCK STORED ===');
    } catch (e) {
      debugPrint('=== MOCK ERROR: $e ===');
    }

    // ── Step 2: Backend upload ─────────────────────────────────────────
    ref
        .read(uploadFormProvider.notifier)
        .startUpload(
          ref: ref,
          onSuccess: (trackId) {
            debugPrint('=== BACKEND SUCCESS === Track ID: $trackId');
            if (context.mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  backgroundColor: Color(0xFF1DB954),
                  content: Text(
                    'Track uploaded successfully!',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              );
            }
          },
          onError: (error) {
            debugPrint('=== BACKEND ERROR === $error');
            if (context.mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  backgroundColor: Colors.red.shade800,
                  content: Text(
                    'Upload failed: $error',
                    style: const TextStyle(color: Colors.white),
                  ),
                ),
              );
            }
          },
        );
  }
}

// ══════════════════════════════════════════════════════════════════════════════
// TRACK INFO TAB
// ══════════════════════════════════════════════════════════════════════════════

class _TrackInfoTab extends ConsumerStatefulWidget {
  final List<String> genres;
  const _TrackInfoTab({required this.genres});

  @override
  ConsumerState<_TrackInfoTab> createState() => _TrackInfoTabState();
}

class _TrackInfoTabState extends ConsumerState<_TrackInfoTab> {
  late TextEditingController _titleController;
  late TextEditingController _tagController;
  late TextEditingController _collaboratorController;

  @override
  void initState() {
    super.initState();
    final draft = ref.read(uploadFormProvider).draft;
    _titleController = TextEditingController(text: draft?.title ?? '');
    _tagController = TextEditingController();
    _collaboratorController = TextEditingController();
  }

  @override
  void dispose() {
    _titleController.dispose();
    _tagController.dispose();
    _collaboratorController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(uploadFormProvider);
    final draft = state.draft;
    final notifier = ref.read(uploadFormProvider.notifier);

    return Column(
      children: [
        // Scrollable form
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ── Audio picker section ──────────────────────────────
                const AudioPickerWidget(),
                const SizedBox(height: 24),

                // ── Title ─────────────────────────────────────────────
                _FieldLabel(label: 'Title', required: true),
                const SizedBox(height: 8),
                _InputField(
                  controller: _titleController,
                  hint: '',
                  onChanged: notifier.setTitle,
                ),
                const SizedBox(height: 24),

                // ── Artist ────────────────────────────────────────────
                _FieldLabel(label: 'Artists', required: true),
                const SizedBox(height: 8),
                _ArtistField(
                  primaryArtist: draft?.artist ?? 'Your Name',
                  controller: _collaboratorController,
                  onArtistChanged: notifier.setArtist,
                ),
                const SizedBox(height: 24),

                // ── Genre ─────────────────────────────────────────────
                _FieldLabel(label: 'Genre'),
                const SizedBox(height: 8),
                _GenrePicker(
                  genres: state.availableGenres.isNotEmpty
                      ? state.availableGenres
                      : widget.genres,
                  selectedGenre: draft?.genre,
                  onChanged: notifier.setGenre,
                ),
                const SizedBox(height: 24),

                // ── Tags ──────────────────────────────────────────────
                _FieldLabel(label: 'Tags'),
                const SizedBox(height: 8),
                _TagsInput(
                  controller: _tagController,
                  selectedTags: draft?.tags ?? [],
                  onAdd: notifier.addTag,
                  onRemove: notifier.removeTag,
                ),
                const SizedBox(height: 24),

                // ── Description ───────────────────────────────────────
                _FieldLabel(label: 'Description'),
                const SizedBox(height: 8),
                _InputField(
                  hint: 'Add any details about your track for fans',
                  onChanged: notifier.setDescription,
                  maxLines: 4,
                  showCharCount: true,
                  maxLength: 4000,
                ),
                const SizedBox(height: 24),

                // ── Privacy ───────────────────────────────────────────
                _FieldLabel(label: 'Privacy'),
                const SizedBox(height: 16),
                _PrivacySelector(
                  isPublic: draft?.isPublic ?? true,
                  onChanged: notifier.setIsPublic,
                ),
                const SizedBox(height: 24),

                // Terms line
                const Text(
                  'By uploading, you confirm that your sounds comply with our Terms of Use and you don\'t infringe anyone\'s rights.',
                  style: TextStyle(color: Colors.grey, fontSize: 11),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 4),
                const Text(
                  'TERMS OF USE',
                  style: TextStyle(
                    color: Colors.grey,
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    decoration: TextDecoration.underline,
                    decorationColor: Colors.grey,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
              ],
            ),
          ),
        ),

        // ── Fixed Save button at bottom ───────────────────────────────
        Container(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 28),
          decoration: const BoxDecoration(color: AppTheme.background),
          child: SizedBox(
            width: double.infinity,
            height: 52,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: state.canSave
                    ? Colors.white
                    : const Color(0xFF2E2E2E),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
                elevation: 0,
              ),
              onPressed: state.canSave
                  ? () {
                      debugPrint('=== BOTTOM SAVE TAPPED ===');
                      final parent = context
                          .findAncestorStateOfType<_UploadTrackScreenState>();
                      if (parent != null) {
                        debugPrint('Found parent state — calling _handleSave');
                        parent._handleSave(context);
                      } else {
                        debugPrint(
                          'ERROR: Could not find _UploadTrackScreenState',
                        );
                      }
                    }
                  : null,
              child: Text(
                'Save',
                style: TextStyle(
                  color: state.canSave ? Colors.black : Colors.grey,
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

// ══════════════════════════════════════════════════════════════════════════════
// ADVANCED TAB
// ══════════════════════════════════════════════════════════════════════════════

class _AdvancedTab extends StatelessWidget {
  const _AdvancedTab();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.tune_rounded, color: Colors.grey, size: 48),
          SizedBox(height: 16),
          Text(
            'Advanced settings',
            style: TextStyle(color: Colors.white, fontSize: 16),
          ),
          SizedBox(height: 8),
          Text(
            'Coming soon',
            style: TextStyle(color: Colors.grey, fontSize: 14),
          ),
        ],
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════════════════════════
// PERMISSIONS TAB
// ══════════════════════════════════════════════════════════════════════════════

class _PermissionsTab extends StatelessWidget {
  const _PermissionsTab();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.lock_outline_rounded, color: Colors.grey, size: 48),
          SizedBox(height: 16),
          Text(
            'Permissions',
            style: TextStyle(color: Colors.white, fontSize: 16),
          ),
          SizedBox(height: 8),
          Text(
            'Coming soon',
            style: TextStyle(color: Colors.grey, fontSize: 14),
          ),
        ],
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════════════════════════
// REUSABLE WIDGETS
// ══════════════════════════════════════════════════════════════════════════════

class _FieldLabel extends StatelessWidget {
  final String label;
  final bool required;

  const _FieldLabel({required this.label, this.required = false});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: Colors.grey,
            fontSize: 13,
            fontWeight: FontWeight.w500,
          ),
        ),
        if (required) ...[
          const SizedBox(width: 3),
          const Text('*', style: TextStyle(color: Colors.red, fontSize: 13)),
        ],
      ],
    );
  }
}

class _InputField extends StatelessWidget {
  final String hint;
  final ValueChanged<String> onChanged;
  final int maxLines;
  final TextEditingController? controller;
  final bool showCharCount;
  final int? maxLength;

  const _InputField({
    required this.hint,
    required this.onChanged,
    this.maxLines = 1,
    this.controller,
    this.showCharCount = false,
    this.maxLength,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      onChanged: onChanged,
      maxLines: maxLines,
      maxLength: maxLength,
      style: const TextStyle(color: Colors.white, fontSize: 16),
      cursorColor: Colors.white,
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(color: Colors.grey, fontSize: 14),
        filled: true,
        fillColor: AppTheme.background,
        counterText: showCharCount ? null : '',
        contentPadding: const EdgeInsets.symmetric(horizontal: 0, vertical: 10),
        enabledBorder: const UnderlineInputBorder(
          borderSide: BorderSide(color: Colors.white24),
        ),
        focusedBorder: const UnderlineInputBorder(
          borderSide: BorderSide(color: Colors.white, width: 1.5),
        ),
      ),
    );
  }
}

// ── Artist field with primary artist chip + collaborator input ────────────────

class _ArtistField extends StatefulWidget {
  final String primaryArtist;
  final TextEditingController controller;
  final ValueChanged<String> onArtistChanged;

  const _ArtistField({
    required this.primaryArtist,
    required this.controller,
    required this.onArtistChanged,
  });

  @override
  State<_ArtistField> createState() => _ArtistFieldState();
}

class _ArtistFieldState extends State<_ArtistField> {
  final List<String> _collaborators = [];

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Primary artist chip + collaborator chips + input
        Wrap(
          spacing: 8,
          runSpacing: 8,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            // Primary artist chip (not removable)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.white12,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                widget.primaryArtist.toUpperCase(),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),

            // Collaborator chips
            for (final collab in _collaborators)
              GestureDetector(
                onTap: () => setState(() => _collaborators.remove(collab)),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white12,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        collab.toUpperCase(),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(width: 6),
                      const Icon(
                        Icons.close_rounded,
                        color: Colors.white54,
                        size: 14,
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ),
        const SizedBox(height: 10),

        // Input for adding collaborators
        TextField(
          controller: widget.controller,
          style: const TextStyle(color: Colors.white, fontSize: 14),
          cursorColor: Colors.white,
          decoration: const InputDecoration(
            hintText: 'Add any other collaborators of the track',
            hintStyle: TextStyle(color: Colors.grey, fontSize: 14),
            filled: true,
            fillColor: AppTheme.background,
            contentPadding: EdgeInsets.symmetric(horizontal: 0, vertical: 10),
            enabledBorder: UnderlineInputBorder(
              borderSide: BorderSide(color: Colors.white24),
            ),
            focusedBorder: UnderlineInputBorder(
              borderSide: BorderSide(color: Colors.white, width: 1.5),
            ),
          ),
          onSubmitted: (value) {
            final name = value.trim();
            if (name.isNotEmpty) {
              setState(() => _collaborators.add(name));
              widget.controller.clear();
            }
          },
        ),
      ],
    );
  }
}

// ── Genre picker ──────────────────────────────────────────────────────────────

class _GenrePicker extends StatelessWidget {
  final List<String> genres;
  final String? selectedGenre;
  final ValueChanged<String> onChanged;

  const _GenrePicker({
    required this.genres,
    required this.selectedGenre,
    required this.onChanged,
  });

  void _show(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF1A1A1A),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (_) => ListView.builder(
        key: const Key('track_upload_genre_list_view'),
        itemCount: genres.length,
        itemBuilder: (_, i) {
          final genre = genres[i];
          final isSelected = genre == selectedGenre;
          return ListTile(
            title: Text(
              genre,
              style: TextStyle(
                color: isSelected ? Colors.white : Colors.grey,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
              ),
            ),
            trailing: isSelected
                ? const Icon(Icons.check_rounded, color: Colors.white)
                : null,
            onTap: () {
              onChanged(genre);
              Navigator.pop(context);
            },
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      key: const Key('track_upload_genre_picker_gesture_detector'),
      onTap: () => _show(context),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: const BoxDecoration(
          border: Border(bottom: BorderSide(color: Colors.white24)),
        ),
        child: Row(
          children: [
            Expanded(
              child: Text(
                selectedGenre ?? 'Help fans discover your track',
                style: TextStyle(
                  color: selectedGenre != null ? Colors.white : Colors.grey,
                  fontSize: 14,
                ),
              ),
            ),
            // Single up-down arrow (↕)
            const Icon(Icons.unfold_more_rounded, color: Colors.grey, size: 20),
          ],
        ),
      ),
    );
  }
}

// ── Tags input ────────────────────────────────────────────────────────────────

class _TagsInput extends StatelessWidget {
  final TextEditingController controller;
  final List<String> selectedTags;
  final ValueChanged<String> onAdd;
  final ValueChanged<String> onRemove;

  const _TagsInput({
    required this.controller,
    required this.selectedTags,
    required this.onAdd,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    final atLimit = selectedTags.length >= 10;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Input
        TextField(
          controller: controller,
          enabled: !atLimit,
          style: const TextStyle(color: Colors.white, fontSize: 14),
          cursorColor: Colors.white,
          decoration: InputDecoration(
            hintText: atLimit
                ? 'Maximum 10 tags reached'
                : 'Add tags to describe track for reachability',
            hintStyle: const TextStyle(color: Colors.grey, fontSize: 14),
            filled: true,
            fillColor: AppTheme.background,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 0,
              vertical: 10,
            ),
            enabledBorder: const UnderlineInputBorder(
              borderSide: BorderSide(color: Colors.white24),
            ),
            focusedBorder: const UnderlineInputBorder(
              borderSide: BorderSide(color: Colors.white, width: 1.5),
            ),
            // Right arrow icon
            suffixIcon: const Icon(
              Icons.chevron_right_rounded,
              color: Colors.grey,
            ),
          ),
          onSubmitted: (value) {
            final tag = value.trim().toLowerCase();
            if (tag.isEmpty || atLimit) return;
            onAdd(tag);
            controller.clear();
          },
        ),
        const SizedBox(height: 10),

        // Selected chips
        if (selectedTags.isNotEmpty)
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: selectedTags.map((tag) {
              return GestureDetector(
                onTap: () => onRemove(tag),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white12,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: Colors.white24),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        tag,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                        ),
                      ),
                      const SizedBox(width: 6),
                      const Icon(
                        Icons.close_rounded,
                        color: Colors.white54,
                        size: 12,
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),
          ),
      ],
    );
  }
}

// ── Privacy selector ──────────────────────────────────────────────────────────

class _PrivacySelector extends StatelessWidget {
  final bool isPublic;
  final ValueChanged<bool> onChanged;

  const _PrivacySelector({required this.isPublic, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _PrivacyOption(
          title: 'Public',
          subtitle: 'Anyone can find this',
          isSelected: isPublic,
          onTap: () => onChanged(true),
        ),
        const SizedBox(height: 16),
        _PrivacyOption(
          title: 'Unlisted (Private)',
          subtitle: 'Anyone with private link can access',
          isSelected: !isPublic,
          onTap: () => onChanged(false),
        ),
      ],
    );
  }
}

class _PrivacyOption extends StatelessWidget {
  final String title;
  final String subtitle;
  final bool isSelected;
  final VoidCallback onTap;

  const _PrivacyOption({
    required this.title,
    required this.subtitle,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    color: isSelected ? Colors.white : Colors.grey,
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: const TextStyle(color: Colors.grey, fontSize: 12),
                ),
              ],
            ),
          ),
          // Checkmark circle
          Container(
            width: 24,
            height: 24,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: isSelected ? Colors.white : Colors.white38,
                width: 2,
              ),
            ),
            child: isSelected
                ? const Icon(Icons.check_rounded, color: Colors.white, size: 14)
                : null,
          ),
        ],
      ),
    );
  }
}
