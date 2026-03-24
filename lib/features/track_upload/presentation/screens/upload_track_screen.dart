import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:rythmify/core/theme/app_theme.dart';
import 'package:rythmify/features/track_upload/presentation/providers/upload_track_provider.dart';
import 'package:rythmify/features/track_upload/presentation/widgets/audio_picker_widget.dart';
import 'package:rythmify/features/track_upload/presentation/widgets/upload_progress_overlay.dart';
import 'package:rythmify/features/track_upload/data/mock/upload_mock_store.dart';

class UploadTrackScreen extends ConsumerStatefulWidget {
  const UploadTrackScreen({super.key});

  @override
  ConsumerState<UploadTrackScreen> createState() =>
      _UploadTrackScreenState();
}

class _UploadTrackScreenState extends ConsumerState<UploadTrackScreen>
    with SingleTickerProviderStateMixin {

  late TabController _tabController;

  static const List<String> _genres = [
    'Electronic', 'Hip-Hop', 'Rock', 'Pop', 'Jazz',
    'Classical', 'R&B / Soul', 'Ambient', 'Folk',
    'Metal', 'Country', 'Reggae', 'Podcast', 'Other',
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _tabController.addListener(() {
      ref.read(uploadFormProvider.notifier).setTab(_tabController.index);
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
      appBar: _buildAppBar(context, state),
      body: Stack(
        children: [
          // ── Main content ──────────────────────────────────────────
          Column(
            children: [
              _buildTabBar(),
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

          // ── Progress overlay ──────────────────────────────────────
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

  // ── AppBar ──────────────────────────────────────────────────────────────

  AppBar _buildAppBar(BuildContext context, UploadFormState state) {
    return AppBar(
      backgroundColor: AppTheme.background,
      elevation: 0,
      leading: IconButton(
        icon: const Icon(
          Icons.close_rounded,
          color: AppTheme.appBarItems,
        ),
        onPressed: () {
          ref.read(uploadFormProvider.notifier).reset();
          context.pop();
        },
      ),
      title: Text('Upload', style: AppTheme.appBarTitle),
      actions: [
        Padding(
          padding: const EdgeInsets.only(right: 12, top: 8, bottom: 8),
          child: TextButton(
            style: TextButton.styleFrom(
              backgroundColor: state.canSave
                  ? Colors.white
                  : AppTheme.surface,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 20),
            ),
            onPressed: state.canSave
                ? () => _handleSave(context)
                : null,
            child: Text(
              'Save',
              style: AppTheme.labelLarge.copyWith(
                color: state.canSave
                    ? Colors.black
                    : AppTheme.textSecondary,
              ),
            ),
          ),
        ),
      ],
    );
  }

  // ── Tab bar ─────────────────────────────────────────────────────────────

  Widget _buildTabBar() {
    return Container(
      decoration: const BoxDecoration(
        border: Border(
          bottom: BorderSide(color: Colors.white12, width: 1),
        ),
      ),
      child: TabBar(
        controller: _tabController,
        indicatorColor: Colors.white,
        indicatorWeight: 2,
        labelColor: Colors.white,
        unselectedLabelColor: AppTheme.textSecondary,
        labelStyle: AppTheme.labelLarge,
        unselectedLabelStyle: AppTheme.labelLarge,
        tabs: const [
          Tab(text: 'Track info'),
          Tab(text: 'Advanced'),
          Tab(text: 'Permissions'),
        ],
      ),
    );
  }

  // ── Save handler ─────────────────────────────────────────────────────────

  void _handleSave(BuildContext context) {
     final state = ref.read(uploadFormProvider);
  if (state.draft == null) return;

  ref.read(uploadFormProvider.notifier).startUpload(
    ref: ref,
    onSuccess: (trackId) {
      debugPrint('=== UPLOAD SUCCESS === Track ID: $trackId');
      // Overlay shows success automatically via draft.status
    },
    onError: (error) {
      debugPrint('=== UPLOAD FAILED === $error');
      // Overlay shows error automatically via draft.status
    },
  );
    // Simulate upload progress for UI testing
    _simulateUpload();
  }

  void _simulateUpload() async {
    final notifier = ref.read(uploadFormProvider.notifier);
    for (int i = 1; i <= 10; i++) {
      await Future.delayed(const Duration(milliseconds: 300));
      notifier.setUploadProgress(i / 10);
    }
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
  late TextEditingController _artistController;
  late TextEditingController _tagController;

  @override
  void initState() {
    super.initState();
    final draft = ref.read(uploadFormProvider).draft;
    _titleController  = TextEditingController(text: draft?.title  ?? '');
    _artistController = TextEditingController(text: draft?.artist ?? '');
    _tagController    = TextEditingController();
  }

  @override
  void dispose() {
    _titleController.dispose();
    _artistController.dispose();
    _tagController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state    = ref.watch(uploadFormProvider);
    final draft    = state.draft;
    final notifier = ref.read(uploadFormProvider.notifier);

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [

          // ── Top: dashed frame + audio info ─────────────────────────
          const AudioPickerWidget(),
          const SizedBox(height: 28),

          // ── Divider ────────────────────────────────────────────────
          const Divider(color: Colors.white12, height: 1),
          const SizedBox(height: 24),

          // ── Title ──────────────────────────────────────────────────
          _FieldLabel(label: 'Title', required: true),
          const SizedBox(height: 10),
          _InputField(
            controller: _titleController,
            hint:       '',
            onChanged:  notifier.setTitle,
          ),
          const SizedBox(height: 24),

          // ── Artist ─────────────────────────────────────────────────
          _FieldLabel(label: 'Artist', required: true),
          const SizedBox(height: 6),
          Text(
            'Add any other collaborators of the track',
            style: AppTheme.bodyMedium,
          ),
          const SizedBox(height: 10),
          _InputField(
            controller: _artistController,
            hint:       'Add any other collaborators of the track',
            onChanged:  notifier.setArtist,
          ),
          const SizedBox(height: 24),

          // ── Genre ──────────────────────────────────────────────────
          _FieldLabel(label: 'Genre'),
          const SizedBox(height: 6),
          Text(
            'Help fans discover your track',
            style: AppTheme.bodyMedium,
          ),
          const SizedBox(height: 10),
          _GenrePicker(
            genres:        widget.genres,
            selectedGenre: draft?.genre,
            onChanged:     notifier.setGenre,
          ),
          const SizedBox(height: 24),

          // ── Tags ───────────────────────────────────────────────────
          _FieldLabel(label: 'Tags'),
          const SizedBox(height: 6),
          Text(
            'Add tags to describe your track for reachability',
            style: AppTheme.bodyMedium,
          ),
          const SizedBox(height: 10),
          _TagsInput(
            controller:   _tagController,
            selectedTags: draft?.tags ?? [],
            onAdd:        notifier.addTag,
            onRemove:     notifier.removeTag,
          ),
          const SizedBox(height: 24),

          // ── Description ────────────────────────────────────────────
          _FieldLabel(label: 'Description'),
          const SizedBox(height: 10),
          _InputField(
            hint:      'Add any details about your track for fans',
            onChanged:  notifier.setDescription,
            maxLines:   4,
          ),
          const SizedBox(height: 24),

          // ── Caption ────────────────────────────────────────────────
          _FieldLabel(label: 'Caption'),
          const SizedBox(height: 10),
          _InputField(
            hint:     'Add any caption to your post (optional)',
            onChanged: notifier.setCaption,
          ),
          const SizedBox(height: 24),

          // ── Privacy ────────────────────────────────────────────────
          _FieldLabel(label: 'Privacy'),
          const SizedBox(height: 16),
          _PrivacySelector(
            isPublic:  draft?.isPublic ?? true,
            onChanged: notifier.setIsPublic,
          ),
          const SizedBox(height: 32),

          // ── Save button ────────────────────────────────────────────
          _SaveButton(
            enabled: state.canSave,
            onPressed: () {
              final parentState = ref.read(uploadFormProvider);
              final parentDraft = parentState.draft;
              if (parentDraft == null) return;

              UploadMockStore.add(MockTrackSubmission(
                title:            parentDraft.title         ?? '',
                artist:           parentDraft.artist        ?? '',
                genre:            parentDraft.genre,
                tags:             parentDraft.tags,
                description:      parentDraft.description,
                caption:          parentDraft.caption,
                isPublic:         parentDraft.isPublic,
                localAudioPath:   parentDraft.localAudioPath,
                localArtworkPath: parentDraft.localArtworkPath,
                duration:         parentDraft.duration,
                submittedAt:      DateTime.now(),
              ));

              _simulateUpload();
            },
          ),
          const SizedBox(height: 40),
        ],
      ),
    );
  }

  void _simulateUpload() async {
    final notifier = ref.read(uploadFormProvider.notifier);
    for (int i = 1; i <= 10; i++) {
      await Future.delayed(const Duration(milliseconds: 300));
      notifier.setUploadProgress(i / 10);
    }
  }
}

// ══════════════════════════════════════════════════════════════════════════════
// ADVANCED TAB
// ══════════════════════════════════════════════════════════════════════════════

class _AdvancedTab extends StatelessWidget {
  const _AdvancedTab();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.tune_rounded,
            color: AppTheme.textSecondary,
            size: 48,
          ),
          const SizedBox(height: 16),
          Text('Advanced settings', style: AppTheme.titleMedium),
          const SizedBox(height: 8),
          Text('Coming soon', style: AppTheme.bodyMedium),
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
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.lock_outline_rounded,
            color: AppTheme.textSecondary,
            size: 48,
          ),
          const SizedBox(height: 16),
          Text('Permissions', style: AppTheme.titleMedium),
          const SizedBox(height: 8),
          Text('Coming soon', style: AppTheme.bodyMedium),
        ],
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════════════════════════
// REUSABLE WIDGETS
// ══════════════════════════════════════════════════════════════════════════════

// ── Field label ───────────────────────────────────────────────────────────────

class _FieldLabel extends StatelessWidget {
  final String label;
  final bool required;

  const _FieldLabel({required this.label, this.required = false});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(label, style: AppTheme.labelLarge),
        if (required) ...[
          const SizedBox(width: 3),
          const Text(
            '*',
            style: TextStyle(
              color:      Colors.red,
              fontSize:   14,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ],
    );
  }
}

// ── Input field ───────────────────────────────────────────────────────────────

class _InputField extends StatelessWidget {
  final String hint;
  final ValueChanged<String> onChanged;
  final int maxLines;
  final TextEditingController? controller;

  const _InputField({
    required this.hint,
    required this.onChanged,
    this.maxLines  = 1,
    this.controller,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller:  controller,
      onChanged:   onChanged,
      maxLines:    maxLines,
      style:       AppTheme.bodyLarge,
      cursorColor: Colors.white,
      decoration: InputDecoration(
        hintText:  hint,
        hintStyle: AppTheme.bodyMedium,
        filled:    true,
        fillColor: AppTheme.background,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 0,
          vertical:   12,
        ),
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

  void _showPicker(BuildContext context) {
    showModalBottomSheet(
      context:         context,
      backgroundColor: const Color(0xFF1A1A1A),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (_) => ListView.builder(
        itemCount: genres.length,
        itemBuilder: (_, i) {
          final genre      = genres[i];
          final isSelected = genre == selectedGenre;
          return ListTile(
            title: Text(
              genre,
              style: TextStyle(
                color:      isSelected ? Colors.white : Colors.grey,
                fontWeight: isSelected
                    ? FontWeight.w600
                    : FontWeight.normal,
              ),
            ),
            trailing: isSelected
                ? const Icon(
                    Icons.check_rounded,
                    color: Colors.white,
                  )
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
      onTap: () => _showPicker(context),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: const BoxDecoration(
          border: Border(
            bottom: BorderSide(color: Colors.white24),
          ),
        ),
        child: Row(
          children: [
            Expanded(
              child: Text(
                selectedGenre ?? 'Help fans discover your track',
                style: TextStyle(
                  color:    selectedGenre != null
                      ? Colors.white
                      : Colors.grey,
                  fontSize: 14,
                ),
              ),
            ),
            // Two arrows side by side
            const Row(
              children: [
                Icon(
                  Icons.keyboard_arrow_up_rounded,
                  color: Colors.grey,
                  size:  18,
                ),
                Icon(
                  Icons.keyboard_arrow_down_rounded,
                  color: Colors.grey,
                  size:  18,
                ),
              ],
            ),
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
        // Input field
        TextField(
          controller:  controller,
          enabled:     !atLimit,
          style: const TextStyle(
            color:    Colors.white,
            fontSize: 14,
          ),
          cursorColor: Colors.white,
          decoration: InputDecoration(
            hintText: atLimit
                ? 'Maximum 10 tags reached'
                : 'Add tags to describe track for reachability',
            hintStyle: const TextStyle(
              color:    Colors.grey,
              fontSize: 14,
            ),
            filled:    true,
            fillColor: AppTheme.background,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 0,
              vertical:   12,
            ),
            enabledBorder: const UnderlineInputBorder(
              borderSide: BorderSide(color: Colors.white24),
            ),
            focusedBorder: const UnderlineInputBorder(
              borderSide: BorderSide(color: Colors.white, width: 1.5),
            ),
            disabledBorder: const UnderlineInputBorder(
              borderSide: BorderSide(color: Colors.white12),
            ),
          ),
          onSubmitted: (value) {
            final tag = value.trim().toLowerCase();
            if (tag.isEmpty) return;
            if (atLimit)     return;
            onAdd(tag);
            controller.clear();
          },
        ),
        const SizedBox(height: 12),

        // Selected tags
        if (selectedTags.isNotEmpty) ...[
          Wrap(
            spacing:    8,
            runSpacing: 8,
            children: selectedTags.map((tag) {
              return GestureDetector(
                onTap: () => onRemove(tag),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical:    6,
                  ),
                  decoration: BoxDecoration(
                    color:        Colors.white12,
                    borderRadius: BorderRadius.circular(20),
                    border:       Border.all(color: Colors.white24),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        tag,
                        style: const TextStyle(
                          color:    Colors.white,
                          fontSize: 12,
                        ),
                      ),
                      const SizedBox(width: 6),
                      const Icon(
                        Icons.close_rounded,
                        color: Colors.white54,
                        size:  12,
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 8),
          Text(
            '${selectedTags.length}/10 tags',
            style: const TextStyle(
              color:    Colors.grey,
              fontSize: 11,
            ),
          ),
        ],
      ],
    );
  }
}

class _PrivacySelector extends StatelessWidget {
  final bool isPublic;
  final ValueChanged<bool> onChanged;

  const _PrivacySelector({
    required this.isPublic,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _PrivacyOption(
          title:      'Public',
          subtitle:   'Anyone can find this',
          isSelected: isPublic,
          onTap:      () => onChanged(true),
        ),
        const SizedBox(height: 20),
        _PrivacyOption(
          title:      'Unlisted (Private)',
          subtitle:   'Anyone with private link can access',
          isSelected: !isPublic,
          onTap:      () => onChanged(false),
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
          // Radio circle
          Padding(
            padding: const EdgeInsets.only(top: 2),
            child: Container(
              width:  20,
              height: 20,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: isSelected ? Colors.white : Colors.white38,
                  width: 2,
                ),
              ),
              child: isSelected
                  ? Center(
                      child: Container(
                        width:  10,
                        height: 10,
                        decoration: const BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                        ),
                      ),
                    )
                  : null,
            ),
          ),
          const SizedBox(width: 14),
          // Text
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  color:      isSelected ? Colors.white : Colors.grey,
                  fontSize:   14,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 3),
              Text(
                subtitle,
                style: const TextStyle(
                  color:    Colors.grey,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ── Save button ───────────────────────────────────────────────────────────────

class _SaveButton extends StatelessWidget {
  final bool enabled;
  final VoidCallback onPressed;

  const _SaveButton({
    required this.enabled,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width:  double.infinity,
      height: 48,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: enabled ? Colors.white : AppTheme.surface,
          foregroundColor: enabled ? Colors.black : Colors.grey,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(4),
          ),
        ),
        onPressed: enabled ? onPressed : null,
        child: Text(
          'Save',
          style: TextStyle(
            color:      enabled ? Colors.black : Colors.grey,
            fontSize:   15,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }
}
