import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:rythmify/core/theme/app_theme.dart';
import 'package:rythmify/features/track_upload/presentation/providers/upload_track_provider.dart';
import 'package:rythmify/features/track_upload/presentation/widgets/audio_picker_widget.dart';
import 'package:rythmify/features/track_upload/presentation/widgets/upload_progress_overlay.dart';
import 'package:rythmify/features/track_upload/presentation/widgets/track_checklist_widget.dart';
import 'package:rythmify/features/track_upload/presentation/widgets/cover_image_picker_widget.dart';
import 'package:rythmify/features/track_upload/data/mock/upload_mock_store.dart';
import 'package:rythmify/features/track_upload/domain/entities/track_draft.dart';
import 'package:rythmify/core/domain/entities/track.dart' as track_entity;
import 'package:rythmify/features/premium/domain/premium_gate.dart';
import 'package:rythmify/features/premium/presentation/widgets/premium_upgrade_prompt.dart';

/// Screen: UploadTrackScreen
class UploadTrackScreen extends ConsumerStatefulWidget {
  final track_entity.Track? track;
  const UploadTrackScreen({super.key, this.track});

  static const Map<String, String> _countries = {
    'Egypt': 'EG',
    'Palestine': 'PS',
    'Saudi Arabia': 'SA',
    'United Arab Emirates': 'AE',
    'Jordan': 'JO',
    'Lebanon': 'LB',
    'Syria': 'SY',
    'Iraq': 'IQ',
    'Kuwait': 'KW',
    'Qatar': 'QA',
    'Bahrain': 'BH',
    'Oman': 'OM',
    'Yemen': 'YE',
    'Libya': 'LY',
    'Tunisia': 'TN',
    'Algeria': 'DZ',
    'Morocco': 'MA',
    'Sudan': 'SD',
    'United States': 'US',
    'United Kingdom': 'GB',
    'Germany': 'DE',
    'France': 'FR',
    'Japan': 'JP',
    'Brazil': 'BR',
    'Canada': 'CA',
    'Australia': 'AU',
  };

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

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (widget.track != null) {
        ref.read(uploadFormProvider.notifier).initFromTrack(widget.track!);
      }
      ref.read(uploadFormProvider.notifier).fetchGenres(ref);
      ref.read(uploadFormProvider.notifier).fetchTags(ref); // ← fetch real tags
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
        title: Text(
          widget.track != null ? 'Update Track' : 'Upload',
          style: const TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
        actions: const [
          Padding(
            padding: EdgeInsets.only(right: 12),
            child: TrackChecklistBadge(),
          ),
        ],
      ),
      body: Stack(
        children: [
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
          if (state.draft != null &&
              state.draft!.trackId == null &&
              state.draft!.status == UploadStatus.uploading)
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

  void _handleSave(BuildContext context) {
    final state = ref.read(uploadFormProvider);
    final draft = state.draft;
    if (draft == null) return;

    // ── Update track flow (partner's code — untouched) ──────────────────
    if (draft.trackId != null) {
      ref
          .read(uploadFormProvider.notifier)
          .handleUpdate(
            ref: ref,
            onSuccess: () {
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Track updated successfully!')),
                );
                context.pop();
              }
            },
            onError: (error) {
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Update failed: $error')),
                );
              }
            },
          );
      return;
    }

    // ── New upload flow ──────────────────────────────────────────────────
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
    } catch (_) {}

    ref
        .read(uploadFormProvider.notifier)
        .startUpload(
          ref: ref,
          onSuccess: (trackId) {
            if (context.mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  backgroundColor: Color(0xFF1DB954),
                  content: Text('Track uploaded successfully!'),
                ),
              );
              context.pop();
            }
          },
          onError: (error) {
            if (context.mounted) {
              // 403 upload limit → show premium upgrade prompt
              if (error.contains('UPLOAD_LIMIT_403')) {
                PremiumUpgradePrompt.show(
                  context,
                  reason: 'upload more tracks',
                );
                return;
              }
              if (PremiumGate.handleError(context, error)) {
                return;
              }
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  backgroundColor: Colors.red.shade800,
                  content: Text('Upload failed: $error'),
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
  late TextEditingController _descriptionController;
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    final draft = ref.read(uploadFormProvider).draft;
    _titleController = TextEditingController(text: draft?.title ?? '');
    _tagController = TextEditingController();
    _collaboratorController = TextEditingController();
    _descriptionController = TextEditingController(
      text: draft?.description ?? '',
    );
  }

  @override
  void dispose() {
    _titleController.dispose();
    _tagController.dispose();
    _collaboratorController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _pickArtwork() async {
    final source = await showModalBottomSheet<ImageSource>(
      context: context,
      backgroundColor: const Color(0xFF1A1A1A),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (_) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 8),
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.white24,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 16),
            ListTile(
              leading: const Icon(
                Icons.photo_library_outlined,
                color: Colors.white70,
              ),
              title: const Text(
                'Choose from gallery',
                style: TextStyle(color: Colors.white),
              ),
              onTap: () => Navigator.pop(context, ImageSource.gallery),
            ),
            ListTile(
              leading: const Icon(
                Icons.camera_alt_outlined,
                color: Colors.white70,
              ),
              title: const Text(
                'Take a photo',
                style: TextStyle(color: Colors.white),
              ),
              onTap: () => Navigator.pop(context, ImageSource.camera),
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );

    if (source == null) return;

    final XFile? image = await _picker.pickImage(
      source: source,
      imageQuality: 85,
      maxWidth: 1000,
      maxHeight: 1000,
    );

    if (image != null) {
      ref.read(uploadFormProvider.notifier).setArtwork(image.path);
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(uploadFormProvider);
    final draft = state.draft;
    final notifier = ref.read(uploadFormProvider.notifier);
    final isUpdate = draft?.trackId != null;

    if (isUpdate && _titleController.text.isEmpty && draft?.title != null) {
      _titleController.text = draft!.title!;
    }
    if (isUpdate &&
        _descriptionController.text.isEmpty &&
        draft?.description != null) {
      _descriptionController.text = draft!.description!;
    }

    return Column(
      children: [
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ── Artwork + Audio ───────────────────────────────────
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    CoverImagePickerWidget(onTap: _pickArtwork),
                    const SizedBox(width: 20),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (!isUpdate) ...[
                            const AudioPickerWidget(),
                          ] else ...[
                            const _FieldLabel(label: 'Audio File'),
                            const SizedBox(height: 8),
                            const Text(
                              'Audio file cannot be changed during update',
                              style: TextStyle(
                                color: Colors.grey,
                                fontSize: 13,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                // ── Title ─────────────────────────────────────────────
                const _FieldLabel(label: 'Title', required: true),
                const SizedBox(height: 8),
                _InputField(
                  controller: _titleController,
                  hint: '',
                  onChanged: notifier.setTitle,
                ),
                const SizedBox(height: 24),

                // ── Artists ───────────────────────────────────────────
                const _FieldLabel(label: 'Artists', required: true),
                const SizedBox(height: 8),
                _ArtistField(
                  primaryArtist: draft?.artist ?? 'Your Name',
                  controller: _collaboratorController,
                  onArtistChanged: notifier.setArtist,
                ),
                const SizedBox(height: 24),

                // ── Genre ─────────────────────────────────────────────
                const _FieldLabel(label: 'Genre'),
                const SizedBox(height: 8),
                _GenrePicker(
                  genres: state.availableGenres.isNotEmpty
                      ? state.availableGenres
                      : widget.genres,
                  selectedGenre: draft?.genre,
                  onChanged: notifier.setGenre,
                ),
                const SizedBox(height: 24),

                // ── Tags — free text input ───────────────────────────
                const _FieldLabel(label: 'Tags'),
                const SizedBox(height: 8),
                _TagsInput(
                  controller: _tagController,
                  selectedTags: draft?.tags ?? [],
                  onAdd: notifier.addTag,
                  onRemove: notifier.removeTag,
                ),
                const SizedBox(height: 24),

                // ── Description ───────────────────────────────────────
                const _FieldLabel(label: 'Description'),
                const SizedBox(height: 8),
                _InputField(
                  controller: _descriptionController,
                  hint: 'Add any details about your track for fans',
                  onChanged: notifier.setDescription,
                  maxLines: 4,
                  showCharCount: true,
                  maxLength: 4000,
                ),
                const SizedBox(height: 24),

                // ── Privacy ───────────────────────────────────────────
                const _FieldLabel(label: 'Privacy'),
                const SizedBox(height: 16),
                _PrivacySelector(
                  isPublic: draft?.isPublic ?? true,
                  isHidden: draft?.isHidden ?? false,
                  onChanged: (public, hidden) {
                    notifier.setIsPublic(public);
                    notifier.setIsHidden(hidden);
                  },
                ),
                const SizedBox(height: 24),

                const Text(
                  'By uploading, you confirm that your sounds comply with our Terms of Use and you don\'t infringe anyone\'s rights.',
                  style: TextStyle(color: Colors.grey, fontSize: 11),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),

                // ── Delete button (update mode only — partner's code) ──
                if (isUpdate) ...[
                  const Divider(color: Colors.white12, height: 40),
                  SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: OutlinedButton(
                      key: const Key('uploads_delete_option'),
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: Colors.redAccent),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                      ),
                      onPressed: () => _handleDelete(context),
                      child: const Text(
                        'Delete Track',
                        style: TextStyle(
                          color: Colors.redAccent,
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                ],
              ],
            ),
          ),
        ),

        // ── Save / Update button ───────────────────────────────────────
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
                      final parent = context
                          .findAncestorStateOfType<_UploadTrackScreenState>();
                      if (parent != null) parent._handleSave(context);
                    }
                  : null,
              child: state.isLoading
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        color: Colors.black,
                        strokeWidth: 2,
                      ),
                    )
                  : Text(
                      isUpdate ? 'Update' : 'Save',
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

  // ── Delete dialog (partner's code — untouched) ────────────────────────
  void _handleDelete(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1A1A1A),
        title: const Text(
          'Delete Track',
          style: TextStyle(color: Colors.white),
        ),
        content: const Text(
          'Are you sure you want to permanently delete this track? This action cannot be undone.',
          style: TextStyle(color: Colors.grey),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel', style: TextStyle(color: Colors.white)),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              ref
                  .read(uploadFormProvider.notifier)
                  .handleDelete(
                    ref: ref,
                    onSuccess: () {
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Track deleted successfully'),
                          ),
                        );
                        context.pop();
                      }
                    },
                    onError: (error) {
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Delete failed: $error')),
                        );
                      }
                    },
                  );
            },
            child: const Text(
              'Delete',
              style: TextStyle(color: Colors.redAccent),
            ),
          ),
        ],
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════════════════════════
// ADVANCED TAB
// ══════════════════════════════════════════════════════════════════════════════

