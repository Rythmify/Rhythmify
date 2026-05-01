import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:rythmify/features/settings/domain/entities/notification_preferences_entity.dart';
import 'package:rythmify/features/settings/domain/repositories/settings_repo_interface.dart';
import 'package:rythmify/features/settings/presentation/providers/notification_prefs_notifier.dart';
import 'package:rythmify/features/settings/presentation/providers/settings_providers.dart';

/// Mock [SettingsRepoInterface] for stubbing notification-preference reads and writes.
class MockSettingsRepoInterface extends Mock implements SettingsRepoInterface {}

/// Fixture with every field enabled and [MessagesFrom.everyone], used as the
/// pre-save state in all [NotificationPrefsNotifier.save] tests.
const tNotifEntity = NotificationPreferencesEntity(
  newFollowerPush: true,
  newFollowerEmail: true,
  repostOfYourPostPush: true,
  repostOfYourPostEmail: true,
  newPostByFollowedPush: true,
  newPostByFollowedEmail: true,
  likesAndPlaysPush: true,
  likesAndPlaysEmail: true,
  commentOnPostPush: true,
  commentOnPostEmail: true,
  recommendedContentPush: true,
  recommendedContentEmail: true,
  newMessagePush: true,
  newMessageEmail: true,
  messagesFrom: MessagesFrom.everyone,
  featureUpdatesPush: true,
  featureUpdatesEmail: true,
  surveysAndFeedbackPush: true,
  surveysAndFeedbackEmail: true,
  promotionalContentPush: true,
  promotionalContentEmail: true,
  newsletterEmail: true,
);

/// Tests for [NotificationPrefsNotifier] via [notificationPrefsProvider].
///
/// Verifies that [build] fetches from the repository once and exposes the entity,
/// that [save] optimistically applies the updated entity and then commits the
/// server response (or emits [AsyncError] and reverts on failure), and that the
/// correct entity is forwarded to [SettingsRepoInterface.updateNotificationPreferences].
void main() {
  late MockSettingsRepoInterface mockRepo;
  late ProviderContainer container;

  setUp(() {
    mockRepo = MockSettingsRepoInterface();
    registerFallbackValue(tNotifEntity);
    container = ProviderContainer(
      overrides: [settingsRepositoryProvider.overrideWithValue(mockRepo)],
    );
  });

  tearDown(() => container.dispose());

  group('NotificationPrefsNotifier', () {
    group('build', () {
      test('loads preferences from repository on first read', () async {
        when(
          () => mockRepo.getNotificationPreferences(),
        ).thenAnswer((_) async => tNotifEntity);

        final result = await container.read(notificationPrefsProvider.future);

        expect(result, tNotifEntity);
        verify(() => mockRepo.getNotificationPreferences()).called(1);
      });

      test('calls getNotificationPreferences exactly once on build', () async {
        when(
          () => mockRepo.getNotificationPreferences(),
        ).thenAnswer((_) async => tNotifEntity);

        await container.read(notificationPrefsProvider.future);

        verify(() => mockRepo.getNotificationPreferences()).called(1);
      });
    });

    group('save', () {
      test(
        'optimistically applies updated entity then commits server response',
        () async {
          when(
            () => mockRepo.getNotificationPreferences(),
          ).thenAnswer((_) async => tNotifEntity);

          final updated = tNotifEntity.copyWith(newFollowerPush: false);
          final serverResponse = tNotifEntity.copyWith(
            newFollowerPush: false,
            newsletterEmail: false,
          );

          when(
            () => mockRepo.updateNotificationPreferences(any()),
          ).thenAnswer((_) async => serverResponse);

          await container.read(notificationPrefsProvider.future);

          await container
              .read(notificationPrefsProvider.notifier)
              .save(updated);

          final state = container.read(notificationPrefsProvider);
          expect(state.value, serverResponse);
          verify(() => mockRepo.updateNotificationPreferences(any())).called(1);
        },
      );

      test(
        'reverts to previous state and emits AsyncError when update fails',
        () async {
          when(
            () => mockRepo.getNotificationPreferences(),
          ).thenAnswer((_) async => tNotifEntity);

          when(
            () => mockRepo.updateNotificationPreferences(any()),
          ).thenThrow(Exception('Update failed'));

          await container.read(notificationPrefsProvider.future);

          final updated = tNotifEntity.copyWith(newFollowerPush: false);
          await container
              .read(notificationPrefsProvider.notifier)
              .save(updated);

          final state = container.read(notificationPrefsProvider);
          expect(state, isA<AsyncError>());
        },
      );

      test('passes the updated entity to the repository', () async {
        when(
          () => mockRepo.getNotificationPreferences(),
        ).thenAnswer((_) async => tNotifEntity);

        final updated = tNotifEntity.copyWith(
          messagesFrom: MessagesFrom.nobody,
          newFollowerPush: false,
        );

        when(
          () => mockRepo.updateNotificationPreferences(any()),
        ).thenAnswer((_) async => updated);

        await container.read(notificationPrefsProvider.future);
        await container.read(notificationPrefsProvider.notifier).save(updated);

        final captured =
            verify(
                  () => mockRepo.updateNotificationPreferences(captureAny()),
                ).captured.single
                as NotificationPreferencesEntity;
        expect(captured.messagesFrom, MessagesFrom.nobody);
        expect(captured.newFollowerPush, false);
      });
    });
  });
}
