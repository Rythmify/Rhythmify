import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import '../../../../../core/theme/app_theme.dart';
import '../providers/profile_provider.dart';
import '../providers/profile_state.dart';
import '../widgets/profile_avatar.dart';
import '../widgets/unsaved_changes_dialog.dart';

/// A full-screen page for editing the authenticated user's profile.
///
/// Accessible via:
/// - [PublicProfilePage] edit icon → `context.push('/home/profile/edit')`
/// - GoRouter route `/home/profile/edit`
///
/// **Route ordering**: `/profile/edit` MUST be declared BEFORE
/// `/profile/:userId` in [app_router.dart]. If the order is reversed,
/// GoRouter will match `/profile/edit` as `/profile/:userId` with
/// `userId = 'edit'`, causing the backend to return
/// `invalid input syntax for type uuid: edit`.
///
/// ### Editable fields
/// - **Display name** (max 50 chars) — inline [TextField]
/// - **Username** (max 30 chars) — inline [TextField]
/// - **First name** (max 50 chars) — inline [TextField]
/// - **Last name** (max 50 chars) — inline [TextField]
/// - **City** (max 35 chars) — inline [TextField]
/// - **Country** — bottom-sheet country picker ([_showCountryPicker])
///   stores an ISO alpha-2 code internally but displays the full name.
/// - **Bio** — bottom-sheet multi-line editor ([_showBioEditor])
///
/// ### Media uploads
/// - **Avatar** — tapping [ProfileAvatar] opens the gallery via
///   [ImagePicker] and calls [ProfileNotifier.uploadAvatar].
/// - **Cover photo** — tapping the cover area camera icon opens the
///   gallery and calls [ProfileNotifier.uploadCoverPhoto].
///
/// ### Unsaved changes guard
/// When back navigation is triggered and [_hasChanges] is `true`, an
/// [UnsavedChangesDialog] is shown. Uses [PopScope] to intercept the
/// system back gesture/button.
///
/// ### Save feedback
/// A [SnackBar] is shown after a successful save. [ProfileNotifier.isSaving]
/// drives the button spinner.
class EditProfilePage extends ConsumerStatefulWidget {
  const EditProfilePage({super.key});

  @override
  ConsumerState<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends ConsumerState<EditProfilePage> {
  final _displayNameController = TextEditingController();
  final _usernameController = TextEditingController();
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _cityController = TextEditingController();
  final _bioController = TextEditingController();
  final _instagramController = TextEditingController();
  final _facebookController = TextEditingController();
  final _githubController = TextEditingController();

  /// The ISO alpha-2 country code sent to the API (e.g. `'EG'`).
  String _selectedCountry = '';

  /// The full country name shown in the UI (e.g. `'Egypt'`).
  String _selectedCountryDisplay = '';

  /// Whether the user has made any changes since the page was opened.
  ///
  /// Used by [PopScope] to decide whether to show [UnsavedChangesDialog].
  bool _hasChanges = false;

  /// Map of display name → ISO alpha-2 code for the country picker.
  ///
  /// Covers the most common countries for Rythmify's target market.
  /// The picker stores [_selectedCountry] as ISO code and
  /// [_selectedCountryDisplay] as the full name.
  final Map<String, String> _countries = {
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
  void initState() {
    super.initState();
    _loadCurrentValues();
    _displayNameController.addListener(_onChanged);
    _usernameController.addListener(_onChanged);
    _firstNameController.addListener(_onChanged);
    _lastNameController.addListener(_onChanged);
    _cityController.addListener(_onChanged);
    _bioController.addListener(_onChanged);
    _instagramController.addListener(_onChanged);
    _facebookController.addListener(_onChanged);
    _githubController.addListener(_onChanged);
  }

  /// Populates text controllers and country fields from the current [ProfileLoaded] state.
  ///
  /// Reads from [ownProfileProvider] which is specific to the authenticated user.
  /// Performs a reverse lookup on [_countries] to translate the stored
  /// ISO code back to the full country display name.
  void _loadCurrentValues() {
    final state = ref.read(ownProfileProvider);
    if (state is ProfileLoaded) {
      _displayNameController.text = state.profile.displayName;
      _usernameController.text = state.profile.username ?? '';
      _firstNameController.text = state.profile.firstName ?? '';
      _lastNameController.text = state.profile.lastName ?? '';
      _cityController.text = state.profile.city ?? '';
      _bioController.text = state.profile.bio ?? '';
      _instagramController.text = state.profile.instagramUrl ?? '';
      _facebookController.text = state.profile.facebookUrl ?? '';
      _githubController.text = state.profile.githubUrl ?? '';

      final countryCode = state.profile.country ?? '';
      _selectedCountry = countryCode;
      _selectedCountryDisplay = _countries.entries
          .firstWhere(
            (e) => e.value == countryCode,
            orElse: () => MapEntry(countryCode, countryCode),
          )
          .key;
    }
  }

  /// Marks [_hasChanges] as `true` when any text field changes.
  ///
  /// Wrapped in an `if (!_hasChanges)` guard to call [setState] only once.
  void _onChanged() {
    if (!_hasChanges) setState(() => _hasChanges = true);
  }

  @override
  void dispose() {
    _displayNameController.dispose();
    _usernameController.dispose();
    _firstNameController.dispose();
    _lastNameController.dispose();
    _cityController.dispose();
    _bioController.dispose();
    _instagramController.dispose();
    _facebookController.dispose();
    _githubController.dispose();
    super.dispose();
  }

  /// Shows [UnsavedChangesDialog] and returns the user's decision.
  ///
  /// Returns `true` if the user chose to discard changes (safe to navigate
  /// away). Returns `false` if they chose to continue editing.
  Future<bool> _onWillPop() async {
    if (!_hasChanges) return true;
    final result = await showDialog<bool>(
      context: context,
      builder: (_) => const UnsavedChangesDialog(),
    );
    return result ?? false;
  }

  /// Opens the image gallery and uploads the selected image as the avatar.
  ///
  /// Uses [ImagePicker] with a 512×512 max size and 85% quality.
  /// Calls [ProfileNotifier.uploadAvatar] via [ownProfileProvider.notifier].
  Future<void> _pickAvatar() async {
    final picker = ImagePicker();
    final image = await picker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 512,
      maxHeight: 512,
      imageQuality: 85,
    );
    if (image != null) {
      await ref
          .read(ownProfileProvider.notifier)
          .uploadAvatar(filePath: image.path);
      if (!mounted) return;
      await _reloadOwnProfile();
    }
  }

  /// Opens the image gallery and uploads the selected image as the cover photo.
  ///
  /// Uses [ImagePicker] with max width 1200px and 85% quality.
  /// Calls [ProfileNotifier.uploadCoverPhoto] via [ownProfileProvider.notifier].
  Future<void> _pickCoverPhoto() async {
    final picker = ImagePicker();
    final image = await picker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 1200,
      imageQuality: 85,
    );
    if (image != null) {
      await ref
          .read(ownProfileProvider.notifier)
          .uploadCoverPhoto(filePath: image.path);
      if (!mounted) return;
      await _reloadOwnProfile();
    }
  }