class _AdvancedTab extends ConsumerWidget {
  const _AdvancedTab();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(uploadFormProvider);
    final draft = state.draft;
    final notifier = ref.read(uploadFormProvider.notifier);

    if (draft == null) {
      return const Center(child: CircularProgressIndicator());
    }

    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
      children: [
        const _FieldLabel(label: 'Geo-Restrictions'),
        const SizedBox(height: 16),
        _GeoRestrictionSelector(
          currentType: draft.geoRestrictionType,
          onChanged: (type) {
            notifier.setGeoRestrictionType(type);
            if (type == 'worldwide') {
              notifier.clearGeoRegions();
            }
          },
        ),
        if (draft.geoRestrictionType != 'worldwide') ...[
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _FieldLabel(
                label: draft.geoRestrictionType == 'exclusive_regions'
                    ? 'Allowed Countries'
                    : 'Blocked Countries',
              ),
              TextButton(
                onPressed: () => _showCountryPicker(context, ref),
                child: const Text(
                  'Add Countries',
                  style: TextStyle(color: Colors.white, fontSize: 13),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          if (draft.geoRegions.isEmpty)
            const Text(
              'No countries selected yet.',
              style: TextStyle(color: Colors.grey, fontSize: 14),
            )
          else
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: draft.geoRegions.map((code) {
                final name = UploadTrackScreen._countries.entries
                    .firstWhere(
                      (e) => e.value == code,
                      orElse: () => MapEntry(code, code),
                    )
                    .key;
                return Chip(
                  label: Text(
                    name,
                    style: const TextStyle(color: Colors.white, fontSize: 12),
                  ),
                  backgroundColor: Colors.white12,
                  deleteIcon: const Icon(
                    Icons.close,
                    size: 14,
                    color: Colors.white54,
                  ),
                  onDeleted: () => notifier.toggleGeoRegion(code),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                    side: const BorderSide(color: Colors.white24),
                  ),
                );
              }).toList(),
            ),
        ],
        const SizedBox(height: 40),
        const Text(
          'Advanced features like scheduled releases and custom licenses are coming soon.',
          style: TextStyle(color: Colors.grey, fontSize: 12),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  void _showCountryPicker(BuildContext context, WidgetRef ref) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: const Color(0xFF1A1A1A),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (_) => const _CountryPickerModal(),
    );
  }
}

