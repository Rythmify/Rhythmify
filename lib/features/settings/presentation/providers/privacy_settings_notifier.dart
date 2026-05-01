import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rythmify/features/settings/domain/entities/privacy_settings_entity.dart';
import 'package:rythmify/features/settings/presentation/providers/settings_providers.dart';

/// Provides and manages the current user's privacy settings.
///
/// Loads settings on first access. Consumers read this provider and call
/// [PrivacySettingsNotifier.save] to apply user changes.
final privacySettingsProvider =
    AsyncNotifierProvider<PrivacySettingsNotifier, PrivacySettingsEntity>(
      PrivacySettingsNotifier.new,
    );

/// Notifier for privacy settings with optimistic UI updates.
///
/// [save] immediately applies the toggle in local state, then fires the PATCH.
/// The server response is intentionally NOT used to overwrite the local state —
/// the PATCH response may default absent fields to `true`, silently reverting
/// toggles the user just set. Errors are swallowed when the backend row does
/// not yet exist for the account.
class PrivacySettingsNotifier extends AsyncNotifier<PrivacySettingsEntity> {
  @override
  /// Fetches privacy settings from the repository on initial load.
  Future<PrivacySettingsEntity> build() {
    return ref.watch(settingsRepositoryProvider).getPrivacySettings();
  }

  /// Applies [updated] optimistically and persists only the changed fields.
  Future<void> save(PrivacySettingsEntity updated) async {
    final previous = state;
    state = AsyncData(updated);
    try {
      final old = previous.asData?.value ?? updated;
      await ref
          .read(settingsRepositoryProvider)
          .updatePrivacySettings(old, updated);
      // Keep optimistic state — server confirmed the patch.
      // Do NOT overwrite with the server response: fields absent from the
      // PATCH response are defaulted by fromJson and would silently revert
      // toggles the user just set (e.g. show_as_top_fan flipping back to true).
    } catch (_) {
      // Keep optimistic state — backend row may not exist yet for this account.
    }
  }
}
