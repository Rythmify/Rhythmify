import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import '../../../../../core/theme/app_theme.dart';
import '../providers/profile_provider.dart';
import '../providers/profile_state.dart';
import '../widgets/profile_avatar.dart';
import '../widgets/unsaved_changes_dialog.dart';

class EditProfilePage extends ConsumerStatefulWidget {
  const EditProfilePage({super.key});

  @override
  ConsumerState<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends ConsumerState<EditProfilePage> {
  final _displayNameController = TextEditingController();
  final _cityController = TextEditingController();
  final _bioController = TextEditingController();
  String _selectedCountry = '';
  bool _hasChanges = false;

  @override
  void initState() {
    super.initState();
    _loadCurrentValues();

    // Track changes
    _displayNameController.addListener(_onChanged);
    _cityController.addListener(_onChanged);
    _bioController.addListener(_onChanged);
  }

  void _loadCurrentValues() {
    final state = ref.read(profileProvider);
    if (state is ProfileLoaded) {
      _displayNameController.text = state.profile.displayName;
      _cityController.text = state.profile.city ?? '';
      _bioController.text = state.profile.bio ?? '';
      _selectedCountry = state.profile.country ?? '';
    }
  }

  void _onChanged() {
    if (!_hasChanges) {
      setState(() => _hasChanges = true);
    }
  }

  @override
  void dispose() {
    _displayNameController.dispose();
    _cityController.dispose();
    _bioController.dispose();
    super.dispose();
  }

  Future<bool> _onWillPop() async {
    if (!_hasChanges) return true;
    final result = await showDialog<bool>(
      context: context,
      builder: (_) => const UnsavedChangesDialog(),
    );
    return result ?? false;
  }

  Future<void> _pickAvatar() async {
    final picker = ImagePicker();
    final image = await picker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 512,
      maxHeight: 512,
      imageQuality: 85,
    );
    if (image != null) {
      ref.read(profileProvider.notifier).uploadAvatar(filePath: image.path);
    }
  }

  Future<void> _pickCoverPhoto() async {
    final picker = ImagePicker();
    final image = await picker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 1200,
      imageQuality: 85,
    );
    if (image != null) {
      ref
          .read(profileProvider.notifier)
          .uploadCoverPhoto(filePath: image.path);
    }
  }

  void _onSave() {
    ref.read(profileProvider.notifier).updateProfile(
          displayName: _displayNameController.text.trim(),
          city: _cityController.text.trim(),
          country: _selectedCountry,
          bio: _bioController.text.trim(),
        );
  }

  @override
  Widget build(BuildContext context) {
    final profileState = ref.watch(profileProvider);
    final isSaving =
        profileState is ProfileLoaded && profileState.isSaving;

    ref.listen(profileProvider, (previous, next) {
      if (previous is ProfileLoaded &&
          previous.isSaving &&
          next is ProfileLoaded &&
          !next.isSaving) {
        setState(() => _hasChanges = false);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Profile saved successfully')),
        );
      }
    });

    return PopScope(
      canPop: !_hasChanges,
      onPopInvoked: (didPop) async {
        if (!didPop && _hasChanges) {
          final result = await showDialog<bool>(
            context: context,
            builder: (_) => const UnsavedChangesDialog(),
          );
          if (result == true && context.mounted) {
            context.pop();
          }
        }
      },
      child: Scaffold(
        backgroundColor: AppTheme.background,
        appBar: AppBar(
          title: const Text('Edit profile'),
          leading: IconButton(
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
        body: profileState is! ProfileLoaded
            ? const Center(
                child: CircularProgressIndicator(
                  color: AppTheme.primaryBrand,
                ),
              )
            : SingleChildScrollView(
                child: Column(
                  children: [
                    // ── Cover photo ──────────────────────────────────
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
                                )
                              : null,
                        ),
                        // Cover camera icon
                        Positioned(
                          right: 12,
                          bottom: 12,
                          child: GestureDetector(
                            onTap: _pickCoverPhoto,
                            child: Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: AppTheme.background.withOpacity(0.7),
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
                        // Avatar on cover
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

                    // ── Fields ────────────────────────────────────────
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Display name
                          _buildField(
                            label: 'Display Name',
                            controller: _displayNameController,
                            maxLength: 50,
                          ),

                          const Divider(color: AppTheme.surface, height: 1),

                          // City
                          _buildField(
                            label: 'City',
                            controller: _cityController,
                            maxLength: 35,
                          ),

                          const Divider(color: AppTheme.surface, height: 1),

                          // Country
                          _buildChevronField(
                            label: 'Country',
                            value: _selectedCountry.isEmpty
                                ? 'Select country'
                                : _selectedCountry,
                            onTap: _showCountryPicker,
                          ),

                          const Divider(color: AppTheme.surface, height: 1),

                          // Bio
                          _buildChevronField(
                            label: 'Bio',
                            value: _bioController.text.isEmpty
                                ? 'Bio'
                                : _bioController.text,
                            onTap: _showBioEditor,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
      ),
    );
  }

  Widget _buildField({
    required String label,
    required TextEditingController controller,
    required int maxLength,
  }) {
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
                  controller: controller,
                  maxLength: maxLength,
                  style: AppTheme.bodyLarge,
                  decoration: InputDecoration(
                    border: InputBorder.none,
                    counterText: '',
                    hintText: label,
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
  }

  Widget _buildChevronField({
    required String label,
    required String value,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
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
            const Icon(
              Icons.chevron_right,
              color: AppTheme.textSecondary,
            ),
          ],
        ),
      ),
    );
  }

  void _showCountryPicker() {
    final countries = [
      'Egypt', 'Palestine', 'Saudi Arabia', 'United Arab Emirates',
      'Jordan', 'Lebanon', 'Syria', 'Iraq', 'Kuwait', 'Qatar',
      'Bahrain', 'Oman', 'Yemen', 'Libya', 'Tunisia', 'Algeria',
      'Morocco', 'Sudan', 'United States', 'United Kingdom',
      'Germany', 'France', 'Japan', 'Brazil', 'Canada', 'Australia',
    ];

    showModalBottomSheet(
      context: context,
      backgroundColor: AppTheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (_) => ListView.builder(
        itemCount: countries.length,
        itemBuilder: (context, index) => ListTile(
          title: Text(countries[index], style: AppTheme.bodyLarge),
          onTap: () {
            setState(() {
              _selectedCountry = countries[index];
              _hasChanges = true;
            });
            Navigator.pop(context);
          },
        ),
      ),
    );
  }

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
}