class _GeoRestrictionSelector extends StatelessWidget {
  final String currentType;
  final ValueChanged<String> onChanged;

  const _GeoRestrictionSelector({
    required this.currentType,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _RestrictionOption(
          title: 'Worldwide',
          subtitle: 'Available everywhere',
          isSelected: currentType == 'worldwide',
          onTap: () => onChanged('worldwide'),
        ),
        const SizedBox(height: 16),
        _RestrictionOption(
          title: 'Allow Selected',
          subtitle: 'Only available in specific countries',
          isSelected: currentType == 'exclusive_regions',
          onTap: () => onChanged('exclusive_regions'),
        ),
        const SizedBox(height: 16),
        _RestrictionOption(
          title: 'Block Selected',
          subtitle: 'Available everywhere except specific countries',
          isSelected: currentType == 'blocked_regions',
          onTap: () => onChanged('blocked_regions'),
        ),
      ],
    );
  }
}

class _RestrictionOption extends StatelessWidget {
  final String title;
  final String subtitle;
  final bool isSelected;
  final VoidCallback onTap;

  const _RestrictionOption({
    required this.title,
    required this.subtitle,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected
              ? Colors.white.withValues(alpha: 0.05)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? Colors.white : Colors.white12,
            width: 1.5,
          ),
        ),
        child: Row(
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
                      fontWeight: FontWeight.w600,
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
            if (isSelected)
              const Icon(
                Icons.check_circle_rounded,
                color: Colors.white,
                size: 20,
              ),
          ],
        ),
      ),
    );
  }
}