  /// Dispatches the save operation with current field values via [ownProfileProvider.notifier].
  ///
  /// Sends [_selectedCountry] (ISO code) as the country, not the
  /// display name. Called by the Save button in the AppBar.
  /// After saving successfully, navigates back to profile page.
  Future<void> _onSave() async {
    if (!_validateSocialLinks()) return;

    await ref
        .read(ownProfileProvider.notifier)
        .updateProfile(
          displayName: _displayNameController.text.trim(),
          username: _usernameController.text.trim().toLowerCase(),
          firstName: _firstNameController.text.trim(),
          lastName: _lastNameController.text.trim(),
          city: _cityController.text.trim(),
          country: _selectedCountry,
          bio: _bioController.text.trim(),
          instagramUrl: _normalizeOptionalUrl(_instagramController.text),
          facebookUrl: _normalizeOptionalUrl(_facebookController.text),
          githubUrl: _normalizeOptionalUrl(_githubController.text),
        );

    await _reloadOwnProfile();

    // Navigate back after successful save.
    if (mounted) {
      context.pop();
    }
  }

  Future<void> _reloadOwnProfile() async {
    await ref.read(ownProfileProvider.notifier).loadProfile(userId: 'me');
  }

  bool _validateSocialLinks() {
    final links = <String, String>{
      'Instagram': _instagramController.text.trim(),
      'Facebook': _facebookController.text.trim(),
      'GitHub': _githubController.text.trim(),
    };
    for (final entry in links.entries) {
      final value = entry.value;
      if (value.isEmpty) continue;
      final normalized = _normalizeOptionalUrl(value);
      final uri = Uri.tryParse(normalized);
      final isValid =
          uri != null &&
          (uri.scheme == 'http' || uri.scheme == 'https') &&
          uri.host.isNotEmpty;
      if (!isValid) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Please enter a valid ${entry.key} URL.')),
        );
        return false;
      }
    }
    return true;
  }

  String _normalizeOptionalUrl(String value) {
    final trimmed = value.trim();
    if (trimmed.isEmpty) return '';
    final hasScheme =
        trimmed.startsWith('http://') || trimmed.startsWith('https://');
    return hasScheme ? trimmed : 'https://$trimmed';
  }

  /// Shows a bottom sheet with a scrollable country list.
  ///
  /// On selection, updates [_selectedCountry] (ISO code) and
  /// [_selectedCountryDisplay] (full name), and sets [_hasChanges] to `true`.
  void _showCountryPicker() {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppTheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (_) => ListView(
        children: _countries.entries
            .map(
              (entry) => ListTile(
                key: Key('item_${entry.value}'),
                title: Text(entry.key, style: AppTheme.bodyLarge),
                onTap: () {
                  setState(() {
                    _selectedCountry = entry.value;
                    _selectedCountryDisplay = entry.key;
                    _hasChanges = true;
                  });
                  Navigator.pop(context);
                },
              ),
            )
            .toList(),
      ),
    );
  }

  /// Shows a bottom sheet with a multi-line [TextField] for editing the bio.
  ///
  /// The sheet adjusts for the keyboard using [MediaQuery.viewInsets].
  /// Changes to the bio controller are reflected via the existing
  /// [_onChanged] listener.
  void _showBioEditor() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppTheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (_) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
          left: 16,
          right: 16,
          top: 16,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Bio', style: AppTheme.titleMedium),
            const SizedBox(height: 12),
            TextField(
              key: const Key('edit_profile_bio_textfield'),
              controller: _bioController,
              maxLines: 5,
              maxLength: 500,
              style: AppTheme.bodyLarge,
              autofocus: true,
              decoration: InputDecoration(
                hintText: 'Tell the world about yourself',
                hintStyle: AppTheme.bodyMedium,
                border: InputBorder.none,
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                key: const Key('edit_profile_bio_done_button'),
                onPressed: () {
                  setState(() => _hasChanges = true);
                  Navigator.pop(context);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primaryBrand,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: Text('Done', style: AppTheme.labelLarge),
              ),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    /// Watch [ownProfileProvider] for this authenticated user's profile data.
    /// This prevents flicker from public profile data.
    final profileState = ref.watch(ownProfileProvider);
    final isSaving = profileState is ProfileLoaded && profileState.isSaving;

    // Listen for successful save and reset unsaved changes flag
    ref.listen(ownProfileProvider, (previous, next) {
      if (previous is ProfileLoaded &&
          previous.isSaving &&
          next is ProfileLoaded &&
          !next.isSaving) {
        setState(() => _hasChanges = false);
        // Don't show snackbar here since we're navigating away
      }
    });

    return PopScope(
      canPop: !_hasChanges,
      onPopInvokedWithResult: (didPop, result) async {
        if (didPop) return;
        if (_hasChanges) {
          final shouldPop = await showDialog<bool>(
            context: context,
            builder: (_) => const UnsavedChangesDialog(),
          );
          if ((shouldPop ?? false) && context.mounted) context.pop();
        }
      },
      child: Scaffold(
        backgroundColor: AppTheme.background,
        appBar: AppBar(
          title: const Text('Edit profile'),
          leading: IconButton(
            key: const Key('edit_profile_back_button'),
            icon: const Icon(Icons.arrow_back),
            onPressed: () async {
              final canLeave = await _onWillPop();
              if (canLeave && context.mounted) context.pop();
            },
          ),
          actions: [
            Padding(
              padding: const EdgeInsets.only(right: 12),
              child: ElevatedButton(
                key: const Key('edit_profile_save_button'),
                onPressed: isSaving ? null : _onSave,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: Colors.black,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 8,
                  ),
                  elevation: 0,
                ),
                child: isSaving
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.black,
                        ),
                      )
                    : const Text('Save'),
              ),
            ),
          ],
        ),
        body: SafeArea(
          child: profileState is! ProfileLoaded
              ? const Center(
                  child: CircularProgressIndicator(
                    color: AppTheme.primaryBrand,
                  ),
                )
              : SingleChildScrollView(
                  padding: const EdgeInsets.only(bottom: 174),
                  child: Column(
                    children: [
                      // Cover photo + avatar overlap stack
                      Stack(
                        children: [
                          Container(
                            width: double.infinity,
                            height: 120,
                            color: AppTheme.surface,
                            child: profileState.profile.coverUrl != null
                                ? Image.network(
                                    profileState.profile.coverUrl!,
                                    fit: BoxFit.cover,
                                    errorBuilder: (a, b, c) => const SizedBox(),
                                  )
                                : null,
                          ),
                          Positioned(
                            right: 12,
                            bottom: 12,
                            child: GestureDetector(
                              key: const Key('edit_profile_pick_cover_gesture'),
                              onTap: _pickCoverPhoto,
                              child: Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: AppTheme.background.withValues(
                                    alpha: 0.7,
                                  ),
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(
                                  Icons.camera_alt,
                                  color: AppTheme.textPrimary,
                                  size: 20,
                                ),
                              ),
                            ),
                          ),
                          Positioned(
                            left: 16,
                            bottom: -40,
                            child: ProfileAvatar(
                              avatarUrl: profileState.profile.avatarUrl,
                              radius: 44,
                              showCameraIcon: true,
                              onTap: _pickAvatar,
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 56),

                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildField(
                              key: const Key('edit_profile_name_textfield'),
                              label: 'Display Name',
                              controller: _displayNameController,
                              maxLength: 50,
                            ),
                            const Divider(color: AppTheme.surface, height: 1),
                            _buildField(
                              key: const Key('edit_profile_username_textfield'),
                              label: 'Username',
                              controller: _usernameController,
                              maxLength: 30,
                              hintText: 'soundwave_cairo',
                              pattern: r'^[a-z0-9_-]+$',
                            ),
                            const Divider(color: AppTheme.surface, height: 1),
                            _buildField(
                              key: const Key('edit_profile_city_textfield'),
                              label: 'City',
                              controller: _cityController,
                              maxLength: 35,
                            ),
                            const Divider(color: AppTheme.surface, height: 1),
                            _buildField(
                              key: const Key(
                                'edit_profile_first_name_textfield',
                              ),
                              label: 'First Name',
                              controller: _firstNameController,
                              maxLength: 50,
                            ),
                            const Divider(color: AppTheme.surface, height: 1),
                            _buildField(
                              key: const Key(
                                'edit_profile_last_name_textfield',
                              ),
                              label: 'Last Name',
                              controller: _lastNameController,
                              maxLength: 50,
                            ),
                            const Divider(color: AppTheme.surface, height: 1),
                            _buildChevronField(
                              key: const Key('edit_profile_country_gesture'),
                              label: 'Country',
                              value: _selectedCountryDisplay.isEmpty
                                  ? 'Select country'
                                  : _selectedCountryDisplay,
                              onTap: _showCountryPicker,
                            ),
                            const Divider(color: AppTheme.surface, height: 1),
                            _buildChevronField(
                              key: const Key('edit_profile_bio_gesture'),
                              label: 'Bio',
                              value: _bioController.text.isEmpty
                                  ? 'Bio'
                                  : _bioController.text,
                              onTap: _showBioEditor,
                            ),
                            const Divider(color: AppTheme.surface, height: 1),
                            _buildField(
                              key: const Key(
                                'edit_profile_instagram_textfield',
                              ),
                              label: 'Instagram',
                              controller: _instagramController,
                              maxLength: 200,
                              hintText: 'https://instagram.com/username',
                            ),
                            const Divider(color: AppTheme.surface, height: 1),
                            _buildField(
                              key: const Key('edit_profile_facebook_textfield'),
                              label: 'Facebook',
                              controller: _facebookController,
                              maxLength: 200,
                              hintText: 'https://facebook.com/username',
                            ),
                            const Divider(color: AppTheme.surface, height: 1),
                            _buildField(
                              key: const Key('edit_profile_github_textfield'),
                              label: 'GitHub',
                              controller: _githubController,
                              maxLength: 200,
                              hintText: 'https://github.com/username',
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
        ),
      ),
    );
  }

  /// Builds an inline [TextField] row with a character counter.
  ///
  /// [label] — the field label shown above the text field.
  /// [controller] — the [TextEditingController] for this field.
  /// [maxLength] — character limit shown in the counter.
  /// [hintText] — optional placeholder text for the field.
  /// [pattern] — optional regex for validation (currently used for visual feedback).
  Widget _buildField({
    Key? key,
    required String label,
    required TextEditingController controller,
    required int maxLength,
    String? hintText,
    String? pattern,
  }) {
    return StatefulBuilder(
      builder: (context, setState) {
        controller.addListener(() {
          setState(() {}); // Triggers rebuild to update character count
        });

        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: AppTheme.bodyMedium),
              const SizedBox(height: 4),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      key: key,
                      controller: controller,
                      maxLength: maxLength,
                      style: AppTheme.bodyLarge,
                      decoration: InputDecoration(
                        border: InputBorder.none,
                        counterText: '',
                        hintText: hintText ?? label,
                        hintStyle: AppTheme.bodyMedium,
                        isDense: true,
                        contentPadding: EdgeInsets.zero,
                      ),
                    ),
                  ),
                  Text(
                    '${controller.text.length}/$maxLength',
                    style: AppTheme.labelSmall,
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  /// Builds a tappable row that opens a bottom-sheet editor or picker.
  ///
  /// Used for Country and Bio fields that require a custom input UI.
  ///
  /// [label] — the field label shown above the value.
  /// [value] — the current value or placeholder text.
  /// [onTap] — the callback that opens the picker/editor.
  Widget _buildChevronField({
    Key? key,
    required String label,
    required String value,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      key: key,
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 16),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(label, style: AppTheme.bodyMedium),
                  const SizedBox(height: 4),
                  Text(value, style: AppTheme.bodyLarge),
                ],
              ),
            ),
            const Icon(Icons.chevron_right, color: AppTheme.textSecondary),
          ],
        ),
      ),
    );
  }
}
