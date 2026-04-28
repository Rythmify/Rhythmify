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
      final saved = await ref
          .read(settingsRepositoryProvider)
          .updatePrivacySettings(updated);
      state = AsyncData(saved);
    } catch (e, st) {
      state = previous;
      state = AsyncError(e, st);
    }
  }
}
