import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:rythmify/features/settings/domain/entities/privacy_settings_entity.dart';
import 'package:rythmify/features/settings/domain/repositories/settings_repo_interface.dart';
import 'package:rythmify/features/settings/presentation/providers/privacy_settings_notifier.dart';
import 'package:rythmify/features/settings/presentation/providers/settings_providers.dart';

class MockSettingsRepoInterface extends Mock implements SettingsRepoInterface {}

const tPrivacyEntity = PrivacySettingsEntity(
  isPrivate: false,
  receiveMessageFromAnyone: true,
  showActivitiesInDiscovery: true,
  showAsTopFan: true,
  showTopFansOnTracks: true,
);

void main() {
  late MockSettingsRepoInterface mockRepo;
  late ProviderContainer container;

  setUp(() {
    mockRepo = MockSettingsRepoInterface();
    registerFallbackValue(tPrivacyEntity);
    container = ProviderContainer(
      overrides: [
        settingsRepositoryProvider.overrideWithValue(mockRepo),
      ],
    );
  });

  tearDown(() => container.dispose());

  group('PrivacySettingsNotifier', () {
    group('build', () {
      test('loads privacy settings from repository on first read', () async {
        when(() => mockRepo.getPrivacySettings())
            .thenAnswer((_) async => tPrivacyEntity);

        final result = await container.read(privacySettingsProvider.future);

        expect(result, tPrivacyEntity);
        verify(() => mockRepo.getPrivacySettings()).called(1);
      });

      test('calls getPrivacySettings exactly once on build', () async {
        when(() => mockRepo.getPrivacySettings())
            .thenAnswer((_) async => tPrivacyEntity);

        await container.read(privacySettingsProvider.future);

        verify(() => mockRepo.getPrivacySettings()).called(1);
      });
    });

    group('save', () {
      test('optimistically applies updated entity and keeps it after confirmed patch', () async {
        when(() => mockRepo.getPrivacySettings())
            .thenAnswer((_) async => tPrivacyEntity);

        final updated = tPrivacyEntity.copyWith(receiveMessageFromAnyone: false);
        const serverResponse = PrivacySettingsEntity(
          isPrivate: false,
          receiveMessageFromAnyone: false,
          showActivitiesInDiscovery: true,
          showAsTopFan: true,
          showTopFansOnTracks: true,
        );

        when(() => mockRepo.updatePrivacySettings(any(), any()))
            .thenAnswer((_) async => serverResponse);

        await container.read(privacySettingsProvider.future);
        await container.read(privacySettingsProvider.notifier).save(updated);

        // Optimistic state is kept — server response is NOT used to overwrite state.
        // This prevents fields absent from the PATCH response (defaulted by fromJson)
        // from reverting toggles the user just set.
        final state = container.read(privacySettingsProvider);
        expect(state.value, updated);
        verify(() => mockRepo.updatePrivacySettings(any(), any())).called(1);
      });

      test('keeps optimistic state when update throws (silent catch)', () async {
        when(() => mockRepo.getPrivacySettings())
            .thenAnswer((_) async => tPrivacyEntity);

        when(() => mockRepo.updatePrivacySettings(any(), any()))
            .thenThrow(Exception('Update failed'));

        await container.read(privacySettingsProvider.future);

        final updated = tPrivacyEntity.copyWith(receiveMessageFromAnyone: false);
        await container.read(privacySettingsProvider.notifier).save(updated);

        // Error is swallowed — state stays as the optimistic update.
        final state = container.read(privacySettingsProvider);
        expect(state, isA<AsyncData<PrivacySettingsEntity>>());
        expect(state.value, updated);
      });

      test('passes previous state as "old" and updated entity to repository', () async {
        when(() => mockRepo.getPrivacySettings())
            .thenAnswer((_) async => tPrivacyEntity);

        final updated = tPrivacyEntity.copyWith(showAsTopFan: false);

        when(() => mockRepo.updatePrivacySettings(tPrivacyEntity, updated))
            .thenAnswer((_) async => updated);

        await container.read(privacySettingsProvider.future);
        await container.read(privacySettingsProvider.notifier).save(updated);

        verify(
          () => mockRepo.updatePrivacySettings(tPrivacyEntity, updated),
        ).called(1);
      });

      test('uses updated entity as "old" when state has no data before save', () async {
        // build returns normally so we get data first, then simulate a save
        // while the state is already updated (second save scenario).
        when(() => mockRepo.getPrivacySettings())
            .thenAnswer((_) async => tPrivacyEntity);

        final firstUpdate = tPrivacyEntity.copyWith(showAsTopFan: false);
        final secondUpdate = firstUpdate.copyWith(showActivitiesInDiscovery: false);

        when(() => mockRepo.updatePrivacySettings(any(), any()))
            .thenAnswer((_) async => firstUpdate);

        await container.read(privacySettingsProvider.future);

        // First save — state becomes firstUpdate after commit.
        await container.read(privacySettingsProvider.notifier).save(firstUpdate);

        when(() => mockRepo.updatePrivacySettings(any(), any()))
            .thenAnswer((_) async => secondUpdate);

        // Second save — previous is firstUpdate.
        await container.read(privacySettingsProvider.notifier).save(secondUpdate);

        final state = container.read(privacySettingsProvider);
        expect(state.value, secondUpdate);
      });
    });
  });
}