class _CountryPickerModal extends ConsumerStatefulWidget {
  const _CountryPickerModal();

  @override
  ConsumerState<_CountryPickerModal> createState() =>
      _CountryPickerModalState();
}

class _CountryPickerModalState extends ConsumerState<_CountryPickerModal> {
  String _searchQuery = '';
  late TextEditingController _searchController;

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(uploadFormProvider);
    final draft = state.draft!;
    final notifier = ref.read(uploadFormProvider.notifier);

    final filteredCountries = UploadTrackScreen._countries.entries.where((e) {
      return e.key.toLowerCase().contains(_searchQuery.toLowerCase());
    }).toList();

    return Container(
      height: MediaQuery.of(context).size.height * 0.8,
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        children: [
          const SizedBox(height: 12),
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.white24,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 20),
          const Text(
            'Select Countries',
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _searchController,
            onChanged: (v) => setState(() => _searchQuery = v),
            style: const TextStyle(color: Colors.white),
            decoration: InputDecoration(
              hintText: 'Search countries...',
              hintStyle: const TextStyle(color: Colors.grey),
              prefixIcon: const Icon(Icons.search, color: Colors.grey),
              filled: true,
              fillColor: Colors.white10,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
            ),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: ListView.builder(
              itemCount: filteredCountries.length,
              itemBuilder: (context, i) {
                final entry = filteredCountries[i];
                final isSelected = draft.geoRegions.contains(entry.value);

                return ListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Text(
                    entry.key,
                    style: TextStyle(
                      color: isSelected ? Colors.white : Colors.grey,
                      fontWeight: isSelected
                          ? FontWeight.w600
                          : FontWeight.normal,
                    ),
                  ),
                  trailing: Checkbox(
                    value: isSelected,
                    onChanged: (v) => notifier.toggleGeoRegion(entry.value),
                    activeColor: Colors.white,
                    checkColor: Colors.black,
                    side: const BorderSide(color: Colors.white38, width: 2),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                  onTap: () => notifier.toggleGeoRegion(entry.value),
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 20),
            child: SizedBox(
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
                  'Done',
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
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

// ── Artist field ──────────────────────────────────────────────────────────────

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
        Wrap(
          spacing: 8,
          runSpacing: 8,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
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
            const Icon(Icons.unfold_more_rounded, color: Colors.grey, size: 20),
          ],
        ),
      ),
    );
  }
}

// ── Tags input (free text) ──────────────────────────────────────────────────

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
  final bool isHidden;
  final void Function(bool isPublic, bool isHidden) onChanged;

  const _PrivacySelector({
    required this.isPublic,
    required this.isHidden,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _PrivacyOption(
          title: 'Public',
          subtitle: 'Anyone can find this',
          isSelected: isPublic,
          onTap: () => onChanged(true, false),
        ),
        const SizedBox(height: 16),
        _PrivacyOption(
          title: 'Unlisted (Private)',
          subtitle: 'Anyone with private link can access',
          isSelected: !isPublic,
          onTap: () => onChanged(false, false),
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
