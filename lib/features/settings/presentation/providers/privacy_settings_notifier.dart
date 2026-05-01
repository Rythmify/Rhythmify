import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rythmify/features/settings/domain/entities/privacy_settings_entity.dart';
import 'package:rythmify/features/settings/presentation/providers/settings_providers.dart';

final privacySettingsProvider =
    AsyncNotifierProvider<PrivacySettingsNotifier, PrivacySettingsEntity>(
      PrivacySettingsNotifier.new,
    );

class PrivacySettingsNotifier extends AsyncNotifier<PrivacySettingsEntity> {
  @override
  Future<PrivacySettingsEntity> build() {
    return ref.watch(settingsRepositoryProvider).getPrivacySettings();
  }

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
