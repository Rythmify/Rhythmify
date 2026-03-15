import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_theme.dart';
import '../providers/upload_track_provider.dart';
import '../widgets/audio_picker_widget.dart';
import '../widgets/cover_image_picker_widget.dart';
import '../widgets/upload_progress_overlay.dart';

class UploadTrackScreen extends ConsumerStatefulWidget {
  const UploadTrackScreen({super.key});

  @override
  ConsumerState<UploadTrackScreen> createState() =>
      _UploadTrackScreenState();
}

class _UploadTrackScreenState extends ConsumerState<UploadTrackScreen>
    with SingleTickerProviderStateMixin {

  late TabController _tabController;

  // Hardcoded genres for now
  // Replace with API call when backend is ready
  static const List<String> _genres = [
    'Electronic', 'Hip-Hop', 'Rock', 'Pop', 'Jazz',
    'Classical', 'R&B / Soul', 'Ambient', 'Folk',
    'Metal', 'Country', 'Reggae', 'Podcast', 'Other',
  ];

  // Hardcoded tags for now
  // Replace with GET /tags when backend is ready
  static const List<String> _availableTags = [
    'chill', 'electronic', 'lofi', 'summer', 'vibes',
    'instrumental', 'hiphop', 'beats', 'acoustic', 'live',
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
              // SoundCloud-style tab bar
              _buildTabBar(),

              // Tab content
              Expanded(
                child: TabBarView(
                  controller: _tabController,
                  children: [
                    _TrackInfoTab(genres: _genres, availableTags: _availableTags),
                    _AdvancedTab(),
                    _PermissionsTab(),
                  ],
                ),
              ),
            ],
          ),

          // ── Progress overlay (sits on top) ────────────────────────
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

  AppBar _buildAppBar(BuildContext context, UploadFormState state) {
    return AppBar(
      backgroundColor: AppTheme.background,
      elevation: 0,
      leading: IconButton(
        icon: const Icon(Icons.close_rounded, color: AppTheme.appBarItems),
        onPressed: () {
          ref.read(uploadFormProvider.notifier).reset();
          context.pop();
        },
      ),
      title: Text('Upload', style: AppTheme.appBarTitle),
      actions: [
        // Save button in app bar — SoundCloud style
        Padding(
          padding: const EdgeInsets.only(right: 12, top: 8, bottom: 8),
          child: TextButton(
            style: TextButton.styleFrom(
              backgroundColor: state.canSave
                  ? AppTheme.primaryBrand
                  : AppTheme.surface,
              foregroundColor: state.canSave
                  ? Colors.white
                  : AppTheme.textSecondary,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 20),
            ),
            onPressed: state.canSave ? () => _handleSave(context) : null,
            child: Text('Save', style: AppTheme.labelLarge.copyWith(
              color: state.canSave ? Colors.white : AppTheme.textSecondary,
            )),
          ),
        ),
      ],
    );
  }

  Widget _buildTabBar() {
    return Container(
      decoration: const BoxDecoration(
        border: Border(
          bottom: BorderSide(color: Colors.white12, width: 1),
        ),
      ),
      child: TabBar(
        controller: _tabController,
        indicatorColor: AppTheme.primaryBrand,
        indicatorWeight: 2,
        labelColor: AppTheme.primaryBrand,
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

  void _handleSave(BuildContext context) {
    // TOdo: wire to upload usecase when backend is ready
    // For now just show a snackbar
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: AppTheme.surface,
        content: Text(
          'Upload coming soon — backend not connected yet',
          style: AppTheme.bodyMedium.copyWith(color: AppTheme.textPrimary),
        ),
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════════════════════════
// TRACK INFO TAB
// ══════════════════════════════════════════════════════════════════════════════

class _TrackInfoTab extends ConsumerWidget {
  final List<String> genres;
  final List<String> availableTags;

  const _TrackInfoTab({
    required this.genres,
    required this.availableTags,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(uploadFormProvider);
    final notifier = ref.read(uploadFormProvider.notifier);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [

          // ── Audio file card ───────────────────────────────────────
          const AudioPickerWidget(),
          const SizedBox(height: 20),

          // ── Artwork + Title row (SoundCloud layout) ───────────────
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Artwork picker
              CoverImagePickerWidget(
                onTap: () => _pickArtwork(context, ref),
              ),
              const SizedBox(width: 16),

              // Title field next to artwork
              Expanded(
                child: _FormField(
                  label: 'Title',
                  hint: 'Name your track',
                  required: true,
                  onChanged: notifier.setTitle,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // ── Artist ────────────────────────────────────────────────
          _FormField(
            label: 'Artist',
            hint: 'Your artist name',
            required: true,
            onChanged: notifier.setArtist,
          ),
          const SizedBox(height: 20),

          // ── Genre dropdown ────────────────────────────────────────
          _SectionLabel(label: 'Genre'),
          const SizedBox(height: 8),
          _GenreDropdown(
            genres: genres,
            selectedGenre: state.draft?.genre,
            onChanged: notifier.setGenre,
          ),
          const SizedBox(height: 20),

          // ── Tags ──────────────────────────────────────────────────
          _SectionLabel(label: 'Tags'),
          const SizedBox(height: 8),
          _TagsSection(
            availableTags: availableTags,
            selectedTags: state.draft?.tags ?? [],
            onAdd: notifier.addTag,
            onRemove: notifier.removeTag,
          ),
          const SizedBox(height: 20),

          // ── Description ───────────────────────────────────────────
          _FormField(
            label: 'Description',
            hint: 'Describe your track',
            onChanged: notifier.setDescription,
            maxLines: 4,
          ),
          const SizedBox(height: 20),

          // ── Caption ───────────────────────────────────────────────
          _FormField(
            label: 'Caption',
            hint: 'Add a short caption',
            onChanged: notifier.setCaption,
          ),
          const SizedBox(height: 20),

          // ── Privacy ───────────────────────────────────────────────
          _SectionLabel(label: 'Privacy'),
          const SizedBox(height: 8),
          _PrivacySelector(
            isPublic: state.draft?.isPublic ?? true,
            onChanged: notifier.setIsPublic,
          ),
          const SizedBox(height: 40),
        ],
      ),
    );
  }

  void _pickArtwork(BuildContext context, WidgetRef ref) {
    // Show bottom sheet to choose gallery or camera
    showModalBottomSheet(
      context: context,
      backgroundColor: AppTheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (_) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 8),
            // Handle bar
            Container(
              width: 40, height: 4,
              decoration: BoxDecoration(
                color: Colors.white24,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 16),
            ListTile(
              leading: const Icon(
                Icons.photo_library_outlined,
                color: AppTheme.appBarItems,
              ),
              title: Text('Choose from gallery',
                  style: AppTheme.bodyLarge),
              onTap: () {
                Navigator.pop(context);
                // TOdo: wire pick_cover_usecase when testing on device
              },
            ),
            ListTile(
              leading: const Icon(
                Icons.camera_alt_outlined,
                color: AppTheme.appBarItems,
              ),
              title: Text('Take a photo', style: AppTheme.bodyLarge),
              onTap: () {
                Navigator.pop(context);
                // TOdo: wire pick_cover_usecase when testing on device
              },
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════════════════════════
// ADVANCED TAB — UI placeholder
// ══════════════════════════════════════════════════════════════════════════════

class _AdvancedTab extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.tune_rounded,
              color: AppTheme.textSecondary, size: 48),
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
// PERMISSIONS TAB — UI placeholder
// ══════════════════════════════════════════════════════════════════════════════

class _PermissionsTab extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.lock_outline_rounded,
              color: AppTheme.textSecondary, size: 48),
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
// REUSABLE SMALL WIDGETS
// ══════════════════════════════════════════════════════════════════════════════

// ── Section label ─────────────────────────────────────────────────────────────

class _SectionLabel extends StatelessWidget {
  final String label;
  final bool required;

  const _SectionLabel({required this.label, this.required = false});

  @override
  Widget build(BuildContext context) {
    return RichText(
      text: TextSpan(
        text: label,
        style: AppTheme.labelLarge,
        children: [
          if (required)
            TextSpan(
              text: ' *',
              style: AppTheme.labelLarge.copyWith(
                color: AppTheme.primaryBrand,
              ),
            ),
        ],
      ),
    );
  }
}

// ── Text field ────────────────────────────────────────────────────────────────

class _FormField extends StatelessWidget {
  final String label;
  final String hint;
  final ValueChanged<String> onChanged;
  final bool required;
  final int maxLines;

  const _FormField({
    required this.label,
    required this.hint,
    required this.onChanged,
    this.required = false,
    this.maxLines = 1,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _SectionLabel(label: label, required: required),
        const SizedBox(height: 8),
        TextField(
          onChanged: onChanged,
          maxLines: maxLines,
          style: AppTheme.bodyLarge,
          cursorColor: AppTheme.primaryBrand,
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: AppTheme.bodyMedium,
            filled: true,
            fillColor: AppTheme.surface,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 14,
              vertical: 12,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: Colors.white12),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: Colors.white12),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(
                color: AppTheme.primaryBrand,
                width: 1.5,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

// ── Genre dropdown ────────────────────────────────────────────────────────────

class _GenreDropdown extends StatelessWidget {
  final List<String> genres;
  final String? selectedGenre;
  final ValueChanged<String> onChanged;

  const _GenreDropdown({
    required this.genres,
    required this.selectedGenre,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.white12),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: selectedGenre,
          hint: Text('Select genre', style: AppTheme.bodyMedium),
          isExpanded: true,
          dropdownColor: AppTheme.surface,
          icon: const Icon(
            Icons.keyboard_arrow_down_rounded,
            color: AppTheme.textSecondary,
          ),
          items: genres.map((genre) {
            return DropdownMenuItem(
              value: genre,
              child: Text(genre, style: AppTheme.bodyLarge),
            );
          }).toList(),
          onChanged: (value) {
            if (value != null) onChanged(value);
          },
        ),
      ),
    );
  }
}

// ── Tags section ──────────────────────────────────────────────────────────────

class _TagsSection extends StatelessWidget {
  final List<String> availableTags;
  final List<String> selectedTags;
  final ValueChanged<String> onAdd;
  final ValueChanged<String> onRemove;

  const _TagsSection({
    required this.availableTags,
    required this.selectedTags,
    required this.onAdd,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    // Tags not yet selected — shown as suggestions
    final suggestions = availableTags
        .where((tag) => !selectedTags.contains(tag))
        .toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Selected tags — shown with × to remove
        if (selectedTags.isNotEmpty) ...[
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: selectedTags.map((tag) {
              return _TagChip(
                label: tag,
                isSelected: true,
                onTap: () => onRemove(tag),
              );
            }).toList(),
          ),
          const SizedBox(height: 10),
        ],

        // Suggestion tags — shown as tappable
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: suggestions.map((tag) {
            return _TagChip(
              label: tag,
              isSelected: false,
              onTap: () => onAdd(tag),
            );
          }).toList(),
        ),
      ],
    );
  }
}

class _TagChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _TagChip({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected
              ? AppTheme.primaryBrand.withOpacity(0.15)
              : AppTheme.surface,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected
                ? AppTheme.primaryBrand
                : Colors.white24,
            width: 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              label,
              style: AppTheme.labelSmall.copyWith(
                color: isSelected
                    ? AppTheme.primaryBrand
                    : AppTheme.textSecondary,
              ),
            ),
            if (isSelected) ...[
              const SizedBox(width: 4),
              Icon(
                Icons.close_rounded,
                size: 12,
                color: AppTheme.primaryBrand,
              ),
            ],
          ],
        ),
      ),
    );
  }
}

// ── Privacy selector ──────────────────────────────────────────────────────────

class _PrivacySelector extends StatelessWidget {
  final bool isPublic;
  final ValueChanged<bool> onChanged;

  const _PrivacySelector({
    required this.isPublic,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.white12),
      ),
      child: Column(
        children: [
          _PrivacyOption(
            title: 'Public',
            subtitle: 'Everyone can hear this track',
            icon: Icons.public_rounded,
            isSelected: isPublic,
            onTap: () => onChanged(true),
          ),
          Divider(height: 1, color: Colors.white12),
          _PrivacyOption(
            title: 'Unlisted',
            subtitle: 'Only people with the link can hear it',
            icon: Icons.link_rounded,
            isSelected: !isPublic,
            onTap: () => onChanged(false),
          ),
        ],
      ),
    );
  }
}

class _PrivacyOption extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final bool isSelected;
  final VoidCallback onTap;

  const _PrivacyOption({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        color: Colors.transparent,
        child: Row(
          children: [
            Icon(icon,
                color: isSelected
                    ? AppTheme.primaryBrand
                    : AppTheme.textSecondary,
                size: 22),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: AppTheme.labelLarge.copyWith(
                      color: isSelected
                          ? AppTheme.primaryBrand
                          : AppTheme.textPrimary,
                    ),
                  ),
                  Text(subtitle, style: AppTheme.labelSmall),
                ],
              ),
            ),
            // Radio indicator
            Container(
              width: 20,
              height: 20,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: isSelected
                      ? AppTheme.primaryBrand
                      : Colors.white38,
                  width: 2,
                ),
              ),
              child: isSelected
                  ? Center(
                      child: Container(
                        width: 10,
                        height: 10,
                        decoration: const BoxDecoration(
                          color: AppTheme.primaryBrand,
                          shape: BoxShape.circle,
                        ),
                      ),
                    )
                  : null,
            ),
          ],
        ),
      ),
    );
  }
}